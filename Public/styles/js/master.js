//login
function showLoader(){
    $('#preloader').show(); //<----here
    $.ajax({
     success:function(result){
         $('#preloader').hide();  //<--- hide again
     }
  })
};

//index
function countChar(val) {
        var len = val.value.length;
        if (len > 1000) {
          val.value = val.value.substring(0, 1000);
        } else {
          $('#charNum').text(1000 - len);
          $('#charNum')
        }
};



//index when view loads
(function() {
//the data
//commentpostforeignkey
var CD = document.getElementsByClassName('commentPostID');
//total comment count
var CC= parseInt(document.getElementById('totalcommentsCount').innerHTML);
//postID
var PID = document.getElementsByClassName('postID');
//output
var CO = document.getElementsByClassName('commentOutput');

var a = [];
var b = [];
// append the commentpostforeignkey in the array
for (var i = 0; i < CC; i++) {
    a.push(CD[i].innerHTML);
}
for (var i = 0; i < PID.length; i++) {
  b.push(PID[i].innerHTML);
}
for (var i = 0; i < PID.length; i++) {

      //if theres no comment dont show it
      if (a.filter(myFunction).length == 0) {
        CO[i].innerHTML = "";
      }else {
        CO[i].innerHTML = a.filter(myFunction).length;
      }
      function myFunction(value) {
          return value == b[i];
      }
}
})();
