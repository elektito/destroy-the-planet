extends Node2D
tool

const BUILDING_POP_TIME := 0.075

signal clicked()
signal info_updated(building, item, value)

export(Texture) var texture : Texture = null setget set_texture, get_texture
export(bool) var selected : bool = false setget set_selected, get_selected
export(bool) var upgrade_available : bool = false setget set_upgrade_available
export(int, 0, 100) var smoke_rate : int = 1 setget set_smoke_rate, get_smoke_rate
export(bool) var decorative := false
export(bool) var operations_paused := false

var outline_material : ShaderMaterial
var shaking := false

var world
var smoke_nodes := []

var supports_boost := false
var boost := 0 setget set_boost

# these should be initialized in the sub-classes
var level = 1
var levels = null
var current_level = null

func init(world):
	self.world = world
	init_data()
	
	for node in Global.get_all_node_children(self):
		if node.is_in_group('smoke') and node != $smoke_blueprint:
			smoke_nodes.append(node)


func init_data():
	# to be overridden in sub-classes
	pass


func _ready():
	for node in get_children():
		if node.is_in_group('smoke_positions'):
				var smoke = $smoke_blueprint.duplicate()
				$base.add_child(smoke)
				smoke.visible = true
				smoke.emitting = true
				smoke.position = node.position - $base.position
				if decorative:
					smoke.rate = 100
					smoke.preprocess = 10
				smoke.add_to_group('smoke')
	
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
	# Instead of using `for node in smoke_nodes` we're using this way to iterate,
	# because according to the profiler this is a good bit faster.
	for i in range(len(smoke_nodes)):
		var node = smoke_nodes[i]
		if node.rate != value:
			node.rate = value


func get_smoke_rate() -> int:
	return smoke_rate


func set_boost(value: int):
	boost = value
	_boost_changed()


func _boost_changed():
	# to be overridden in sub-classes
	pass


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


func find_upgrade_action(actions):
	for action in actions:
		if action.name.begins_with('level'):
			return action
	return null


func update_upgrade_label():
	var actions = get_actions()
	var upgrade_action = find_upgrade_action(actions)
	if upgrade_action == null:
		set_upgrade_available(false)
	else:
		set_upgrade_available(world.money >= actions[0]['price'])


func shake():
	if Engine.is_editor_hint():
		return
	
	shaking = true
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
	shaking = false


func get_level_upgrade_price(level):
	# buildings can override this to have custom pricing methods
	return int(pow(100, level))


func post_level_upgrade():
	# should be overridden in the sub-classes if necessary.
	pass


func get_actions():
	# should be overridden in the sub-classes if necessary.
	return []


func add_upgrade_action(level, levels):
	var action = preload("res://BuildingAction.tscn").instance()
	action.name = 'level' + str(level + 1)
	action.title = 'Upgrade to level ' + str(level + 1)
	action.description = 'Upgrade building to level ' + str(level + 1) + '.'
	action.price = get_level_upgrade_price(level)
	
	var current_level = levels[level - 1]
	var next_level = levels[level]
	action.stats = Global.get_level_upgrade_stats(current_level, next_level)
	
	$actions.add_child(action)
	$actions.move_child(action, 0)


func perform_level_upgrade(action):
	# this function contains generic level upgrade functionality for all
	# buildings
	
	# just remove the child from the actions list. the widget will free it later.
	$actions.remove_child(action)
	print('action %s removed from tree' % action.name)
	
	level += 1
	current_level = levels[level - 1]
	
	# perform post-level-upgrade, possibly overridden in the sub-classes
	post_level_upgrade()
	
	if level < len(levels):
		add_upgrade_action(level, levels)
	elif supports_boost:
		add_boost_action()
	
	update_upgrade_label()
	
	emit_signal("info_updated", self, Global.StatType.LEVEL, level)
	emit_signal("info_updated", self, Global.StatType.ACTIONS, get_actions())


func add_boost_action():
	var action = preload("res://BuildingAction.tscn").instance()
	action.name = 'boost'
	action.type = Global.ActionType.BOOST
	action.title = 'Boost Building'
	action.description = 'Temporarily boost building performance.'
	$actions.add_child(action)


func _process(delta):
	return
	for x in $actions.get_children():
		if x.type == Global.ActionType.BOOST:
			print('moving to ', $actions.get_child_count() - 1)
			$actions.move_child(x, $actions.get_child_count() - 1)


func _on_main_area_mouse_entered():
	if shaking:
		return
	$building_pop_tween.stop_all()
	$building_pop_tween.interpolate_property(self, 'scale', null, Vector2(1.2, 1.2), BUILDING_POP_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$building_pop_tween.interpolate_property($base, 'position:y', null, -8, BUILDING_POP_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$building_pop_tween.start()


func _on_main_area_mouse_exited():
	if shaking:
		return
	$building_pop_tween.stop_all()
	$building_pop_tween.interpolate_property(self, 'scale', null, Vector2(1.0, 1.0), BUILDING_POP_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$building_pop_tween.interpolate_property($base, 'position:y', null, 0, BUILDING_POP_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$building_pop_tween.start()


func _on_main_area_gui_input(event):
	if decorative:
		return
	if event is InputEventMouseButton and not event.pressed:
		emit_signal("clicked")

