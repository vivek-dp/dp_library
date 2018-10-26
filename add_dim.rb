require_relative './rows.rb'
require 'sketchup.rb'


#Component adjacent hash
comp_h = {4769=>{:type=>:double, :adj=>[4770], :dims=>{}}, 4774=>{:type=>:double, :adj=>[4775], :dims=>{}}, 4768=>{:type=>:single, :adj=>[], :dims=>{}}, 4766=>{:type=>:double, :adj=>[4767], :dims=>{}}, 4767=>{:type=>:double, :adj=>[4768], :dims=>{}}, 4880=>{:type=>:single, :adj=>[], :dims=>{}}, 4772=>{:type=>:single, :adj=>[], :dims=>{}}, 6179=>{:type=>:double, :adj=>[], :dims=>{}}, 4775=>{:type=>:single, :adj=>[], :dims=>{}}, 4770=>{:type=>:double, :adj=>[4880], :dims=>{}}, 9117=>{:type=>:double, :adj=>[], :dims=>{}}, 7310=>{:type=>false, :adj=>[], :dims=>{}}, 7311=>{:type=>false, :adj=>[], :dims=>{}}}
#Row array of arrays
rows = [
	[6179, 4774, 4775],
	[6179, 4772],
	[9117, 4769, 4770, 4880],
	[9117, 4766, 4767, 4768]
]
singles = [4768, 4880, 4772, 4775]
corners = [9117, 6179]
#DIM_OFFSET = 10
Sketchup.active_model.layers.add('dimension_layer') if Sketchup.active_model.layers['dimension_layer'].nil?

def lower_bounds e; return e.bounds.corner(0), e.bounds.corner(1), e.bounds.corner(3), e.bounds.corner(2);end
DIM_HEIGHT = -200
STD_DIM_DIST = 20
comp_h.keys.each{|cid|
	comp = DP.get_comp_pid cid
	next if comp.nil?
	pts = lower_bounds comp
	
	(0..3).each{|i| pts[i].z = DIM_HEIGHT}
	face = Sketchup.active_model.entities.add_face(pts)
	face.layer 	= 	'dimension_layer'
	face.hidden	=	true
}

def add_dimensions comp, corner=false
	corners = [9117, 6179]
	#puts "comp : #{comp}"
	rotz = comp.transformation.rotz  
	corner = true if corners.include?(comp.persistent_id)
	case rotz
	when 0
		st_index, end_index, vector = 2,3, Geom::Vector3d.new(0,DIM_OFFSET,0)
	when 90
		st_index, end_index, vector = 0,2, Geom::Vector3d.new(-DIM_OFFSET,0,0)
		st_index, end_index = 0, 1 if corner
	when 180
		st_index, end_index, vector = 0,1, Geom::Vector3d.new(0,-DIM_OFFSET,0) 	
	when -90
		st_index, end_index, vector = 1,3, Geom::Vector3d.new(DIM_OFFSET,0, 0) 
	end	
	pt1, pt2 = TT::Bounds.point(comp.bounds, st_index), TT::Bounds.point(comp.bounds, end_index)
	#puts pt1, pt2, vector
	
	puts "corner : #{corner} : #{comp.persistent_id}"
	pt1.z=DIM_HEIGHT;pt2.z=DIM_HEIGHT;
	unless corner
		dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)
		dim_l.layer = 'dimension_layer'
		dim_l.arrow_type=1
	end
	return pt1, pt2, vector
end

