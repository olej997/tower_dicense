extends Area2D  # 📌 Teraz pocisk działa na Area2D - bez fizyki
@export var speed: float = 1000.0  # 📌 Prędkość pocisku
@export var damage: int = 1  # 📌 Obrażenia zadawane przez pocisk
@export var lifetime: float = 3.0  # ⏳ Czas życia pocisku (w sekundach)
var direction: Vector2 = Vector2.ZERO  # 📌 Kierunek lotu pocisku
var is_paused: bool = false  # Flaga do kontrolowania pauzy
var target: Node2D = null  # 🎯 Cel pocisku
func _ready():
	add_to_group("bullets")
	rotation = direction.angle()  # 🏹 Obracamy strzałę w kierunku lotu
	await get_tree().create_timer(lifetime).timeout  # ⏳ Auto-destrukcja po czasie
	queue_free()
func _process(delta):
	position += direction * speed * delta 
	#rotation = linear_velocity.angle()  # 🏹 Aktualizacja obrotu w trakcie lotu
	# Jeśli target został usunięty → znikamy
	if target == null or not is_instance_valid(target):
		queue_free()
func _on_body_entered(body):
	# 📌 Sprawdzamy, czy to wróg
	if body.is_in_group("enemies") and body == target:
		body.take_damage(damage)  # 🩸 Zadajemy obrażenia wrogowi
		queue_free()  # Usuwamy pocisk po trafieniu
func toggle_pause():
	is_paused = !is_paused
