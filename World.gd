extends Node2D

var placing := -1
var inside_placing_area := false
var snap_angles = []
onready var buttons = [
	$hud/hbox/toolbox/factory_btn,
	$hud/hbox/toolbox/mine_btn,
	$hud/hbox/toolbox/powerplant_btn,
	$hud/hbox/toolbox/apartment_btn,
	$hud/hbox/toolbox/bar_btn,
]
var preview_icons = [
	preload("res://assets/gfx/sprites/factory.png"),
	preload("res://assets/gfx/sprites/mine.png"),
	preload("res://assets/gfx/sprites/powerplant.png"),
	preload("res://assets/gfx/sprites/apartment.png"),
	preload("res://assets/gfx/sprites/bar.png"),
]

func _ready():
	var img = preload("res://assets/gfx/sprites/factory.png")
	
	for i in range(0, 40):
		snap_angles.append(2 * PI / 40 * i)

func _input(event):
	if event is InputEventMouseMotion:
		if placing >= 0:
			$placing_icon.position = get_local_mouse_position()
		
			var v : Vector2 = $placing_area.get_local_mouse_position() - $placing_area/planet.position
			var angle = get_snap_angle(v.angle())
			v = Vector2.RIGHT.rotated(angle)
			$placing_area/preview_icon.position = v.normalized() * 230
			$placing_area/preview_icon.rotation = v.angle() + PI / 2
	
	if event is InputEventMouseButton:
		#var b = $building.duplicate()
		#b.z_index = -10
		#add_child(b)
		
		if placing >= 0 and event.button_index == BUTTON_RIGHT:
			placing = -1
			$placing_icon.visible = false


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
	$placing_icon.texture = buttons[btn].icon
	$placing_icon.position = get_local_mouse_position()
	$placing_icon.visible = true
	placing = btn
	$placing_area/preview_icon.texture = preview_icons[btn]


func _on_toolbox_btn_mouse_entered(btn):
	print('enter ', btn)
	$highlight.rect_position.x = 4
	$highlight.rect_position.y = buttons[btn].rect_position.y + 6
	$highlight.visible = true


func _on_toolbox_btn_mouse_exited(btn):
	print('exit ', btn)
	$highlight.visible = false


func _on_placing_area_mouse_entered():
	inside_placing_area = true
	if placing >= 0:
		$placing_area/preview_icon.visible = true
		$placing_icon.visible = false


func _on_placing_area_mouse_exited():
	inside_placing_area = false
	if placing >= 0:
		$placing_area/preview_icon.visible = false
		$placing_icon.visible = true
