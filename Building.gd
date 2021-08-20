extends Node2D
tool

signal clicked()

export(Texture) var texture : Texture = null setget set_texture, get_texture
export(bool) var selected : bool = false setget set_selected, get_selected

func _ready():
	shake()


func _on_texture_gui_input(event):
	if event is InputEventMouseButton and not event.pressed:
		emit_signal("clicked")


func set_texture(value):
	$texture.texture = value


func get_texture():
	return $texture.texture


func set_selected(value : bool):
	$selection.visible = value


func get_selected() -> bool:
	return $selection.visible


func shake():
	var parent_pos = get_parent().global_position
	var pos = global_position
	var initial_rotation = get_parent().rotation
	
	# move the parent node (a Node2D) further down into the planet, while keeping
	# the on-screen position unchanged. This changes the point around which the
	# building is shaken.
	var v = Vector2.UP.rotated(global_rotation)
	get_parent().global_position -= v * 50
	global_position += v * 50
	
	for i in range(1):
		$tween.interpolate_property(get_parent(), 'rotation', null, get_parent().rotation + 0.1, 0.025, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$tween.start()
		yield($tween, "tween_completed")
		$tween.interpolate_property(get_parent(), 'rotation', null, get_parent().rotation - 0.2, 0.025, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$tween.start()
		yield($tween, "tween_completed")
	
	$tween.interpolate_property(get_parent(), 'rotation', null, initial_rotation, 0.0125, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$tween.start()
	yield($tween, "tween_completed")
	
	# move and rotate things back to normal
	get_parent().global_position = parent_pos
	global_position = pos
	get_parent().rotation = initial_rotation