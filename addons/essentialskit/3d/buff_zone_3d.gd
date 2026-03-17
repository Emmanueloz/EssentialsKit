## Area that applies health modifiers (buffs/debuffs) to entities that enter it.
## Works with HealthComponent - no longer separates buffs from debuffs.
class_name BuffZone3D
extends Area3D

@export_group("Modifier Settings")
@export var modifiers: Array[HealthModifier]

@export_group("Behavior")
@export var apply_on_enter: bool = true
@export var apply_periodically: bool = false
@export var apply_interval: float = 1.0
@export var remove_on_exit: bool = true

@export_group("Visual")
@export var debug_color: Color = Color(0, 1, 0, 0.3)

var _targets_in_area: Array[Node3D] = []
var _applied_modifiers: Dictionary = {}
var _timer: Timer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if apply_periodically:
		_timer = Timer.new()
		add_child(_timer)
		_timer.wait_time = apply_interval
		_timer.timeout.connect(_on_apply_periodic)
		_timer.start()

func _on_body_entered(body: Node3D) -> void:
	var health_comp = HealthComponent.get_health_component(body)
	if health_comp == null:
		print("[BuffZone3D] No HealthComponent found on: ", body.name, " - modifiers not applied")
		return
	
	_targets_in_area.append(body)
	_applied_modifiers[body] = []
	
	if apply_on_enter:
		_apply_all_modifiers(body, health_comp)
		print("[BuffZone3D] Applied modifiers to: ", body.name)

func _on_body_exited(body: Node3D) -> void:
	_targets_in_area.erase(body)
	
	if remove_on_exit:
		var health_comp = HealthComponent.get_health_component(body)
		if health_comp != null and body in _applied_modifiers:
			for modifier in _applied_modifiers[body]:
				health_comp.remove_modifier(modifier)
				print("[BuffZone3D] Removed modifier '%s' from: %s" % [modifier.name, body.name])
			_applied_modifiers.erase(body)

func _apply_all_modifiers(body: Node3D, health_comp: HealthComponent) -> void:
	var modifiers_to_apply: Array[HealthModifier] = []
	
	for mod in modifiers:
		var new_modifier: HealthModifier = mod.duplicate()
		new_modifier.time_remaining = mod.duration
		modifiers_to_apply.append(new_modifier)
	
	for modifier in modifiers_to_apply:
		health_comp.add_modifier(modifier)
	
	if body in _applied_modifiers:
		_applied_modifiers[body] = modifiers_to_apply

func _on_apply_periodic() -> void:
	for body in _targets_in_area:
		var health_comp = HealthComponent.get_health_component(body)
		if health_comp != null:
			_apply_all_modifiers(body, health_comp)
