extends Spatial
signal done


onready var targetScenePath = "res://sceneList/zone0005_disco/Disco.tscn"

onready var areaNode = $"Area"
onready var portalTargetSceneNode = get_tree ().get_root ().find_node("PortalTargetScene", true, false)
onready var passageway = $"passageway"
onready var tweenNode = $"Tween"
onready var animationPlayer = $"AnimationPlayer"
#thread load
onready var resourceAsyncLoader = ResourceAsyncLoader.new()
onready var thread: = Thread.new()
onready var mutex = Mutex.new()
onready var threadTask = null
onready var threadTaskOut = null


func _ready():
	areaNode.connect("body_entered",self,"OnBodyEnteredCallback")
	resourceAsyncLoader.start()
	thread.start(self, 'threaded_load', 0)
	
func OnBodyEnteredCallback(body):
	if(body.name.find("Player")!=-1):
		PortalLoad()

func PortalLoad():
	#Step 1: Load target scene
	threadTask = targetScenePath
	yield(self, "done")
	
	var childeNumber = threadTaskOut.get_child_count()
	for i in range(childeNumber):
	
		var child = threadTaskOut.get_child(0)
		threadTaskOut.remove_child(child)
		portalTargetSceneNode.add_child(child)
		child.set_owner(portalTargetSceneNode)
		yield(get_tree(),"idle_frame")
		yield(get_tree(),"idle_frame")
		yield(get_tree(),"idle_frame")
	threadTaskOut.queue_free()
#	portalTargetSceneNode.add_child(threadTaskOut)

	#Step 2: Open passageway
	ShowPassageway()




#region Internal Method 
func ShowPassageway():
	passageway.show()
	animationPlayer.play("PassagewayOpen")
	
#endregion





func threaded_load(id):
	while(true):
		if threadTask != null :
			threadTaskOut = load(threadTask).instance()
			threadTask = null
			call_deferred('emit_signal', 'done')

