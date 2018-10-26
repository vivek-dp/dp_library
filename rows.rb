require 'C:\Users\Decorpot-020\Desktop\poc\test.rb'
#load 'C:\Users\Decorpot-020\Desktop\poc\test.rb'
#load 'C:\Users\Decorpot-020\Desktop\poc\rows.rb'
#load 'C:\Users\Lenovo\Desktop\dp_18-21_oct_2018\rows.rb'

def get_xn_pts c1, c2
	xn = c1.bounds.intersect c2.bounds
	corners = []
	(0..7).each{|x| corners<<xn.corner(x)}
	
	arr = corners.inject([]){ |array, point| array.any?{ |p| p == point } ? array : array << point }
	return arr
end

comp_h = parse_components
corners = []
singles = []
comp_h.each_pair{|x, y| singles<<x if y[:type] == :single}
comp_h.each_pair{|x, y| 
	if y[:type] == :double
		adj_comps = y[:adj]
		cor_comp =  DP.get_comp_pid x
		comp1 = DP.get_comp_pid adj_comps[0]
		comp2 = DP.get_comp_pid adj_comps[1]
		if (comp1.transformation.rotz+comp2.transformation.rotz)%180 != 0
			#This check when its row component but the adjacents are rotated
			f1 = DP.ents.add_face(get_xn_pts cor_comp, comp1)
			f2 = DP.ents.add_face(get_xn_pts cor_comp, comp2)
			if f2.normal.perpendicular? f1.normal
				corners<<x 
				#DP.sel.add cor_comp
			end
			DP.ents.erase_entities f1, f2
		end
	end
}

DP.ents.each{|x| DP.ents.erase_entities x if !x.is_a?(Sketchup::ComponentInstance)} 
puts "#-------------------------#"
puts comp_h
puts corners
rows = []
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
puts "+++++++++++++++++++++++++++"
puts "singles : #{singles}"
puts comp_h
@ret_h = comp_h
def ret_comp_h
	return @ret_h
end
pp rows