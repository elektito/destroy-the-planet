extends Node2D

signal info_updated(world, item)

const TRILLION := 1000000000000
const MAX_POLLUTION := 10000 * TRILLION

const MAX_ROTATION_SPEED := 4.0
const ROTATION_DAMP := 0.95
const ROTATION_ACCEL_INC := 1.2

var pollution := 0
var money := 100
var population := 0
var recruiters := 1
var recruiter_price := 10
var population_inc_per_recruiter := 1
var recruiter_price_increase := 10

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

# This dictionary is used for caching the result of the get_total_property
# function. Profiling showed that's an expensive function, so using this,
# we cache the results. The cache is reset on every physics frame.
var totals := {}

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
	Global.BuildingType.AD_AGENCY: {
		'button': $hud/hbox/toolbox/vbox/ad_agency_btn,
		'preview_icon': preload("res://assets/gfx/sprites/ad-agency0000.png"),
		'scene': preload("res://AdAgency.tscn"),
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
	
	$hud/hbox/vbox/top_bar.init(self)
	$hud/hbox/vbox/bottom_bar.init(self)
	$hud/hbox/building_panel.init(self, null)


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
				b.connect('info_updated', self, '_on_building_info_updated')
				consume_money(get_price(b.type))
				b.init(self)
				$placement_sound.play()
				placing = -1
				used_angles.append($placing_area/preview_icon.rotation)
				placed_buildings.append(b)
				update_toolbox()
				emit_signal("info_updated", self, Global.StatType.MONEY, money)


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
			$hud/hbox/building_panel.building = null
		
		if Input.is_action_pressed("rotate_left"):
			rotation_accel -= ROTATION_ACCEL_INC
			$rotation_reset_timer.start()
		elif Input.is_action_pressed("rotate_right"):
			rotation_accel += ROTATION_ACCEL_INC
			$rotation_reset_timer.start()


func _physics_process(delta):
	totals = {}
	
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
	
	$hud/hbox/building_panel.building = building


func _on_building_info_updated(building, item, _value):
	if item == Global.StatType.ADS:
		emit_signal("info_updated", self, Global.StatType.REACH, get_reach())
	
	var notifiable = [
		Global.StatType.POLLUTION_PER_CYCLE,
		Global.StatType.MONEY_PER_CYCLE,
	]
	for property in notifiable:
		emit_signal("info_updated", self, property, get_total_property(property))


func get_total_property(property):
	if property in totals:
		return totals[property]
	
	var total = 0
	
	for b in placed_buildings:
		if property in b.effects:
			total += b.get_property(property)
	
	totals[property] = total
	
	return total


func update_toolbox():
	for building_type in Global.get_building_types():
		var btn : Button = building_info[building_type]['button']
		var building_name := Global.get_building_name(building_type)
		var building_price = get_price(building_type)
		btn.hint_tooltip = building_name + '\nCost: ' + Global.human_readable(building_price)
		btn.disabled = (money < building_price)


func _on_action_button_clicked(_widget, action, count):
	consume_money(action.price * count)
	selected_building.perform_action(action, count)
	$placement_sound.play()


func _on_batch_size_changed(count, widget, action):
	widget.button_disabled = (money < action['price'] * count)


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
		Global.BuildingType.AD_AGENCY:
			base_price = 200
			exponent = get_building_count(Global.BuildingType.AD_AGENCY)
	
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
	emit_signal("info_updated", self, Global.StatType.MONEY, money)
	update_toolbox()


func consume_money(amount):
	if game_over:
		return
	money -= amount
	emit_signal("info_updated", self, Global.StatType.MONEY, money)
	update_toolbox()


func produce_pollution(amount):
	if game_over:
		return
	pollution += amount
	if pollution > MAX_POLLUTION or pollution < 0: # overflow
		pollution = MAX_POLLUTION
	if pollution == MAX_POLLUTION:
		win()
	emit_signal("info_updated", self, Global.StatType.POLLUTION, pollution)
	
	$bg_layer/background.color = lerp(Color('00bbff'), Color.lightblue, float(pollution) / MAX_POLLUTION)
	$bg_layer/background.modulate = lerp(Color.white, Color('999999'), float(pollution) / MAX_POLLUTION)


func add_population(amount):
	if game_over:
		return
	population += amount
	var cap := get_population_cap()
	if population > cap:
		population = cap
	emit_signal("info_updated", self, Global.StatType.POPULATION, population)


func hire_recruiter(count: int = 1):
	recruiters += count
	recruiter_price += count * recruiter_price_increase
	emit_signal("info_updated", self, Global.StatType.POPULATION_INCREASE_PER_CYCLE, get_population_increment_per_cycle())
	emit_signal("info_updated", self, Global.StatType.RECRUITERS, recruiters)


func get_recruiter_price():
	return recruiter_price


func get_recruiter_count():
	return recruiters


func get_population_increment_per_cycle():
	return recruiters * population_inc_per_recruiter


func get_population() -> int:
	return population


func get_population_cap() -> int:
	var apartments = get_placed_buildings(Global.BuildingType.APARTMENT_BUILDING)
	var cap := 100 # initial cap
	for apartment in apartments:
		cap += apartment.get_population_cap()
	return cap


func get_reach() -> float:
	var ads = get_total_property(Global.StatType.ADS)
	
	# the following function ensures that reach is always in range [0, 1]. 
	# you can adjust a and b parameters to change the rate of the function.
	var a := 20.0
	var b := 2.0
	var reach := 1 - log(a) / log(a + b * ads)
	
	if reach < 0.01:
		return 0.01
	
	return reach


func win():
	game_over = true
	for building in get_tree().get_nodes_in_group('buildings'):
		building.operations_paused = true
	for button in get_tree().get_nodes_in_group('building_buttons'):
		button.disabled = true
	var interpolate_time := 1.0
	var scrh : float = ProjectSettings.get('display/window/size/height')
	$hud/hbox/vbox/top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$hud/hbox/vbox/bottom_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$victory_tween.interpolate_property($victory_banner_top, 'rect_position:y',  null, 0.0, interpolate_time, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$victory_tween.interpolate_property($victory_banner_bottom, 'rect_position:y', null, scrh - $victory_banner_bottom.rect_size.y, interpolate_time, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$victory_tween.interpolate_property($hud/hbox/vbox/top_bar, 'modulate:a', null, 0.0, interpolate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$victory_tween.interpolate_property($hud/hbox/vbox/bottom_bar, 'modulate:a', null, 0.0, interpolate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$victory_tween.interpolate_property($music, 'volume_db', $music.volume_db, -80, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$victory_tween.interpolate_property($ominous_background, 'volume_db', -80, 0, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$victory_tween.start()
	$end_sound.play()
	$ominous_background.play()
	$hud/hbox/vbox/top_bar.visible = false
	$hud/hbox/vbox/bottom_bar.visible = false


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


func _on_recruiter_cycle_timer_timeout():
	add_population(recruiters * population_inc_per_recruiter)
