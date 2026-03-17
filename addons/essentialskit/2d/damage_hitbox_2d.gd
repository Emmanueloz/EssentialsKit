## Area-based damage hitbox for 2D games.
## Detects collisions and applies damage to entities with HealthComponent.
class_name DamageHitbox2D
extends Area2D

@export_group("Damage Settings")
@export var damage: DamageType
@export var multiplier: float = 1.0

@export_group("Life Cycle")
@export var auto_remove: bool = true
@export var wait_time: float = 5.0

@export_group("Advanced")
@export var can_hit_same_target: bool = true
@export var hit_cooldown: float = 0.0
@export var auto_remove_on_hit: bool = false

var _hit_targets: Array[Node2D] = []

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
	if health_comp == null:
		print("[DamageHitbox2D] No HealthComponent found on: ", body.name)
		return
	
	if damage == null:
		print("[DamageHitbox2D] No DamageType assigned!")
		return
	
	if not can_hit_same_target and body in _hit_targets:
		return
	
	var hurtbox = _get_hurtbox_from_body(body)
	
	var final_damage: float = damage.damage * multiplier
	
	if hurtbox:
		var hurtbox_mult: float = hurtbox.get_damage_multiplier()
		if hurtbox_mult != 1.0:
			print("[DamageHitbox2D] Hurtbox '%s' multiplier: x%.2f" % [hurtbox.get_zone_name(), hurtbox_mult])
			final_damage *= hurtbox_mult
	
	health_comp.take_damage(final_damage, self, hurtbox)
	
	_apply_modifiers(body)
	
	if not can_hit_same_target:
		_hit_targets.append(body)
	
	if auto_remove_on_hit and not auto_remove:
		queue_free()

func _get_hurtbox_from_body(body: Node2D) -> Hurtbox2D:
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area is Hurtbox2D and area.get_parent() == body and area.can_be_hit:
			return area
	return null

func _apply_modifiers(target: Node) -> void:
	if damage == null or damage.modifiers_on_hit.size() == 0:
		return
	
	var health_comp = HealthComponent.get_health_component(target)
	if health_comp == null:
		return
	
	for mod in damage.modifiers_on_hit:
		var new_mod: HealthModifier = mod.duplicate()
		new_mod.time_remaining = mod.duration
		health_comp.add_modifier(new_mod)
		print("[DamageHitbox2D] Applied modifier: %s" % mod.name)
