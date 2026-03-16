class_name OngoingDamageHitbox
extends Area3D

@export_group("Damage Settings")
@export var damage: DamageType
@export var multiplier: float = 1.0
@export var wait_damage:float = 5.0

@export_group("Life Cycle")
@export var auto_remove: bool = false
@export var wait_time: float = 20

var _entity_in_area: bool = false
var _bodys_entitys: Array[HealthEntity] = []

var _timer_damage: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Iniciamos la cuenta regresiva si auto_remove está activo
	if auto_remove:
		_start_self_destruct()

func _start_self_destruct() -> void:
	# El atajo 'await' es ideal aquí: espera y luego borra
	await get_tree().create_timer(wait_time).timeout
	body_entered.disconnect(_on_body_entered)
	body_exited.disconnect(_on_body_exited)
	queue_free()

func _on_body_entered(body:Node3D):
	if body is not HealthEntity:
		return
	print("body")
	print(body)
	_bodys_entitys.append(body) 
	_entity_in_area = true
	_timer_damage = Timer.new()
	add_child(_timer_damage)
	_timer_damage.wait_time = wait_damage
	_timer_damage.timeout.connect(_on_recurre_damage)
	_timer_damage.start()
	print("Timer start")
	
func _on_body_exited(body:Node3D):
	if body is not HealthEntity:
		return
	var idx= _bodys_entitys.bsearch(body)
	_bodys_entitys.remove_at(idx)
	
	if len(_bodys_entitys) != 0 and not _entity_in_area:
		return
	
	_entity_in_area = false
	_timer_damage.stop()
	_timer_damage.queue_free()
	_timer_damage = null
	print("Timer stop")
	
func _on_recurre_damage():
	for body in _bodys_entitys:
		var final_damage = damage.damage * multiplier
		body.take_damage(final_damage)
		print("Hit: ", body.name, " for ", final_damage, " damage.")
