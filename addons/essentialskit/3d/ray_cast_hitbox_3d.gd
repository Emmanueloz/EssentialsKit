class_name RayCastHitbox3D
extends RayCast3D

@export_group("Damage Settings")
@export var damage: DamageType
@export var multiplier: float = 1.0

@export_group("Life Cycle")
@export var auto_remove: bool = true
@export var wait_time: float = 5.0

func _ready() -> void:
	if auto_remove:
		_start_self_destruct()

func _start_self_destruct() -> void:
	await get_tree().create_timer(wait_time).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta: float) -> void:
	var target = get_collider()
	if target:
		var health_comp = HealthComponent.get_health_component(target as Node)
		if health_comp and damage:
			var final_damage = damage.damage * multiplier
			health_comp.take_damage(final_damage)
