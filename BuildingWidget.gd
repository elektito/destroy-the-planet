extends PanelContainer
tool

signal action_button_clicked()

export(String, MULTILINE) var text setget set_text, get_text
export(int) var price setget set_price, get_price
export(bool) var button_disabled setget set_button_disabled, get_button_disabled

func _ready():
	update_action_button()


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


func set_stats(stats):
	for stat in stats:
		if stat['type'] != Global.StatType.LEVEL:
			var widget = preload("res://BuildingStat.tscn").instance()
			widget.type = stat['type']
			widget.text = stat['value']
			$margin/vbox.add_child_below_node($margin/vbox/description, widget)


func update_action_button():
	if price == 0 or price == null:
		$margin/vbox/action_btn.text = 'Upgrade'
	else:
		$margin/vbox/action_btn.text = 'Upgrade (' + str(Global.human_readable_money(price)) + ')'


func _on_action_btn_pressed():
	emit_signal("action_button_clicked")
