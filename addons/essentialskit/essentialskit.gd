@tool
extends EditorPlugin


func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree():
	# Components
	add_custom_type("HealthComponent", "Node", preload("res://addons/essentialskit/components/health_component.gd"), null)
	
	# Resources
	add_custom_type("DamageType", "Resource", preload("res://addons/essentialskit/resources/damage_type.gd"), null)
	
	# 3D Hitboxes
	add_custom_type("DamageHitbox3D", "Area3D", preload("res://addons/essentialskit/3d/damage_hitbox_3d.gd"), null)
	add_custom_type("OngoingDamageHitbox3D", "Area3D", preload("res://addons/essentialskit/3d/ongoing_damage_hitbox_3d.gd"), null)
	add_custom_type("RayCastHitbox3D", "RayCast3D", preload("res://addons/essentialskit/3d/ray_cast_hitbox_3d.gd"), null)
	
	# 2D Hitboxes
	add_custom_type("DamageHitbox2D", "Area2D", preload("res://addons/essentialskit/2d/damage_hitbox_2d.gd"), null)
	add_custom_type("OngoingDamageHitbox2D", "Area2D", preload("res://addons/essentialskit/2d/ongoing_damage_hitbox_2d.gd"), null)
	add_custom_type("RayCastHitbox2D", "RayCast2D", preload("res://addons/essentialskit/2d/ray_cast_hitbox_2d.gd"), null)

func _exit_tree():
	remove_custom_type("HealthComponent")
	remove_custom_type("DamageType")
	remove_custom_type("DamageHitbox3D")
	remove_custom_type("OngoingDamageHitbox3D")
	remove_custom_type("RayCastHitbox3D")
	remove_custom_type("DamageHitbox2D")
	remove_custom_type("OngoingDamageHitbox2D")
	remove_custom_type("RayCastHitbox2D")
