class_name DamageHitbox2D
extends Area2D

@export_group("Damage Settings")
@export var damage: DamageType
@export var multiplier: float = 1.0

@export_group("Life Cycle")
@export var auto_remove: bool = true
@export var wait_time: float = 5.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	if auto_remove:
		_start_self_destruct()

func _start_self_destruct() -> void:
	await get_tree().create_timer(wait_time).timeout
	if is_instance_valid(self):
		body_entered.disconnect(_on_body_entered)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	var health_comp = HealthComponent.get_health_component(body)
	if health_comp and damage:
		var final_damage = damage.damage * multiplier
		health_comp.take_damage(final_damage)
		print("Hit: ", body.name, " for ", final_damage, " damage.")
