extends "res://Scripts/edible_object.gd"

enum EnemyStates {
	IDLE,
	CHASE,
}

var state: EnemyStates;

@export var MOVE_SPEED: float = 100.0;

@onready var animationPlayer = $AnimationPlayer;
@onready var sprite = $Sprite2D;

var is_active: bool = false;

func _ready() -> void:
	state = EnemyStates.IDLE;
	frog = get_tree().get_first_node_in_group("player");

func _physics_process(delta: float) -> void:
	super(delta);
	
	if eaten:
		$Hitbox.queue_free();
		eaten = false;
	
	match state:
		EnemyStates.IDLE:
			idle();
			pass;
		EnemyStates.CHASE:
			chase_player();
			pass;
	pass;

func idle():
	pass;

func chase_player() -> void:
	animationPlayer.play("chase");
	
	var direction = (frog.global_position - global_position).normalized();
	
	sprite.flip_h = (direction.x > 0);
	
	var object = self;
	
	if self.is_class("CharacterBody2D"):
		(object as CharacterBody2D).velocity = direction * MOVE_SPEED;
		(object as CharacterBody2D).move_and_slide();
	
	pass;

func _on_visible_on_screen() -> void:
	if !is_active:
		is_active = true;
		$VisibleOnScreenEnabler2D.queue_free();
		animationPlayer.play("surprise");
		await animationPlayer.animation_finished;
		state = EnemyStates.CHASE;
