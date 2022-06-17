extends Node

var halignerContainer: HBoxContainer

var labelBox: VBoxContainer

var labelNode: Dictionary = {}
var font_theme=load("res://sceneList/demo20_DebugTool/font/font_size_normal.tres")
var emptyStyleBox_theme=load("res://sceneList/demo20_DebugTool/theme/stylebox_empty.tres")
func _enter_tree() -> void:
	
	
	halignerContainer = HBoxContainer.new()
	
	halignerContainer.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	# Make the outer "main box" fill the entire screen
	halignerContainer.anchor_top = 0.1
	halignerContainer.anchor_right = 0.95
	halignerContainer.anchor_left = 0.05
	halignerContainer.anchor_bottom = 0.9
	
	labelBox = VBoxContainer.new()
	labelBox.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	labelBox.size_flags_horizontal= 3
	labelBox.anchor_top = 1
	labelBox.anchor_right = 1
	labelBox.anchor_left =1
	labelBox.anchor_bottom =1
	# Add the nodes into the tree
	add_child(halignerContainer)
	halignerContainer.add_child(labelBox)


func set_label(lblid: String, text: String) -> void:
	var lbl: Label = labelNode.get(lblid)
	if (!lbl):
		lbl = Label.new()
		lbl.add_font_override("font",font_theme)
		labelBox.add_child(lbl)
		labelNode[lblid] = lbl
		
	lbl.text = text


func add_timed_label(text: String, timeout: float) -> void:
	# Create the label and add into the container
	var lbl: Label = Label.new()
	lbl.text = text
	labelBox.add_child(lbl)
	
	# Setup the timer
	var t: Timer = Timer.new()
	t.process_mode = Timer.TIMER_PROCESS_IDLE
	# Give at least half second before removing the text label from the container.
	t.wait_time = max(0.5, timeout)
	t.one_shot = true
	# warning-ignore:return_value_discarded
	t.connect("timeout", self, "_on_timeout", [t, lbl])
	add_child(t)
	t.start()

func remove_label(lblid) -> void:
	var lbl: Label = labelNode.get(lblid)
	if (lbl):
		lbl.queue_free()
		# warning-ignore:return_value_discarded
		labelNode.erase(lbl)

func set_line(lblid: String,color:Color=Color(1,0,0,1),sizey:float=1.0):
	var line: ColorRect = labelNode.get(lblid)
	if(!line):
		line = ColorRect.new()
		line.color=color
		line.rect_min_size=Vector2(0,sizey)
		labelBox.add_child(line)
		labelNode[lblid] = line

func setTextArea(lblid: String,newLine:String,maxLine:int=1200):
	var textEdit :TextEdit =labelNode.get(lblid)
	if(!textEdit):
		textEdit=TextEdit.new()
		labelBox.add_child(textEdit)
		textEdit.wrap_enabled=true
		textEdit.show_line_numbers=true
		textEdit.rect_min_size=Vector2(0,maxLine)
		textEdit.readonly=true
		textEdit.virtual_keyboard_enabled=false
		textEdit.selecting_enabled=false

		textEdit.add_font_override("font",font_theme)

		textEdit.add_stylebox_override("normal",emptyStyleBox_theme)
		textEdit.add_stylebox_override("read_only",emptyStyleBox_theme)

		labelNode[lblid] = textEdit
		
	var content = textEdit.text
	content += newLine+ "\n"
	textEdit.text = content
	textEdit.cursor_set_line(textEdit.get_line_count())
	if(textEdit.get_line_count()>100):
		content=""

func set_visibility(visible: bool) -> void:
	pass

func toggle_visibility() -> void:
	pass

func set_horizontal_align_left() -> void:
	halignerContainer.alignment = BoxContainer.ALIGN_BEGIN

func set_horizontal_align_center() -> void:
	halignerContainer.alignment = BoxContainer.ALIGN_CENTER

func set_horizontal_align_right() -> void:
	halignerContainer.alignment = BoxContainer.ALIGN_END

func clear() -> void:
	for lid in labelNode:
		labelNode[lid].queue_free()
	labelNode.clear()



