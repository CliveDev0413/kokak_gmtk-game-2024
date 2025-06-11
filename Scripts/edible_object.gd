extends Node2D

@export var frog_size_threshold: int = 1;
@export var no_eat_collisions: bool = false;
@export var eat_sounds: Array[AudioStream];

@onready var outline_shader = preload("res://Shaders/outline.gdshader");
@onready var audioPlayer = $AudioStreamPlayer2D;

var is_mouse_hovering: bool = false;
var eaten:bool = false;

var frog: CharacterBody2D;

var rng = RandomNumberGenerator.new();

func _ready() -> void:
	frog = get_tree().get_first_node_in_group("player");

func _physics_process(delta: float) -> void:	
	if frog.frog_size >= frog_size_threshold:
		if Input.is_action_just_pressed("left_click") and is_mouse_hovering:
			eaten = true;
			
			if !eat_sounds.is_empty():
				var random_num = rng.randf_range(0, eat_sounds.size());
				audioPlayer.stream = eat_sounds[random_num];
				audioPlayer.pitch_scale = rng.randf_range(0.7, 1.3);
				audioPlayer.play();
			
			if no_eat_collisions:
				$Collider.queue_free();
				
			await get_tree().create_timer(20 * delta).timeout;
			
			var tween = get_tree().create_tween();
			tween.tween_property(self, "global_position", frog.sprite.global_position, .3);
			
			await tween.finished;
				
			frog.ate_object($".");

func _on_mouse_entered() -> void:
	if frog.frog_size < frog_size_threshold:
		return;
		
	var sprite = $Sprite2D;
	
	is_mouse_hovering = true;
	frog.is_hovering_object = true;
	sprite.material = ShaderMaterial.new();
	sprite.material.shader = outline_shader;

func _on_mouse_exited() -> void:
	if frog.frog_size < frog_size_threshold:
		return;
	
	var sprite = $Sprite2D;
	
	is_mouse_hovering = false;
	frog.is_hovering_object = false;
	
	if sprite.material != null:
		sprite.material.shader = outline_shader;
		sprite.material = null;
