//login
function showLoader(){
    $('#preloader').show(); //<----here
    $.ajax({
     success:function(result){
         $('#preloader').hide();  //<--- hide again
     }
  })
}
