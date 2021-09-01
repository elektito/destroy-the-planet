extends Node2D
tool

const BUILDING_POP_TIME := 0.075

signal clicked()

export(Texture) var texture : Texture = null setget set_texture, get_texture
export(bool) var selected : bool = false setget set_selected, get_selected
export(bool) var upgrade_available : bool = false setget set_upgrade_available
export(int, 0, 100) var smoke_rate : int = 1 setget set_smoke_rate, get_smoke_rate
export(bool) var decorative := false

var outline_material : ShaderMaterial

func _ready():
	for node in get_children():
		if node.is_in_group('smoke_positions'):
				var smoke = $smoke_blueprint.duplicate()
				smoke.visible = true
				smoke.emitting = true
				smoke.position = node.position - $base.position
				if decorative:
					smoke.rate = 100
					smoke.preprocess = 10
				smoke.add_to_group('smoke')
				$base.add_child(smoke)
	
	if decorative:
		return
	
	outline_material = ShaderMaterial.new()
	outline_material.shader = preload("res://Outline.gdshader")
	outline_material.set_shader_param('line_thickness', 25)
	
	shake()


func set_texture(value):
	$base/texture.texture = value


func get_texture():
	return $base/texture.texture


func set_selected(value : bool):
	if not is_inside_tree():
		return
	if value:
		$base/texture.material = outline_material
	else:
		$base/texture.material = null


func get_selected() -> bool:
	return $base/texture.material == null


func set_smoke_rate(value : int):
	for node in get_children():
		if node.is_in_group('smoke'):
			if node.rate != value:
				node.rate = value


func get_smoke_rate() -> int:
	return smoke_rate


func set_upgrade_available(value : bool):
	if not upgrade_available and value:
		var pos = find_node('upgrade_available_pos')
		if pos != null:
			$upgrade_label.rect_position = pos.position + Vector2(0, 10)
			$upgrade_label_tween.stop_all()
			$upgrade_label_tween.interpolate_property($upgrade_label, 'rect_position:y', null, pos.position.y, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
			$upgrade_label_tween.start()
	
	upgrade_available = value
	$upgrade_label.visible = value


func update_upgrade_label(parent):
	var actions = parent.get_actions()
	if len(actions) > 0 and actions[0]['name'] == 'level':
		set_upgrade_available(parent.world.money >= actions[0]['price'])
	else:
		set_upgrade_available(false)


func shake():
	if Engine.is_editor_hint():
		return
	
	var parent_pos = $base.global_position
	var pos = $base/texture.rect_global_position
	var initial_rotation = $base.rotation
	
	# move the parent node (a Node2D) further down into the planet, while keeping
	# the on-screen position unchanged. This changes the point around which the
	# building is shaken.
	var v = Vector2.UP.rotated(global_rotation)
	$base.global_position -= v * 50
	$base/texture.rect_global_position += v * 50
	
	for _i in range(1):
		$tween.interpolate_property($base, 'rotation', null, $base.rotation + 0.1, 0.025, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$tween.start()
		yield($tween, "tween_completed")
		$tween.interpolate_property($base, 'rotation', null, $base.rotation - 0.2, 0.025, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$tween.start()
		yield($tween, "tween_completed")
	
	$tween.interpolate_property($base, 'rotation', null, initial_rotation, 0.0125, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$tween.start()
	yield($tween, "tween_completed")
	
	# move and rotate things back to normal
	$base.global_position = parent_pos
	$base/texture.rect_global_position = pos
	$base.rotation = initial_rotation


func _on_main_area_mouse_entered():
	$building_pop_tween.stop_all()
	$building_pop_tween.interpolate_property(self, 'scale', null, Vector2(1.2, 1.2), BUILDING_POP_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$building_pop_tween.interpolate_property($base, 'position:y', null, -8, BUILDING_POP_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$building_pop_tween.start()


func _on_main_area_mouse_exited():
	$building_pop_tween.stop_all()
	$building_pop_tween.interpolate_property(self, 'scale', null, Vector2(1.0, 1.0), BUILDING_POP_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$building_pop_tween.interpolate_property($base, 'position:y', null, 0, BUILDING_POP_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$building_pop_tween.start()


func _on_main_area_gui_input(event):
	if decorative:
		return
	if event is InputEventMouseButton and not event.pressed:
		emit_signal("clicked")
