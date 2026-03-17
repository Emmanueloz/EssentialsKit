@tool
extends EditorPlugin


func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree():
	add_custom_type("HealthComponent", "Node", preload("res://addons/essentialskit/components/health_component.gd"), null)
	add_custom_type("DefenseComponent", "Node", preload("res://addons/essentialskit/components/defense_component.gd"), null)
	
	add_custom_type("DamageType", "Resource", preload("res://addons/essentialskit/resources/damage_type.gd"), null)
	add_custom_type("Modifier", "Resource", preload("res://addons/essentialskit/resources/modifier.gd"), null)
	add_custom_type("HealthModifier", "Resource", preload("res://addons/essentialskit/resources/health_modifier.gd"), null)
	
	add_custom_type("DamageHitbox3D", "Area3D", preload("res://addons/essentialskit/3d/damage_hitbox_3d.gd"), null)
	add_custom_type("OngoingDamageHitbox3D", "Area3D", preload("res://addons/essentialskit/3d/ongoing_damage_hitbox_3d.gd"), null)
	add_custom_type("RayCastHitbox3D", "RayCast3D", preload("res://addons/essentialskit/3d/ray_cast_hitbox_3d.gd"), null)
	
	add_custom_type("Hurtbox3D", "Area3D", preload("res://addons/essentialskit/3d/hurtbox_3d.gd"), null)
	
	add_custom_type("BuffZone3D", "Area3D", preload("res://addons/essentialskit/3d/buff_zone_3d.gd"), null)
	
	add_custom_type("DamageHitbox2D", "Area2D", preload("res://addons/essentialskit/2d/damage_hitbox_2d.gd"), null)
	add_custom_type("OngoingDamageHitbox2D", "Area2D", preload("res://addons/essentialskit/2d/ongoing_damage_hitbox_2d.gd"), null)
	add_custom_type("RayCastHitbox2D", "RayCast2D", preload("res://addons/essentialskit/2d/ray_cast_hitbox_2d.gd"), null)
	
	add_custom_type("Hurtbox2D", "Area2D", preload("res://addons/essentialskit/2d/hurtbox_2d.gd"), null)
	
	add_custom_type("BuffZone2D", "Area2D", preload("res://addons/essentialskit/2d/buff_zone_2d.gd"), null)

func _exit_tree():
	remove_custom_type("HealthComponent")
	remove_custom_type("DefenseComponent")
	
	remove_custom_type("DamageType")
	remove_custom_type("Modifier")
	remove_custom_type("HealthModifier")
	
	remove_custom_type("DamageHitbox3D")
	remove_custom_type("OngoingDamageHitbox3D")
	remove_custom_type("RayCastHitbox3D")
	remove_custom_type("Hurtbox3D")
	remove_custom_type("BuffZone3D")
	
	remove_custom_type("DamageHitbox2D")
	remove_custom_type("OngoingDamageHitbox2D")
	remove_custom_type("RayCastHitbox2D")
	remove_custom_type("Hurtbox2D")
	remove_custom_type("BuffZone2D")
