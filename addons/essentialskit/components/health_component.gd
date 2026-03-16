class_name HealthComponent
extends Node

@export var max_health: float = 100.0

var current_health: float

signal health_changed(new_health: float)
signal died

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if current_health <= 0:
		return
		
	current_health -= amount
	health_changed.emit(current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	died.emit()

static func get_health_component(node: Node) -> HealthComponent:
	if not node:
		return null
	for child in node.get_children():
		if child is HealthComponent:
			return child
	return null
