module Decor_Standards
	def self.decor_import_comp
		dialog = UI::WebDialog.new("#{TITLE}", true, "#{TITLE}", 700, 600, 150, 150, true)
		html_path = File.join(WEBDIALOG_PATH, 'import_comp.html')
		dialog.set_file(html_path)
		dialog.set_position(0, 150)
		dialog.show

		dialog.add_action_callback("loadmaincatagory"){|a, b|
			path = DECORPOT_ASSETS + "/"
			mainarray = []
			dirpath = Dir[path+"*"]
			dirpath.each {|mc|
				mainarray.push(mc)
			}
			js_maincat = "passMainCategoryToJs("+mainarray.to_s+")"
			a.execute_script(js_maincat)
		}

		dialog.add_action_callback("get_category") {|d, val|
			val = val.to_s
			@path = DECORPOT_ASSETS + "/" + val + "/"
			@arr_value = []
			@dirpath = Dir[@path+"*"]
			
			@dirpath.each {|file|
				@arr_value.push(file)
			}
			js_subcat = "passSubCategoryToJs("+@arr_value.to_s+")"
			d.execute_script(js_subcat)
		}

		dialog.add_action_callback("load-sketchupfile") {|s, cat|
			cat = cat.split(",")
			@subpath = DECORPOT_ASSETS + "/" + cat[0] + "/" + cat[1] + "/"
			@subarr = []
			@subdir = Dir[@subpath+"*.skp"]
			@subdir.each{|s|
				@subarr.push(s)
			}
			js_command = "passFromRubyToJavascript("+ @subarr.to_s + ")"
			s.execute_script(js_command)
		}

		dialog.add_action_callback("place_model"){|d, val|
			self.place_Defcomponent(val)
		}
	end

	def self.place_Defcomponent(val)
		@model = Sketchup::active_model
		cdef = @model.definitions.load(val)
		placecomp = @model.place_component cdef.entities[0].definition
	end
end