extends Control

# Called when the node enters the scene tree for the first time.
var is_pause_menu: bool = false  # Flaga czy menu jest otwarte przez pauzę



func _ready() -> void:
	await get_tree().process_frame  # Czeka jedną klatkę
	#DisplayServer.window_set_current_screen(1)

# Pobieramy przyciski
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)
	# Sprawdzamy, czy to menu pauzy
	if is_pause_menu:
		$VBoxContainer/StartButton.visible = false  # Ukrywamy "Start", jeśli to pauza
		$VBoxContainer/ResumeButton.visible = true  # Pokazujemy "Wznów"
func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/MapSelection.tscn")  # Przechodzimy do wyboru map!

# Przycisk Wyjścia → Zamyka grę
func _on_exit_pressed():
	#print("❌ Zamknięcie gry!")
	get_tree().quit()
# Przycisk "Wznów" → Wraca do gry
func _on_resume_pressed():
	#print("⏸️ Wznawianie gry")
	get_tree().paused = false  # Wznawiamy grę
	queue_free()  # Usuwamy menu
