require 'sketchup.rb'
require 'extensions.rb'

def sel
  Sketchup.active_model.selection
end

def mod
  Sketchup.active_model
end

def ent
  Sketchup.active_model.entities
end

def visible_entities

end

def visible_faces

end

def add_dimension edge, vector

end

def stop
  Sketchup.active_model.start_operation 'testing'
end

def abop
  Sketchup.active_model.abort_operation
end

def get_points face
  pts = [face.bounds.center]
  pts << face.vertices
  pts.flatten!
end


def visible_faces faces, view
  case view
  when "top"
    l 	= 	1000
    z	  =	500
    pts = [[-l,-l,z], [l,-l,z], [l,l,z], [-l,l,z]]

    hit_face = ent.add_face pts
    pp "Top view"
    puts "hit_face : #{hit_face}"
    faces.each { |f|
      pts = get_points f
      puts "pts : #{pts}"
      pts.each do |pt|
        nor_vector = f.normal.z > 0 ? f.normal : f.normal.reverse
        hit_item = mod.raytest(pt, nor_vector)
        puts "hit_item : #{hit_item}"
        if hit_item && hit_item[1][0] == hit_face
          f.material = 'red'
        end
      end
    }
  when "right"
    l 	= 	1000
    x	  =	  500
    pts = [[x,-l,-l], [x,l,-l], [x,l,l], [x,-l,l]]

    hit_face = ent.add_face pts
    pp "Right view"
    puts "hit_face : #{hit_face}"
    faces.each { |f|
      pts = get_points f
      puts "pts : #{pts}"
      pts.each do |pt|
        nor_vector = f.normal.x > 0 ? f.normal : f.normal.reverse
        hit_item = mod.raytest(pt, nor_vector)
        puts "hit_item : #{hit_item}"
        if hit_item && hit_item[1][0] == hit_face
          f.material = 'blue'
        end
      end
    }
  when "left"
    l 	= 	1000
    x	  =	  500
    pts = [[-x,-l,-l], [-x,l,-l], [-x,l,l], [-x,-l,l]]

    hit_face = ent.add_face pts
    pp "Left view"
    puts "hit_face : #{hit_face}"
    faces.each { |f|
      pts = get_points f
      puts "pts : #{pts}"
      pts.each do |pt|
        nor_vector = f.normal.x < 0 ? f.normal : f.normal.reverse
        hit_item = mod.raytest(pt, nor_vector)
        puts "hit_item : #{hit_item}"
        if hit_item && hit_item[1][0] == hit_face
          f.material = 'green'
        end
      end
    }
  when "front"
    l 	= 	1000
    y	  =	  500
    pts = [[-l,-y,-l], [l,-y,-l], [l,-y,l], [-l,-y,l]]

    hit_face = ent.add_face pts
    pp "Front view"
    puts "hit_face : #{hit_face}"
    faces.each { |f|
      pts = get_points f
      puts "pts : #{pts}"
      pts.each do |pt|
        nor_vector = f.normal.y < 0 ? f.normal : f.normal.reverse
        hit_item = mod.raytest(pt, nor_vector)
        puts "hit_item : #{hit_item}"
        if hit_item && hit_item[1][0] == hit_face
          f.material = 'yellow'
        end
      end
    }
  when "back"
    l 	= 	1000
    y	  =	  500
    pts = [[-l,y,-l], [l,y,-l], [l,y,l], [-l,y,l]]

    hit_face = ent.add_face pts
    pp "Back view"
    puts "hit_face : #{hit_face}"
    faces.each { |f|
      pts = get_points f
      puts "pts : #{pts}"
      pts.each do |pt|
        nor_vector = f.normal.y > 0 ? f.normal : f.normal.reverse
        hit_item = mod.raytest(pt, nor_vector)
        puts "hit_item : #{hit_item}"
        if hit_item && hit_item[1][0] == hit_face
          f.material = 'DeepPink'
        end
      end
    }
  end

  #Deleting the plane created for raytest
  mod.active_entities.erase_entities hit_face.edges if hit_face
end

stop
faces = ent.grep(Sketchup::Face)
visible_faces faces, 'top'

visible_faces faces, 'right'

visible_faces faces, 'left'

visible_faces faces, 'back'

visible_faces faces, 'front'








#
# ent.grep(Sketchup::Face).each{|e|
#   v = e.normal.z > 0 ? e.normal : e.normal.reverse
#   pt1 = e.bounds.center
#   pt2 = Geom::Point3d.new(pt1.x, pt1.y, 1000)
#   puts "#{v} : #{pt1} : #{pt2}"
#   ent.add_cline(pt1, pt2)
# }
#
# ent.each do |e|
#
# end
