extends Area2D

@onready var player: CharacterBody2D = $".."

func _on_area_entered(_area: Area2D) -> void:
	if player.health == 0:
		player.go_to_death_state()
		player.collision_layer = 0 # Altera a camada de colisão para nao colidir mais
	else:
		player.call_deferred("take_damage") # Leva dano
