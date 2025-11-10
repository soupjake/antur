extends Control

signal textbox_closed

@export var enemy: Resource = null

var current_player_health := 0
var current_enemy_health := 0
var is_defending := false

func _ready() -> void:
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	set_health($PlayerPanel/MarginContainer/PlayerData/ProgressBar, Player.current_health, Player.max_health)
	$EnemyContainer/Enemy.texture = enemy.texture
	
	current_player_health = Player.current_health
	current_enemy_health = enemy.health
	
	$Textbox.hide()
	$ActionsPanel.hide()
	
	display_text("A wild %s appears!" % enemy.name.to_upper())
	$ActionsPanel.show()

func set_health(progress_bar: ProgressBar, health: int, max_health: int) -> void:
	progress_bar.value = health
	progress_bar.max_value = max_health


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and $Textbox.visible:
		$Textbox.hide()
		emit_signal("textbox_closed")


func display_text(text: String) -> void:
	$Textbox.show()
	$Textbox/MarginContainer/Label.text = text
	await self.textbox_closed


func enemy_turn() -> void:
	if is_defending:
		is_defending = false
		var defended_damage = round(enemy.damage / 2)
		print(defended_damage)
		
		display_text("%s dealt %s damage!" % [enemy.name, defended_damage])
		current_player_health = max(0, current_player_health - defended_damage)
		set_health($PlayerPanel/MarginContainer/PlayerData/ProgressBar, current_player_health, Player.max_health)
		return
	
	display_text("%s dealt %s damage!" % [enemy.name, enemy.damage])
	current_player_health = max(0, current_player_health - enemy.damage)
	set_health($PlayerPanel/MarginContainer/PlayerData/ProgressBar, current_player_health, Player.max_health)


func _on_run_button_pressed() -> void:
	display_text("Got away safely!")
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()


func _on_attack_button_pressed() -> void:
	display_text("You dealt %d damage!" % Player.damage)
	
	current_enemy_health = max(0, current_enemy_health - Player.damage)
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	
	enemy_turn()


func _on_defend_button_pressed() -> void:
	is_defending = true
	
	display_text("You defend!")
	await get_tree().create_timer(1.0).timeout
	enemy_turn()
