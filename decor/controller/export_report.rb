require 'WriteExcel'
module Decor_Standards
	def self.export_report_xls
		model = Sketchup.active_model
		path = model.path
		@output_folder = File.dirname(path)
		@title = Sketchup.active_model.title
		if Sketchup.active_model.title != ""
			@title = Sketchup.active_model.title
		else
			@title = "Untitled"
		end

		workbook  = WriteExcel.new(@output_folder+"#{@title}"+'.xls')
		format0 = workbook.add_format(:color=>8,:bold=>1,:size=>10,:border=>1,:align=>:center,:valign=>:vcenter)
		format1 = workbook.add_format(:color=>8,:bold=>1,:size=>11,:border=>1,:align=>:center,:valign=>:vcenter,:text_wrap=>1,:bg_color=>22)
		format2 = workbook.add_format(:color=>8,:size=>10,:border=>1,:align=>:left,:text_wrap=>1,:valign=>:vcenter)
		format3 = workbook.add_format(:color=>8,:size=>10,:border=>1,:align=>:center,:text_wrap=>1,:valign=>:vcenter)

		worksheet1 = workbook.add_worksheet("Model Wise Report")
		[0,1].each{|n| worksheet1.set_row(n, 30) }

		worksheet1.merge_range("A1:J1", "Dynamic Attributes -  Model Wise Report",format1)
		worksheet1.write("A2","S.No",format0)
		worksheet1.set_column('A:A', 5)
		
		worksheet1.write("B2","Model Name",format0)
		worksheet1.set_column('B:B', 25)

		worksheet1.write("C2","Product Name",format0)
		worksheet1.set_column('C:C', 30)

		worksheet1.write("D2","Laminate Code",format0)
		worksheet1.set_column('D:D', 30)
		
		worksheet1.write("E2","No of Panels",format0)
		worksheet1.set_column('E:E', 15)

		worksheet1.write("F2","Quantity",format0)
		worksheet1.set_column('F:F', 15)

		worksheet1.write("G2","Total Panels",format0)
		worksheet1.set_column('G:G', 15)
		
		worksheet1.write("H2","Depth (LenX)",format0)
		worksheet1.set_column('H:H', 15)

		worksheet1.write("I2","Width (LenY)",format0)
		worksheet1.set_column('I:I', 15)

		worksheet1.write("J2","Height (LenZ)",format0)
		worksheet1.set_column('J:J', 15)

		@definitions = Sketchup.active_model.entities.grep(Sketchup::ComponentInstance)
		@mcounts = []
		@definitions.each {|m|
			@mcounts.push(m.definition.name)
		}	

		sn = 1
		row = 3
		mscount = []
		product_hash = {}
		@definitions.each {|d|
			if !mscount.include?(d.definition.name)
				mscount.push(d.definition.name)
				worksheet1.set_row(row-1, 25)
				worksheet1.write("A#{row}", sn, format3)
				worksheet1.write("B#{row}", d.definition.name, format3)
				
				pcount = []
				d.definition.entities.grep(Sketchup::ComponentInstance).each {|pa|
					pcount.push(pa.definition.name)
				}
				worksheet1.write("E#{row}", pcount.count.to_i, format3)
				worksheet1.write("F#{row}", @mcounts.count(d.definition.name).to_i, format3)
				worksheet1.write("G#{row}", "=(E#{row}*F#{row})", format3)

				d.definition.attribute_dictionaries["dynamic_attributes"].map{|da,dv|
					if da == "lenx"
						inches = dv.to_f
						worksheet1.write("H#{row}", inches.to_cm, format3)
					elsif da == "leny"
						inches = dv.to_f
						worksheet1.write("I#{row}", inches.to_cm, format3)
					elsif da == "lenz"
						inches = dv.to_f
						worksheet1.write("J#{row}", inches.to_cm, format3)
					elsif da == "product_name"
						worksheet1.write("C#{row}", dv, format3)
						product_hash[d.definition.name] = dv
					end
				}
				sn += 1
				row += 1
			end
		}

		worksheet2 = workbook.add_worksheet("Panel Wise Report")
		[0,1].each{|n| worksheet2.set_row(n, 30) }

		worksheet2.merge_range("A1:I1", "Dynamic Attributes -  Panel Wise Report",format1)
		worksheet2.write("A2","S.No",format0)
		worksheet2.set_column('A:A', 5)

		worksheet2.write("B2","Model Name",format0)
		worksheet2.set_column('B:B', 25)

		worksheet2.write("C2","Product Name",format0)
		worksheet2.set_column('C:C', 30)

		worksheet2.write("D2","Laminate Code",format0)
		worksheet2.set_column('D:D', 30)

		worksheet2.write("E2","Panel Name",format0)
		worksheet2.set_column('E:E', 25)

		worksheet2.write("F2","Depth (LenX)",format0)
		worksheet2.set_column('F:F', 15)

		worksheet2.write("G2","Width (LenY)",format0)
		worksheet2.set_column('G:G', 15)

		worksheet2.write("H2","Height (LenZ)",format0)
		worksheet2.set_column('H:H', 15)

		worksheet2.write("I2","Quantity",format0)
		worksheet2.set_column('I:I', 15)

		row1 = 3
		pscount = []
		@definitions = Sketchup.active_model.entities.grep(Sketchup::ComponentInstance)
		@definitions.each {|m|
			if !pscount.include?(m.definition.name)
				pscount.push(m.definition.name)
				worksheet2.set_row(row1-1, 25)
				worksheet2.write("B#{row1}", m.definition.name, format3)
				if product_hash.length == 0
					worksheet2.write("C#{row1}", "--", format3)
				else
					worksheet2.write("C#{row1}", product_hash[m.definition.name], format2)
				end
				worksheet2.write("I#{row1}", @mcounts.count(m.definition.name).to_i, format3)

				sno = 1
				row1 = row1
				@panels = m.definition.entities.grep(Sketchup::ComponentInstance)
				@panels.each {|pa|
					worksheet2.set_row(row1-1, 25)
					worksheet2.write("A#{row1}", sno, format3)
					worksheet2.write("E#{row1}", pa.definition.name, format3)

					pa.definition.attribute_dictionaries["dynamic_attributes"].map{|da,dv|
						if da == "lenx"
							inches = dv.to_f
							worksheet2.write("F#{row1}", inches.to_cm, format3)
						elsif da == "leny"
							inches = dv.to_f
							worksheet2.write("G#{row1}", inches.to_cm, format3)
						elsif da == "lenz"
							inches = dv.to_f
							worksheet2.write("H#{row1}", inches.to_cm, format3)
						end
					}
					sno += 1
					row1 += 1
				}
			end
			row1 += 1
		}

		workbook.close
		UI.messagebox 'Export successful',MB_OK
	end
end