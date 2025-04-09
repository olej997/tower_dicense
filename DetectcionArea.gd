extends Area2D  # Area2D wykrywa wrogów w zasięgu wieżyczki.
@export var turret: Node2D  # Odniesienie do wieżyczki
@export var targeting_mode: int = 2  # Domyślny tryb atakowania (1 = największe HP)
var current_target: Node2D = null  # 🎯 Aktualny cel
var enemies_in_range = []  # Lista wrogów w zasięgu
func _ready():
	update_range()
# 📌 Aktualizuje CollisionShape2D na podstawie range_radius wieżyczki
func update_range(new_radius: float = 100.0):
	if $CollisionShape2D and $CollisionShape2D.shape is CircleShape2D:
		$CollisionShape2D.shape.radius = new_radius
# 📌 Wykrywanie wrogów wchodzących do zasięgu
func _on_body_entered(body):
	#if body.is_in_group("enemies") and not body.is_in_group("bullets"): 
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)  # Dodajemy wroga do listy
		update_target()  # Aktualizacja celu wieżyczki
func update_target():
	if enemies_in_range.is_empty():
		current_target = null  # Jeśli nie ma wrogów, brak celu
		return
	match targeting_mode:
		1:  # 🎯 Priorytet: Wróg z największym HP
			current_target = enemies_in_range.reduce(func(a, b): return a if a.current_health > b.current_health else b)
		2:  # 🏃‍♂️ Priorytet: Wróg najdalej na ścieżce
			current_target = enemies_in_range.reduce(func(a, b): return a if a.get_progress() > b.get_progress() else b)
		3:  # 💔 Priorytet: Wróg z najmniejszym HP
			current_target = enemies_in_range.reduce(func(a, b): return a if a.current_health < b.current_health else b)
# 📌 Wykrywanie wrogów opuszczających zasięg
func _on_body_exited(body):
	if body in enemies_in_range:
		enemies_in_range.erase(body)  # Usuwamy wroga z listy
		update_target()  # Aktualizacja celu po wyjściu wroga
func get_range_radius() -> float:
	if $CollisionShape2D.shape is CircleShape2D:
		return $CollisionShape2D.shape.radius
	return 0.0  # Jeśli nie jest poprawnie ustawione, zwróć 0
func set_targeting_mode(mode: int):
	targeting_mode = mode
	update_target()
