# EssentialsKit

Sistema de gestión de vida, daño y modificación de entidades para Godot 4.x.

## Características

- **HealthComponent**: Componente central para gestionar vida/durabilidad de entidades
- **DefenseComponent**: Sistema modular de defensa/mitigación con durabilidad
- **Hitboxes**: Detección de daño flexible (Area2D/3D y RayCast2D/3D)
- **Hurtboxes**: Zonas de vulnerabilidad con multiplicadores de daño
- **BuffZones**: Áreas que aplican modificadores a entidades
- **HealthModifier**: Sistema de modificadores para buffs/debuffs

## Instalación

1. Descarga o clona el addon en tu proyecto
2. Habilita el addon en `Project > Project Settings > Plugins`
3. ¡Listo para usar!

## Uso Rápido

### HealthComponent

Añade un nodo `HealthComponent` a tu personaje o entidad:

```gdscript
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
    health_component.health_changed.connect(_on_health_changed)
    health_component.died.connect(_on_died)

func take_damage(amount: float) -> void:
    health_component.take_damage(amount)

func heal(amount: float) -> void:
    health_component.heal(amount)
```

### Hurtboxes

Añade nodos `Hurtbox2D` o `Hurtbox3D` como hijos de tu personaje:

- `zone_name`: Nombre de la zona (ej: "head", "body")
- `damage_multiplier`: Multiplicador de daño (2.0 = doble daño)
- `can_be_hit`: Si puede ser alcanzado

### Hitboxes

#### DamageHitbox (Area2D/3D)
Detecta colisiones y aplica daño:

```gdscript
# En el editor
@export var damage: DamageType  # Recurso con el daño
@export var multiplier: float = 1.0
@export var auto_remove: bool = true
```

#### RayCastHitbox (RayCast2D/3D)
Para proyectiles y ataques direccionales:

```gdscript
@export var continuous_damage: bool = false  # Daño continuo
@export var auto_remove_on_hit: bool = true  # Eliminar al impactar
```

### DefenseComponent

Añade como hijo de HealthComponent para defensa modular:

```gdscript
# En el editor
@export var defense_value: float = 0.5    # 50% reducción
@export var defense_chance: float = 1.0   # 100% probabilidad
@export var durability: float = 3          # 3 usos
```

### BuffZones

Añade áreas que aplican modificadores:

```gdscript
# En el editor
@export var modifiers: Array[HealthModifier]
@export var remove_on_exit: bool = true
```

### HealthModifier (Recurso)

Crea un recurso `HealthModifier` para buffs/debuffs:

- **MAX_HEALTH**: Modifica la vida máxima
- **CURRENT_HEALTH**: Daño o curación instantánea
- **DAMAGE_RECEIVED**: Multiplicador de daño recibido

### DamageType (Recurso)

Crea un recurso para definir tipos de daño:

```gdscript
@export var name: String
@export var damage: float
@export var critical_multiplier: float = 1.5
@export var critical_chance: float = 0.0
@export var modifiers_on_hit: Array[HealthModifier]
```

## Señales

### HealthComponent
- `health_changed(new_health, old_health)`
- `died`
- `damage_received(amount, final_damage, source)`
- `modifier_added(modifier)`
- `modifier_removed(modifier)`
- `max_health_changed(new_max, old_max)`

### DefenseComponent
- `defense_applied(original_damage, reduced_damage)`
- `defense_failed(original_damage)`
- `durability_changed(new_durability)`
- `broken`

## Flujo de Daño

```
Hitbox detecta colisión
    ↓
Obtiene el Hurtbox específico alcanzado
    ↓
Aplica multiplicador del Hurtbox
    ↓
Aplica modificadores de daño recibido
    ↓
Busca DefenseComponent o usa get_defense()
    ↓
Aplica reducción de daño
    ↓
HealthComponent recibe daño final
    ↓
Emite señales y verifica muerte
```

## Ejemplos

Ver las escenas de ejemplo en `src/2d/` y `src/3d/`:

- **2D**: `main_2d.tscn` - Demo con todos los tipos de hitboxes
- **3D**: `main_3d.tscn` - Demo 3D con sistemas equivalentes

## Requisitos

- Godot 4.x
- GDScript

## Licencia

MIT License
