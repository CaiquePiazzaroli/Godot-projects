extends CharacterBody3D

var SPEED : float = 2.0
const JUMP_VELOCITY : float = 4.5
var mouse_sensitivity : float = 0.003
var double_jump: int = 0

# Executado quando o nó é criado na arvore 
func _ready() -> void:
	# Captura o mouse e esconde ele dentro da janela do jogo
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	
	
func _unhandled_input(event: InputEvent) -> void:
	# Verifica se o evento é um movimento do mouse
	if event is InputEventMouseMotion:
		# print("Mexeu o mouse")
		
		# 1. Rotação Horizontal (Gira o CORPO todo)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# 2. Rotação Vertical (Gira apenas a CÂMERA)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		
		# 3. Travar a câmera (Clamp)
		# Isso impede que o personagem dê uma cambalhota completa com o pescoço
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))

## Roda com um limite fixo de frames (60)
func _physics_process(delta: float) -> void:
	
	# Corrida do player
	playerRun(delta)
	
	# Pulo do player
	playerJump()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "foward", "back")
	if(input_dir and !is_on_floor()):
		print("Movimentado e pulando")
	else:
		print("Parada")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# Mecanica de corrida
func playerRun(delta: float) -> void: 
	if Input.is_action_pressed("run"):
		#print("Correndo")
		SPEED = 400 * delta
	else:
		#print("Andando")
		SPEED = 200 * delta

# Mecanica de pulo
func playerJump() -> void:
	if is_on_floor():
		double_jump = 0
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		double_jump +=1
	if Input.is_action_just_pressed("ui_accept") and !is_on_floor() and double_jump == 1:
		velocity.y = JUMP_VELOCITY
		double_jump = 0
