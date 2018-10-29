#-----------------------------------------------
#
#Decorpot Sketchup Core library
#
#-----------------------------------------------

require 'sketchup.rb'
require_relative 'tt_bounds.rb'
require_relative 'test.rb'

module DP
	def self.mod
		Sketchup.active_model
	end
	
	def self.ents
		Sketchup.active_model.entities
	end
	
	def self.comps
		Sketchup.active_model.entities.grep(Sketchup::ComponentInstance)
	end
	
	def self.sel
		Sketchup.active_model.selection
	end
	
	def self.fsel
		Sketchup.active_model.selection[0]
	end
	
	def self.fpid
		compn = Sketchup.active_model.selection[0]
		return compn.persistent_id if compn.is_a?(Sketchup::ComponentInstance)
		return nil
	end
	
	def self.pid entity
		return entity.persistent_id if entity.is_a?(Sketchup::ComponentInstance)
		return nil
	end
	
	def self.lower_bounds e; 
		return e.bounds.corner(0), e.bounds.corner(1), e.bounds.corner(3), e.bounds.corner(2);
	end
	
	def self.get_comp_pid id;
		Sketchup.active_model.entities.each{|x| return x if x.persistent_id == id};
		return nil;
	end
	
	#Input 	:	Face, offset distance
	#return :	Array of offset points
	def self.face_off_pts(face, dist)
		pi = Math::PI
		
		return nil unless face.is_a?(Sketchup::Face)
		if (not ((dist.class==Fixnum || dist.class==Float || dist.class==Length) && dist!=0))
			return nil
		end
		
		verts=face.outer_loop.vertices
		pts = []
		
		# CREATE ARRAY pts OF OFFSET POINTS FROM FACE
		
		0.upto(verts.length-1) do |a|
			vec1 = (verts[a].position-verts[a-(verts.length-1)].position).normalize
			vec2 = (verts[a].position-verts[a-1].position).normalize
			vec3 = (vec1+vec2).normalize
			if vec3.valid?
				ang = vec1.angle_between(vec2)/2
				ang = pi/2 if vec1.parallel?(vec2)
				vec3.length = dist/Math::sin(ang)
				t = Geom::Transformation.new(vec3)
				if pts.length > 0
					vec4 = pts.last.vector_to(verts[a].position.transform(t))
					if vec4.valid?
						unless (vec2.parallel?(vec4))
							t = Geom::Transformation.new(vec3.reverse)
						end
					end
				end
				
				pts.push(verts[a].position.transform(t))
			end
		end
		duplicates = []
		pts.each_index do |a|
			pts.each_index do |b|
				next if b==a
				duplicates<<b if pts[a]===pts[b]
			end
			break if a==pts.length-1
		end
		duplicates.reverse.each{|a| pts.delete(pts[a])}
		return pts
	end
	
	def self.get_view_face view
		ent	  = Sketchup.active_model.entities
		l,x,y,z = 1000, 500, 500, 500
		
		case view
		when "top"
			pts = [[-l,-l,z], [l,-l,z], [l,l,z], [-l,l,z]]
			hit_face = ent.add_face pts
		when "right"
			pts = [[x,-l,-l], [x,l,-l], [x,l,l], [x,-l,l]]
			hit_face = ent.add_face pts
		when "left"
			pts = [[-x,-l,-l], [-x,l,-l], [-x,l,l], [-x,-l,l]]
			hit_face = ent.add_face pts
		when "front"
			pts = [[-l,-y,-l], [l,-y,-l], [l,-y,l], [-l,-y,l]]
			hit_face = ent.add_face pts
		when "back"
			pts = [[-l,y,-l], [l,y,-l], [l,y,l], [-l,y,l]]
			hit_face = ent.add_face pts
		end
		return hit_face
	end
	
	def self.get_points comp, view
		hit_pts = []
		mod	  = Sketchup.active_model
		ent	  = mod.entities
		
		bounds = comp.bounds
		case view
		when "top"
			indexes = [4,5,7,6,10,11,13,15,24]
			vector 	= Geom::Vector3d.new(0,0,1)
		when "right"
			indexes = [1,3,7,5,14,15,17,19,21]
			vector 	= Geom::Vector3d.new(1,0,0)
		when "left"
			indexes = [0,2,6,4,12,13,16,18,20]
			vector 	= Geom::Vector3d.new(-1,0,0)
		when "front"
			indexes = [0,1,5,4,8,10,16,17,22]
			vector 	= Geom::Vector3d.new(0,-1,0)
		when "back"
			indexes = [2,3,7,6,9,11,18,19,23]
			vector 	= Geom::Vector3d.new(0,1,0)
		end
		indexes.each { |i|
			hit_pts << TT::Bounds.point(bounds, i)
		}
        temp_face = ent.add_face(hit_pts[0],hit_pts[1],hit_pts[2],hit_pts[3])
		hit_pts = face_off_pts temp_face, -2
		#temp_face = ent.add_face(hit_pts[0],hit_pts[1],hit_pts[2],hit_pts[3])
		del_comps = [temp_face, temp_face.edges]
		del_comps.flatten.each{|x| ent.erase_entities x unless x.deleted?}
		
		return hit_pts, vector
	end
	
	#Get visible decorpot components from the view
	# floor = Sketchup.active_model.entities.select{|c| c.layer.name == 'DP_Floor'}[0]
	# pts = face_off_pts floor, 50
	# (pts.length).times{|i| pts[i].z = 200}
	# hit_face = Sketchup.active_model.entities.add_face(pts)
	def self.get_visible_comps view='top'
		mod	  = Sketchup.active_model
		ent	  = mod.entities
				
		comps = ent.grep(Sketchup::ComponentInstance)
        comps = comps.select{|x| x.hidden? == false}
		
		#comps = Sketchup.active_model.selection
		
		hit_face = get_view_face view
		visible_comps = []
		comps.each{|comp|
			pts, nor_vector = get_points comp, view
			#ent.add_face(pts)
			pts.each { |pt|
				hit_item = mod.raytest(pt, nor_vector)
				if hit_item && hit_item[1][0] == hit_face
					visible_comps << comp
					mod.selection.add comp
					break
				end
			}
		}
		del_comps = [hit_face, hit_face.edges]
		del_comps.flatten.each{|x| 
            unless x.deleted?
                ent.erase_entities x 
            end
        }
		return visible_comps
	end
	
	#Get the intersection of two components
	def self.get_xn_pts c1, c2
		xn = c1.bounds.intersect c2.bounds
		corners = []
		(0..7).each{|x| corners<<xn.corner(x)}
		arr = corners.inject([]){ |array, point| array.any?{ |p| p == point } ? array : array << point }
		return arr
	end

	
	def self.check_adj c1, c2
		return 0 unless (c1.bounds.intersect c2.bounds).valid?
		corners=[];
		intx=c1.bounds.intersect c2.bounds;
		(0..7).each{|x| corners<<intx.corner(x)}
		#puts corners
		return corners.map{|x| x.to_s}.uniq.length
	end
	
	def self.get_schema comp_arr
		comps = {}
		comp_arr.each {|comp| 
			next if comp.definition.name == 'region'
			pid = DP::pid comp;
			comps[pid] = {:type=>false, :adj=>[] , :row_elem=>false}
		}
		comps
	end
    
    def self.del_face face
        face.edges.each{|x| Sketchup.active_model.entities.erase_entities x unless x.deleted?}
    end
	
	#Parse the components and get the hash.
	def self.parse_components comp_arr
		comp_list = get_schema comp_arr
		corners = []
		comp_list.keys.each { |id|
			#lb_curr = lower_bounds id 
			adj_comps = []
			outer_comp = DP.get_comp_pid id
			#DP.comps.each{|inner_comp| # Just delete this line.........Not needed
            comp_arr.each{|inner_comp|    
				next if inner_comp.definition.name == 'region'
				next if outer_comp == inner_comp 
				alen = check_adj outer_comp, inner_comp
				type = :single
				if alen > 2
					next if inner_comp.definition.name == 'region'
					adj_comps << inner_comp.persistent_id
					if adj_comps.length > 1
                        adj = DP.get_comp_pid adj_comps[0]
                        #vec1    = outer_comp.bounds.center.vector_to adj.bounds.center
                        min_vec1    = outer_comp.bounds.min.vector_to adj.bounds.min
                        #max_vec1    = outer_comp.bounds.max.vector_to adj.bounds.max
                        type    = :double
                        #adj_face    = Sketchup.active_model.entities.add_face(xn_pts) 
                        (1..adj_comps.length-1).each{ |i|
                            adj_c   = DP.get_comp_pid adj_comps[i]
                            #vec2    = outer_comp.bounds.center.vector_to adj_c.bounds.center
                            min_vec2    = outer_comp.bounds.min.vector_to adj_c.bounds.min
                            #max_vec2    = outer_comp.bounds.max.vector_to adj_c.bounds.max
                            type = :corner if min_vec1.perpendicular?(min_vec2)
                            #type = :corner if max_vec1.perpendicular?(max_vec2)
                        }
                    end
					comp_list[id][:type] = type
					#corners << inner_comp.persistent_id) if adj_comps.length > 1
				end
			}

			comp_list[id][:adj] = adj_comps
		}
		return comp_list
	end
	
	#Create layers for multi components
	def self.create_layers
		layers = ['DP_Floor', 'DP_Dimension_layer', 'DP_Comp_layer', 'DP_lamination']
		layers.each { |name|
			Sketchup.active_model.layers.add(name) if Sketchup.active_model.layers[name].nil?
		}
	end
	
	def self.corners b
		arr=[];(0..7).each{|i| arr<<b.bounds.corner(i)}
		return arr
	end
	
	def self.test_mod_fun
		puts "test_mod_fun"
	end
	
	def self.test_fun
		test_mod_fun
		puts "test fun"
	end
end