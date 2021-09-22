extends PanelContainer

var world
var building
var action

var boost_property
var boost_time := 5.0
var boost_level := 1

func init(_world, _building, _action):
	world = _world
	building = _building
	action = _action
	
	boost_property = action.get_timed_property('boost')
	if boost_property == null:
		boost_property = action.add_timed_property('boost', boost_time)
		boost_property.set_timeout_action(building, 'set_boost', [0])
	
	update_description()
	update_progress()


func update_description():
	$margin/vbox/description.bbcode_text = '[b]' + action.title + '[/b]\n\n' + action.description


func update_progress():
	var value = boost_property.get_value()
	$margin/vbox/progress_bar.value = value
	if value == 1.0:
		$margin/vbox/action_btn.disabled = false
		$margin/vbox/progress_bar.value = 0.0
		building.boost = 0
	else:
		$margin/vbox/action_btn.disabled = boost_property.is_in_progress()


func _physics_process(_delta):
	if $margin/vbox/action_btn.disabled:
		update_progress()


func _on_action_btn_pressed():
	$margin/vbox/action_btn.disabled = true
	boost_property.start()
	building.boost = boost_level
