extends Node2D

var world = null

func init(world):
	self.world = world
	
	world.use_resources(1000, Vector2(global_position.x - 24, global_position.y - 16))
	world.add_pollution(200, Vector2(global_position.x, global_position.y - 24))
