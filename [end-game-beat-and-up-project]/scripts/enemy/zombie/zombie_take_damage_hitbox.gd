extends Area2D

@onready var enemy_zombie: CharacterBody2D = $".."

func _on_area_entered(_area: Area2D) -> void:
	enemy_zombie.go_to_take_damage_state()
	enemy_zombie.call_deferred("take_damage")
