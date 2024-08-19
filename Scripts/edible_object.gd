extends Node2D

@export var frog_size_threshold: int = 1;
@onready var outline_shader = preload("res://Shaders/outline.gdshader");

var is_mouse_hovering: bool = false;

func _process(delta: float) -> void:
	if Global.frog.frog_size >= frog_size_threshold:
		if Input.is_action_just_pressed("left_click") and is_mouse_hovering:
			await get_tree().create_timer(.3).timeout;
			
			var tween = get_tree().create_tween();
			tween.tween_property(self, "position", Global.frog.sprite.global_position, .3);
			
			await get_tree().create_timer(.3).timeout;
			
			Global.frog.ate_object($".");

func _on_mouse_entered() -> void:
	if Global.frog.frog_size < frog_size_threshold:
		return;
		
	var sprite = $Sprite2D;
	
	is_mouse_hovering = true;
	Global.frog.is_hovering_object = true;
	sprite.material = ShaderMaterial.new();
	sprite.material.shader = outline_shader;

func _on_mouse_exited() -> void:
	if Global.frog.frog_size < frog_size_threshold:
		return;
	
	var sprite = $Sprite2D;
	
	is_mouse_hovering = false;
	Global.frog.is_hovering_object = false;
	
	if sprite.material != null:
		sprite.material.shader = outline_shader;
		sprite.material = null;
