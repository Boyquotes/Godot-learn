extends Node

signal beat

enum GroupType{Fast, Middle, Slow}
var AudioLoaderScript = load("res://sceneList/demo28_LaunchPad/Script/AudioImport.gd")

#region Export Variable
var AudioResourePath = "res://sceneList/demo28_LaunchPad/Audio/"


# res://sceneList/demo28_LaunchPad/Audio/loop/fast/快速A1.wav
var bpm = [100.3071, 100.3071, 70.3071]
var filePattern = ["\/loop\/fast\/([\\s\\S])+.wav$", "\/loop\/middle\/([\\s\\S])+.wav$", "\/loop\/slow\/([\\s\\S])+.wav$", "\/transition\/([\\s\\S])+.wav$"]
var fileSubPattern = ["A(\\d){1,2}", "B(\\d){1,2}", "C(\\d){1,2}", "D(\\d){1,2}", "E(\\d){1,2}", "F(\\d){1,2}"]
#endregion


#region Internal Variable
onready var currentBeat=0
onready var launchPadAudio:LaunchPadAudio = LaunchPadAudio.new()
onready var currentGroupType = null
onready var audioStreamPlayer = []
onready var audioStreamSample = AudioStreamSample.new()

onready var timer = get_node("Timer")
onready var audioAddArray = []
onready var audioRemoveArray = []

onready var currentLaunchNum = -1 
onready var enableGroup = [false, false, false, false, false, false]

#region Godot Callback
func _ready():
	LoadAudioResource()
	InitAudioStreamPlayer()
	timer.connect("timeout", self, "ExecuteTast")

#endregion


#region Public Method
func LaunchAudio(groupType, launchNum):
	if(launchNum>5 or launchNum<-1):
		return

	if(currentGroupType!=null and groupType != currentGroupType):
		StopAllPlay()
		PlayTransition()
		yield(get_tree().create_timer(PlayTransition()), "timeout")

	match groupType:
		GroupType.Fast:
			SetRhythmTimer(launchPadAudio.fast.bpm)
			PlayLoop(launchPadAudio.fast, launchNum)
		GroupType.Middle:
			SetRhythmTimer(launchPadAudio.middle.bpm)
			PlayLoop(launchPadAudio.middle, launchNum)
		GroupType.Slow:
			SetRhythmTimer(launchPadAudio.slow.bpm)
			PlayLoop(launchPadAudio.slow, launchNum)

	currentGroupType = groupType

#endregion


#region Internal Method

func StopAllPlay():
	for i in range(6):
		enableGroup[i] = false

	for item in  audioStreamPlayer:
		item.stop()

	currentLaunchNum = -1
func PlayLoop(launchPadAudioLoop:LaunchPadAudioLoop, launchNum = 0):

	if(launchNum > currentLaunchNum):  #Add
		for i in range(currentLaunchNum, launchNum):
			var randomGroupIndex = GroupRandom(launchPadAudioLoop)
			enableGroup[randomGroupIndex] = true
			match randomGroupIndex:
				0:
					AddAudioAddTask(StringArrayRandom(launchPadAudioLoop.groupA.audioPath) ,audioStreamPlayer[0])
				1:
					AddAudioAddTask(StringArrayRandom(launchPadAudioLoop.groupB.audioPath) ,audioStreamPlayer[1])
				2:
					AddAudioAddTask(StringArrayRandom(launchPadAudioLoop.groupC.audioPath) ,audioStreamPlayer[2])
				3:
					AddAudioAddTask(StringArrayRandom(launchPadAudioLoop.groupD.audioPath) ,audioStreamPlayer[3])
				4:
					AddAudioAddTask(StringArrayRandom(launchPadAudioLoop.groupE.audioPath) ,audioStreamPlayer[4])
				5:
					AddAudioAddTask(StringArrayRandom(launchPadAudioLoop.groupF.audioPath) ,audioStreamPlayer[5])

	elif(launchNum < currentLaunchNum): #Remove
		for i in range(launchNum, currentLaunchNum):
			var randomGroupIndex = GroupRandom(launchPadAudioLoop, false)
			enableGroup[randomGroupIndex] = false
			match randomGroupIndex:
				0:
					AddAudioRemoveTask(audioStreamPlayer[0])
				1:
					AddAudioRemoveTask(audioStreamPlayer[1])
				2:
					AddAudioRemoveTask(audioStreamPlayer[2])
				3:
					AddAudioRemoveTask(audioStreamPlayer[3])
				4:
					AddAudioRemoveTask(audioStreamPlayer[4])
				5:
					AddAudioRemoveTask(audioStreamPlayer[5])
	else: #ChangeCombination
		var currentLaunchNumCopy = currentLaunchNum
		StopAllPlay()
		PlayLoop(launchPadAudioLoop, currentLaunchNumCopy)

	currentLaunchNum = launchNum

func SetRhythmTimer(bpm):
	timer.wait_time = 60/bpm

func PlayTransition():
	var audioStream :AudioStream= load(StringArrayRandom(launchPadAudio.transition.audioPath))

	audioStreamPlayer[0].stream = audioStream
	audioStreamPlayer[0].play()

	return audioStream.get_length()
	

