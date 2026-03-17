class_name DamageType
extends Resource

@export var name: String
@export var damage: float
@export var critical_multiplier: float = 1.5
@export var critical_chance: float = 0.0
@export_group("On Hit Modifiers")
@export var modifiers_on_hit: Array[HealthModifier]
