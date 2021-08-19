extends Node2D

enum MouseMode { NORMAL, PLACING }
enum Buildings { NONE, LUMBERYARD }

var buildings = {
	Buildings.LUMBERYARD: {
		'name': 'Lumberyard',
		'scene': preload("res://Lumberyard.tscn"),
		'icon': preload("res://assets/gfx/icons/lumberyard.png")
	}
}

var free_places := []
var occupied_places := {}

var placing : int = Buildings.NONE

var resources = 9223372036854775807 # 2**63-1
var pollution = 0

func _ready():
	var scrw = ProjectSettings.get('display/window/size/width')
	var y = 16 * 32
	for x in range(0, scrw, 32):
		free_places.append(Vector2(x + 16, y + 16))


func _on_toolbox_btn_pressed(btn):
	placing = Buildings.LUMBERYARD
	set_placing_icon()


func set_placing_icon():
	$drag_icon.visible = true
	$drag_icon.texture = buildings[placing]['icon']
	$drag_icon.position = get_tile_pos(get_local_mouse_position())


func get_tile(pos):
	pos /= 32
	pos = Vector2(int(pos.x), int(pos.y))
	return pos


func get_tile_pos(pos):
	pos = get_tile(pos)
	pos = pos * 32 + Vector2(16, 16)
	return pos


func _input(event):
	if placing != Buildings.NONE:
		if event is InputEventMouseMotion:
			var pos = get_tile_pos(event.position)
			if pos in free_places and not pos in occupied_places:
				$drag_icon.modulate = Color(1.0, 1.0, 1.0, 0.5)
			else:
				$drag_icon.modulate = Color(0.0, 0.0, 0.0, 0.5)
			$drag_icon.position = pos
		
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
			var pos = get_tile_pos(event.position)
			if pos in free_places:
				var instance = buildings[placing]['scene'].instance()
				occupied_places[pos] = instance
				free_places.erase(pos)
				instance.position = pos
				instance.init(self)
				add_child(instance)
			
		if placing and event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
			placing = Buildings.NONE
			$drag_icon.visible = false


func _process(delta):
	$resources_label.text = 'Resources: ' + str(resources)
	$pollution_label.text = 'Pollution: ' + str(pollution)


func use_resources(amount, pos):
	resources -= amount
	fly_number(-amount, Color.red, pos)


func add_pollution(amount, pos):
	pollution += amount
	fly_number(amount, Color.black, pos)


func fly_number(amount, color, pos):
	var label = preload("res://FlyingLabel.tscn").instance()
	label.text = str(amount) if amount < 0 else '+' + str(amount)
	label.add_color_override('font_color', color)
	if color == Color.black:
		label.get_font("font").outline_color = Color.white
	else:
		label.get_font("font").outline_color = Color.black
	label.rect_global_position = pos
	add_child(label)
	
	$tween.interpolate_property(label, "rect_position:y", null, pos.y - 50, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$tween.interpolate_property(label, "modulate:a", null, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$tween.start()

func _on_tween_tween_completed(object, key):
	object.queue_free()
