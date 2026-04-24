extends CanvasLayer

var player: CharacterBody2D
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	get_player()
	get_player_health()

func get_player() -> void:
	if get_tree().get_nodes_in_group("player")[0] is CharacterBody2D:
		player = get_tree().get_nodes_in_group("player")[0]
	else:
		print("Player not found in scene")
		get_tree().quit()

func get_player_health() -> void:
	progress_bar.max_value = player.max_health
	progress_bar.value = player.health
	
func update_value(value:int) -> void:
	progress_bar.value = value

func _on_progress_bar_changed() -> void:
	progress_bar.value = player.health
