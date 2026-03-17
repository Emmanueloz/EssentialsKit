## RayCast-based damage hitbox for 2D games.
## Detects collisions and applies damage to entities with HealthComponent.
class_name RayCastHitbox2D
extends RayCast2D

@export_group("Damage Settings")
@export var damage: DamageType
@export var multiplier: float = 1.0

@export_group("Life Cycle")
@export var auto_remove: bool = true
@export var wait_time: float = 5.0

@export_group("Advanced")
@export var can_hit_same_target: bool = false
@export var auto_remove_on_hit: bool = false
@export var continuous_damage: bool = false
@export var damage_interval: float = 1.0

var _hit_targets: Array[Node2D] = []
var _continuous_targets: Dictionary = {}
var _self_destruct_timer: Timer = null

func _ready() -> void:
	if auto_remove:
		_start_self_destruct()

func _start_self_destruct() -> void:
	await get_tree().create_timer(wait_time).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta: float) -> void:
	if not is_colliding():
		_process_continuous_damage_end()
		return
	
	var target = get_collider()
	if target == null:
		return
	
	var health_comp = HealthComponent.get_health_component(target as Node)
	if health_comp == null:
		return
	
	if damage == null:
		print("[RayCastHitbox2D] No DamageType assigned!")
		return
	
	if not can_hit_same_target and target in _hit_targets:
		return
	
	if continuous_damage:
		_handle_continuous_damage(target, health_comp)
	else:
		_apply_single_damage(target, health_comp)

func _apply_single_damage(target: Node2D, health_comp: HealthComponent) -> void:
	var hurtbox = _get_hurtbox_from_body(target)
	var final_damage: float = damage.damage * multiplier
	
	if hurtbox:
		var hurtbox_mult: float = hurtbox.get_damage_multiplier()
		if hurtbox_mult != 1.0:
			print("[RayCastHitbox2D] Hurtbox '%s' multiplier: x%.2f" % [hurtbox.get_zone_name(), hurtbox_mult])
			final_damage *= hurtbox_mult
	
	health_comp.take_damage(final_damage, self, hurtbox)
	
	_apply_modifiers(target)
	
	if not can_hit_same_target:
		_hit_targets.append(target)
	
	if auto_remove_on_hit:
		queue_free()

func _handle_continuous_damage(target: Node2D, health_comp: HealthComponent) -> void:
	if not target in _continuous_targets:
		var timer = Timer.new()
		timer.wait_time = damage_interval
		timer.one_shot = false
		timer.timeout.connect(func(): _apply_continuous_damage(target, health_comp))
		add_child(timer)
		timer.start()
		
		_continuous_targets[target] = {
			"timer": timer,
			"hurtbox": _get_hurtbox_from_body(target)
		}
		
		_apply_continuous_damage(target, health_comp)

func _apply_continuous_damage(target: Node2D, health_comp: HealthComponent) -> void:
	if not is_instance_valid(health_comp):
		_stop_continuous_damage(target)
		return
	
	var hurtbox = _continuous_targets[target].get("hurtbox")
	var final_damage: float = damage.damage * multiplier
	
	if hurtbox:
		var hurtbox_mult: float = hurtbox.get_damage_multiplier()
		if hurtbox_mult != 1.0:
			final_damage *= hurtbox_mult
	
	health_comp.take_damage(final_damage, self, hurtbox)
	
	print("[RayCastHitbox2D] Continuous damage to %s: %.1f" % [target.name, final_damage])

func _process_continuous_damage_end() -> void:
	for target in _continuous_targets.keys():
		if not is_colliding() or get_collider() != target:
			_stop_continuous_damage(target)

func _stop_continuous_damage(target: Node2D) -> void:
	if target in _continuous_targets:
		var data = _continuous_targets[target]
		if "timer" in data and is_instance_valid(data.timer):
			data.timer.stop()
			data.timer.queue_free()
		_continuous_targets.erase(target)

func _get_hurtbox_from_body(body: Node2D) -> Hurtbox2D:
	var ray_point = get_collision_point()
	var hurtboxes = _get_all_hurtboxes(body)
	
	var closest: Hurtbox2D = null
	var closest_dist: float = INF
	
	for hurtbox in hurtboxes:
		if not hurtbox.can_be_hit:
			continue
		
		var shape_node = _get_child_of_type(hurtbox, CollisionShape2D)
		if shape_node == null:
			continue
		
		var center = shape_node.get_global_position()
		var dist = ray_point.distance_to(center)
		if dist < closest_dist:
			closest_dist = dist
			closest = hurtbox
	
	return closest

func _get_all_hurtboxes(body: Node2D) -> Array[Hurtbox2D]:
	var result: Array[Hurtbox2D] = []
	for child in body.get_children():
		if child is Hurtbox2D and child.can_be_hit:
			result.append(child)
	return result

func _get_child_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
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
		print("[RayCastHitbox2D] Applied modifier: %s" % mod.name)

func _exit_tree() -> void:
	for target in _continuous_targets.keys():
		_stop_continuous_damage(target)
	_continuous_targets.clear()
