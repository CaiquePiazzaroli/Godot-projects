extends Camera3D

var playerPosition: Vector3 
var heightFromPlayer: int = -2
var distanceFromPlayer: int = -6
var rodateCameraDegree: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation.x = -0.45 # Define the rotation of camera


func _process(delta: float) -> void:
	playerPosition = get_tree().get_nodes_in_group("player").get(0).position
	position = playerPosition - Vector3(0, heightFromPlayer, distanceFromPlayer)
