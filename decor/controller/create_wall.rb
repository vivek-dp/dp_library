require_relative 'tt_bounds.rb'

module Decor_Standards
	def self.decor_create_wall
		dialog = UI::HtmlDialog.new({:dialog_title=>"#{TITLE}", :preferences_key=>"com.sample.plugin", :scrollable=>true, :resizable=>true, :width=>600, :height=>420, :style=>UI::HtmlDialog::STYLE_DIALOG})
		html_path = File.join(WEBDIALOG_PATH, 'create_wall.html')
		dialog.set_file(html_path)
		dialog.set_position(0, 150)
		dialog.show

		dialog.add_action_callback("clickcancel") { |action_context, param1|
		  dialog.close
		}

		dialog.add_action_callback("submitval"){|ac, params|
			puts JSON.parse(params)
			puts "------------------------------"
			inp_h =	JSON.parse(params)
			return nil if inp_h.empty?
			#create walls
			mod = Sketchup.active_model
			wwidth 	= inp_h['wall1'].to_f.mm.to_inch
			wlength = inp_h['wall2'].to_f.mm.to_inch
			wheight = inp_h['wheight'].to_f.mm.to_inch
			thick	= inp_h['wthick'].to_f.mm.to_inch

			pts = [Geom::Point3d.new(0,0,0), Geom::Point3d.new(wwidth,0,0), Geom::Point3d.new(wwidth,wlength,0), Geom::Point3d.new(0,wlength,0)]
			floor_face = Sketchup.active_model.entities.add_face(pts)

			#----------------------------------------------------------------------------
				puts thick, thick.class
				pi = Math::PI
				
				
				if (not ((thick.class==Fixnum || thick.class==Float || thick.class==Length) && thick!=0))
					puts "inside" #return nil
				end
				verts = floor_face.outer_loop.vertices
				pts = []
				floor = []

				0.upto(verts.length-1) do |a|
					#puts verts[a], verts[a].position
					vec1 = (verts[a].position-verts[a-(verts.length-1)].position).normalize
					vec2 = (verts[a].position-verts[a-1].position).normalize
					vec3 = (vec1+vec2).normalize
					if vec3.valid?
						ang = vec1.angle_between(vec2)/2
						ang = pi/2 if vec1.parallel?(vec2)
						vec3.length = thick/Math::sin(ang)
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
					floor.push(verts[a].position)
				end

				duplicates = []
				pts.each_index do |a|
				pts.each_index do |b|
				next if b == a
				duplicates<<b if pts[a]===pts[b]
				end
				break if a == pts.length - 1
				end
				duplicates.reverse.each{|a| pts.delete(pts[a])}

				(pts.length > 2) ? (f = Sketchup.active_model.entities.add_face(pts)) : 0
				f.pushpull -wheight

			#----------------------------------------------------------------------------

			door_h 			= inp_h["door"]
			door_view 		= door_h['door_view'].to_sym
			door_position	= door_h['door_position'].to_f.mm.to_inch
			door_height		= door_h['door_height'].to_f.mm.to_inch
			door_width		= door_h['door_length'].to_f.mm.to_inch
			zvector			= Geom::Vector3d.new(0, 0, 1)

			case door_view
			when :front	
				vector 		= Geom::Vector3d.new(-1, 0, 0)
				start_point = TT::Bounds.point(floor_face.bounds, 1) 
				
				door_start_point 	= start_point.offset(vector, door_position)
				door_end_point		= start_point.offset(vector, door_position+door_width)
				door_left_point		= door_start_point.offset(zvector, door_height)
				door_right_point	= door_end_point.offset(zvector, door_height)
				
				door = mod.entities.add_face(door_start_point, door_end_point, door_right_point, door_left_point)
				door.pushpull -thick
				
		#Use for windows creation		
=begin		
				Sketchup.active_model.entities.erase_entities door unless door.deleted?
				
				vector		= Geom::Vector3d.new(0, -1, 0)
				
				wall_start_point 	= door_start_point.offset(vector, thick)
				wall_end_point		= door_end_point.offset(vector, thick)
				wall_left_point		= wall_start_point.offset(zvector, door_height)
				wall_right_point	= wall_end_point.offset(zvector, door_height)
				
				wall_door = mod.entities.add_face(wall_start_point, wall_end_point, wall_right_point, wall_left_point)
				Sketchup.active_model.entities.erase_entities wall_door unless wall_door.deleted?
=end		
			when :back
				vector = Geom::Vector3d.new(1, 0, 0)
				start_point = TT::Bounds.point(floor_face.bounds, 2)
				
				door_start_point 	= start_point.offset(vector, door_position)
				door_end_point		= start_point.offset(vector, door_position+door_width)
				door_left_point		= door_start_point.offset(zvector, door_height)
				door_right_point	= door_end_point.offset(zvector, door_height)
				
				door = mod.entities.add_face(door_start_point, door_end_point, door_right_point, door_left_point)
				door.pushpull -thick
			when :left
				vector = Geom::Vector3d.new(0, 1, 0)
				start_point = TT::Bounds.point(floor_face.bounds, 0)
				
				door_start_point 	= start_point.offset(vector, door_position)
				door_end_point		= start_point.offset(vector, door_position+door_width)
				door_left_point		= door_start_point.offset(zvector, door_height)
				door_right_point	= door_end_point.offset(zvector, door_height)
				
				door = mod.entities.add_face(door_start_point, door_end_point, door_right_point, door_left_point)
				door.pushpull -thick
			when :right
				vector = Geom::Vector3d.new(0, -1, 0)
				start_point = TT::Bounds.point(floor_face.bounds, 3)
				
				door_start_point 	= start_point.offset(vector, door_position)
				door_end_point		= start_point.offset(vector, door_position+door_width)
				door_left_point		= door_start_point.offset(zvector, door_height)
				door_right_point	= door_end_point.offset(zvector, door_height)
				
				door = mod.entities.add_face(door_start_point, door_end_point, door_right_point, door_left_point)
				door.pushpull -thick
			end
		}
		
	end
end