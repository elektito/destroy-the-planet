extends Node2D

const TRILLION := 1000000000000
const MAX_RESOURCES := 10000 * TRILLION
const MAX_POLLUTION := 10000 * TRILLION

const MAX_ROTATION_SPEED := 4.0
const ROTATION_DAMP := 0.95
const ROTATION_ACCEL_INC := 1.2

var pollution := 0
var resources := MAX_RESOURCES
var money := 100
var population := 0

var click_money := 10

var placing := -1
var inside_placing_area := false
var selected_building = null
var snap_angles = []
var used_angles = []
var placed_buildings = []
var game_over := false
var prev_angle = null
var rotation_accel = 0.0
var rotation_speed = 0.0

onready var building_info = {
	Global.BuildingType.FACTORY: {
		'button': $hud/hbox/toolbox/vbox/factory_btn,
		'preview_icon': preload("res://assets/gfx/sprites/factory.png"),
		'scene': preload("res://Factory.tscn"),
	},
	Global.BuildingType.MINE: {
		'button': $hud/hbox/toolbox/vbox/mine_btn,
		'preview_icon': preload("res://assets/gfx/sprites/mine.png"),
		'scene': preload("res://Mine.tscn"),
	},
	Global.BuildingType.POWERPLANT: {
		'button': $hud/hbox/toolbox/vbox/powerplant_btn,
		'preview_icon': preload("res://assets/gfx/sprites/powerplant.png"),
		'scene': preload("res://Powerplant.tscn"),
	},
	Global.BuildingType.APARTMENT_BUILDING: {
		'button': $hud/hbox/toolbox/vbox/apartment_btn,
		'preview_icon': preload("res://assets/gfx/sprites/apartment.png"),
		'scene': preload("res://Apartment.tscn"),
	},
	Global.BuildingType.BAR: {
		'button': $hud/hbox/toolbox/vbox/bar_btn,
		'preview_icon': preload("res://assets/gfx/sprites/bar.png"),
		'scene': preload("res://Bar.tscn"),
	},
}

onready var placing_icon = $hud/placing_icon

func _ready():
	for i in range(0, 40):
		snap_angles.append(2 * PI / 40 * i)
	
	$victory_screen.set_process(false)
	$victory_screen.set_process_input(false)
	$victory_screen.set_physics_process(false)
	
	$settings.set_process_input(false)
	
	create_plants()
	
	update_toolbox()
	update_building_panel()
	update_resource_bar()
	update_info_bar()


func create_plants():
	var textures = [
		preload("res://assets/gfx/sprites/plant1.png"),
		preload("res://assets/gfx/sprites/plant2.png"),
		preload("res://assets/gfx/sprites/plant3.png"),
		preload("res://assets/gfx/sprites/plant4.png"),
		preload("res://assets/gfx/sprites/plant5.png"),
		preload("res://assets/gfx/sprites/plant6.png"),
	]
	var nplants = 40
	for i in range(nplants):
		var angle = i * 2 * PI / nplants
		var plant = preload("res://Plant.tscn").instance()
		plant.z_index = -20
		plant.texture = textures[randi() % len(textures)]
		var v = Vector2.RIGHT.rotated(angle)
		plant.position = v.normalized() * 208
		plant.rotation = v.angle() + PI / 2
		$placing_area.add_child(plant)


