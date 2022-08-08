extends Reference

# 用户工具类
class_name PlayerTool

# =============================================================================
# 初始化人物
# =============================================================================

# 初始化人物形象	
static func init_character(data: Array, skeleton: Node, camera: Camera):
	if data == null or skeleton == null or data.empty():
		return
	for model in data:
		var nodeName:String = model.category_name
		# 1.背景色
		if nodeName.matchn("9_Background"):
			setup_background(model, camera)
			var viewportContainer:ViewportContainer=skeleton.get_parent().get_parent().get_parent().get_node("ViewportContainer")
			if viewportContainer!=null:
				var viewport:Viewport=viewportContainer.get_node_or_null("Viewport")
				if viewport!=null:
					var bgCamera:Camera=viewport.get_node_or_null("Camera")
					#if skeleton.get_parent().get_parent().get_parent().get_node("ViewportContainer/Viewport/Camera")!=null:
					if 	bgCamera!=null:
						setup_background(model, bgCamera)
			continue
		# 2.骨骼相关
		#var childCount=skeleton.get_child_count()
		#for index in childCount:
		#	var child:Node=skeleton.get_child(index)
		#	var showNode=show_node(data,child.name)
			#SkyBridge.printLog(str("child.name->",child.name,"showNode  ",showNode))
		#	child.visible=showNode
		setup_skeleton(model, skeleton)
		#else :
				
		pass
	pass

static func show_node(data: Array,nodeName:String):
	for index in data.size():
		var item=data[index]
		var categoryName:String=item["category_name"]
		if categoryName.matchn(nodeName):
			return true
	return false
# 处理 背景色 数据
static func setup_background(data: Dictionary, camera: Camera):
	if data == null or camera == null or data.empty():
		return
	var materials:Array = data["material_info"]
	if materials != null and materials.size() > 0:
		var color = materials[0]["color"]
		camera.environment.set_bg_color(Color8(color.r, color.g, color.b, 255))
	pass


# 处理 骨骼的 material
static func setup_skeleton(data: Dictionary, skeleton: Node):
	if data == null or skeleton == null or data.empty():
		return

	var node:MeshInstance = skeleton.get_node(data.category_name)  # 节点名称
	#SkyBridge.printLog(str("setup_skeleton node->",node.name))
	
	if node == null:
		#SkyBridge.printLog(str("node节点没有找到 --> ", data.category_name))
		return

	var active = data["active"]  # 是否激活，0 未激活， 1 激活
	if active == 0:
		node.visible = false
		return

	node.visible = true
	var meshName:String = data["name"]  # 模型名称
	#SkyBridge.printLog(str("mesh->",meshName))
	#if meshName.ends_with("_000.mesh"):  # 000.mesh是没有mesh，001.mesh是基础版
	#	meshName = "A_Empty_000.mesh"
	if data.category_name.matchn("17_Helmet") :
		if meshName.matchn("A_17_Helmet_000.mesh"):
			skeleton.get_node("13_Hair").visible=true
			skeleton.get_node("14_Beard").visible=true
			skeleton.get_node("15_Accessory").visible=true
			skeleton.get_node("16_Hat").visible=true
		else :
			skeleton.get_node("13_Hair").visible=false
			skeleton.get_node("14_Beard").visible=false
			skeleton.get_node("15_Accessory").visible=false
			skeleton.get_node("16_Hat").visible=false	
		

	var mesh = ResourceLoader.load("res://player-manager/player/assets/Mesh/" + meshName)
	if mesh == null:  # Mesh 没有找到
		#SkyBridge.printLog(str("Mesh没有找到 --> ", meshName))
		node.visible = false
		return

	node.mesh = mesh
	var materials:Array = data["material_info"]  # 材质信息
	
	for materialIndex in materials.size():
		var materialItem:Dictionary = materials[materialIndex]
		var materialName:String = materialItem["name"]  # 材质名称
		SkyBridge.printLog(str("materialName->",materialName))
		if materialName == null or materialName.empty():
			#SkyBridge.printLog(str("材质name为空 --> ", materialName, " 对应的Mesh是 ", meshName))
			continue
		var material:ShaderMaterial = ResourceLoader.load("res://player-manager/player/assets/Material/" + materialName)
		if material == null:  # 材质没有找到
			#SkyBridge.printLog(str("材质没有找到 --> ", materialName, " 对应的Mesh是 ", meshName))
			continue
		if materialItem.has("color") and material.get_shader_param("texture") == null:
			var color = materialItem["color"]  # 256颜色数据
			if color != null and color.has("r") and color.has("g") and color.has("b"):
				var r = int(color["r"])
				var g = int(color["g"])
				var b = int(color["b"])
				material.set_shader_param("base_color",Color8(r, g, b))
				#material.shader.set_default_texture_param() = Color8(r, g, b)
		node.set_surface_material(materialIndex, material)  # 为Mesh资源的表面设置Material
		pass
	pass



