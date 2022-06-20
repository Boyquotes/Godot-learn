#Debug UI界面生成脚本
#接口1：SetTheme(label,styleBox,title)
#接口1：AddTitle(lblid: String, text: String)
#接口1：AddLabel(lblid: String, text: String)
#接口1：AddLine(lblid: String,color:Color=Color(1,0,0,1),sizey:float=1.0)
#接口1：AddTextArea(lblid: String,newLine:String,maxLine:int=1200)
#接口1：Remove(lblid)
#接口1：SetVisibility(visible: bool) 
#接口1：Clear()
extends Control

var halignerContainer: HBoxContainer

var contentBox: VBoxContainer
var contentDict: Dictionary = {}
var isVisible=false

var labelFontTheme
var titleFontTheme
var logFontTheme
var emptyStyleBoxTheme

func _enter_tree() -> void:

	anchor_top = 0.08
	anchor_right = 0.98
	anchor_left = 0.02
	anchor_bottom = 0.95
	
	halignerContainer = HBoxContainer.new()
	
	halignerContainer.anchor_top = 0.08
	halignerContainer.anchor_right = 0.98
	halignerContainer.anchor_left = 0.02
	halignerContainer.anchor_bottom = 0.95

	halignerContainer.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	# Make the outer "main box" fill the entire screen

	contentBox = VBoxContainer.new()
	contentBox.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	contentBox.size_flags_horizontal= 3
	contentBox.anchor_top = 1
	contentBox.anchor_right = 1
	contentBox.anchor_left =1
	contentBox.anchor_bottom =1

	# Add the nodes into the tree
	add_child(halignerContainer)
	halignerContainer.add_child(contentBox)
	
	SetVisibility(false)
	
func SetTheme(label,title,debugLog,styleBox):
	labelFontTheme=label
	titleFontTheme=title
	logFontTheme=debugLog
	emptyStyleBoxTheme=styleBox
	
func AddTitle(lblid: String, text: String)-> void:
	if(not CheckTheme()):
		print("You have to set theme before call AddTitle()")
		return
	var lbl: Label = contentDict.get(lblid)
	if (!lbl):
		lbl = Label.new()
		lbl.add_font_override("font",titleFontTheme)
		lbl.autowrap=true
		lbl.size_flags_horizontal=3
		contentBox.add_child(lbl)
		contentDict[lblid] = lbl
	lbl.text = text

	
func AddLabel(lblid: String, text: String) -> void:
	if(not CheckTheme()):
		print("You have to set theme before call AddLabel()")
		return
	var lbl: Label = contentDict.get(lblid)
	if (!lbl):
		lbl = Label.new()
		lbl.add_font_override("font",labelFontTheme)
		lbl.autowrap=true
		lbl.size_flags_horizontal=3
		contentBox.add_child(lbl)
		contentDict[lblid] = lbl
		
	lbl.text = text



func AddLine(lblid: String,color:Color=Color(1,0,0,1),sizey:float=1.0):
	var line: ColorRect = contentDict.get(lblid)
	if(!line):
		line = ColorRect.new()
		line.color=color
		line.rect_min_size=Vector2(0,sizey)
		contentBox.add_child(line)
		contentDict[lblid] = line

func AddTextArea(lblid: String,newLine:String,maxLine:int=1200,hightLight=false):
	if(not CheckTheme()):
		print("You have to set theme before call AddTextArea()")
		return
	var textEdit :TextEdit =contentDict.get(lblid)
	if(!textEdit):
		textEdit=TextEdit.new()
		contentBox.add_child(textEdit)
		textEdit.wrap_enabled=true
		textEdit.show_line_numbers=true
		textEdit.rect_min_size=Vector2(0,maxLine)
		textEdit.readonly=true
		textEdit.virtual_keyboard_enabled=false
		textEdit.selecting_enabled=false

		textEdit.syntax_highlighting=hightLight
		
		textEdit.add_color_override("font_color_readonly",Color.white)
		textEdit.add_color_override("line_number_color",Color.white)
		textEdit.add_font_override("font",logFontTheme)

		textEdit.add_stylebox_override("normal",emptyStyleBoxTheme)
		textEdit.add_stylebox_override("read_only",emptyStyleBoxTheme)

		contentDict[lblid] = textEdit
		
	var content = textEdit.text
	content += newLine+"\n" 
	
	textEdit.text = content
	textEdit.cursor_set_line(textEdit.get_line_count())
	if(textEdit.get_line_count()>1000):  #保证debug print内容不会过多
		textEdit.text=""

func Remove(lblid) -> void:
	var lbl: Label = contentDict.get(lblid)
	if (lbl):
		lbl.queue_free()
		# warning-ignore:return_value_discarded
		contentDict.erase(lbl)


func SetVisibility(visible: bool) -> void:
	isVisible=visible
	if(visible):
		show()
		return
	hide()
	pass

func Clear() -> void:
	for lid in contentDict:
		contentDict[lid].queue_free()
	contentDict.clear()

func CheckTheme()->bool:
	if(labelFontTheme and titleFontTheme and logFontTheme and emptyStyleBoxTheme):
		return true
	else:
		return false

