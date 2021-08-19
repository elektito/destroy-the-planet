extends Node2D

var building_name = 'Coal Powerplant'
var description = 'The best kind of power plant there is.'

var resource_usage = 2 setget set_resource_usage, get_resource_usage
var pollution = 4 setget set_pollution, get_pollution

func set_resource_usage(value):
	# property can't be changed
	pass


func get_resource_usage():
	return 2


func set_pollution(value):
	# property can't be changed
	pass


func get_pollution():
	return 4
