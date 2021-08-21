extends MarginContainer
tool

export(Global.StatType) var type setget set_type, get_type
export(String) var text setget set_text, get_text

var type_info = {
	Global.StatType.POLLUTION: {
		'name': 'Pollution (per cycle)',
		'texture': preload("res://assets/gfx/icons/pollution.png"),
	},
	Global.StatType.USAGE: {
		'name': 'Resource Usage (per cycle)',
		'texture': preload("res://assets/gfx/icons/usage.png"),
	},
	Global.StatType.MONEY: {
		'name': 'Money (per cycle)',
		'texture': preload("res://assets/gfx/icons/money.png"),
	},
	Global.StatType.ENTERTAINMENT: {
		'name': 'Entertainment',
		'texture': preload("res://assets/gfx/icons/entertainment.png"),
	},
	Global.StatType.POWER: {
		'name': 'Power Production',
		'texture': preload("res://assets/gfx/icons/power.png"),
	},
	Global.StatType.MINING: {
		'name': 'Mining',
		'texture': preload("res://assets/gfx/icons/mining.png"),
	},
	Global.StatType.POPULATION_CAP: {
		'name': 'Population Cap',
		'texture': preload("res://assets/gfx/icons/population-cap.png"),
	},
	Global.StatType.POPULATION_INCREASE: {
		'name': 'Population Increase (per cycle)',
		'texture': preload("res://assets/gfx/icons/population-increase.png"),
	},
}

func set_type(value):
	type = value
	
	var info = type_info[type]
	$hbox/icon.texture = info['texture']
	$hbox.hint_tooltip = info['name']


func get_type():
	return type


func set_text(value):
	$hbox/label.text = value


func get_text():
	return $hbox/label.text
