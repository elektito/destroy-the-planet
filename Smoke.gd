extends CPUParticles2D
tool

const MAX_AMOUNT := 50
const MAX_LIFETIME := 10
const MIN_SCALE = 0.2
const MAX_SCALE = 0.4

const MAX_RATE := 100
export(int, 0, 100) var rate = 0 setget set_rate, get_rate

func set_rate(value : int):
	rate = value
	
	if rate == 0:
		emitting = false
	else:
		emitting = true
		
		amount = int(float(rate+1) / MAX_RATE * MAX_AMOUNT)
		lifetime = int(float(rate) / MAX_RATE * (MAX_LIFETIME - 1)) + 1
		scale_amount = MIN_SCALE + float(rate) / MAX_RATE * (MAX_SCALE - MIN_SCALE)


func get_rate() -> int:
	return rate
