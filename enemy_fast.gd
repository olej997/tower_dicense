extends "res://Enemy.gd"  # Ustawiamy dziedziczenie!

func _ready():
	max_health = 5  # Mniej HP
	speed = 100.0  # Większa prędkość
	armor = 0.0  # Brak pancerza
	super._ready()  # Wywołuje metodę `_ready()` z `Enemy.gd`

func _process(delta):
	velocity = Vector2(speed, 0)  # Szybki ruch w prawo
	move_and_slide()
