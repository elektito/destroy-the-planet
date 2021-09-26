extends Area2D

export(Texture) var texture : Texture setget set_texture, get_texture

var world

func init(_world):
	world = _world


func set_texture(value : Texture):
	$sprite.texture = value
	$destruction_particles.texture = value


func get_texture() -> Texture:
	return $sprite.texture


func _on_Plant_area_entered(area : Area2D):
	if area.is_in_group('building_area'):
		print('plant destruct ', world.deserializing)
		if world.deserializing:
			# do not show destruction animation if this is happening when we're
			# loading the game.
			_on_free_timer_timeout()
		else:
			$sprite.visible = false
			$destruction_particles.emitting = true
			
			# free in twice the particles lifetime to make sure all particles have
			# vanished.
			$free_timer.start($destruction_particles.lifetime * 2)
	else:
		$sprite.modulate.a = 0.2


func _on_Plant_area_exited(_area):
	$sprite.modulate.a = 1.0


func _on_free_timer_timeout():
	queue_free()