#rows.flatten.uniq.each { |comp_id|
#	add_dimensions DP.get_comp_pid comp_id
#}
row_dim = []
singles_position = {}
rows.each{ |row|
	puts "row : #{row}"
	#DIM_OFFSET += 10
	row.sort_by!{|r| comp=DP.get_comp_pid r; comp.transformation.origin.x}
	pts = []
	start_comp 	= row.first
	end_comp 	= row.last
	row_vector 	= ''
	pt1, pt2, vector = add_dimensions DP.get_comp_pid start_comp
	pts << [pt1, pt2]
	pt1, pt2, vector = add_dimensions DP.get_comp_pid end_comp
	pts << [pt1, pt2]
	
	#Add singles position
	singles_position[start_comp] = :start if singles.include?(start_comp)
	singles_position[end_comp] = :end if singles.include?(end_comp)
	
	#row_vector = vector
	#puts "--------------------"
	#puts pts.combination(2).to_a
	#puts "--------------------"
	curr_dist = 0
	arr = pts.combination(2).to_a.flatten
	arr = arr.inject([]){ |array, point| array.any?{ |p| p == point } ? array : array << point }
	#puts "arr : #{arr}"
	row_pts = ''
	arr.combination(2).to_a.each{|comb| 
		#puts "comb : #{comb}"
		dist = comb[0].distance comb[1];
		
		if dist >curr_dist
			row_pts=comb 
			curr_dist = dist
		end
	}
	puts "row_pts : #{row_pts} : #{curr_dist} : #{vector}"

	if row.length > 2 #temp reason
		(1..row.length-2).each{|i|
			pt1, pt2, row_vector = add_dimensions DP.get_comp_pid row[i]
			puts "vector................. #{i} : #{row_vector}"
		}
	else
		row_vector = vector
	end
	puts "row vector : #{row_vector}"
	
	unless row_pts.empty?
		pt1 = row_pts[0]; pt1.z=-200
		pt2 = row_pts[1]; pt2.z=-200
		row_dim << [pt1, pt2, row_vector]
	end
	
}
corners.each{|cor|
	comp = DP.get_comp_pid cor
	rotz = comp.transformation.rotz  
	case rotz
	when 0
		pts = [2,3, Geom::Vector3d.new(0,DIM_OFFSET,0)], [0,2, Geom::Vector3d.new(-DIM_OFFSET,0,0)]
	when -90
		pts = [2,3, Geom::Vector3d.new(0,DIM_OFFSET,0)], [1,3, Geom::Vector3d.new(DIM_OFFSET,0, 0)]
	when 180
		pts = [0,1, Geom::Vector3d.new(0,-DIM_OFFSET,0)], [1,3, Geom::Vector3d.new(DIM_OFFSET,0, 0)]  	
	when 90
		pts = [0,1, Geom::Vector3d.new(0,-DIM_OFFSET,0)], [0,2, Geom::Vector3d.new(-DIM_OFFSET,0,0)] 
	end	
	pts.each { |pt|
		pt1, pt2 = TT::Bounds.point(comp.bounds, pt[0]), TT::Bounds.point(comp.bounds, pt[1])
		vector = pt[2]

		pt1.z=DIM_HEIGHT;pt2.z=DIM_HEIGHT;
		dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)
		dim_l.layer = 'dimension_layer'
		dim_l.arrow_type=1
	}
}
=begin
singles_position.each_pair{|id, posn|
	comp = DP.get_comp_pid cor
	rotz = comp.transformation.rotz  
	case rotz
	when 0
		pts = [2,3, Geom::Vector3d.new(0,DIM_OFFSET,0)], [0,2, Geom::Vector3d.new(-DIM_OFFSET,0,0)]
	when -90
		pts = [2,3, Geom::Vector3d.new(0,DIM_OFFSET,0)], [1,3, Geom::Vector3d.new(DIM_OFFSET,0, 0)]
	when 180
		pts = [0,1, Geom::Vector3d.new(0,-DIM_OFFSET,0)], [1,3, Geom::Vector3d.new(DIM_OFFSET,0, 0)]  	
	when 90
		pts = [0,1, Geom::Vector3d.new(0,-DIM_OFFSET,0)], [0,2, Geom::Vector3d.new(-DIM_OFFSET,0,0)] 
	end	
	
}
=end
DIM_OFFSET += 30
row_dim.each { |row|
	pt1, pt2, row_vector = row[0], row[1], row[2]
	if row_vector.x != 0
		row_vector.x > 0 ? row_vector.x += STD_DIM_DIST : row_vector.x -= STD_DIM_DIST
	end
	if row_vector.y != 0
		row_vector.y > 0 ? row_vector.y += STD_DIM_DIST : row_vector.y -= STD_DIM_DIST
	end
	dim_l = Sketchup.active_model.entities.add_dimension_linear pt1, pt2, row_vector
	dim_l.layer = 'dimension_layer'
	dim_l.arrow_type=1
}

puts "posn : #{singles_position}"
#load 'C:\Users\Decorpot-020\Desktop\poc\add_dim.rb'