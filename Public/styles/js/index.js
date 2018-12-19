//when the view loads in the index
(function() {

postTextCounter(); //counter for the text character being input in the postSection
commentCounter(); //counter for comment function
showAllComment();//show all comments onlick
})();

function postTextCounter(val){
  if (val != null) {
    var len = val.value.length;
      if (len > 1000) {
        val.value = val.value.substring(0, 1000);
      } else {
        $('#charNum').text(1000 - len);
        $('#charNum')
      }
  }
}
function commentCounter(){
  //the data
  //commentpostforeignkey
  var CD = document.getElementsByClassName('commentPostID');
  //total comment count
  var CC= parseInt(document.getElementById('totalcommentsCount').innerHTML);
  //postID
  var PID = document.getElementsByClassName('postID');
  //output
  var CO = document.getElementsByClassName('commentCount');

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
}
function showAllComment(input){
  //th that acts like a button
  var B = document.getElementsByClassName('showCommentButton');
  //the initially hidden comment container
  var commCont = document.getElementsByClassName('commentsContainer');
  //postid
  var PID = document.getElementsByClassName('postID');
  var a = [];

  for (var i = 0; i < PID.length; i++) {
    //push the post id inside array
    a.push(PID[i].innerHTML);
  }
  //top to bottom postid [6,5,4,2,1]
  //top to bottom a[6,5,4,2,1]
//adding the click listener to table th element
for (var i = 0; i < B.length; i++) {
    B[i].addEventListener("click", showCommentContainer());
}
function showCommentContainer(){

    for (var i = 0; i < a.length; i++) {
      if (a[i] == input) {
            commCont[i].style.display = "block";
      }
    }
  }
}
