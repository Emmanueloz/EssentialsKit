@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree():
	# Registrar la entidad base es vital para que otras clases la reconozcan como tipo
	add_custom_type("HealthEntity", "CharacterBody3D", preload("res://addons/essentialskit/nodes/health_entity.gd"), null)
	add_custom_type("DamageHitbox", "Area3D", preload("res://addons/essentialskit/nodes/damage_hitbox.gd"),null)
	add_custom_type("DamageType", "Resource", preload("res://addons/essentialskit/resource/damage_type.gd"),null)

func _exit_tree():
	remove_custom_type("HealthEntity")
	remove_custom_type("DamageHitbox")
	remove_custom_type("DamageType")
