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
