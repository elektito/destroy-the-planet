extends Panel

signal action_button_clicked()

var world
var building setget set_building

func init(world, building):
	self.world = world
	world.connect("info_updated", self, "_on_world_info_updated")
	
	set_building(building)


func set_building(new_building):
	if building:
		building.disconnect("info_updated", self, "_on_building_info_updated")
	
	building = new_building
	if building:
		building.connect("info_updated", self, "_on_building_info_updated")
	
	build_panel()


func build_panel():
	for node in $margin/vbox/stats.get_children():
		node.queue_free()
	for node in $margin/vbox/widgets.get_children():
		node.queue_free()

	if building == null:
		$margin/vbox/description.bbcode_text = ''
		return
	
	$margin/vbox/description.bbcode_text = '[b]' + building.building_name + '[/b]\n\n' + building.description
	
	for stat in building.get_stats():
		var widget = preload("res://BuildingStat.tscn").instance()
		widget.type = stat.type
		widget.init(building)
		widget.text = Global.human_readable(int(stat.value))
		$margin/vbox/stats.add_child(widget)
	for action in building.get_actions():
		var widget = create_widget_for_action(action)
		$margin/vbox/widgets.add_child(widget)


func create_widget_for_action(action):
	var widget = preload("res://BuildingWidget.tscn").instance()
	widget.init(world, building, action)
	widget.set_meta('action', action)
	widget.connect('action_button_clicked', self, '_on_action_button_clicked')
	return widget


func _on_world_info_updated(_world, _item, _value):
	pass


func _on_building_info_updated(building, item, value):
	if item == Global.StatType.ACTIONS:
		var actions = value
		
		# look among existing widgets and delete the ones whose action no longer
		# exists
		for widget in $margin/vbox/widgets.get_children():
			var found = false
			for action in actions:
				if widget.get_meta('action').name == action.name:
					found = true
			if not found:
				widget.queue_free()
				print('widget for action %s queued for freeing' % widget.get_meta('action').name)
				
				# freeing the removed action is also our responsibility, since
				# the parent building only removes it from the tree.
				widget.get_meta('action').queue_free()
				print('action %s queued for freeing' % widget.get_meta('action').name)
		
		# look among new actions and add a widget for the ones that do not have
		# one
		var i = 0
		for action in actions:
			var found = false
			for widget in $margin/vbox/widgets.get_children():
				if widget.get_meta('action').name == action.name:
					found = true
			if not found:
				var widget = create_widget_for_action(action)
				$margin/vbox/widgets.add_child(widget)
				$margin/vbox/widgets.move_child(widget, i)
			i += 1


func _on_action_button_clicked(widget, action, count):
	emit_signal("action_button_clicked", widget, action, count)

