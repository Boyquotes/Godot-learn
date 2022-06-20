extends Spatial
var i =0
var playerHealth=100

var debugLayoutScrpt = load("res://sceneList/demo20_DebugTool/prefab/DebugLayoutDemo.gd")
var debugLayout

var networkString="{\"name\":\"格式1\",\"stringFormats\":[{\"word_num\":1,\"word_length_max\":4,\"word_length_min\":2,\"size\":32,\"text_color\":\"#F8F8FF\",\"height\":\"32\",\"orientation\":0,\"space_width\":0,\"character_spacing\":0,\"fit\":\"True\",\"word_split\":\"False\",\"position\":{\"x\":800,\"y\":40}},{\"word_num\":1,\"word_length_max\":1,\"word_length_min\":1,\"size\":32,\"text_color\":\"#000000\",\"height\":\"32\",\"orientation\":0,\"space_width\":0,\"character_spacing\":0,\"fit\":\"True\",\"word_split\":\"False\",\"position\":{\"x\":60,\"y\":500}},{\"word_num\":1,\"word_length_max\":2,\"word_length_min\":1,\"size\":32,\"text_color\":\"#000000\",\"height\":\"32\",\"orientation\":0,\"space_width\":0,\"character_spacing\":0,\"fit\":\"True\",\"word_split\":\"False\",\"position\":{\"x\":300,\"y\":500}}]}"
# fake debug variable
var roomID="4216t1251531r1tg14534"
var userToken="asfsagheriowughio1yh"

func _ready():
	
	debugLayout= Node.new()
	debugLayout.set_script(debugLayoutScrpt)
	add_child(debugLayout)
	#add fake variable to creat debug lable ui
	debugLayout.variableDict["roomID"]=roomID
	debugLayout.variableDict["userToken"]=userToken
	debugLayout.variableDict["playerHealth"]=playerHealth

func _process(delta):
	i+=1
	if(i%360==0):
		debugLayout.DebugPrint("masmdfiashgbiulegbhnwilahvgn fhsdaiufhasdiljgb")
		
	if(i%720==0):
		playerHealth-=10
		debugLayout.variableDict["playerHealth"]=playerHealth
		
	if(i%480==0):
		debugLayout.NetworkPrint(networkString)
