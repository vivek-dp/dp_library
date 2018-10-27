
def set_lamination comp, value
	dict_name = 'lamination_code'
	key = 'lamination'
	comp.set_attribute(dict_name, key, value)
end

def get_lamination comp, value
	dict_name = 'lamination_code'
	key = 'lamination'
	comp.get_attribute(dict_name, key)
end

UI.add_context_menu_handler do |popup|
        sel = Sketchup.active_model.selection
        if sel[0].is_a?(Sketchup::ComponentInstance)
            popup.add_item('Lamination Code') {
                puts S[0].definition.name
            }
        end
end  

inp_h =	{	"wall1"=>"210",
		 "wall2"=>"220",
		 "wheight"=>"120",
		 "wthick"=>"10",
		"door"=>{	"door_view"=>"right", 
				"door_position"=>"100", 
				"door_height"=>"150"}
	}