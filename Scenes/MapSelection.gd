# Kontroler sceny wyboru mapy
extends Control

# Zmienne globalne
var map_data = []  # Lista dostępnych map wczytanych z JSON
var selected_tier = 1  # Aktualny poziom trudności (tier)
var available_maps = []  # Mapy dostępne dla aktualnego tieru

# Referencje do elementów UI
@onready var map1_info = $VBoxContainer/Map1Container/Map1Info  # Panel informacji o pierwszej mapie
@onready var map2_info = $VBoxContainer/Map2Container/Map2Info  # Panel informacji o drugiej mapie
@onready var map_button_1 = $VBoxContainer/Map1Container/MapButton1  # Przycisk wyboru pierwszej mapy
@onready var map_button_2 = $VBoxContainer/Map2Container/MapButton2  # Przycisk wyboru drugiej mapy
@onready var return_button = $VBoxContainer/ReturnButton  # Przycisk powrotu do menu

# Inicjalizacja sceny
func _ready():
	# Upewniamy się, że gra nie jest spauzowana
	var tree = get_tree()
	if tree:
		tree.paused = false
	
	# Pobieramy RunManager i sprawdzamy dostępne mapy
	var run_manager = get_tree().get_first_node_in_group("run_manager")
	if not run_manager:
		print("❌ Nie znaleziono run_manager!")
		return
		
	selected_tier = run_manager.current_tier
	
	# Pobieramy i wyświetlamy mapy dla aktualnego tieru
	var tier_str = str(selected_tier)
	var tier_maps = run_manager.tier_maps
	if tier_maps.has(tier_str):
		var available_maps = tier_maps[tier_str]
		
		if available_maps.size() < 2:
			print("❌ Niewystarczająca liczba map dla tieru:", selected_tier)
			return
			
		# Wybieramy dwie mapy do wyświetlenia
		var selected_maps = []
		for i in range(2):
			selected_maps.append(available_maps[i])
		
		display_map_choices(selected_maps)
		_ensure_input_handling()
	else:
		print("❌ Brak map dla tieru:", tier_str)

# Obsługa zdarzeń systemowych
func _notification(what):
	match what:
		NOTIFICATION_READY, NOTIFICATION_ENTER_TREE, NOTIFICATION_VISIBILITY_CHANGED:
			if visible:
				_ensure_input_handling()

# Obsługa wejścia myszy
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if map_button_1 and map_button_2:
				var button1_rect = map_button_1.get_global_rect()
				var button2_rect = map_button_2.get_global_rect()
				
				if button1_rect.has_point(event.position):
					_handle_map1_pressed()
					accept_event()
					return
				elif button2_rect.has_point(event.position):
					_handle_map2_pressed()
					accept_event()

# Obsługa wejścia GUI
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if map_button_1 and map_button_2:
			var button1_rect = map_button_1.get_global_rect()
			var button2_rect = map_button_2.get_global_rect()
			
			if button1_rect.has_point(event.position):
				_handle_map1_pressed()
				accept_event()
			elif button2_rect.has_point(event.position):
				_handle_map2_pressed()
				accept_event()

# Sygnały przycisków
func _on_button1_pressed():
	_handle_map1_pressed()

func _on_button2_pressed():
	_handle_map2_pressed()

# Obsługa wyboru pierwszej mapy
func _handle_map1_pressed():
	if not map_button_1:
		return
		
	if map_button_1.has_meta("map_id"):
		var chosen_map_id = map_button_1.get_meta("map_id")
		
		var run_manager = get_tree().get_first_node_in_group("run_manager")
		if run_manager:
			run_manager.set_selected_map(chosen_map_id)
			call_deferred("_safe_change_to_main")

# Obsługa wyboru drugiej mapy
func _handle_map2_pressed():
	if not map_button_2:
		return
		
	if map_button_2.has_meta("map_id"):
		var chosen_map_id = map_button_2.get_meta("map_id")
		
		var run_manager = get_tree().get_first_node_in_group("run_manager")
		if run_manager:
			run_manager.set_selected_map(chosen_map_id)
			call_deferred("_safe_change_to_main")

# Obsługa klawiszy numerycznych jako alternatywny sposób wyboru mapy
func _unhandled_key_input(event):
	if event.pressed:
		match event.keycode:
			KEY_1:
				_handle_map1_pressed()
			KEY_2:
				_handle_map2_pressed()
			KEY_ESCAPE:
				get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

# Wyświetlanie informacji o mapach
func display_map_choices(selected_maps):
	if selected_maps.size() < 2:
		return
		
	selected_maps.shuffle()
	var map1 = selected_maps[0]
	var map2 = selected_maps[1]
	
	# Aktualizacja informacji o mapach
	map1_info.text = "🌍 Mapa: " + map1["name"] + "\n👾 Wrogowie: " + str(map1["enemies"].size())
	map2_info.text = "🌍 Mapa: " + map2["name"] + "\n👾 Wrogowie: " + str(map2["enemies"].size())
	
	# Przypisanie ID map do przycisków
	map_button_1.set_meta("map_id", map1["map_id"])
	map_button_2.set_meta("map_id", map2["map_id"])

# Powrót do menu głównego
func _on_return_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

# Konfiguracja obsługi wejścia i przycisków
func _ensure_input_handling():
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_input(true)
	set_process_unhandled_input(true)
	
	if map_button_1 and map_button_2:
		for button in [map_button_1, map_button_2]:
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			button.focus_mode = Control.FOCUS_ALL
			button.visible = true
			button.disabled = false
			
		# Podłączenie sygnałów przycisków
		if not map_button_1.pressed.is_connected(_on_button1_pressed):
			map_button_1.pressed.connect(_on_button1_pressed)
		if not map_button_2.pressed.is_connected(_on_button2_pressed):
			map_button_2.pressed.connect(_on_button2_pressed)

# Zdarzenia cyklu życia węzła
func _enter_tree():
	_ensure_input_handling()

func _exit_tree():
	# Czyszczenie połączeń sygnałów
	if map_button_1 and map_button_1.pressed.is_connected(_on_button1_pressed):
		map_button_1.pressed.disconnect(_on_button1_pressed)
	if map_button_2 and map_button_2.pressed.is_connected(_on_button2_pressed):
		map_button_2.pressed.disconnect(_on_button2_pressed)

# Bezpieczna zmiana sceny na główną scenę gry
func _safe_change_to_main():
	var tree = get_tree()
	if not tree:
		return
		
	tree.paused = false
	
	var packed_scene = load("res://Scenes/main.tscn")
	if packed_scene:
		call_deferred("_do_change_scene", packed_scene)

# Wykonanie zmiany sceny
func _do_change_scene(packed_scene):
	var tree = get_tree()
	if tree:
		var result = tree.change_scene_to_packed(packed_scene)
		if result != OK:
			print("❌ Błąd podczas zmiany sceny:", result)
