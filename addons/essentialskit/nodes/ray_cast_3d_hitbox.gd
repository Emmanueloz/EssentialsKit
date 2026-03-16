class_name RayCast3DHitbox
extends RayCast3D

@export_group("Damage Settings")
@export var damage: DamageType
@export var multiplier: float = 1.0

@export_group("Life Cycle")
@export var auto_remove: bool = true
@export var wait_time: float = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Iniciamos la cuenta regresiva si auto_remove está activo
	if auto_remove:
		_start_self_destruct()

func _start_self_destruct() -> void:
	# El atajo 'await' es ideal aquí: espera y luego borra
	await get_tree().create_timer(wait_time).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var target = get_collider()
	if target is HealthEntity:
		target.take_damage(10)
	
