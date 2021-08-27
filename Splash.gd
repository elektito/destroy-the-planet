extends Node2D

func _ready():
	randomize()
	var n = 100
	for i in range(n):
		var building = create_building()
		var angle = 2 * PI / n * i
		var v = Vector2.RIGHT.rotated(angle)
		building.position = v.normalized() * 540
		building.rotation = v.angle() + PI / 2
		$planet.add_child(building)


func create_building():
	var scenes = {
		Global.BuildingType.APARTMENT_BUILDING: preload('res://Apartment.tscn'),
		Global.BuildingType.BAR: preload('res://Bar.tscn'),
		Global.BuildingType.FACTORY: preload('res://Factory.tscn'),
		Global.BuildingType.MINE: preload('res://Mine.tscn'),
		Global.BuildingType.POWERPLANT: preload('res://Powerplant.tscn'),
	}
	var building_types = [
		Global.BuildingType.APARTMENT_BUILDING,
		Global.BuildingType.BAR,
		Global.BuildingType.FACTORY,
		Global.BuildingType.FACTORY,
		Global.BuildingType.FACTORY,
		Global.BuildingType.FACTORY,
		Global.BuildingType.MINE,
		Global.BuildingType.MINE,
		Global.BuildingType.MINE,
		Global.BuildingType.POWERPLANT,
		Global.BuildingType.POWERPLANT,
		Global.BuildingType.POWERPLANT,
		Global.BuildingType.POWERPLANT,
	]
	#var idx = randi() % len(scenes)
	var building_type = building_types[randi() % len(building_types)] #scenes.keys()[idx]
	var building_scene = scenes[building_type] #scenes.values()[idx]
	var building = building_scene.instance()
	building.decorative = true
	if building_type == Global.BuildingType.FACTORY:
		building.get_node("smoke1").rate = 100
		building.get_node("smoke2").rate = 100
		building.get_node("smoke1").preprocess = 10
		building.get_node("smoke2").preprocess = 10
		building.get_node("smoke1").local_coords = false
		building.get_node("smoke2").local_coords = false
	elif building_type == Global.BuildingType.POWERPLANT:
		building.get_node("smoke").rate = 100
		building.get_node("smoke").preprocess = 10
		building.get_node("smoke").local_coords = false
	return building


func _on_animation_speed_timer_timeout():
	if $animation.playback_speed > 0.1:
		$animation.playback_speed *= 0.93


func _input(event):
	if event is InputEventKey or \
	   (event is InputEventMouseButton and event.button_index in [BUTTON_LEFT, BUTTON_RIGHT]):
		next_screen()


func _on_animation_animation_finished(anim_name):
	yield(get_tree().create_timer(1.5), "timeout")
	next_screen()


func next_screen():
	get_tree().change_scene("res://World.tscn")

