extends Area2D



func _on_Plant_area_entered(area):
	if area.is_in_group('building_area'):
		queue_free()
	else:
		$sprite.modulate.a = 0.2


func _on_Plant_area_exited(area):
	$sprite.modulate.a = 1.0
