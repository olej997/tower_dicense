extends "res://Enemy.gd"  # Ustawiamy dziedziczenie!

func _ready():
	max_health = 5  # Mniej HP
	speed = 40.0  # Większa prędkość
	armor = 0.0  # Brak pancerza
	super._ready()  # Wywołuje metodę `_ready()` z `Enemy.gd`

func _process(delta):
	health_bar.global_position = global_position + Vector2(-22, -50)
	move_and_slide()  # Ruch wroga (do zaimplementowania w podklasach)
