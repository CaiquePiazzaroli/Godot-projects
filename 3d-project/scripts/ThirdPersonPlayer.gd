extends CharacterBody3D

#importando o nome camera
@onready var camera = $Camera3D

# Exporta a variável para ser acessada no inspector
@export var player_speed: int = 5
@export var mouse_sensitivity: float = 0.005;

func handle_mouse(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		print("Mexeu mouse")
		$".".rotate_y(-event.relative.x * mouse_sensitivity)
		
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)

func handle_move(delta: float) -> void:
	var input_user := Input.get_vector("left","right","foward", "back")
	if input_user:
		# Adiciona posição ao eixo y do personagem (para frente ou para tras)
		position.z += input_user.y * delta * player_speed 
		# Adiciona posição ao eixo x do personagem (Um lado para outro)
		position.x += input_user.x * delta * player_speed

func _physics_process(delta: float) -> void:
	handle_move(delta)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	handle_mouse(event)
