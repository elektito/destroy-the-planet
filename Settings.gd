extends ColorRect

signal closed()

onready var master_bus = AudioServer.get_bus_index('Master')
onready var music_bus = AudioServer.get_bus_index('Music')
onready var sfx_bus = AudioServer.get_bus_index('SFX')

func _ready():
	$master_slider.value = db2linear(AudioServer.get_bus_volume_db(master_bus))
	$music_slider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))
	$sfx_slider.value = db2linear(AudioServer.get_bus_volume_db(sfx_bus))
	
	$master_slider.grab_focus()


func _input(_event):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		close_screen()


func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, linear2db(value))


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, linear2db(value))


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus, linear2db(value))


func close_screen():
	emit_signal("closed")
	get_tree().set_input_as_handled()


func _on_back_btn_pressed():
	$ui_sound.play()
	close_screen()


func _on_exit_btn_pressed():
	get_tree().quit()


func _on_fullscreen_checkbox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
