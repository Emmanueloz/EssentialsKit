class_name Hurtbox2D
extends Area2D

@export var zone_name: String = "body"
@export var damage_multiplier: float = 1.0
@export var can_be_hit: bool = true

func get_damage_multiplier() -> float:
	return damage_multiplier

func get_zone_name() -> String:
	return zone_name

static func get_hurtbox(node: Node2D) -> Hurtbox2D:
	if not node:
		return null
	for child in node.get_children():
		if child is Hurtbox2D:
			return child
	return null

static func get_all_hurtboxes(node: Node2D) -> Array[Hurtbox2D]:
	var hurtboxes: Array[Hurtbox2D] = []
	if not node:
		return hurtboxes
	for child in node.get_children():
		if child is Hurtbox2D:
			hurtboxes.append(child)
	return hurtboxes
