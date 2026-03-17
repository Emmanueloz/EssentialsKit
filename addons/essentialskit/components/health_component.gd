## Component that manages entity health/durability, damage, healing, and buffs.
## Supports optional DefenseComponent for modular defense/mitigation.
class_name HealthComponent
extends Node

signal health_changed(new_health: float, old_health: float)
signal died
signal damage_received(amount: float, final_damage: float, source: Node)
signal modifier_added(modifier: HealthModifier)
signal modifier_removed(modifier: HealthModifier)
signal max_health_changed(new_max: float, old_max: float)

@export var max_health: float = 100.0
@export var invincibility_duration: float = 0.0

@export_group("Advanced")
@export var is_invincible: bool = false

var current_health: float
var _last_damage_time: float = 0.0
var _modifiers: Array[HealthModifier] = []
var _max_health_cache: float = 0.0
var _damage_received_cache: float = 1.0

func _ready() -> void:
	current_health = max_health
	_max_health_cache = max_health

func _process(delta: float) -> void:
	_process_modifiers(delta)

func get_defense() -> float:
	return 0.0

func _get_defense_component() -> DefenseComponent:
	return DefenseComponent.get_defense_component(self)

func take_damage(amount: float, source: Node = null, hurtbox: Node = null) -> void:
	if current_health <= 0:
		return
	
	if is_invincible:
		print("[HealthComponent] Damage blocked - entity is invincible")
		return
	
	if invincibility_duration > 0:
		var current_time: float = Time.get_ticks_msec() / 1000.0
		if current_time - _last_damage_time < invincibility_duration:
			print("[HealthComponent] Damage blocked - invincibility frames active")
			return
		_last_damage_time = current_time
	
	var damage_multiplier: float = 1.0
	if hurtbox and hurtbox.has_method("get_damage_multiplier"):
		damage_multiplier = hurtbox.get_damage_multiplier()
	
	var final_damage: float = amount * damage_multiplier
	
	if damage_multiplier != 1.0:
		print("[HealthComponent] Hurtbox multiplier: x%.2f (base: %.1f)" % [damage_multiplier, amount])
	
	final_damage *= _damage_received_cache
	
	var defense_comp: DefenseComponent = _get_defense_component()
	if defense_comp:
		var original_damage: float = final_damage
		final_damage = defense_comp.apply_defense(final_damage)
		if final_damage < original_damage:
			print("[HealthComponent] DefenseComponent reduced damage: %.1f -> %.1f" % [original_damage, final_damage])
	else:
		var defense_percent: float = get_defense()
		if defense_percent > 0:
			var damage_after_defense: float = final_damage * (1.0 - defense_percent)
			print("[HealthComponent] Defense: %.1f%% (reduced from %.1f to %.1f)" % [defense_percent * 100, final_damage, damage_after_defense])
			final_damage = damage_after_defense
	
	final_damage = max(0, final_damage)
	
	var old_health: float = current_health
	current_health -= final_damage
	
	print("[HealthComponent] Damage: %.1f (multiplier: x%.2f, health: %.1f -> %.1f)" % [final_damage, damage_multiplier, old_health, current_health])
	
	health_changed.emit(current_health, old_health)
	damage_received.emit(amount, final_damage, source)
	
	if current_health <= 0:
		die()

func heal(amount: float) -> void:
	if current_health <= 0:
		return
	
	var old_health: float = current_health
	current_health = min(current_health + amount, max_health)
	print("[HealthComponent] Healed: +%.1f (health: %.1f -> %.1f)" % [amount, old_health, current_health])
	health_changed.emit(current_health, old_health)

func get_max_health() -> float:
	return _max_health_cache

func set_max_health(value: float, heal_full: bool = false) -> void:
	var old_max: float = _max_health_cache
	_max_health_cache = value
	
	if heal_full:
		current_health = value
	
	print("[HealthComponent] Max health changed: %.1f -> %.1f" % [old_max, value])
	max_health_changed.emit(_max_health_cache, old_max)

func die() -> void:
	print("[HealthComponent] Entity died!")
	died.emit()

func add_modifier(modifier: HealthModifier) -> void:
	if modifier.stack_type == Modifier.StackType.IGNORE:
		for existing in _modifiers:
			if existing.name == modifier.name and existing.health_type == modifier.health_type:
				print("[HealthComponent] Modifier '%s' ignored (already exists with IGNORE stack type)" % modifier.name)
				return
	
	if modifier.stack_type == Modifier.StackType.REPLACE:
		remove_modifier_by_name(modifier.name)
	
	_modifiers.append(modifier)
	modifier.on_apply(self)
	modifier_added.emit(modifier)
	_recalculate_modifiers()
	print("[HealthComponent] Modifier added: %s" % modifier.name)

func remove_modifier(modifier: HealthModifier) -> void:
	if modifier in _modifiers:
		_modifiers.erase(modifier)
		modifier.on_remove(self)
		modifier_removed.emit(modifier)
		_recalculate_modifiers()
		print("[HealthComponent] Modifier removed: %s" % modifier.name)

func remove_modifier_by_name(name: String) -> void:
	var to_remove: Array[HealthModifier] = []
	for modifier in _modifiers:
		if modifier.name == name:
			to_remove.append(modifier)
	
	for modifier in to_remove:
		remove_modifier(modifier)

func get_active_modifiers() -> Array[HealthModifier]:
	return _modifiers.duplicate()

func has_modifier(modifier_name: String) -> bool:
	for modifier in _modifiers:
		if modifier.name == modifier_name:
			return true
	return false

func _process_modifiers(delta: float) -> void:
	var to_remove: Array[HealthModifier] = []
	
	for modifier in _modifiers:
		if modifier.duration > 0:
			modifier.time_remaining -= delta
			modifier.on_tick(self, delta)
			if modifier.time_remaining <= 0:
				to_remove.append(modifier)
				print("[HealthComponent] Modifier '%s' expired" % modifier.name)
	
	for modifier in to_remove:
		remove_modifier(modifier)

func _recalculate_modifiers() -> void:
	_max_health_cache = max_health
	var _current_health_cache = current_health
	_damage_received_cache = 1.0
	
	for modifier in _modifiers:
		match modifier.health_type:
			HealthModifier.HealthType.MAX_HEALTH:
				_max_health_cache = modifier.apply_to_value(_max_health_cache)
			HealthModifier.HealthType.CURRENT_HEALTH:
				_current_health_cache = modifier.apply_to_value(current_health)
			HealthModifier.HealthType.DAMAGE_RECEIVED:
				_damage_received_cache = modifier.apply_to_value(_damage_received_cache)
	
	if _max_health_cache != max_health:
		max_health_changed.emit(_max_health_cache, max_health)
	if _current_health_cache != current_health and _current_health_cache <= _max_health_cache:
		current_health = _current_health_cache
		health_changed.emit(current_health,_current_health_cache)
	elif _current_health_cache != current_health:
		current_health = _max_health_cache
		health_changed.emit(current_health,_current_health_cache)
		

static func get_health_component(node: Node) -> HealthComponent:
	if not node:
		return null
	for child in node.get_children():
		if child is HealthComponent:
			return child
	return null
