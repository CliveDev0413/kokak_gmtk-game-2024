extends "res://Scripts/edible_object.gd"

@export var MOVE_SPEED: float = 50;
@export var walking_points: Array[Marker2D];

@onready var sprite = $Sprite2D;

var walking_point: Vector2;
var is_walking: bool = false;
var rng = RandomNumberGenerator.new();

func _physics_process(delta: float) -> void:
	super(delta);
	
	if !is_walking:
		walking_point = get_random_point();
		is_walking = true;
	
	if is_walking:
		npc_walk();

func npc_walk() -> void:
	if !self.is_class("CharacterBody2D"):
		return;
	
	var object = self;
	var characterBody = (object as CharacterBody2D);
	var dir = (walking_point - global_position).normalized();
	
	sprite.flip_h = (dir.x > 0);
	
	if abs(global_position - walking_point) <= Vector2(0.5, 0.5):
		characterBody.velocity = Vector2.ZERO;
		print("stop");
		is_walking = false;
		return;

	characterBody.velocity = dir * MOVE_SPEED;
		
	characterBody.move_and_slide();
	
	pass;

func get_random_point() -> Vector2:
	var random_num = rng.randf_range(0, walking_points.size());
	return walking_points[random_num].global_position;
