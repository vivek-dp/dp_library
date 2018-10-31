module Decor_Standards
	def self.load_dynamic_config
		@selection = Sketchup.active_model.selection
		if @selection.length != 0 and @selection.length == 1
			dialog = UI::WebDialog.new("Decor - Dynamic Configure", true, "Decor - Dynamic Configure", 300, 1000, 10, 150, true)
			html_path = File.join(WEBDIALOG_PATH, 'dynamic_config.html')
			dialog.set_file(html_path)
			dialog.show

			dialog.add_action_callback("loadingpage") {|key, val|
				loadval = []
				proname = []
				title = []
				chkattributes = []
				Sketchup.active_model.selection[0].definition.attribute_dictionaries["dynamic_attributes"].map{|dynamique_attibute,dynamique_value|
					puts "#{dynamique_attibute}-----#{dynamique_value}"
					split_attr = dynamique_attibute.split("_")
					if dynamique_value.class != NilClass and dynamique_value != "&"
						if split_attr[0] != "" or split_attr.last == "options"
							if dynamique_value.to_f != 0.0
								if dynamique_value.to_f <= 10.00
									inches = dynamique_value.to_f
								else
									inches = dynamique_value.to_f
									inches = inches.to_cm
								end
								if !chkattributes.include?(dynamique_attibute)
									loadval.push("#{dynamique_attibute}/#{inches}")
								end
							else
								if dynamique_attibute.include?("options")
									val1 = dynamique_attibute.split("_")
									rmspace = val1.reject { |c| c.empty? }
									pname1 = rmspace.join("_")
									pname = pname1.gsub("_options", "")
									loadval.push("#{pname}/#{dynamique_value}")
									chkattributes.push(pname)
								else
									proname.push(dynamique_value) if dynamique_attibute == "product_name"
								end
							end
						elsif dynamique_attibute == "_name"
							title.push(dynamique_value)
						end
					end
				}
				js_command = "showDynamicValue("+loadval.to_s+','+title.to_s+','+proname.to_s+")"
				key.execute_script(js_command)
			}

			dialog.add_action_callback("changeapply"){|key, val|
				vals = val.split(",")
				mod = Sketchup.active_model
				sel = mod.selection
				sel.grep(Sketchup::ComponentInstance).each do |s|
					hashvalue = {}
					for i in vals
						spval = i.split("/")
						if spval[0].to_s == "lenx"
							k = "_lenx_formula"
							hashvalue[k] = spval[1]
						elsif spval[0].to_s == "leny"
							k = "_leny_formula"
							hashvalue[k] = spval[1]
						elsif spval[0].to_s == "lenz"
							k = "_lenz_formula"
							hashvalue[k] = spval[1]
						else
							hashvalue[spval[0]] = spval[1]
						end
					end
					hashvalue.each {|k, v|
						s.set_attribute "dynamic_attributes", k, v
					}
					$dc_observers.get_latest_class.redraw_with_undo(s)
				end
			}
		else
			UI.messagebox "Please select any one component!", MB_OK
		end
	end
end