extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var player: CharacterBody2D = body
		player.call_deferred("set_weapon", "fixedKey")
		queue_free()
