$(document).ready(function(){
	$(".allownumeric").keypress(function (e) {
		if ((event.which != 46 || $(this).val().indexOf('.') != -1) && (event.which < 48 || event.which > 57)) {
      //alert('Numbers only allowed!')
      $.growl.error({ message: "Numbers only allowed!" });
      return false;
    }
  });
});


function OnCancel(){
	sketchup.clickcancel(1);
}

function checkd(){
	var checkDo = document.getElementById("checkdoor");
	var dropDoo = document.getElementById("doorblock");
	if (checkDo.checked == true){
		dropDoo.style.display = "block"
	}else{
		dropDoo.style.display = "none"
	}
}

function checkw(){
	var checkWi = document.getElementById("checkwin");
	var dropWin = document.getElementById("windowblock");
	if (checkWi.checked == true){
		dropWin.style.display = "block"
	}else{
		dropWin.style.display = "none"
	}
}

function SubmitVal(){
	var array = [];
	var json = {};
	var ids = new Array ("wall1", "wall2", "wheight", "wthick")
	for (i in ids){
		var inval = document.getElementById(ids[i]).value;
		json[ids[i]] = inval
	}
	
	var door_check = document.getElementById("checkdoor");
	if (door_check.checked == true){
		var doorids = new Array ("door_view", "door_position", "door_height", "door_length")
		var json1 = {};
		for (j in doorids){
			var getval = document.getElementById(doorids[j]).value;
			if (doorids[j] == "door_view"){
				if (getval == 0){
					alert("Door view can't be blank!")
					return false;
				}else{
					json1[doorids[j]] = getval
				}
			}else{
				json1[doorids[j]] = getval
			}
		}
		var j1 = JSON.stringify(json1)
		json["door"] = json1
	}

	var win_check = document.getElementById("checkwin");
	if (win_check.checked == true){
		var winids = new Array ("window_view", "win_lftposition", "win_btmposition")
		var json2 = {};
		for (i in winids){
			var getval = document.getElementById(winids[i]).value;
			json2[winids[i]] = getval
		}
		var j2 = JSON.stringify(json2)
		json["window"] = json2
	}
	var str = JSON.stringify(json);
	sketchup.submitval(str)
}
