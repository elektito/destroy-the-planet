extends Resource
class_name Stat

# This should be `export(Global.StatType) var type`, but that line errors out
# with "expected constant expression" error. GDScript being the patched-up
# hack of a language that it is. I'm just using an int, right now.
export(int) var type

export(String) var value: String
