extends ColorRect

func _ready():
	$sprite.modulate.a = 0
	$sprite/factory/smoke1.rate = 100
	$sprite/factory/smoke2.rate = 100
	$sprite/factory2/smoke1.rate = 100
	$sprite/factory2/smoke2.rate = 100
	$sprite/powerplant/smoke.rate = 100
	$sprite/powerplant2/smoke.rate = 100


func start():
	$end_sound.play()
	$tween.interpolate_property($sprite, 'modulate:a', 0.0, 1.0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$tween.start()


func _on_exit_btn_pressed():
	get_tree().quit()


func _on_credits_btn_pressed():
	get_tree().paused = false
	if get_tree().change_scene("res://CreditsScreen.tscn") != OK:
		print('change_scene failed. Run for your life!6')


func _on_new_game_btn_pressed():
	$new_game_dialog.popup_centered()


func _on_new_game_dialog_confirmed():
	get_tree().change_scene("res://World.tscn")
