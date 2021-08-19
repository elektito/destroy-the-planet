extends Node2D

var building_name = 'Bar'
var description = 'Where people go to have fun.'

var resource_usage = 1 setget set_resource_usage, get_resource_usage
var pollution = 1 setget set_pollution, get_pollution

func set_resource_usage(value):
	# property can't be changed
	pass


func get_resource_usage():
	return 1


func set_pollution(value):
	# property can't be changed
	pass


func get_pollution():
	return 1
