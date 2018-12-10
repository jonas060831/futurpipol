$(document).ready(function($) {
        // hide preloader when everthing in the document load
        $('#preloader').css('display', 'none');
 });

 //this only works on Chrome tried in safari and firefox but did not work
 if(!!window.performance && window.performance.navigation.type == 2)
 {
     window.location.reload();
 }
 //tailored for safari
 $(window).bind("pageshow", function(event) {
     if (event.originalEvent.persisted) {
         window.location.reload();
     }
 });
