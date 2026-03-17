## Component that provides defense/mitigation to an entity.
## Can be attached as a child of HealthComponent to modify incoming damage.
## Includes durability system - if durability reaches 0, defense stops working.
class_name DefenseComponent
extends Node

## Amount of damage reduction (0.0 = no reduction, 1.0 = full reduction).
@export_range(0.0, 1.0) var defense_value: float = 0.0
## Probability of applying defense (0.0 = never, 1.0 = always).
@export_range(0.0, 1.0) var defense_chance: float = 1.0
## Number of times defense can be used (-1 = infinite).
## When durability reaches 0, the component is removed and broken signal is emitted.
@export var durability: float = -1.0
## If true, the component automatically removes itself when durability reaches 0.
@export var auto_remove: bool = true

signal defense_applied(original_damage: float, reduced_damage: float)
signal defense_failed(original_damage: float)
signal durability_changed(new_durability: float)
signal broken

var _is_broken: bool = false

func _ready() -> void:
	durability_changed.emit(durability)

func apply_defense(damage: float) -> float:
	if _is_broken or durability == 0:
		print("[DefenseComponent] Defense broken or no durability - no mitigation applied")
		return damage
	
	if randf() > defense_chance:
		print("[DefenseComponent] Defense chance failed (%.0f%% < %.0f%%) - no mitigation" % [randf() * 100, defense_chance * 100])
		defense_failed.emit(damage)
		return damage
	
	var reduced_damage: float = damage * (1.0 - defense_value)
	var actual_reduction: float = damage - reduced_damage
	
	print("[DefenseComponent] Defense applied: %.1f -> %.1f (reduced by %.1f, chance: %.0f%%)" % [damage, reduced_damage, actual_reduction, defense_chance * 100])
	defense_applied.emit(damage, reduced_damage)
	
	_consume_durability()
	
	return reduced_damage

func _consume_durability() -> void:
	if durability < 0:
		return
	
	durability -= 1
	durability_changed.emit(durability)
	
	if durability <= 0:
		_break()

func _break() -> void:
	_is_broken = true
	print("[DefenseComponent] Defense broken! durability depleted.")
	broken.emit()
	
	if auto_remove:
		call_deferred("queue_free")

func get_defense_info() -> Dictionary:
	return {
		"defense_value": defense_value,
		"defense_chance": defense_chance,
		"durability": durability,
		"is_broken": _is_broken
	}

static func get_defense_component(node: Node) -> DefenseComponent:
	if not node:
		return null
	for child in node.get_children():
		if child is DefenseComponent:
			return child
	return null
