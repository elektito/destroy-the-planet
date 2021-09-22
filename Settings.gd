extends ColorRect

signal closed()

onready var master_bus = AudioServer.get_bus_index('Master')
onready var music_bus = AudioServer.get_bus_index('Music')
onready var sfx_bus = AudioServer.get_bus_index('SFX')

var action_after_confirm := ''

func _ready():
	$master_slider.value = db2linear(AudioServer.get_bus_volume_db(master_bus))
	$music_slider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))
	$sfx_slider.value = db2linear(AudioServer.get_bus_volume_db(sfx_bus))
	$fullscreen_checkbox.pressed = OS.window_fullscreen
	
	$master_slider.grab_focus()


func _input(_event):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		close_screen()


func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, linear2db(value))
	Global.save_settings()


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, linear2db(value))
	Global.save_settings()


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus, linear2db(value))
	Global.save_settings()


func close_screen():
	emit_signal("closed")
	get_tree().set_input_as_handled()


func _on_back_btn_pressed():
	$ui_sound.play()
	close_screen()


func _on_exit_btn_pressed():
	action_after_confirm = 'exit'
	$confirm_dialog.dialog_text = 'Are you sure you want to exit? You will permanently lose your current progress.'
	$confirm_dialog.popup_centered()


func _on_fullscreen_checkbox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	Global.save_settings()


func _on_new_game_btn_pressed():
	action_after_confirm = 'reset'
	$confirm_dialog.dialog_text = 'Are you sure you want to reset? You will permanently lose your current progress.'
	$confirm_dialog.popup_centered()


func _on_confirm_dialog_confirmed():
	if action_after_confirm == 'reset':
		if get_tree().reload_current_scene() != OK:
			print('Cannot reload current scene. Run for your lives!')
	elif action_after_confirm == 'exit':
		get_tree().quit()
