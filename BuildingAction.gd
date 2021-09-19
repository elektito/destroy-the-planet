extends Node

signal info_updated(action, item, value)

export(Global.ActionType) var type: int = Global.ActionType.NORMAL
export(String) var title: String setget set_title
export(String, MULTILINE) var description: String setget set_description
export(int) var price: int setget set_price
export(String) var button_text: String = 'Perform'
export(bool) var batch_enabled := false

# should be an array of Stat resource, enforced in set_stats, since looks like
# godot doesn't support using custom resources as export hints.
export(Array, Resource) var stats := [] setget set_stats


class TimedProperty:
	var parent: Node
	var name: String
	var timeout: float
	var start_time: float = -1
	var timeout_action_object: Object
	var timeout_action_method: String
	var timeout_action_args
	var timer: Timer
	
	func init(parent: Node, name: String, timeout: float):
		self.parent = parent
		self.name = name
		self.timeout = timeout
		
		self.timer = Timer.new()
		self.timer.one_shot = true
		self.timer.wait_time = self.timeout
		self.timer.connect("timeout", self, "_on_timer_timeout")
		self.parent.add_child(self.timer)
		
		return self
	
	func cleanup():
		self.timer.queue_free()
	
	func start():
		self.start_time = OS.get_ticks_usec()
		if self.timer != null:
			self.timer.start()
	
	func set_timeout_action(object: Object, method_name: String, args: Array):
		self.timeout_action_object = object
		self.timeout_action_method = method_name
		self.timeout_action_args = args
		self.parent.add_child(self.timer)
	
	func get_elapsed_time() -> float:
		var now := OS.get_ticks_usec()
		var time := (now - self.start_time) / 1000000.0
		return time
	
	func is_in_progress():
		if self.start_time < 0:
			return false
		if get_elapsed_time() >= self.timeout:
			self.start_time = -1
			return false
		return true
	
	func is_done():
		return (self.value == 1.0)
	
	func get_value() -> float:
		if self.start_time < 0:
			return 0.0
		var time := get_elapsed_time()
		if time >= self.timeout:
			return 1.0
		else:
			return time / self.timeout
	
	func _on_timer_timeout():
		self.timeout_action_object.callv(self.timeout_action_method, self.timeout_action_args)


var timed_properties := {}

func set_stats(value: Array):
	for stat in value:
		if stat.get_script() == null or stat.get_script().get_path() != "res://Stat.gd":
			push_error("Only Stat resources can be set in BuildingAction.stats")
			assert(false, "Only Stat resources can be set in BuildingAction.stats")
	stats = value
	
	emit_signal("info_updated", self, Global.StatType.ACTION_STATS, stats)


func set_title(value):
	title = value
	emit_signal("info_updated", self, Global.StatType.TITLE, title)


func set_description(value):
	description = value
	emit_signal("info_updated", self, Global.StatType.DESCRIPTION, description)


func set_price(value: int):
	price = value
	emit_signal("info_updated", self, Global.StatType.PRICE, price)


func add_timed_property(name: String, timeout: float):
	var timed_property = TimedProperty.new().init(self, name, timeout)
	timed_properties[name] = timed_property
	return timed_property


func get_timed_property(name: String) -> TimedProperty:
	return timed_properties.get(name, null)


func remove_timed_property(name: String):
	var property = timed_properties[name]
	property.cleanup()
	timed_properties.erase(name)
