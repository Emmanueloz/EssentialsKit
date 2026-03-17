## Base class for all modifiers (buffs/debuffs) that can be applied to entities.
## Subclasses like HealthModifier provide specific health modifications.
class_name Modifier
extends Resource

## Defines how the modifier value is applied to the base stat.
enum ModifierType {
	ADDITIVE,       ## Adds value: current + value (e.g., +10 health)
	SUBTRACTIVE,    ## Subtracts value: current - value (e.g., -5 speed)
	MULTIPLICATIVE, ## Multiplies value: current * value (e.g., x1.5 damage)
	DIVISIVE        ## Divides value: current / value (e.g., /2, with protection against division by zero)
}

## Defines how multiple modifiers of the same type stack.
enum StackType {
	ADD,      ## Stacks additively with existing modifiers of the same name
	REPLACE,  ## Replaces any existing modifier with the same name
	IGNORE    ## Doesn't stack - ignores if a modifier with the same name already exists
}

## Name identifier for this modifier (used for stacking logic).
@export var name: String
## Duration in seconds. -1 means permanent (infinite).
@export var duration: float = -1.0
## How the modifier value affects the stat.
@export var modifier_type: ModifierType = ModifierType.ADDITIVE
## How multiple modifiers of the same name should stack.
@export var stack_type: StackType = StackType.ADD
## Optional icon for UI display.
@export var icon: Texture2D
## Description for UI/tooltips.
@export var description: String

## Remaining time before this modifier expires. -1 means permanent.
var time_remaining: float = 0.0
## Whether this modifier is currently active on an entity.
var is_active: bool = false

## Constructor for creating a new modifier.
## @param p_name: The name identifier of the modifier
## @param p_duration: Duration in seconds, -1 for permanent
func _init(p_name: String = "", p_duration: float = -1.0) -> void:
	name = p_name
	duration = p_duration

## Applies this modifier's effect to a base value.
## Override in subclasses to provide custom behavior.
## @param base_value: The original stat value before modification
## @return: The modified value after applying this modifier's effect
func apply_to_value(base_value: float) -> float:
	return base_value

## Called when this modifier is applied to an entity.
## Override to add custom logic (e.g., play sound, trigger effect).
## @param target: The node (usually a character) this modifier is being applied to
func on_apply(target: Node) -> void:
	pass

## Called when this modifier is removed from an entity.
## Override to add cleanup logic.
## @param target: The node this modifier is being removed from
func on_remove(target: Node) -> void:
	pass

## Called every frame while this modifier is active.
## Override to add per-frame logic (e.g., damage over time).
## @param target: The node this modifier is active on
## @param delta: Time elapsed since last frame
func on_tick(target: Node, delta: float) -> void:
	pass
