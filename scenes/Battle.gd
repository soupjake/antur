extends Control

signal textbox_closed

@export var enemy: Resource = null

func _ready() -> void:
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	set_health($PlayerPanel/MarginContainer/PlayerData/ProgressBar,Player.current_health, Player.max_health)
	$EnemyContainer/Enemy.texture = enemy.texture
	
	$Textbox.hide()
	$ActionsPanel.hide()
	
	display_text("A wild %s appears!" %enemy.name.to_upper())
	await self.textbox_closed
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


func _on_run_button_pressed() -> void:
	display_text("Got away safely!")
	await self.textbox_closed
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()
