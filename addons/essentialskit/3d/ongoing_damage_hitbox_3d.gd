class_name OngoingDamageHitbox3D
extends Area3D

@export_group("Damage Settings")
@export var damage: DamageType
@export var multiplier: float = 1.0
@export var wait_damage: float = 5.0

@export_group("Life Cycle")
@export var auto_remove: bool = false
@export var wait_time: float = 20.0

var _health_components_in_area: Array[HealthComponent] = []
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
	if not health_comp:
		return
		
	if not _health_components_in_area.has(health_comp):
		_health_components_in_area.append(health_comp)
		
	if _health_components_in_area.size() > 0 and not is_instance_valid(_timer_damage):
		_timer_damage = Timer.new()
		add_child(_timer_damage)
		_timer_damage.wait_time = wait_damage
		_timer_damage.timeout.connect(_on_recurre_damage)
		_timer_damage.start()

func _on_body_exited(body: Node3D) -> void:
	var health_comp = HealthComponent.get_health_component(body)
	if not health_comp:
		return
		
	_health_components_in_area.erase(health_comp)
	
	if _health_components_in_area.size() == 0 and is_instance_valid(_timer_damage):
		_timer_damage.stop()
		_timer_damage.queue_free()
		_timer_damage = null

func _on_recurre_damage() -> void:
	for health_comp in _health_components_in_area:
		if damage and is_instance_valid(health_comp):
			var final_damage = damage.damage * multiplier
			health_comp.take_damage(final_damage)
			print("Hit (Ongoing): ", health_comp.get_parent().name, " for ", final_damage, " damage.")
