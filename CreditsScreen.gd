extends ColorRect

onready var credits_y = $credits.rect_position.y
onready var title_x = $title/game_title.rect_position.x

func _ready():
	$title/factory/smoke1.rate = 100
	$title/factory/smoke2.rate = 100
	$title/powerplant/smoke.rate = 100
	
	$credits.rect_position.y = -$credits.rect_size.y - 100
	$title.position.x = -$title/game_title.rect_size.x - 100
	
	start()


func start():
	$title_tween.interpolate_property($title, 'position:x', null, title_x, 1.0, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$title_tween.start()
	yield($title_tween, "tween_completed")
	$title_tween.interpolate_property($credits, 'rect_position:y', null, credits_y, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$title_tween.start()


func _on_exit_btn_pressed():
	get_tree().quit()


func _on_new_game_btn_pressed():
	get_tree().change_scene("res://World.tscn")
