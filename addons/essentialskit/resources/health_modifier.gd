## Extends Modifier to provide health-specific modifications.
## Used to modify health values like max health, current health, and damage received.
class_name HealthModifier
extends Modifier

enum HealthType {
	MAX_HEALTH,
	CURRENT_HEALTH,
	DAMAGE_RECEIVED
}

@export var health_type: HealthType = HealthType.MAX_HEALTH
@export var value: float = 0.0
@export var priority: int = 0

func _init(p_name: String = "", p_duration: float = -1.0, p_health_type: HealthType = HealthType.MAX_HEALTH, p_value: float = 0.0) -> void:
	super._init(p_name, p_duration)
	health_type = p_health_type
	value = p_value

func apply_to_value(base_value: float) -> float:
	match health_type:
		HealthType.MAX_HEALTH:
			return base_value + value
		HealthType.CURRENT_HEALTH:
			return base_value + value
		HealthType.DAMAGE_RECEIVED:
			return base_value * value
	return base_value

static func get_health_type_name(ht: HealthType) -> String:
	match ht:
		HealthType.MAX_HEALTH: return "max_health"
		HealthType.CURRENT_HEALTH: return "current_health"
		HealthType.DAMAGE_RECEIVED: return "damage_received"
	return ""

static func health_type_from_string(s: String) -> HealthType:
	match s:
		"max_health": return HealthType.MAX_HEALTH
		"current_health": return HealthType.CURRENT_HEALTH
		"damage_received": return HealthType.DAMAGE_RECEIVED
		_: return HealthType.MAX_HEALTH
