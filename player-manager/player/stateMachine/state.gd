extends Spatial
class_name Model


# 是否带了帽子
var haveHat: bool = false

var modelPath: String = ""

# 开启动画开关，用于吃豆人里的鬼
var enableAnimation = true
	
func _ready() -> void:
	if(NavigatorTool.singleGameType):
		for i in $Armature/Skeleton.get_child_count():
			$Armature/Skeleton.get_child(i).set_visible(true)
		pass

# 设置模型信息 - 个人套装模型，参数是glb或者tscn的路径
func setUserGlb(path: String):
	self.modelPath = path
	if path == null or path.empty():
		return
	var glb: Resource = ResourceLoader.load(path)
	if glb == null:  # lb 或者 tscn 文件 没有找到
		SkyBridge.printLog("人物模型没有找到 --> {0}".format([path]))
		return
	
	# 准备替换人物 Armature
	var person = glb.instance()
	var armatureNode = person.get_node("Armature")
	if armatureNode == null:
		SkyBridge.printLog("人物模型没有找到 --> {0}".format([path]))
		return
	
	self.remove_child($Armature)
	person.remove_child(armatureNode)
	self.add_child(armatureNode)
	pass


# 设置模型信息 - 官方模型
func setUserModels(cell: NTUserModel):
	if cell == null:
		return

	if (cell.categoryName == "9_Background"): # 不需要被背景
		return

	var isActive = true
	if (cell.active == 0):  # 是否激活，0 未激活， 1 激活
		isActive = false

	if not $Armature/Skeleton.has_node(cell.categoryName):
		print( "node节点没有找到 --> {0}".format([cell.categoryName]) )
		return
	var node:MeshInstance = $Armature/Skeleton.get_node(cell.categoryName)

	if isActive == false:  # 是否激活，0 未激活， 1 激活
		node.visible = false
		return

	var meshName = cell.name
	var mesh = ResourceLoader.load("res://player-manager/player/assets/Mesh/" + meshName) # 部件名
	if mesh != null:
		var meshC = mesh.duplicate()
		node.visible = isActive
		node.mesh = meshC
	else:
		node.visible = false
		SkyBridge.printLog("mesh没有找到 ----> {0}".format([cell.name]))
		return
		
	if cell.materialInfo == null or cell.materialInfo.empty():  # 获取材质信息，是个数组
		return

	for materialIndex in range(cell.materialInfo.size()):
		var item:NTMaterialResponse = cell.materialInfo[materialIndex]
		
		var material = ResourceLoader.load("res://player-manager/player/assets/Material/" + item.name)
		if material == null:  # 材质没有找到
			SkyBridge.printLog("警告 - 材质没有找到 {0}".format([item.name]))
			continue
		var materialC = material.duplicate()
		if (material is SpatialMaterial) and item.color != null and material.albedo_texture == null:
			materialC.albedo_color = Color8(item.color.r, item.color.g, item.color.b)

		node.set_surface_material(materialIndex, materialC)  # 为Mesh资源的表面设置Material
		pass
	pass


# 替换 player的 skeleton 和 animation
# 如果值不为空，就不会替换
func change_player_skeleton(skeleton: Node, animation: Node):
	if skeleton != null:
		var arm = $Armature
		arm.remove_child($Armature/Skeleton)
		arm.add_child(skeleton)
		
	if animation != null:
		self.remove_child($AnimationPlayer) 
		self.add_child(animation)
	pass


# 给一个人物模型，改变现有人物模型
# 参数 modelNode 人物的模型，必须包含 Armature 节点
# 参数 include_animation 是否包含 AnimationPlayer 节点
# 返回值： 是否替换成功
func change_player_model(modelNode: Node, include_animation: bool) -> bool:
	if modelNode == null:
		return false
	var armatureNode = modelNode.get_node("Armature")
	if armatureNode == null:
		return false

	self.remove_child($Armature)
	modelNode.remove_child(armatureNode)
	self.add_child(armatureNode)
	
	if include_animation:
		var ani = modelNode.get_node("AnimationPlayer")
		if ani != null:
			self.remove_child($AnimationPlayer)
			modelNode.remove_child(ani)
			self.add_child(ani)
	return true

