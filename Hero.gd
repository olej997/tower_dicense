extends CharacterBody2D

@export var max_health: int = 10  # Maksymalne zdrowie gracza
var current_health: int = max_health
@onready var health_bar = $HealthBar  # Pasek życia
@onready var game_manager = get_tree().get_first_node_in_group("game_manager")  # Pobieramy GameManager
@onready var damage_zone = $DamageZone  # Nowy obszar kolizji
func _ready():
	add_to_group("hero")  # 📌 Teraz bohater należy do grupy "hero"
	health_bar.max_value = max_health
	health_bar.value = current_health
	# 📌 Podpinamy sygnał wykrywania wrogów
	damage_zone.connect("area_entered", Callable(self, "_on_enemy_entered"))
func take_damage(damage: int):
	current_health -= damage

	health_bar.value = current_health
	if current_health <= 0:
		die()
func _on_enemy_entered(enemy_area):
	if enemy_area.get_parent().is_in_group("enemies"):

		take_damage(10)  # Możesz zmieniać wartość obrażeń
func die():

	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.on_game_lost()  # Informujemy GameManager o przegranej
		
