extends ImmediateGeometry

func create_line(points):
	if points==null or points.size()<=1:
		return
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	set_color(Color.red)
	
	for p in points:
		add_vertex(p)
	end()
func clear_line():
	clear()
