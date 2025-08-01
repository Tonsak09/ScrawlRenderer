extends Control

@onready var slider = $HSlider
@onready var textEdit = $TextEdit

func GetValue():
	return slider.value

func TextEditChange():
	print_debug(textEdit.text)
