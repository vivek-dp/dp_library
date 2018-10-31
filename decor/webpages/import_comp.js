function loadMainCategory(){
	var val = 1;
	window.location = 'skp:loadmaincatagory@'+ val;
}

function passMainCategoryToJs(main){
	var main_cat = "";
	for (var m = 0; m < main.length; m++){
		var mainsplit = main[m].split("/")
		var slicemain = mainsplit.slice(-1)
		main_cat += '<option value="'+slicemain+'">'+slicemain+'</option>'
	}
	var maincat1 = '<div class="form-group"><select  class="form-control" id="main-category" onchange="changeMainCategory()"><option value="0" selected="selected">Select Category</option>	'+main_cat+'</select></div>'
	document.getElementById('load_maincategory').innerHTML = maincat1;
}

function changeMainCategory() {
	var val = document.getElementById('main-category').value;
	if (val != 0) {
		window.location = 'skp:get_category@' + val;
	}else{
		document.getElementById('load_subcategory').innerHTML = "";
		document.getElementById('load_sketchup').innerHTML = "";
	}
}

function passSubCategoryToJs(cat){
	document.getElementById('load_sketchup').innerHTML = "";
	document.getElementById('load_subcategory').innerHTML = "";
	var subcat = "";
	for (var i = 0; i < cat.length; i++){
		var splitcat = cat[i].split("/")
		var sname = splitcat.slice(-1)
		subcat += '<option value="'+sname+'">'+sname+'</option>'
	}
	var subcat1 = '<div class="form-group"><select class="form-control" id="sub-category" class="form-control" onchange="changeSubCategory()"><option value="0" selected="selected">Select Sub-Category</option>'+subcat+'</select></div>'
	document.getElementById('load_subcategory').innerHTML = subcat1;
}

function changeSubCategory(){
	var maincat = document.getElementById('main-category').value;
	var subcat = document.getElementById('sub-category').value;
	if (subcat != 0){
		var value = maincat +","+ subcat
		window.location = 'skp:load-sketchupfile@' + value;
	}
}

function passFromRubyToJavascript(value) {
	document.getElementById('load_sketchup').innerHTML = "";
	var skpimg = "";
	if (value.length != 0){
		for (var i = 0; i < value.length; i++) {
			var split_val = value[i].split("/")
			var mname = split_val.slice(-1)
			var ename = mname[0].split(".")
			var res = value[i].replace(/skp/g, "jpg");
			skpimg += '<tr><td style="width:20%;"><input type="hidden" id="imgicon_'+[i]+'" value="'+value[i]+'"><img src="'+res+'" onclick="checkImage('+[i]+');" height="40" width="40" style="cursor:pointer;""></td><td><span style="line-height:40px;">'+ename[0]+'</span></td></tr>'
		}
	} else {
		skpimg = '<tr><td style="text-align:center;"><i class="fa fa-warning" style="font-size:36px;color:red;"></i>&emsp;<span style="color:red;"><b>No file found!</b></span></td></tr>'
	}	
	var img = '<table class="table table-hover table-bordered">'+skpimg+'</table>';
	document.getElementById('load_sketchup').innerHTML = img;
}

function checkImage(id){
	var getid = document.getElementById("imgicon_"+id).value;
	window.location = 'skp:place_model@' + getid;
}