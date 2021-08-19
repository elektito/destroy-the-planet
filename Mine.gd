extends Node2D

var building_name = 'Mine'
var description = 'Mines resource from the planet, accelerating certain doom.'

var resource_usage = 1 setget set_resource_usage, get_resource_usage
var pollution = 5 setget set_pollution, get_pollution

func set_resource_usage(value):
	# property can't be changed
	pass


func get_resource_usage():
	return 5


func set_pollution(value):
	# property can't be changed
	pass


func get_pollution():
	return 1
