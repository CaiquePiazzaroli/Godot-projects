extends Node2D

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var character_body: CharacterBody2D

func _ready() -> void:
	get_character_body()
	health_label.text = str(character_body.max_health)
	health_bar.max_value = character_body.max_health
	set_visible_bar(character_body.isHealthVisible)

func get_character_body() -> CharacterBody2D: 
	if get_parent() is CharacterBody2D:
		character_body = get_parent() 
	else:
		print("Não foi possivel encontrar o character body")
		get_tree().quit()
	return character_body

func get_health_bar() -> ProgressBar: 
	return health_bar

func set_visible_bar(isBarVisible: bool) -> void: 
	health_bar.visible = isBarVisible
	health_label.visible = isBarVisible

func take_damage() -> void:
	health_bar.value -= 1
	health_label.text = str(health_bar.value)

func _on_health_bar_value_changed(value: float) -> void:
	if value == 0:
		character_body.call_deferred("go_to_death_state")
