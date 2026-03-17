## Area-based ongoing damage hitbox for 3D games.
## Applies damage periodically while entities remain inside the area.
class_name OngoingDamageHitbox3D
extends Area3D

@export_group("Damage Settings")
@export var damage: DamageType
@export var multiplier: float = 1.0
@export var wait_damage: float = 1.0

@export_group("Life Cycle")
@export var auto_remove: bool = false
@export var wait_time: float = 20.0

@export_group("Advanced")
@export var apply_modifiers_on_enter: bool = true

class HitTarget:
	var node: Node3D
	var hurtbox: Hurtbox3D
	var health_component: HealthComponent
	var last_hit_time: float = 0.0
	var modifiers_applied: bool = false

var _targets_in_area: Array[HitTarget] = []
var _timer_damage: Timer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if auto_remove:
		_start_self_destruct()

func _start_self_destruct() -> void:
	await get_tree().create_timer(wait_time).timeout
	if is_instance_valid(self):
		body_entered.disconnect(_on_body_entered)
		body_exited.disconnect(_on_body_exited)
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	var health_comp = HealthComponent.get_health_component(body)
	if health_comp == null:
		print("[OngoingDamageHitbox3D] No HealthComponent found on: ", body.name)
		return
	
	var hit_target = HitTarget.new()
	hit_target.node = body
	hit_target.health_component = health_comp
	hit_target.hurtbox = _get_hurtbox_from_body(body)
	
	_targets_in_area.append(hit_target)
	
	if apply_modifiers_on_enter and not hit_target.modifiers_applied:
		_apply_modifiers(body)
		hit_target.modifiers_applied = true
	
	if _targets_in_area.size() > 0 and not is_instance_valid(_timer_damage):
		_timer_damage = Timer.new()
		add_child(_timer_damage)
		_timer_damage.wait_time = wait_damage
		_timer_damage.timeout.connect(_on_recurre_damage)
		_timer_damage.start()
		print("[OngoingDamageHitbox3D] Damage timer started")

func _on_body_exited(body: Node3D) -> void:
	for hit_target in _targets_in_area:
		if hit_target.node == body:
			_targets_in_area.erase(hit_target)
			break
	
	if _targets_in_area.size() == 0 and is_instance_valid(_timer_damage):
		_timer_damage.stop()
		_timer_damage.queue_free()
		_timer_damage = null

func _on_recurre_damage() -> void:
	for hit_target in _targets_in_area:
		if damage == null or not is_instance_valid(hit_target.health_component):
			continue
		
		var final_damage: float = damage.damage * multiplier
		
		if hit_target.hurtbox:
			var hurtbox_mult: float = hit_target.hurtbox.get_damage_multiplier()
			if hurtbox_mult != 1.0:
				print("[OngoingDamageHitbox3D] Hurtbox '%s' multiplier: x%.2f" % [hit_target.hurtbox.get_zone_name(), hurtbox_mult])
				final_damage *= hurtbox_mult
		
		hit_target.health_component.take_damage(final_damage, self, hit_target.hurtbox)
		
		if not apply_modifiers_on_enter:
			_apply_modifiers(hit_target.node)
		
		print("[OngoingDamageHitbox3D] Ongoing damage to %s: %.1f" % [hit_target.node.name, final_damage])

func _get_hurtbox_from_body(body: Node3D) -> Hurtbox3D:
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area is Hurtbox3D and area.get_parent() == body and area.can_be_hit:
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