func _input(event):
	if event is InputEventMouseMotion:
		if placing >= 0:
			placing_icon.position = get_local_mouse_position()
		
			var v : Vector2 = $placing_area.get_local_mouse_position() - $placing_area/planet.position
			var angle = get_snap_angle(v.angle())
			if angle != prev_angle and inside_placing_area:
				$placement_preview_sound.play()
				prev_angle = angle
			v = Vector2.RIGHT.rotated(angle)
			$placing_area/preview_icon.position = v.normalized() * 230
			$placing_area/preview_icon.rotation = v.angle() + PI / 2
	
	if Input.is_action_just_pressed("ui_cancel"):
		show_settings_screen()
	if event is InputEventMouseButton:
		if placing >= 0 and event.button_index == BUTTON_RIGHT:
			placing = -1
			placing_icon.visible = false
			$placing_area/preview_icon/shape.set_deferred('disabled', true)
			$placing_area/preview_icon.visible = false
		
		if placing >= 0 and event.button_index == BUTTON_LEFT and inside_placing_area and is_zero_approx(rotation_speed):
			if not $placing_area/preview_icon.rotation in used_angles:
				placing_icon.visible = false
				$placing_area/preview_icon.visible = false
				$placing_area/preview_icon/shape.set_deferred('disabled', true)
				var b = building_info[placing]['scene'].instance()
				b.z_index = -10
				b.position = $placing_area/preview_icon.position
				b.rotation = $placing_area/preview_icon.rotation
				$placing_area.add_child(b)
				b.connect('clicked', self, '_on_building_clicked', [b])
				b.connect('upgraded', self, '_on_building_upgraded')
				b.connect('info_updated', self, '_on_building_info_updated')
				consume_money(get_price(b.type))
				b.init(self)
				$placement_sound.play()
				placing = -1
				used_angles.append($placing_area/preview_icon.rotation)
				placed_buildings.append(b)
				update_toolbox()
				update_info_bar()
				update_building_panel()
				update_resource_bar()


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if placing < 0 and event.pressed and event.button_index == BUTTON_LEFT:
			$placement_preview_sound.play()
			click_vfx()
			produce_money(click_money)
		
		if OS.is_debug_build() and placing < 0 and event.pressed and event.button_index == BUTTON_MIDDLE:
			produce_money(100000000000000)
		
		if placing < 0 and selected_building != null and event.button_index == BUTTON_RIGHT:
			selected_building.selected = false
			selected_building = null
			update_building_panel()
		
		if Input.is_action_pressed("rotate_left"):
			rotation_accel -= ROTATION_ACCEL_INC
			$rotation_reset_timer.start()
		elif Input.is_action_pressed("rotate_right"):
			rotation_accel += ROTATION_ACCEL_INC
			$rotation_reset_timer.start()


func _physics_process(delta):
	rotation_speed += rotation_accel * delta
	if rotation_speed > MAX_ROTATION_SPEED:
		rotation_speed = MAX_ROTATION_SPEED
	elif rotation_speed < -MAX_ROTATION_SPEED:
		rotation_speed = -MAX_ROTATION_SPEED
	if rotation_speed != 0.0:
		$placing_area.rotate(rotation_speed * delta)
		rotation_speed *= ROTATION_DAMP
		if abs(rotation_speed) < 0.1:
			rotation_speed = 0.0


