//when the view loads in the index
$(document).ready(function(){
  postTextCounter(); //counter for the text character being input in the postSection
  timeStampConverter();
  commentCounter(); //counter for comment function
  showAllComment();//show all comments onlick

});
function postTextCounter(val){
  if (val != null) {
    var len = val.value.length
      if (len > 1000) {
        val.value = val.value.substring(0, 1000);
      } else {
        $('#charNum').text(1000 - len);
        $('#charNum')
      }
  }
}

function timeStampConverter(){

  //post timeStamp
  var TSR = document.getElementsByClassName("timeStampRaw");
  var ETR = document.getElementsByClassName("timeStamp");


  //update the <p> every second
  var x = setInterval(function(){
      //loop thru rows
      for (var i = 0; i < TSR.length; i++) {
        //get the value of the span class from DB
        var TS = TSR[i].innerText;
        //output the result
        ETR[i].innerHTML = elapseTime(convertToDate(TS));
      }
  },0);

  function convertToDate(input){

    var a = new Date(parseInt(input) * 1000);
    return a;
  }

  //Time Difference from the timestamp called at set Interval in main js file
  function elapseTime(input){

    //getting the current Time
    var a = new Date().getTime();
    //getting the string Timestamp
    var b = input.getTime();

    //difference / elapse
    var c = a - b;

    var years = Math.floor(c / (1000 * 60 * 60 * 24) / 365);
    var months = Math.floor(c / (1000 * 60 * 24 * 7 * 4 * 52.18));
    var weeks= Math.floor(c / (1000 * 60 * 60 * 24 * 7));
    var days = Math.floor(c / (1000 * 60 * 60 * 24));
    var hours = Math.floor((c % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    var minutes = Math.floor((c % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((c % (1000 * 60)) / 1000);

    //date formatter
    var options = {
      weekday: "short", year: "numeric", month: "short",
      day: "numeric", hour: "numeric", minute: "2-digit"
    };
    var options2 = {
      weekday: "short", hour: "numeric", minute: "2-digit"
    };
    var options3 = {
      month: "short",
      day: "numeric", hour: "numeric", minute: "2-digit"
    };

    if (days < 1 && hours < 1 && minutes < 1 && seconds < 60 ) {

      if (seconds <= 1) {
        return "a second ago";
      }
      return seconds + "s ago";
    }else if (days < 1 && hours < 1 && minutes < 60) {
      if(minutes == 1){
        return "a minute ago";
      }else if (minutes < 60 ) {
        return minutes + "m ago";
      }

    }else if (days < 1 && hours < 24){

        if (hours == 1 && minutes > 1) {
          return "an hour " + minutes + "m ago";
        }else if (hours == 1 && minutes == 1) {
          return "an hour ago";
        }else if (hours == 1 && minutes < 1) {
          return "an hour ago";
        }else if(hours >= 1 && minutes >= 2){
          return hours + "h " + minutes + "m ago";
        }else if(hours >= 1 && minutes < 2){
          return hours + "h ago";
        }
    }else if(days < 8){

        if(days == 1 && hours == 0){
          return "a day ago";
        }else if (days < 7){
          //within the week
          return new Date(input).toLocaleTimeString("en-us", options2);
        }
        return new Date(input).toLocaleTimeString("en-us", options3);
    }else if(weeks <= 4){

      if(weeks == 1 && hours <= 0) {
        return "a week ago";
      }
      else if (weeks > 1 && weeks <= 4 ) {
        if (days % 7 == 0) {
          return weeks + "w ";
        }else if (days % 7 >= 1) {
          return weeks + "w " + days % 7 + "d";
        }
      }
        return new Date(input).toLocaleTimeString("en-us", options3);

    }else if(months <= 12){

        if (months == 1 && days < 1) {
          return "a month ago";
        }
        return new Date(input).toLocaleTimeString("en-us", options3);
    }else if(years == 1){

      // return years + "a year ago";os
      return new Date(input).toLocaleTimeString("en-us", options);
    }else if (years > 1){
      // return b;
      return new Date(input).toLocaleTimeString("en-us", options);
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
  //the initially hidden comment container
  var commCont = document.getElementsByClassName('commentsContainer');
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

        //if theres no comment dont show 0
        if (a.filter(sameNumbersOnly).length == 0) {
          CO[i].innerHTML = "";
        }else if (a.filter(sameNumbersOnly).length == 1) {
          CO[i].innerHTML = a.filter(sameNumbersOnly).length;
          commCont[i].style.display = "block";
        }else {
          CO[i].innerHTML = a.filter(sameNumbersOnly).length;
        }
        function sameNumbersOnly(value) {
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
//adding the click listener to table th element
for (var i = 0; i < B.length; i++) {
    B[i].addEventListener("click", showCommentContainer());
}
function showCommentContainer(){

    for (var i = 0; i < a.length; i++) {
      if (a[i] == input ) {
            commCont[i].style.display = "block";
      }
    }
  }
}




$("#search").focus(function() {
  //live search
  $(document).ready(function(){
    $('#search').keyup(function(){
      $('#result').html('');
      var searchField = $('#search').val();
      var expression = new RegExp(searchField, "i");

      $.getJSON('http://localhost:8080/api/users', function(data){
          $.each(data, function(key, value){
            if(value.Name.search(expression) != -1 || value.Username.search(expression) != -1){
              if(searchField != 0){
                $('#result').append('<li class="list-group-item" style="padding: 10px;"><a href="/'+value.id+'">  <img src="'+value.ProfilePictureURL+'"  height="40" width="40" align="center" class="img-thumbnal" /> '+value.Name+' | <span style="color: rgb(162, 162, 162)"> '+value.Username+'</span> </a></li>');
              }else{
                $('#result').html('');
              }
            }
          });
      });
    });
  });
}).blur(function() {
});
