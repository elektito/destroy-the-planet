extends MarginContainer
tool

export(Global.StatType) var type setget set_type, get_type
export(String) var text setget set_text, get_text

var type_info = {
	Global.StatType.LEVEL: {
		'name': 'Level',
		'texture': preload("res://assets/gfx/icons/level.png"),
		'human_readable': false,
	},
	Global.StatType.POLLUTION_PER_CYCLE: {
		'name': 'Pollution (per cycle)',
		'texture': preload("res://assets/gfx/icons/pollution.png"),
		'human_readable': true,
	},
	Global.StatType.RESOURCE_USAGE_PER_CYCLE: {
		'name': 'Resource Usage (per cycle)',
		'texture': preload("res://assets/gfx/icons/usage.png"),
		'human_readable': true,
	},
	Global.StatType.PROFIT: {
		'name': 'Profit per Sale',
		'texture': preload("res://assets/gfx/icons/profit.png"),
		'human_readable': true,
	},
	Global.StatType.MONEY_PER_CYCLE: {
		'name': 'Money (per cycle)',
		'texture': preload("res://assets/gfx/icons/money.png"),
		'human_readable': true,
	},
	Global.StatType.ADS: {
		'name': 'Ads',
		'texture': preload("res://assets/gfx/icons/entertainment.png"),
		'human_readable': true,
	},
	Global.StatType.POWER: {
		'name': 'Power Production',
		'texture': preload("res://assets/gfx/icons/power.png"),
		'human_readable': false,
	},
	Global.StatType.MINING: {
		'name': 'Mining',
		'texture': preload("res://assets/gfx/icons/mining.png"),
		'human_readable': false,
	},
	Global.StatType.POPULATION_CAP: {
		'name': 'Population Cap',
		'texture': preload("res://assets/gfx/icons/population-cap.png"),
		'human_readable': true,
	},
	Global.StatType.POPULATION_INCREASE_PER_CYCLE: {
		'name': 'Population Increase (per cycle)',
		'texture': preload("res://assets/gfx/icons/population-increase.png"),
		'human_readable': true,
	},
}

func init(object: Object):
	if object.connect('info_updated', self, '_on_info_updated') != OK:
		print('Could not connect signal. Bad things could happen!')


func _on_info_updated(_object: Object, item: int, value):
	if item == type:
		var human_readable :  bool = type_info[item]['human_readable']
		if human_readable:
			$hbox/label.text = Global.human_readable_money(value)
		else:
			$hbox/label.text = str(value)


func set_type(value):
	if not value in type_info:
		print('BuildingStat got unexpected stat type: ', value, '. Will be ignored.')
		return
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