func LoadAudioResource():
	var files = listFilesInDirectory(AudioResourePath)

	var regex = RegEx.new()

	regex.compile(filePattern[0])
	launchPadAudio.fast = MakeLaunchPadAudioLoop(StringArrayFilterByRegEx(files, regex))
	launchPadAudio.fast.bpm = bpm[0]

	regex.compile(filePattern[1])
	launchPadAudio.middle = MakeLaunchPadAudioLoop(StringArrayFilterByRegEx(files, regex))
	launchPadAudio.middle.bpm = bpm[1]

	regex.compile(filePattern[2])
	launchPadAudio.slow = MakeLaunchPadAudioLoop(StringArrayFilterByRegEx(files, regex))
	launchPadAudio.slow.bpm = bpm[2]

	regex.compile(filePattern[3])
	launchPadAudio.transition = AudioGroup.new(StringArrayFilterByRegEx(files, regex))

func InitAudioStreamPlayer():
	audioStreamPlayer = FindMultiNodeByType(self.get_tree().get_root(), "AudioStreamPlayer")

func SetAudioStreamPlayer(filePath, audioStreamPlayer:AudioStreamPlayer):
	var audioStream :AudioStream= load(filePath)
	audioStreamPlayer.set_stream(audioStream)
	audioStreamPlayer.set_volume_db(3.0)
	audioStreamPlayer.play()

func AddAudioAddTask(audioPath, audioStreamPlayer):
	var taskParam = {}
	taskParam["audioPath"] = audioPath
	taskParam["audioStreamPlayer"] = audioStreamPlayer
	audioAddArray.append(taskParam)


func AddAudioRemoveTask(audioStreamPlayer):
	audioRemoveArray.append(audioStreamPlayer)

func GroupRandom(launchPadAudioLoop, findUnEnable = true):
	var randomGroup = []
	for i in range(enableGroup.size()):
		if(!enableGroup[i] and findUnEnable):
			randomGroup.append(i)
		elif(enableGroup[i] and !findUnEnable):
			randomGroup.append(i)
	randomize()
	var randIndex:int = randi() % randomGroup.size()
	return randomGroup[randIndex]

func MakeLaunchPadAudioLoop(filePathArray):
	var subRegex = RegEx.new()
	var launchPadAudioLoop = LaunchPadAudioLoop.new()
	subRegex.compile(fileSubPattern[0])
	launchPadAudioLoop.groupA = AudioGroup.new(StringArrayFilterByRegEx(filePathArray, subRegex)) 
	subRegex.compile(fileSubPattern[1])
	launchPadAudioLoop.groupB = AudioGroup.new(StringArrayFilterByRegEx(filePathArray, subRegex)) 
	subRegex.compile(fileSubPattern[2])
	launchPadAudioLoop.groupC = AudioGroup.new(StringArrayFilterByRegEx(filePathArray, subRegex)) 
	subRegex.compile(fileSubPattern[3])
	launchPadAudioLoop.groupD = AudioGroup.new(StringArrayFilterByRegEx(filePathArray, subRegex)) 
	subRegex.compile(fileSubPattern[4])
	launchPadAudioLoop.groupE = AudioGroup.new(StringArrayFilterByRegEx(filePathArray, subRegex)) 
	subRegex.compile(fileSubPattern[5])
	launchPadAudioLoop.groupF = AudioGroup.new(StringArrayFilterByRegEx(filePathArray, subRegex)) 
	return launchPadAudioLoop
#endregion



#region Event Callback
func ExecuteTast():
	currentBeat +=1 

	if(currentBeat==3):
		currentBeat=0
		for item in audioAddArray:
			SetAudioStreamPlayer(item["audioPath"], item["audioStreamPlayer"])
		for item in audioRemoveArray:
			item.stop()
		audioAddArray.clear()
		audioRemoveArray.clear()
		
		emit_signal("beat")
#endregion

#region Internal Class
class LaunchPadAudio:
	var fast : LaunchPadAudioLoop
	var middle : LaunchPadAudioLoop
	var slow : LaunchPadAudioLoop
	var transition : AudioGroup

class LaunchPadAudioLoop:
	var groupA : AudioGroup
	var groupB : AudioGroup
	var groupC : AudioGroup
	var groupD : AudioGroup
	var groupE : AudioGroup
	var groupF : AudioGroup
	var bpm : float

class AudioGroup:
	var audioPath : PoolStringArray
	func _init(pathArray):
		audioPath = pathArray


class AudioTask:
	var audioPath
	var audioStreamPlayer:AudioStreamPlayer

#endregion



#region Tool Script
func listFilesInDirectory(path, recursive = false)-> PoolStringArray:
	var arr: PoolStringArray
	var dir := Directory.new()
	dir.open(path)

	if dir.file_exists(path):
		arr.append(path)

	else:
		dir.list_dir_begin(true,  true)
		while(true):
			var subpath := dir.get_next()
			if subpath.empty():
				break
			arr += listFilesInDirectory(path.plus_file(subpath))

	return arr


func StringArrayFilterByRegEx(strArray:PoolStringArray, regex:RegEx) ->PoolStringArray:
	var res : PoolStringArray
	for strItem in strArray:
		if(regex.search(strItem)):
			res.append(strItem)
	return res

func FindMultiNodeByType(root:Node, type:String, res:Array = []):
	if(root.get_class()==type):
		res.append(root)
	for childNode in root.get_children():
		FindMultiNodeByType(childNode,type,res)
	return res

func StringArrayRandom(strArray):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var num = rng.randi_range(0, strArray.size()-1)
	return strArray[num]
#endregion
