extends Node2D
tool

const MAX_AMOUNT := 50
const MAX_LIFETIME := 10
const MIN_SCALE = 0.2
const MAX_SCALE = 0.4

const MAX_RATE := 100

export(int, 0, 100) var rate = 1 setget set_rate, get_rate
export(bool) var emitting = false setget set_emitting, get_emitting
export(float) var preprocess = 0.0 setget set_preprocess, get_preprocess

onready var main_emitter : CPUParticles2D = $particles

func set_rate(value : int):
	if main_emitter == null:
		return
	if value > MAX_RATE:
		value = MAX_RATE
	if value == rate:
		return
	
	rate = value
	
	if rate == 0:
		main_emitter.emitting = false
	else:
		var new_emitter := main_emitter.duplicate()
		get_tree().create_timer(10.0).connect("timeout", self, "_on_delete_emitter_timeout", [main_emitter])
		main_emitter.emitting = false
		main_emitter = new_emitter
		
		main_emitter.emitting = true
		
		main_emitter.amount = int(float(rate+1) / MAX_RATE * MAX_AMOUNT)
		main_emitter.lifetime = int(float(rate) / MAX_RATE * (MAX_LIFETIME - 1)) + 1
		main_emitter.scale_amount = MIN_SCALE + float(rate) / MAX_RATE * (MAX_SCALE - MIN_SCALE)
		
		add_child(new_emitter)


func get_rate() -> int:
	return rate


func set_emitting(value: bool):
	if main_emitter == null:
		return
	main_emitter.emitting = value


func get_emitting() -> bool:
	if main_emitter == null:
		return false
	return main_emitter.emitting


func set_preprocess(value: float):
	if main_emitter == null:
		return
	main_emitter.preprocess = value


func get_preprocess() -> float:
	if main_emitter == null:
		return 0.0
	return main_emitter.preprocess


func _on_delete_emitter_timeout(emitter: CPUParticles2D):
	emitter.queue_free()
