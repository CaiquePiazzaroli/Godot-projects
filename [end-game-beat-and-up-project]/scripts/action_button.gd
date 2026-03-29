extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Chamada toda vez que acontece um evento de input (mouse/ teclado etc)
func _input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("interaction"):
		print("Entrar no prédio")


func _on_area_2d_area_entered(_area: Area2D) -> void:
	print($".".name)
	anim.show() # Mostra a animação do botao quando o player entra na area


func _on_area_2d_area_exited(_area: Area2D) -> void:
	anim.hide() # esconde a animação do botao quando o player sai da area
