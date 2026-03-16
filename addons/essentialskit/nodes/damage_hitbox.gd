class_name DamageHitbox
extends Area3D

@export_group("Damage Settings")
@export var damage: DamageType
@export var multiplier: float = 1.0

@export_group("Life Cycle")
@export var auto_remove: bool = true
@export var wait_time: float = 5


func _ready() -> void:
	# Conectamos la señal por código para que siempre funcione
	body_entered.connect(_on_body_entered)
	
	# Iniciamos la cuenta regresiva si auto_remove está activo
	if auto_remove:
		_start_self_destruct()

func _start_self_destruct() -> void:
	# El atajo 'await' es ideal aquí: espera y luego borra
	await get_tree().create_timer(wait_time).timeout
	body_entered.disconnect(_on_body_entered)
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	print("body entered")
	if body is HealthEntity:
		var final_damage = damage.damage * multiplier
		body.take_damage(final_damage)
		print("Hit: ", body.name, " for ", final_damage, " damage.")
