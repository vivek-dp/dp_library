#-------------------------------------------------------------------------------    
# 
# File containing code for working drawing
#
#-------------------------------------------------------------------------------    

require_relative 'core.rb'

class DecorPot
    include DP
    
    def initialize
        DP::create_layers
    end
    
    #Create the working drawing for the specific view
	def working_drawing view='top'
		views = ['top', 'left', 'right', 'back', 'front']
		return nil unless views.include?(view)

		comps 	= DP::get_visible_comps view
		comp_h 	= DP::parse_components comps 
		puts "comp_h..............................."
		pp comp_h
		puts "-------------------------------------"
	end
    
    def get_outline_pts comp, view, offset
        return nil unless comp.valid?
        bounds = comp.bounds
        hit_pts = []
		case view
		when "top"
			indexes = [4,5,7,6]
			vector 	= Geom::Vector3d.new(0,0,1)
            offset  = offset - bounds.max.z 
		when "right"
			indexes = [1,3,7,5]
			vector 	= Geom::Vector3d.new(1,0,0)
            offset  = offset - bounds.max.x 
		when "left"
			indexes = [0,2,6,4]
			vector 	= Geom::Vector3d.new(-1,0,0)
            offset  = offset + bounds.min.x
		when "front"
			indexes = [0,1,5,4]
			vector 	= Geom::Vector3d.new(0,-1,0)
            offset  = offset + bounds.min.y
		when "back"
			indexes = [2,3,7,6]
			vector 	= Geom::Vector3d.new(0,1,0)
            offset  = offset - bounds.max.y
		end
		indexes.each { |i|
			hit_pts << TT::Bounds.point(bounds, i)
		}
        face_pts = []
        hit_pts.each{|pt| 
            face_pts << pt.offset(vector, offset)
        }
        face_pts
    end
    
    def add_comp_dimension comp, view='top', side_dimension=false
        return nil unless comp.valid?
        bounds = comp.bounds
        
        rotz = comp.transformation.rotz  
        
        show_dim = false
        case rotz
        when 0
            st_index, end_index, vector = 2,3, Geom::Vector3d.new(0,100,0)
            pt1, pt2 = TT::Bounds.point(comp.bounds, st_index), TT::Bounds.point(comp.bounds, end_index)
            pt1.z=500;pt2.z=500
            dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)
            
            st_index, end_index, vector = 0,2, Geom::Vector3d.new(-100,0,0)
            pt1, pt2 = TT::Bounds.point(comp.bounds, st_index), TT::Bounds.point(comp.bounds, end_index)
            pt1.z=500;pt2.z=500
            dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)
        when 90
            st_index, end_index, vector = 0,2, Geom::Vector3d.new(-100,0,0)
            pt1, pt2 = TT::Bounds.point(comp.bounds, st_index), TT::Bounds.point(comp.bounds, end_index)
            pt1.z=500;pt2.z=500
            dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)
            
            st_index, end_index, vector = 0,1, Geom::Vector3d.new(0,100,0)
            pt1, pt2 = TT::Bounds.point(comp.bounds, st_index), TT::Bounds.point(comp.bounds, end_index)
            pt1.z=500;pt2.z=500
            dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)
        when 180
            st_index, end_index, vector = 0,1, Geom::Vector3d.new(0,-100,0)
            pt1, pt2 = TT::Bounds.point(comp.bounds, st_index), TT::Bounds.point(comp.bounds, end_index)
            pt1.z=500;pt2.z=500
            dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)
            
            st_index, end_index, vector = 0,2, Geom::Vector3d.new(-100,0,0)
            pt1, pt2 = TT::Bounds.point(comp.bounds, st_index), TT::Bounds.point(comp.bounds, end_index)
            pt1.z=500;pt2.z=500
            dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)	
        when -90
            st_index, end_index, vector = 1,3, Geom::Vector3d.new(100,0,0)
            pt1, pt2 = TT::Bounds.point(comp.bounds, st_index), TT::Bounds.point(comp.bounds, end_index)
            pt1.z=500;pt2.z=500
            dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)
            
            st_index, end_index, vector = 0,1, Geom::Vector3d.new(0,-100,0)
            pt1, pt2 = TT::Bounds.point(comp.bounds, st_index), TT::Bounds.point(comp.bounds, end_index)
            pt1.z=500;pt2.z=500
            dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)
        end	
        
=begin
        st_index, end_index, vector = 0,1, Geom::Vector3d.new(0,100,0)
        pt1, pt2 = TT::Bounds.point(comp.bounds, st_index), TT::Bounds.point(comp.bounds, end_index)
        pt1.z=500;pt2.z=500
        dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)
        
        st_index, end_index, vector = 0,2, Geom::Vector3d.new(-100,0,0)
        pt1, pt2 = TT::Bounds.point(comp.bounds, st_index), TT::Bounds.point(comp.bounds, end_index)
        pt1.z=500;pt2.z=500
        dim_l = Sketchup.active_model.entities.add_dimension_linear(pt1, pt2, vector)
