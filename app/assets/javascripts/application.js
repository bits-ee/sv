// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require localization
//= require jquery.livequery
//= require jquery.autocomplete
//= require jquery.tablesorter.min
//= require common
//= require_tree .

 $.tablesorter.defaults.textExtraction = function (node){
    var this_node = $(node);
    if($('.sort', this_node).size() > 0){
      return $('.sort', this_node).text(); }
    else{ return this_node.text(); }
  };

$(function(){
  $("body").bind("click", function () {
    //$('.dropdown-toggle, .dropdown-menu').parent("li").removeClass("open");
    $('.dropdown-menu').removeClass("open");
  });

  $(".dropdown-toggle").click(function (e) {
    $(this).next('ul').toggleClass('open');
    e.preventDefault();
    return false;
  });

  $('#gallery .item').each(function(){
    var $this = $(this);
    var width = $this.outerWidth()+"px";
    var height = $this.outerHeight()+"px";
    var index = $this.index();

    var offset_left = (index%4*210)+"px";
    var offset_top = (Math.floor(index/4)*200)+"px";
    $this.css({
      left: offset_left,
      top: offset_top
    });

    $this.click(function(){
      if($this.hasClass('on')){
        $this.animate({
          left: offset_left,
          top: offset_top,
          width: width,
          height: height
        }, "fast", function(){$this.removeClass('on')});
      }else{
        $this.addClass('on');
        $this.animate({
          top: 0,
          left: 0,
          width: "100%",
          height: "100%"
        }, "fast");
      }
    });
  });

  (function(){
    //xZif48a
    if (screen.width > 699) {
      var _h = $('.menu');
      if( _h.length > 0 ){
        var _o = _h.offset().top;
        var _lag = 10; //UX
        $(window).scroll(function(){
          if($(window).scrollTop() >= _o+_lag){
            _h.addClass('detached');
            //_h.css('top', $(window).scrollTop());
          }else{
            _h.removeClass('detached');
            //_h.css('top', 'auto');
          }
        });
      }
    }
  })();

  $('#status-top > .messages > div').delay(5000).fadeOut();

  $(".admin-checkbox").change(function(){$(".receive-notifications").toggle();});

});
