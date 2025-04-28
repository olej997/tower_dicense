extends CharacterBody2D


@export var max_health: int = 10
@export var speed: float = 30.0
@export var armor: float = 0.0  # Nowa mechanika pancerza (zmniejsza obrażenia)

var current_health: int
var health_bar  # Referencja do paska zdrowia, który będzie wyświetlany nad wrogiem.

@onready var attack_zone = $AttackZone  # Nowy obszar kolizji

func _ready():
	add_to_group("enemies")
	current_health = max_health  # Ustawiamy aktualne zdrowie wroga na maksymalną wartość przy uruchomieniu sceny.
	health_bar = $CanvasLayer/ProgressBar  # Pobieramy referencję do paska zdrowia z hierarchii węzłów (CanvasLayer, aby pasek nie obracał się razem z wrogiem).
	health_bar.max_value = max_health  # Ustawiamy maksymalną wartość paska zdrowia, aby odpowiadała maksymalnemu zdrowiu wroga.
	health_bar.value = current_health  # Ustawiamy aktualną wartość paska zdrowia na bieżące zdrowie wroga.
	# 📌 Podpinamy sygnał wykrywania bohatera
	if attack_zone and not attack_zone.is_connected("area_entered", Callable(self, "_on_hero_entered")):
		attack_zone.connect("area_entered", Callable(self, "_on_hero_entered"))
func get_speed():
	return speed
func _process(_delta):
	# Aktualizujemy pozycję paska zdrowia tak, aby zawsze znajdował się nad wrogiem.
	health_bar.global_position = global_position + Vector2(-22, -50)
	move_and_slide()  # Ruch wroga (do zaimplementowania w podklasach)

func take_damage(damage: int):
	var reduced_damage = max(1, damage - armor)  # Pancerz zmniejsza obrażenia
	current_health -= reduced_damage  
	health_bar.value = current_health  # Aktualizujemy wizualny pasek zdrowia, aby odzwierciedlał nowe zdrowie.
	if current_health <= 0:
		die()
func die():
	# 📌 Informujemy GameManager o śmierci wroga
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.on_enemy_died()
# Usuwamy nadrzędny `EnemyFollower`
	queue_free()  # Usuwamy wroga z gry
	
	
func _on_hero_entered(hero_area):
	print("💥 Wróg dotknął bohatera!")
	if hero_area.get_parent().is_in_group("hero"):
		die()
func get_progress():
	var parent = get_parent()
	if parent is PathFollow2D:
		return parent.progress  # Pobieramy postęp na ścieżce
	return 0.0  # Jeśli wróg nie jest na ścieżce, zwracamy 0