func click_vfx():
	var sprite = Sprite.new()
	sprite.texture = preload("res://assets/gfx/particles/blackSmoke04.png")
	sprite.position = get_local_mouse_position()
	add_child(sprite)
	$click_vfx_tween.interpolate_property(sprite, 'scale', Vector2(1, 1), Vector2(2, 2), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$click_vfx_tween.interpolate_property(sprite, 'modulate:a', 1.0, 0.0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$click_vfx_tween.start()


func _on_click_vfx_tween_tween_completed(object, _key):
	object.queue_free()


func _on_building_clicked(building):
	if placing >= 0:
		return
	if selected_building:
		selected_building.selected = false
	building.selected = true
	selected_building = building
	
	update_building_panel()


func _on_building_upgraded(_building):
	update_building_panel()
	update_info_bar()


func _on_building_info_updated(building, item, _value):
	for b in placed_buildings:
		if b != building:
			b.notify_update(item)
		if item in [Global.StatType.POPULATION_INCREASE_PER_CYCLE, Global.StatType.ENTERTAINMENT]:
			b.notify_update(Global.StatType.DEMAND)
	
	# No need to update the building panel anymore here, because building stats
	# automatically update when the info_updated signal of the building is
	# emitted, and the actions do not change when building_info is updated right
	# now. This means, stat tooltips do not disappear on each update (which can
	# happen frequently in end-game, making reading the tooltips difficult).
	# If actions could change, then this would still be necessary.
	#update_building_panel()


func update_building_panel():
	if selected_building == null:
		$hud/hbox/building_panel/MarginContainer/VBoxContainer/description.bbcode_text = ''
	else:
		$hud/hbox/building_panel/MarginContainer/VBoxContainer/description.bbcode_text = '[b]' + selected_building.building_name + '[/b]\n\n' + selected_building.description
	
	for widget in get_tree().get_nodes_in_group('building_widgets'):
		widget.visible = false
		widget.queue_free()
	
	for widget in get_tree().get_nodes_in_group('building_stats'):
		widget.visible = false
		widget.queue_free()
	
	if selected_building:
		for stat in selected_building.get_stats():
			var widget = preload("res://BuildingStat.tscn").instance()
			widget.type = stat['type']
			widget.init(selected_building)
			widget.text = Global.human_readable_money(int(stat['value']))
			$hud/hbox/building_panel/MarginContainer/VBoxContainer.add_child(widget)
		for action in selected_building.get_actions():
			var widget = preload("res://BuildingWidget.tscn").instance()
			widget.text = '[b]' + action['title'] + '[/b]\n\n' + action['description']
			widget.price = action['price']
			widget.button_disabled = (money < action['price'])
			if 'button_text' in action:
				widget.button_text = action['button_text']
			widget.set_stats(action['stats'])
			widget.connect('action_button_clicked', self, '_on_action_button_clicked', [widget, action])
			$hud/hbox/building_panel/MarginContainer/VBoxContainer.add_child(widget)


func update_resource_bar():
	var money_per_cycle = 0
	
	for b in placed_buildings:
		if b.type == Global.BuildingType.FACTORY:
			money_per_cycle += b.get_money_per_cycle()
	
	$hud/hbox/vbox/resource_bar/margin/hbox/money_value_label.text = Global.human_readable_money(money) + ' (+' + Global.human_readable_money(money_per_cycle) + ')'
	
	var tooltip = 'Money (+Money-per-Cycle): ' + str(money) + ' (+' + str(money_per_cycle) + ')'
	$hud/hbox/vbox/resource_bar/margin/hbox/money_value_label.hint_tooltip = tooltip
	$hud/hbox/vbox/resource_bar/margin/hbox/money_label.hint_tooltip = tooltip
	
	var resources_percent = int(float(resources) / MAX_RESOURCES * 100)
	$hud/hbox/vbox/resource_bar/margin/hbox/resources_value_label.text = str(resources) + ' (' + str(resources_percent) + '%)'
	
	var pollution_percent = int(float(pollution) / MAX_POLLUTION * 100)
	$hud/hbox/vbox/resource_bar/margin/hbox/pollution_value_label.text = str(pollution) + ' (' + str(pollution_percent) + '%)'


func update_toolbox():
	for building_type in Global.get_building_types():
		var btn : Button = building_info[building_type]['button']
		var building_name := Global.get_building_name(building_type)
		var building_price = get_price(building_type)
		btn.hint_tooltip = building_name + '\nCost: ' + Global.human_readable_money(building_price)
		btn.disabled = (money < building_price)


func update_info_bar():
	$hud/hbox/vbox/info_bar/margin/hbox/population_value_label.text = Global.human_readable_money(get_population()) + '/' + Global.human_readable_money(get_population_cap())
	$hud/hbox/vbox/info_bar/margin/hbox/power_value_label.text = str(get_power())
	$hud/hbox/vbox/info_bar/margin/hbox/mining_value_label.text = str(get_mining())
	$hud/hbox/vbox/info_bar/margin/hbox/entertainment_value_label.text = Global.human_readable_money(get_entertainment())
	$hud/hbox/vbox/info_bar/margin/hbox/demand_value_label.text = str(get_demand())


func update_action_widgets():
	for widget in get_tree().get_nodes_in_group('building_widgets'):
		widget.button_disabled = (money < widget.price)


func _on_action_button_clicked(_widget, action):
	consume_money(action['price'])
	selected_building.perform_action(action)
	$placement_sound.play()


func get_price(building) -> int:
	var base_price = -1
	var exponent = 0
	match building:
		Global.BuildingType.FACTORY:
			base_price = 100
			exponent = get_building_count(Global.BuildingType.FACTORY)
		Global.BuildingType.MINE:
			base_price = 200
			exponent = get_building_count(Global.BuildingType.MINE)
		Global.BuildingType.POWERPLANT:
			base_price = 200
			exponent = get_building_count(Global.BuildingType.POWERPLANT)
		Global.BuildingType.APARTMENT_BUILDING:
			base_price = 200
			exponent = get_building_count(Global.BuildingType.APARTMENT_BUILDING)
		Global.BuildingType.BAR:
			base_price = 200
			exponent = get_building_count(Global.BuildingType.BAR)
	
	var price
	if base_price == 100:
		if exponent <= 6:
			price = int(pow(base_price, exponent + 1))
		else:
			price = int(pow(base_price, 7) * pow(2, exponent - 6))
	else:
		if exponent <= 5:
			price = int(pow(base_price, exponent + 1))
		else:
			price = int(pow(base_price, 6) * pow(2, exponent - 5))
	
	return price


func get_building_count(building_type) -> int:
	var count := 0
	for b in placed_buildings:
		if b.type == building_type:
			count += 1
	return count


func get_placed_buildings(building_type):
	var buildings = []
	for b in placed_buildings:
		if b.type == building_type:
			buildings.append(b)
	return buildings


func get_snap_angle(angle):
	while angle < 0:
		angle += 2 * PI
	while angle > 2 * PI:
		angle -= 2 * PI
	for i in range(len(snap_angles) - 1):
		if angle >= snap_angles[i] and angle <= snap_angles[i+1]:
			if abs(angle - snap_angles[i]) < abs(angle - snap_angles[i+1]):
				return snap_angles[i]
			else:
				return snap_angles[i+1]
	return snap_angles[len(snap_angles) - 1]


func _on_toolbox_btn_pressed(building):
	placing_icon.texture = building_info[building]['button'].icon
	placing_icon.position = get_local_mouse_position()
	placing_icon.visible = true
	placing = building
	$placing_area/preview_icon/sprite.texture = building_info[building]['preview_icon']
	$placement_preview_sound.play()


func _on_placing_area_mouse_entered():
	inside_placing_area = true
	if placing >= 0:
		$placing_area/preview_icon.visible = true
		$placing_area/preview_icon/shape.set_deferred('disabled', false)
		
		placing_icon.visible = false


func _on_placing_area_mouse_exited():
	if $placing_area.get_local_mouse_position().length() < $placing_area.get_node("shape").shape.radius:
		return
	inside_placing_area = false
	if placing >= 0:
		$placing_area/preview_icon.visible = false
		$placing_area/preview_icon/shape.set_deferred('disabled', true)
		placing_icon.visible = true


func produce_money(amount):
	if game_over:
		return
	money += amount
	for b in placed_buildings:
		b.notify_update(Global.StatType.MONEY)
	update_resource_bar()
	update_toolbox()
	update_action_widgets()


func consume_money(amount):
	if game_over:
		return
	money -= amount
	for b in placed_buildings:
		b.notify_update(Global.StatType.MONEY)
	update_resource_bar()
	update_toolbox()
	update_action_widgets()


func produce_pollution(amount):
	if game_over:
		return
	pollution += amount
	if pollution > MAX_POLLUTION or pollution < 0: # overflow
		pollution = MAX_POLLUTION
	for b in placed_buildings:
		b.notify_update(Global.StatType.POLLUTION)
	if pollution == MAX_POLLUTION:
		win()
	update_resource_bar()
	
	$bg_layer/background.color = lerp(Color('00bbff'), Color.lightblue, float(pollution) / MAX_POLLUTION)
	$bg_layer/background.modulate = lerp(Color.white, Color('999999'), float(pollution) / MAX_POLLUTION)


func consume_resources(amount):
	if game_over:
		return
	resources -= amount
	if resources < 0:
		resources = 0
	for b in placed_buildings:
		b.notify_update(Global.StatType.RESOURCES)
	if resources == 0:
		win()
	update_resource_bar()
	
	$placing_area/planet.modulate = lerp(Color.white, Color('666666'), float(pollution) / MAX_POLLUTION)


func add_population(amount):
	if game_over:
		return
	population += amount
	var cap := get_population_cap()
	if population > cap:
		population = cap
	for b in placed_buildings:
		b.notify_update(Global.StatType.POPULATION)
		b.notify_update(Global.StatType.DEMAND)
	update_info_bar()


func get_population() -> int:
	return population


func get_population_cap() -> int:
	var apartments = get_placed_buildings(Global.BuildingType.APARTMENT_BUILDING)
	var cap := 0
	for apartment in apartments:
		cap += apartment.get_population_cap()
	return cap


func get_power() -> int:
	var powerplants = get_placed_buildings(Global.BuildingType.POWERPLANT)
	var power := 0
	for powerplant in powerplants:
		power += powerplant.get_power_generation()
	return power


func get_mining() -> int:
	var mines = get_placed_buildings(Global.BuildingType.MINE)
	var mining := 0
	for mine in mines:
		mining += mine.get_mining()
	return mining


func get_entertainment() -> int:
	var bars = get_placed_buildings(Global.BuildingType.BAR)
	var entertainment := 0
	for bar in bars:
		entertainment += bar.get_entertainment()
	return entertainment


func get_demand() -> int:
	var pop = get_population()
	if pop == 0:
		pop = 1
	var entertainment = get_entertainment()
	if entertainment == 0:
		entertainment = 1
	var demand = int(log(pop * entertainment) / log(10) )
	if demand == 0:
		demand = 1
	return demand


func win():
	game_over = true
	for building in get_tree().get_nodes_in_group('buildings'):
		building.operations_paused = true
	for button in get_tree().get_nodes_in_group('building_buttons'):
		button.disabled = true
	var interpolate_time := 1.0
	var scrh : float = ProjectSettings.get('display/window/size/height')
	$hud/hbox/vbox/resource_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$hud/hbox/vbox/info_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$victory_tween.interpolate_property($victory_banner_top, 'rect_position:y',  null, 0.0, interpolate_time, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$victory_tween.interpolate_property($victory_banner_bottom, 'rect_position:y', null, scrh - $victory_banner_bottom.rect_size.y, interpolate_time, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$victory_tween.interpolate_property($hud/hbox/vbox/resource_bar, 'modulate:a', null, 0.0, interpolate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$victory_tween.interpolate_property($hud/hbox/vbox/info_bar, 'modulate:a', null, 0.0, interpolate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$victory_tween.interpolate_property($music, 'volume_db', $music.volume_db, -80, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$victory_tween.interpolate_property($ominous_background, 'volume_db', -80, 0, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$victory_tween.start()
	$end_sound.play()
	$ominous_background.play()
	$hud/hbox/vbox/resource_bar.visible = false
	$hud/hbox/vbox/info_bar.visible = false


func _on_screen_closed():
	$settings.set_process_input(false)
	$settings/screen.visible = false


func show_settings_screen():
	$settings.set_process_input(true)
	$settings/screen.visible = true


func _on_settings_pressed():
	$placement_preview_sound.play()
	show_settings_screen()


func _on_end_game_btn_pressed():
	get_tree().paused = true
	$victory_screen.set_process(true)
	$victory_screen.set_physics_process(true)
	$victory_screen.set_process_input(true)
	$victory_screen/screen.visible = true
	$victory_screen/fade_out_tween.interpolate_property($victory_screen/screen, 'modulate:a', 0.0, 1.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$victory_screen/fade_out_tween.interpolate_property($music, 'volume_db', $music.volume_db, -80, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$victory_screen/fade_out_tween.start()
	yield($victory_screen/fade_out_tween, "tween_all_completed")
	$victory_screen/screen.start()


func _on_rotation_reset_timer_timeout():
	if not Input.is_action_pressed("rotate_left") and not Input.is_action_pressed("rotate_right"):
		rotation_accel = 0.0
