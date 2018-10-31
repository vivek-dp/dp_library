function LoadFuction(){
	var val = 1;
	window.location = 'skp:loadingpage@'+ val;
}

$htmlArray = []
function showDynamicValue(vals, name, pro){
	var subval = "";
	var input = '<div class="text-danger" style="text-align:center;text-transform: capitalize;font-weight:bold;"><span>Component Name:&nbsp;</span>'+name+'</div>'
	subval += input
	for (var i = 0; i < vals.length; i++){
		spval = vals[i].split("/")
		lname = spval[0].replace(/_/g, " ");
		$htmlArray.push(spval[0])
		if (spval[1].indexOf("&") == 0){
			if (spval[0].indexOf("lenx") == 0 || spval[0].indexOf("leny") == 0 || spval[0].indexOf("lenz") == 0){
				var splitv = spval[1].split("&")
				var optionlist = "";
				for (var l = 0; l < splitv.length; l++){
					if (splitv[l] != ""){
						var lastsplit = splitv[l].split("=")
						optionlist += '<option value="'+lastsplit[0]+'">'+parseFloat(lastsplit[0]).toFixed(2)+'</option>'
					}
				}
			}else{
				var splitv = spval[1].split("&")
				var optionlist = "";
				for (var o = 0; o < splitv.length; o++){
					if (splitv[o] != ""){
						var lastsplit = splitv[o].split("=")
						if (lastsplit[1] === pro[0]){
							optionlist += '<option value="'+lastsplit[0]+'" selected="selected">'+lastsplit[1]+'</option>'
						}else{
							if (parseFloat(lastsplit[1]).toFixed(2) != "NaN"){
								optionlist += '<option value="'+lastsplit[0]+'">'+parseFloat(lastsplit[1]).toFixed(2)+'</option>'
							}else{
								optionlist += '<option value="'+lastsplit[0]+'">'+lastsplit[1]+'</option>'
							}
						}
					}
				}
			}
			var input = '<div class="form-group"><span style="text-transform: capitalize;">'+lname+'</span><select id="'+spval[0]+'" class="form-control">'+optionlist+'</select></div>'
		}else{
			var input = '<div class="form-group"><span style="text-transform: capitalize;">'+lname+':</span><span> (cm)</span><input type="text" id="'+spval[0]+'" value="'+parseFloat(spval[1]).toFixed(2)+'" class="form-control"></div>'
		}
		subval += input
	}
	var addsubmit = subval+'<div class="pull-right"><a href="#" class="btn btn-primary" onclick="ChangeConfig();">Apply Changes</a></div>'
	document.getElementById('configval').innerHTML = addsubmit;
}

function ChangeConfig(){
	var ids = $htmlArray
	var arg = [];
	for (i in ids){
		entry = document.getElementById(ids[i]).value;
		if (entry.length != 0){
			arg.push(ids[i]+"/"+entry);
		}else{
			alert("value can't be empty!")
			document.getElementById(ids[i]).focus();
			return false;
		}
	}
	window.location = 'skp:changeapply@' + arg;
}