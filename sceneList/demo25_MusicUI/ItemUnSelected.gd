extends NinePatchRect


var ItemID 
var ItemContent 


func _ready():
	ItemID = get_node("HBoxContainer")
	ItemContent = get_node("HBoxContainer")


#region Public Method
func SetContent(content:String):
	print("SetContent")

	var child0 = get_node("HBoxContainer")
	print(child0)
	ItemContent.text= content
func SetId(content:String):
	print("SetId")
	ItemContent.text= content

#endregion
