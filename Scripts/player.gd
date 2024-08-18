extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D;
@onready var line: Line2D = $Line2D;
@onready var animationTree = $AnimationTree;
@onready var animationState = animationTree.get("parameters/playback");

@onready var jumpCursor = preload('res://Textures/jump_cursor.png');

var frog_size: int = 1;

## amount of objects to eat before sizing up
var size_increase_threshold: int = 3;
var objects_eaten: int;
var is_hovering_object: bool = false;

func _process(delta: float) -> void:
	animationTree.set("parameters/Idle/blend_position", get_frog_direction());
	sprite.flip_h = get_global_mouse_position().x > sprite.global_position.x;
	
	if Input.is_action_just_pressed("left_click") && !Global.is_frog_tongue_out:
		release_tongue(delta);
	
	var pos = get_global_mouse_position() - position;
	if  pos.x < 100 and pos.x > -100 and pos.y < 100 and pos.y > -100:
		
		if !is_hovering_object:
			Input.set_custom_mouse_cursor(jumpCursor, Input.CURSOR_ARROW);
		else:
			Input.set_custom_mouse_cursor(null);
		
		if Input.is_action_just_pressed("right_click"):
			var tween = get_tree().create_tween();
			tween.tween_property(self, "position", get_global_mouse_position(), .2);
			
			animationTree.active = false;
			$AnimationPlayer.play("jump");
			await $AnimationPlayer.animation_finished;
			animationTree.active = true;
	else:
		Input.set_custom_mouse_cursor(null);
	
	move_and_slide();

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
	
	if objects_eaten % size_increase_threshold == 0:
		frog_size += 1;
		sprite.scale += Vector2(0.2, 0.2);
	
	object.queue_free();
	pass;

func get_frog_direction() -> Vector2:
	var vector: Vector2;
	
	vector.x = get_local_mouse_position().x - sprite.position.x;
	vector.y = get_local_mouse_position().y - sprite.position.y;
	
	vector.clamp(Vector2(-1, -1), Vector2(1, 1));
	
	return vector;
