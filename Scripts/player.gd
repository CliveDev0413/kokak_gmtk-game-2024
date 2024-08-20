extends CharacterBody2D

@export var MOVE_SPEED: float = 300;
@export var GROW_SIZE: Vector2 = Vector2(0.3, 0.3);

@onready var sprite: Sprite2D = $Sprite2D;
@onready var line: Line2D = $Line2D;
@onready var animationTree = $AnimationTree;
@onready var animationState = animationTree.get("parameters/playback");
@onready var animationPLayer = $AnimationPlayer;

@onready var jumpCursor = preload('res://Textures/jump_cursor.png');

var frog_size: int = 1;

## amount of objects to eat before sizing up
var size_increase_threshold: int = 3;
var objects_eaten: int;
var is_hovering_object: bool = false;

var is_moving: bool = false;
var is_dead: bool = false;

func _process(delta: float) -> void:
	if is_dead:
		return;
	
	frog_animate();
	
	if Input.is_action_just_pressed("left_click") && !Global.is_frog_tongue_out:
		release_tongue(delta);
	
	frog_jump_detect(delta);
	
	move_and_slide();

func frog_animate() -> void:
	animationTree.set("parameters/Idle/blend_position", get_frog_direction());
	sprite.flip_h = get_global_mouse_position().x > sprite.global_position.x;
	
func frog_jump_detect(delta: float) -> void:
	var pos = get_global_mouse_position() - position;
	if  pos.x < 100 and pos.x > -100 and pos.y < 100 and pos.y > -100:
		
		if !is_hovering_object:
			Input.set_custom_mouse_cursor(jumpCursor, Input.CURSOR_ARROW);
		else:
			Input.set_custom_mouse_cursor(null);
		
		if Input.is_action_just_pressed("right_click"):
			frog_jump();
	else:
		Input.set_custom_mouse_cursor(null);
	
	if is_moving:
		await get_tree().create_timer(.2).timeout;
		velocity = Vector2.ZERO;
		is_moving = false;
	
func frog_jump() -> void:
	var dir = (get_global_mouse_position() - position).normalized();
	velocity += dir * MOVE_SPEED;
	is_moving = true;
	
	# animation
	animationTree.active = false;
	animationPLayer.play("jump");
	await animationPLayer.animation_finished;
	animationTree.active = true;

func release_tongue(delta: float) -> void:
	var last_mouse_pos: Vector2 = get_local_mouse_position();
	var max_points: int = 20;
	var pos: Vector2 = (get_local_mouse_position() - sprite.position) / max_points;
	
	animationTree.set("parameters/Eat/blend_position", get_frog_direction());
	animationState.travel("Eat");
	
	line.clear_points();
	line.add_point(sprite.position, 0)
	
	for i in range(1, max_points):
		await get_tree().create_timer(.001).timeout;
		line.add_point(Vector2(sprite.position.x + i * pos.x, sprite.position.y + i * pos.y), i);
	
	line.set_point_position(max_points - 1, last_mouse_pos);
		
	Global.is_frog_tongue_out = true;
	
	await get_tree().create_timer(.2).timeout;
	
	retract_tongue(delta);

func retract_tongue(delta: float) -> void:	
	var value = line.get_point_count() - 1;
	
	for i in range(0, line.get_point_count()):
		await get_tree().create_timer(.001).timeout;
		line.remove_point(value);
		value -= 1;
		
	Global.is_frog_tongue_out = false;
	animationState.travel("Idle");

func ate_object(object: Node2D) -> void:
	objects_eaten += 1;
	
	object.queue_free();
	velocity = Vector2.ZERO;
	
	if objects_eaten % size_increase_threshold == 0:
		frog_size += 1;
		scale += GROW_SIZE;
		$Camera2D.zoom -= GROW_SIZE;
		size_increase_threshold += 2;
		objects_eaten = 0;
		print(frog_size);
	pass;

func get_frog_direction() -> Vector2:
	var vector: Vector2;
	
	vector.x = get_local_mouse_position().x - sprite.position.x;
	vector.y = get_local_mouse_position().y - sprite.position.y;
	
	vector.clamp(Vector2(-1, -1), Vector2(1, 1));
	
	return vector;

func _on_hurtbox_area_entered(area: Area2D) -> void:
	is_dead = true;
	set_process_mode(Node.PROCESS_MODE_ALWAYS);
	get_tree().paused = true;
	
	animationTree.active = false;
	animationPLayer.play("dead");
	await animationPLayer.animation_finished;
	get_tree().paused = false;
	get_tree().reload_current_scene();
