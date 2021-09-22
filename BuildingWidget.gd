extends PanelContainer
tool

signal action_button_clicked(widget, action, count)
signal count_changed(count)

var world
var building
var action

func _ready():
	$margin/vbox/batch/batch_sizes.clear()
	$margin/vbox/batch/batch_sizes.add_item("1")
	$margin/vbox/batch/batch_sizes.add_item("10")
	$margin/vbox/batch/batch_sizes.add_item("100")
	$margin/vbox/batch/batch_sizes.add_item("1000")
	$margin/vbox/batch/batch_sizes.add_item("10000")
	$margin/vbox/batch/batch_sizes.add_item("100000")


func init(_world, _building, _action):
	world = _world
	building = _building
	action = _action
	
	world.connect("info_updated", self, "_on_world_info_updated")
	building.connect("info_updated", self, "_on_building_info_updated")
	action.connect("info_updated", self, "_on_action_info_updated")
	
	update_action_button()
	update_description()
	update_stats()
	
	$margin/vbox/batch.visible = action.batch_enabled


func get_selected_count():
	var selected = $margin/vbox/batch/batch_sizes.selected
	if selected < 0:
		selected = 0
	return int($margin/vbox/batch/batch_sizes.get_item_text(selected))


func update_action_button():
	if action.price == 0 or action.price == null:
		$margin/vbox/action_btn.text = action.button_text
	else:
		var count = get_selected_count()
		$margin/vbox/action_btn.text = action.button_text + ' ($' + str(Global.human_readable(action.price * count)) + ')'
	
	if world != null and action.price != null and action.price > 0:
		$margin/vbox/action_btn.disabled = (world.money < action.price * get_selected_count())


func update_description():
	$margin/vbox/description.bbcode_text = '[b]' + action.title + '[/b]\n\n' + action.description


func update_stats():
	for child in $margin/vbox/stats.get_children():
		child.queue_free()
		
	for stat in action.stats:
		var widget = preload("res://BuildingStat.tscn").instance()
		$margin/vbox/stats.add_child(widget)
		widget.type = stat.type
		widget.text = stat.value
		
		# we don't call the widget.init function here so that the widget doesn't
		# automatically try to load the stat values upon receiving signals.
		#widget.init(building)


func _on_action_btn_pressed():
	emit_signal("action_button_clicked", self, action, get_selected_count())


func _on_batch_sizes_item_selected(_index):
	update_action_button()
	emit_signal("count_changed", get_selected_count())


func _on_world_info_updated(_world, item, _value):
	if item == Global.StatType.MONEY:
		update_action_button()


func _on_building_info_updated(_building, _item, _value):
	pass


func _on_action_info_updated(_action, item, _value):
	if item == Global.StatType.PRICE:
		update_action_button()
	if item == Global.StatType.TITLE or item == Global.StatType.DESCRIPTION:
		update_description()
