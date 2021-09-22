extends Node2D

var max_speed := 600.0
var max_force := 1000.0

var velocity := Vector2.ZERO
var final_target: Vector2
var next_target: Vector2

var avoidance_target: Vector2
var avoidance_radius: float

var rotation_dir := 1.0

func _ready():
	final_target.x = ProjectSettings.get('display/window/size/width') - 50
	final_target.y = 10
	
	if velocity.angle() > -PI / 4 and velocity.angle() < 3 * PI / 4:
		rotation_dir = -1
	
	choose_next_target()


func choose_next_target():
	if global_position.distance_to(final_target) < 400.0:
		next_target = final_target
		return
	
	next_target = avoidance_target + (global_position - avoidance_target).rotated(rotation_dir * PI / 4).normalized() * 300


func _physics_process(delta):
	$ColorRect.rect_global_position = next_target
	if global_position.distance_squared_to(final_target) < 10000.0:
		queue_free()
		return
	if global_position.distance_squared_to(next_target) < 10000.0:
		choose_next_target()
	var desired_velocity := (next_target - global_position).normalized() * max_speed
	var force := (desired_velocity - velocity).normalized() * max_force
	
	velocity += force * delta
	
	global_position += velocity * delta
