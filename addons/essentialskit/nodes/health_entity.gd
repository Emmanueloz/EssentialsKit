class_name HealthEntity
extends CharacterBody3D

@export var max_health:float = 100
var current_health: float

signal health_changed(new_health:float)
signal died

func _ready():
	current_health = max_health

func take_damage(amount: float):
	current_health -= amount
	health_changed.emit(current_health)
	if current_health <= 0:
		die()

func die():
	died.emit()
	
