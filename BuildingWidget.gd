extends PanelContainer
tool

signal action_button_clicked(count)
signal count_changed(count)

export(String, MULTILINE) var text setget set_text, get_text
export(int) var price setget set_price, get_price
export(bool) var button_disabled setget set_button_disabled, get_button_disabled
export(String) var button_text = 'Upgrade' setget set_button_text, get_button_text
export(bool) var batch_enabled = false setget set_batch_enabled, get_batch_enabled

func _ready():
	update_action_button()
	
	$margin/vbox/batch/batch_sizes.clear()
	$margin/vbox/batch/batch_sizes.add_item("1")
	$margin/vbox/batch/batch_sizes.add_item("10")
	$margin/vbox/batch/batch_sizes.add_item("100")
	$margin/vbox/batch/batch_sizes.add_item("1000")
	$margin/vbox/batch/batch_sizes.add_item("10000")
	$margin/vbox/batch/batch_sizes.add_item("100000")


func set_text(value):
	$margin/vbox/description.bbcode_text = value


func get_text():
	return $margin/vbox/description.bbcode_text


func set_price(value):
	price = value
	update_action_button()


func get_price() -> int:
	return price


func set_button_disabled(value : bool):
	$margin/vbox/action_btn.disabled = value


func get_button_disabled() -> bool:
	return $margin/vbox/action_btn.disabled


func set_button_text(value : String):
	button_text = value
	update_action_button()


func get_button_text() -> String:
	return button_text


func set_stats(stats):
	for stat in stats:
		if stat['type'] != Global.StatType.LEVEL:
			var widget = preload("res://BuildingStat.tscn").instance()
			widget.type = stat['type']
			widget.text = stat['value']
			$margin/vbox.add_child_below_node($margin/vbox/description, widget)


func set_batch_enabled(value: bool):
	if $margin/vbox/batch == null:
		return
	$margin/vbox/batch.visible = value


func get_batch_enabled() -> bool:
	if $margin/vbox/batch == null:
		return false
	return $margin/vbox/batch.visible


func get_selected_count():
	var selected = $margin/vbox/batch/batch_sizes.selected
	if selected < 0:
		selected = 0
	return int($margin/vbox/batch/batch_sizes.get_item_text(selected))

func update_action_button():
	if price == 0 or price == null:
		$margin/vbox/action_btn.text = button_text
	else:
		var count = get_selected_count()
		$margin/vbox/action_btn.text = button_text + ' ($' + str(Global.human_readable_money(price * count)) + ')'


func _on_action_btn_pressed():
	emit_signal("action_button_clicked", get_selected_count())


func _on_batch_sizes_item_selected(_index):
	update_action_button()
	emit_signal("count_changed", get_selected_count())
