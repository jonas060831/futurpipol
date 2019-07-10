
function cookiesConfirmed() {

  var footer = document.getElementById('cookie-footer');
  footer.style.display = 'none'

  var d = new Date();
  d.setTime(d.getTime() + (365*24*60*60*1000));
  var expires = "expires="+ d.toUTCString();
  document.cookie = "cookies-accepted=true;" + expires;
}
