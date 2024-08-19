extends "res://Scripts/edible_object.gd"

enum EnemyStates {
	IDLE,
	CHASE,
	ATTACK
}

var state: EnemyStates = EnemyStates.IDLE;

func _physics_process(delta: float) -> void:
	match state:
		EnemyStates.IDLE:
			idle();
			pass;
		EnemyStates.CHASE:
			chase_player();
			pass;
		EnemyStates.ATTACK:
			attack_player();
			pass;
	pass;

func idle() -> void:
	
	pass;
func chase_player() -> void:
	
	pass;
func attack_player() -> void:
	
	pass;
