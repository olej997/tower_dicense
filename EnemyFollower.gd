extends PathFollow2D  # PathFollow2D umożliwia poruszanie się wzdłuż narysowanej ścieżki (Path2D).


@export var enemy_type: String = "Enemy"  # Domyślny typ przeciwnika

var speed: float = 30.0  # Domyślna prędkość, ale będzie pobierana z Enemy
var is_paused: bool = false  # Flaga do kontrolowania pauzy
var enemy_instance: CharacterBody2D = null  # Przeciwnik wewnątrz PathFollow2D


func _ready():
	spawn_enemy()  # Tworzymy przeciwnika
	
	
func spawn_enemy():
	# Ładujemy odpowiednią scenę przeciwnika na podstawie enemy_type
	var enemy_scene = load("res://Scenes/" + enemy_type + ".tscn")
	if enemy_scene:
		enemy_instance = enemy_scene.instantiate()
		add_child(enemy_instance)  # Dodajemy przeciwnika jako dziecko PathFollow2D
		enemy_instance.global_position = global_position  # Dopasowanie pozycji
		# 📌 Pobieramy rzeczywistą prędkość przeciwnika z Enemy.gd
		if enemy_instance.has_method("get_speed"):
			speed = enemy_instance.get_speed()  



func _process(delta):
	if is_paused:
		return  # Wstrzymaj ruch, jeśli gra jest zapauzowana
	progress += speed * delta

func toggle_pause():
	is_paused = !is_paused
