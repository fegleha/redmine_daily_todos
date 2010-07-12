/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
function $(element_id) {
    return document.getElementById(element_id)
}

function getSelected(listObj) {
    var selected = new Array();
    var index = 0;
    var arrIndex = 0;
    for (var intLoop=0; intLoop < listObj.length; intLoop++) {
        if (listObj[intLoop].selected) {
            index = selected.length;
            selected[arrIndex] = new Object;
            selected[arrIndex].value = listObj.options[intLoop].text;
            selected[arrIndex].index = intLoop;
            arrIndex++;
        }
    }
    return selected;
}


function showAction() {
    var groupText = "";
    var userText = "";
    var showText = "";
    //group select
    var groupSelectedIndex = $("group_select").selectedIndex;
    if(groupSelectedIndex >=0 ) {
        groupText = $("group_select").options[groupSelectedIndex].text;
    } else {
        showText = "Please select group!";
        $("daily_todo_action").innerHTML = showText;
        $("daily_todo_group_detail_submit").disabled = true;
        return;
    }
    
    //user select
    var arrUser = getSelected($("user_select"));
    for (var intLoop=0; intLoop < arrUser.length; intLoop++) {
        userText += arrUser[intLoop].value + ", "
    }
    if(arrUser.length > 0) {
        userText = userText.substring(0, userText.length - 2)
    } else {
        showText = "Please select at least 1 user!";
        $("daily_todo_action").innerHTML = showText;
        $("daily_todo_group_detail_submit").disabled = true;
        return;
    }

    showText = "Add " + userText + " to " + groupText;
    $("daily_todo_action").innerHTML = showText;
    $("daily_todo_group_detail_submit").disabled = false;
}