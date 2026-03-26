extends Camera2D

var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$".".position = player.position + Vector2(100,0)