func enablePropFromFile(bone_name, propFile):
	var prop = ResourceLoader.load(propFile).instance()
	return enableProp(bone_name, prop)
	
func enableProp(bone_name, prop):
	var boneFile = "res://player-manager/player/Bone/" + bone_name + ".tscn"
	var bone = getBone(boneFile)
	if not prop or not bone:
		printerr("bone or prop load failed.")
		return null
	var boneProp = bone.get_node_or_null(prop.name)
	if boneProp:
		return null
	bone.add_child(prop)
	return prop
	
func disablePropFromFile(bone_name, propFile):
	var prop = ResourceLoader.load(propFile).instance()
	return disableProp(bone_name, prop)
	
func disableProp(bone_name, prop):
	var boneFile = "res://player-manager/player/Bone/" + bone_name + ".tscn"
	var bone = getBone(boneFile)
	if not prop or not bone:
		printerr("bone or prop load failed.")
		return null
	var boneProp = bone.get_node_or_null(prop.name)
	if not boneProp:
		return null
	bone.remove_child(boneProp)
	return boneProp
	
func getBone(boneFile):
	var bone = ResourceLoader.load(boneFile).instance()
	var skeleton = get_node("Armature/Skeleton")
	var skeletonBone = skeleton.get_node_or_null(bone.name)
	if not skeletonBone:
		skeleton.add_child(bone)
		return bone
	return skeletonBone

# 加上鬼头套， true显示鬼头套  false不显示鬼头套
func showYamaHat(yama: bool):
	var sk = $Armature/Skeleton
	if sk == null:  # 没有骨骼
		return
	var itemNode: MeshInstance = sk.get_node("18_Mask")
	var mesh = ResourceLoader.load("res://player-manager/player/assets/Mesh/A_18_Mask_001.mesh")
	if itemNode == null or mesh == null:
		# 没有找到抓人者头套
		return
	var hat: MeshInstance = sk.get_node("16_Hat")  # 原始的帽子
	if yama:
		itemNode.visible = true
		itemNode.mesh = mesh
		if hat != null and hat.visible == true:
			self.haveHat = true
			hat.visible = false
	else:
		itemNode.visible = false
		if self.haveHat:
			hat.visible = true
		pass
	pass


# =============================================================================
# MARK: - Debug调试
# =============================================================================

# 打印身体的材质，用于debug处理
func print_skeleton() -> String:
	var sk = $Armature/Skeleton
	if sk == null:
		return "skeleton = null"
		
	var childCount = sk.get_child_count()
	var postData: Array = []
	
	for index in range(childCount):
		var data: Dictionary = {}
		
		var itemNode: MeshInstance = sk.get_child(index)
		data["name"] = itemNode.name
		data["filename"] = itemNode.filename
		data["mesh"] = itemNode.mesh.resource_path
		data["active"] = itemNode.visible
		
		var material_info: Array = []
		var materialCount = itemNode.get_surface_material_count()
		for materialIndex in range(materialCount):
			var matData: Dictionary = {}
			
			var material:SpatialMaterial = itemNode.get_surface_material(materialIndex)
			if material == null:
				continue

			if material.resource_name == null:
				matData["resource_name"] = "null"
			else:
				matData["resource_name"] = material.resource_name + ".material"
			
			if material.resource_path == null:
				matData["resource_path"] = "null"
			else:
				matData["resource_path"] = material.resource_path
			
			var color = material.albedo_color
			if color != null:
				matData["color"] = var2str(material.albedo_color)
			else:
				matData["color"] = "null"

			material_info.append(matData)
			pass
		
		data["material_info"] = material_info
		postData.append(data)
		pass
	
	return to_json(postData)