=end
    end
    
    def add_dimensions comp_h, view='top'
        outline_drawing comp_h, view
        corners = get_corners view
        comp_h.each { |comp_details|
            
        }
        comp_h.each { |comp_details|
            comp_id = comp_details[0]

            comp = DP::get_comp_pid comp_id
            add_comp_dimension comp
        }
    end
    
    def get_rows comp_h,  corners
        rows = []
        corners.each{|cor|
            adjs = comp_h[cor][:adj]
            row = []
            adjs.each{|adj_comp|
                row  = [cor]
                curr = adj_comp
                #comp_h[cor][:adj].delete curr
                comp_h[curr][:adj].delete cor
                while comp_h[curr][:type] == :double
                    row << curr
                    adj_next = comp_h[curr][:adj][0]
                    comp_h[adj_next][:adj].delete curr
                    comp_h[curr][:adj].delete adj_next
                    curr = adj_next
                end
                row << curr
                rows << row
            }
        }
        return rows
    end

    def get_comp_rows comp_h, view
        rows = []
        corners
    end
    
    def outline_drawing comp_h, view, offset=500 #comp_h not needed
        comps 	= DP::get_visible_comps view
		comp_h 	= DP::parse_components comps 
        
        comp_h.keys.each{|cid|
            comp = DP::get_comp_pid cid
            next if comp.nil?
            pts = get_outline_pts comp, view, offset

            face = Sketchup.active_model.entities.add_face(pts)
            face.layer 	= 	'DP_Dimension_layer'
            face.hidden	=	true
        }
    end
    
    def get_single_adj comp_h
        singles=[]; comp_h.each_pair{|x, y| singles<<x if y[:type] == :single}; return singles
    end
    
    def get_corners comp_h
        corners = []
        comp_h.each_pair{|x, y| 
            if y[:type] == :double
                adj_comps = y[:adj]
                cor_comp =  DP.get_comp_pid x
                comp1 = DP.get_comp_pid adj_comps[0]
                comp2 = DP.get_comp_pid adj_comps[1]
                if (comp1.transformation.rotz+comp2.transformation.rotz)%180 != 0
                    #This check when its row component but the adjacents are rotated
                    f1 = DP.ents.add_face(DP::get_xn_pts cor_comp, comp1)
                    f2 = DP.ents.add_face(DP::get_xn_pts cor_comp, comp2)
                    if f2.normal.perpendicular? f1.normal
                        corners<<x 
                        #DP.sel.add cor_comp
                    end
                    DP.ents.erase_entities f1, f2
                end
            end
        }
        return corners
    end
end



=begin
    def add_dims comp_h
        rows = []
        corners = get_corners comp_h
        corners.each { |comp_id|
            next if comp_h[comp_id][:adj].empty?
            puts "corner : #{comp_id}"

            #----------------------     pt1    -----------------------------
            pt1     = comp_h[comp_id][:adj][0]
            comp_h[comp_id][:adj].delete(pt1)
            row 	= [comp_id]
            prev 	= comp_id
            curr 	= pt1
            #puts comp_h[curr]
            20.times do
                curr_rotn = (DP.get_comp_pid curr).transformation.rotz
                puts curr_rotn
                if comp_h[curr][:type] == :single || corners.include?(curr)
                    #puts "if"
                    row<<curr
                    comp_h[curr][ :adj].delete(prev)
                    rows << row
                    break
                else
                    #puts "else"
                    row<<curr
                    comp_h[curr][:adj].delete(prev)
                    prev = curr;
                    curr = comp_h[curr][:adj][0]
                end
            end
            #puts row
            row.each{|x| DP.sel.add DP.get_comp_pid x}
            #break

            #----------------------     pt2    -----------------------------
            puts "pt2 : #{comp_h[comp_id]}"
            pt2 = comp_h[comp_id][:adj][0]
            comp_h[comp_id][:adj].delete(pt2)
            row 	= [comp_id]
            prev 	= comp_id
            curr 	= pt2
            #puts comp_h[curr]
            20.times do
                curr_rotn = (DP.get_comp_pid curr).transformation.rotz
                puts curr_rotn
                if comp_h[curr][:type] == :single || corners.include?(curr)
                    #puts "if"
                    row<<curr
                    comp_h[curr][:adj].delete(prev)
                    rows << row
                    break
                else
                    #puts "else"
                    row<<curr
                    comp_h[curr][:adj].delete(prev)
                    prev = curr;
                    curr = comp_h[curr][:adj][0]
                end
            end
            #puts row
            row.each{|x| DP.sel.add DP.get_comp_pid x}
            #break
        }
        return rows
    end
=end
