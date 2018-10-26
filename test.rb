#-----------------------------------------------
#
#Decorpot Sketchup Core library
#
#-----------------------------------------------

require 'C:\Users\Decorpot-020\Desktop\poc\core.rb'

#Get the component schema for the specific view TBD-view.
def comp_schema
	comps = {}
	DP::comps.each {|comp| pid = DP::pid comp;
		next if comp.definition.name == 'region'
		comps[pid] = {:type=>false, :adj=>[], :dims=>{}}
	}
	comps
end

#Parse the components and get the hash.
def parse_components
	comp_list = comp_schema
	corners = []
	comp_list.keys.each { |id|
		#lb_curr = lower_bounds id 
		adj_comps = []
		outer_comp = DP.get_comp_pid id
		DP.comps.each{|inner_comp|
			next if inner_comp.definition.name == 'region'
			next if outer_comp == inner_comp 
			alen = check_adj outer_comp, inner_comp
			
			if alen > 2
				next if inner_comp.definition.name == 'region'
				adj_comps << inner_comp.persistent_id
				adj_comps.length == 1 ? (type = :single) : (type = :double)
				comp_list[id][:type] = type
				#corners << inner_comp.persistent_id) if adj_comps.length > 1
			end
		}
		
		if adj_comps.length == 2
			#puts "adj"+adj_comps.to_s
			#DP.sel.add outer_comp
		end

		comp_list[id][:adj] = adj_comps
		# comp_list.keys.each{ |cid|
		# 	next if cid == id
		# 	lb_comp = lower_bounds cid
		# 	same_pts = []
		# 	lb_curr.each {|lb_pt|
		# 		lb_comp.each{|lb_pt1|
		# 			same_pts << lb_pt1 if lb_pt == lb_pt1
		# 		}
		# 	}
		# 	adj << cid if same_pts.length > 1
		# }
	}
	return comp_list#, corners
end

def get_glued_instances
  co = DP.fsel.parent.entities.grep(Sketchup::ComponentInstance).find_all { |c| c.glued_to == self}
  return co
end

def check_adj c1, c2
	return 0 unless (c1.bounds.intersect c2.bounds).valid?
	corners=[];
	intx=c1.bounds.intersect c2.bounds;
	(0..7).each{|x| corners<<intx.corner(x)}
	#puts corners
	return corners.map{|x| x.to_s}.uniq.length
=begin	
	ist = c1.bounds.intersect c1.bounds; 
	min = ist.min;max = ist.max
	puts min, max, ist.valid?, ist.width
	return false if min.x == min.y && min.x == min.y 
	return true
=end	
end

def bcors b
	a=[];(0..7).each{|i| a<<b.bounds.corner(i)}
	return a
end
