extends PanelContainer
tool

signal action_button_clicked()

export(String, MULTILINE) var text setget set_text, get_text

func set_text(value):
	$margin/vbox/description.bbcode_text = value


func get_text():
	return $margin/vbox/description.bbcode_text


func _on_action_btn_pressed():
	emit_signal("action_button_clicked")
