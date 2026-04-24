extends Area2D
@onready var enemy_zombie: CharacterBody2D = $".."

func _on_area_entered(area: Area2D) -> void:
	if !(area.owner == self.owner):
		enemy_zombie.go_to_take_damage_state()
		enemy_zombie.call_deferred("take_damage")
