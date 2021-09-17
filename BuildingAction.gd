extends Node

signal info_updated(action, item, value)

export(String) var title: String setget set_title
export(String, MULTILINE) var description: String setget set_description
export(int) var price: int setget set_price
export(String) var button_text: String = 'Perform'
export(bool) var batch_enabled := false

# should be an array of Stat resource, enforced in set_stats, since looks like
# godot doesn't support using custom resources as export hints.
export(Array, Resource) var stats := [] setget set_stats

func set_stats(value: Array):
	for stat in value:
		if stat.get_script() == null or stat.get_script().get_path() != "res://Stat.gd":
			push_error("Only Stat resources can be set in BuildingAction.stats")
			assert(false, "Only Stat resources can be set in BuildingAction.stats")
	stats = value
	
	emit_signal("info_updated", self, Global.StatType.ACTION_STATS, stats)


func set_title(value):
	title = value
	emit_signal("info_updated", self, Global.StatType.TITLE, title)


func set_description(value):
	description = value
	emit_signal("info_updated", self, Global.StatType.DESCRIPTION, description)


func set_price(value: int):
	price = value
	emit_signal("info_updated", self, Global.StatType.PRICE, price)
