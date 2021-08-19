extends Node2D

var snap_angles = []
onready var buttons = [
	$hud/hbox/toolbox/factory_btn,
	$hud/hbox/toolbox/mine_btn,
	$hud/hbox/toolbox/powerplant_btn,
	$hud/hbox/toolbox/apartment_btn,
	$hud/hbox/toolbox/bar_btn,
]

func _ready():
	var img = preload("res://assets/gfx/sprites/factory.png")
	
	for i in range(0, 40):
		snap_angles.append(2 * PI / 40 * i)

func _input(event):
	if event is InputEventMouseMotion:
		var v : Vector2 = event.position - $planet.position
		var angle = get_snap_angle(v.angle())
		v = Vector2.RIGHT.rotated(angle)
		$building.position = $planet.position + v.normalized() * 230
		$building.rotation = v.angle() + PI / 2
	if event is InputEventMouseButton:
		var b = $building.duplicate()
		b.z_index = -10
		add_child(b)


func get_snap_angle(angle):
	while angle < 0:
		angle += 2 * PI
	while angle > 2 * PI:
		angle -= 2 * PI
	for i in range(len(snap_angles) - 1):
		if angle >= snap_angles[i] and angle <= snap_angles[i+1]:
			if abs(angle - snap_angles[i]) < abs(angle - snap_angles[i+1]):
				return snap_angles[i]
			else:
				return snap_angles[i+1]
	return snap_angles[len(snap_angles) - 1]


func _on_toolbox_btn_pressed(btn):
	print('pressed ', btn)


func _on_toolbox_btn_mouse_entered(btn):
	print('enter ', btn)
	$highlight.rect_position.x = 4
	$highlight.rect_position.y = buttons[btn].rect_position.y + 6
	$highlight.visible = true


func _on_toolbox_btn_mouse_exited(btn):
	print('exit ', btn)
	$highlight.visible = false