# =============================================================================
# 获取
# =============================================================================

# 获取骨骼上面的mesh和材质，数组内容是 Dictionary 格式如下
#	{
#	    "active":1,
#	    "name":"A_Empty_000.mesh",
#	    "material_info":[
#	        {
#	            "name":"Color_10_Skin.material",
#	            "color":{
#	                "r":255,
#	                "g":255,
#	                "b":255
#	            }
#	        }
#	    ]
#	}
static func get_skeleton(skeleton: Node) -> Array:
	if skeleton == null:
		return []

	var childCount = skeleton.get_child_count()
	var postData: Array = []
	
	for index in range(childCount):
		var itemNode: MeshInstance = skeleton.get_child(index)
		SkyBridge.printLog(str("get_skeleton index->",index,"  node->",itemNode.name))
		var data: Dictionary = {}
		if itemNode.visible == false:
			data["active"] = 0
		else :
			data["active"] = 1
			
		if itemNode.mesh == null:  # 有些暂时没有设置 mesh
			SkyBridge.printLog(str(itemNode.name,"暂无mesh"))
			pass
		else :
			var meshLocalPath = itemNode.mesh.resource_path
			SkyBridge.printLog(str("get_skeleton meshLocalPath->",meshLocalPath))
			var meshIndex = meshLocalPath.find_last("/")
			var meshName = meshLocalPath.substr(meshIndex + 1, meshLocalPath.length())
			SkyBridge.printLog(str("get_skeleton meshName->",meshName))
			if meshName.count("::") >= 1:  # 处理奇怪的数据，可能会有这种数据 Armature.tscn::16
				continue
			data["name"] = meshName
			data["material_info"] = get_material_with(itemNode)
			pass 	
		postData.append(data)
		SkyBridge.printLog(str("get_skeleton postData->",postData))
	return postData


# 获取 Node 节点的 material
static func get_material_with(itemNode: Node) -> Array:
	if itemNode == null:
		return []
	
	var materialCount = itemNode.get_surface_material_count()
	SkyBridge.printLog(str(itemNode.name," materialCount->",materialCount))
	if materialCount <= 0:
		return []
	
	var array: Array = []
	for materialIndex in materialCount:
		var material:SpatialMaterial = itemNode.get_surface_material(materialIndex)
		if material != null:
			var data: Dictionary = {}
			data["name"] = material.resource_name + ".material"
			if material.albedo_texture == null and material.albedo_color != null:
				var color = material.albedo_color
				data["color"] = {"r": color.r8, "g": color.g8, "b": color.b8}
			array.append(data)
	SkyBridge.printLog(str(itemNode.name," material->",array))
	return array


# 获取 相机 节点的 material 背景色
static func get_camera_bg_with(camera: Camera) -> Dictionary:
	var bgItem: Dictionary = {}
	if camera == null:
		return bgItem
	
	bgItem["name"] = "A_9_Background_000.mesh"
	bgItem["active"] = 1
	
	var bgColor: Dictionary = {}
	var tempColor = camera.environment.background_color
	bgColor["name"] = "bgColor"
	bgColor["color"] = {"r": tempColor.r8, "g": tempColor.g8, "b": tempColor.b8}
	bgItem["material_info"] = [bgColor]
	
	return bgItem
