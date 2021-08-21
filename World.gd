extends Node2D

const MAX_RESOURCES := 9223372036854775807 # 2**63-1
const MAX_POLLUTION := 9223372036854775807 # 2**63-1

var pollution := 0
var resources := MAX_RESOURCES
var money := 100

var click_money := 1

var placing := -1
var inside_placing_area := false
var selected_building = null
var snap_angles = []
var used_angles = []
var placed_buildings = []
onready var buttons = [
	$hud/hbox/toolbox/factory_btn,
	$hud/hbox/toolbox/mine_btn,
	$hud/hbox/toolbox/powerplant_btn,
	$hud/hbox/toolbox/apartment_btn,
	$hud/hbox/toolbox/bar_btn,
]
var preview_icons = [
	preload("res://assets/gfx/sprites/factory.png"),
	preload("res://assets/gfx/sprites/mine.png"),
	preload("res://assets/gfx/sprites/powerplant.png"),
	preload("res://assets/gfx/sprites/apartment.png"),
	preload("res://assets/gfx/sprites/bar.png"),
]
var building_scenes = [
	preload("res://Factory.tscn"),
	preload("res://Mine.tscn"),
	preload("res://Powerplant.tscn"),
	preload("res://Apartment.tscn"),
	preload("res://Bar.tscn"),
]

func _ready():
	for i in range(0, 40):
		snap_angles.append(2 * PI / 40 * i)
	
	update_toolbox()
	update_building_panel()
	update_resource_bar()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if placing >= 0:
			$placing_icon.position = get_local_mouse_position()
		
			var v : Vector2 = $placing_area.get_local_mouse_position() - $placing_area/planet.position
			var angle = get_snap_angle(v.angle())
			v = Vector2.RIGHT.rotated(angle)
			$placing_area/preview_icon.position = v.normalized() * 230
			$placing_area/preview_icon.rotation = v.angle() + PI / 2
	
	if event is InputEventMouseButton:
		if placing < 0 and event.pressed and event.button_index == BUTTON_LEFT:
			produce_money(click_money)
		if OS.is_debug_build() and placing < 0 and event.pressed and event.button_index == BUTTON_MIDDLE:
			produce_money(1000000000000)
		
		if placing >= 0 and event.button_index == BUTTON_RIGHT:
			placing = -1
			$placing_icon.visible = false
		
		if placing >= 0 and event.button_index == BUTTON_LEFT and inside_placing_area:
			if not $placing_area/preview_icon.rotation in used_angles:
				$placing_icon.visible = false
				$placing_area/preview_icon.visible = false
				var b = building_scenes[placing].instance()
				b.z_index = -10
				b.position = $placing_area/preview_icon.position
				b.rotation = $placing_area/preview_icon.rotation
				$placing_area.add_child(b)
				b.get_node('building').connect('clicked', self, '_on_building_clicked', [b])
				b.connect('upgraded', self, '_on_building_upgraded')
				b.init(self)
				consume_money(get_price(b.type))
				placing = -1
				used_angles.append($placing_area/preview_icon.rotation)
				placed_buildings.append(b)
				update_toolbox()
			
		if placing < 0 and not selected_building == null:
			selected_building.get_node('building').selected = false
			selected_building = null
			update_building_panel()


func _on_building_clicked(building):
	if placing >= 0:
		return
	if selected_building:
		selected_building.get_node('building').selected = false
	building.get_node('building').selected = true
	selected_building = building
	
	update_building_panel()


func _on_building_upgraded(building):
	update_building_panel()


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
			widget.text = stat['value']
			$hud/hbox/building_panel/MarginContainer/VBoxContainer.add_child(widget)
		for action in selected_building.get_actions():
			var widget = preload("res://BuildingWidget.tscn").instance()
			widget.text = '[b]' + action['title'] + '[/b]\n\n' + action['description']
			widget.connect('action_button_clicked', self, '_on_action_button_clicked', [widget, action])
			$hud/hbox/building_panel/MarginContainer/VBoxContainer.add_child(widget)


func update_resource_bar():
	$hud/hbox/vbox/resource_bar/margin/hbox/money_value_label.text = str(money)
	
	var resources_percent = int(float(resources) / MAX_RESOURCES * 100)
	$hud/hbox/vbox/resource_bar/margin/hbox/resources_value_label.text = str(resources) + ' (' + str(resources_percent) + '%)'
	
	var pollution_percent = int(float(pollution) / MAX_POLLUTION * 100)
	$hud/hbox/vbox/resource_bar/margin/hbox/pollution_value_label.text = str(pollution) + ' (' + str(pollution_percent) + '%)'


func update_toolbox():
	for building_type in Global.get_building_types():
		var btn : Button = buttons[building_type]
		var building_name := Global.get_building_name(building_type)
		var building_price = get_price(building_type)
		btn.hint_tooltip = building_name + '\nCost: ' + str(building_price)
		btn.disabled = (money < building_price)


func _on_action_button_clicked(widget, action):
	selected_building.perform_action(action)


func get_price(building) -> int:
	match building:
		Global.BuildingType.FACTORY:
			var factories = get_building_count(Global.BuildingType.FACTORY)
			return int(pow(100, factories + 1))
		Global.BuildingType.MINE:
			var mines = get_building_count(Global.BuildingType.MINE)
			return int(pow(200, mines + 1))
		Global.BuildingType.POWERPLANT:
			var powerplants = get_building_count(Global.BuildingType.POWERPLANT)
			return int(pow(200, powerplants + 1))
		Global.BuildingType.APARTMENT_BUILDING:
			var apartment_buildings = get_building_count(Global.BuildingType.APARTMENT_BUILDING)
			return int(pow(200, apartment_buildings + 1))
		Global.BuildingType.BAR:
			var bars = get_building_count(Global.BuildingType.BAR)
			return int(pow(200, bars + 1))
	return -1


func get_building_count(building_type) -> int:
	var count := 0
	for b in placed_buildings:
		if b.type == building_type:
			count += 1
	return count


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


func _on_toolbox_btn_pressed(btn):
	$placing_icon.texture = buttons[btn].icon
	$placing_icon.position = get_local_mouse_position()
	$placing_icon.visible = true
	placing = btn
	$placing_area/preview_icon.texture = preview_icons[btn]


func _on_toolbox_btn_mouse_entered(btn):
	$highlight.rect_position.x = 2
	$highlight.rect_position.y = buttons[btn].rect_position.y + 2
	$highlight.visible = true


func _on_toolbox_btn_mouse_exited(btn):
	$highlight.visible = false


func _on_placing_area_mouse_entered():
	inside_placing_area = true
	if placing >= 0:
		$placing_area/preview_icon.visible = true
		$placing_icon.visible = false


func _on_placing_area_mouse_exited():
	if $placing_area.get_local_mouse_position().length() < $placing_area.get_node("shape").shape.radius:
		return
	inside_placing_area = false
	if placing >= 0:
		$placing_area/preview_icon.visible = false
		$placing_icon.visible = true


func produce_money(amount):
	money += amount
	update_resource_bar()
	update_toolbox()


func consume_money(amount):
	money -= amount
	update_resource_bar()
	update_toolbox()


func produce_pollution(amount):
	pollution += amount
	update_resource_bar()


func consume_resources(amount):
	resources -= amount
	update_resource_bar()
