extends Camera2D

var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_player_node()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$".".position = player.position


func get_player_node():
	var nodes: Array[Node] = get_tree().get_nodes_in_group("player")
	if nodes.size() == 0:
		print("Player not found!")
		return
	player = nodes[0]
