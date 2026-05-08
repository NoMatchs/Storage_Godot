extends Node2D

signal health_depleted(old_value,new_value);

var health = 30;

func take_danage(amount):
	var old_health = health;
	health -= amount;
	if health <= 0:
		health_depleted.emit(old_health,health);
