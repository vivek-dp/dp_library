
def set_lamination comp, value
	dict_name = 'lamination_code'
	key = 'lamination'
	comp.set_attribute(dict_name, key, value)
end

def get_lamination comp
	dict_name = 'lamination_code'
	key = 'lamination'
	lam_code = comp.get_attribute(dict_name, key)
	return lam_code
end

UI.add_context_menu_handler do |popup|
        sel = Sketchup.active_model.selection
        if sel[0].is_a?(Sketchup::ComponentInstance)
            popup.add_item('Lamination Code') {
				prompts = ["Enter lamination code"]
				defaults = [""]
				input = UI.inputbox(prompts, defaults, "Lamination code.")
				set_lamination sel[0], input[0] if input
                puts S[0].definition.name
            }
        end
end  



	



