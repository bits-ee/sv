$.fn.autocomplete = function(settings){
  return this.each(function(){
    var this_container = $(this);
    
    // validate source-data
    if(!this_container.attr('data-resource')){
      try{ console.log("autocomplete: invalid data-resource"); }catch(e){}  
      return;
    }
    
    var this_id = this_container.attr('id');
    var this_name = this_container.attr('name');
    var this_style = this_container.attr('style') || ''; //FIXME: ...or data-style?
    var data_resource = force_mime_json(this_container.attr('data-resource')); //FIXME: external mimefix
    var data_value = this_container.attr('data-value') || '';
    var data_placeholder = this_container.attr('data-placeholder') || '';
    
    var __this_input = $('<input type="text" class="autocomplete-input" autocomplete="off" value="'+data_value+'" data-for="'+this_id+'" style="'+this_style+'" placeholder="'+data_placeholder+'">');
    var __result_panel = $('<div class="autocomplete-result"></div>');
    var __result_list = $('<ul></ul>');
    
    // variables and settings
    var oldText = '';
    var typingTimeout;
    var size = 0;
    var selected = 0;
    var selectClick = false;
    var lastInput = '';
    
    // provide default settings
    settings = $.extend({ 
      minChars : 2,
      timeout : 500,
      validSelection : true,
      parameters : {}
    }, settings);
    
    //
    __result_panel.delegate("ul", "mousedown", function(){	selectClick = true; });
    __result_panel.delegate("ul", "mouseup", function(){ selectClick = false; });
    __result_panel.click(function(e){ e.stopPropagation(); });
    
    // push DOM
    this_container.after(__this_input).after(__result_panel);
    
    function getData(text, force){
      window.clearTimeout(typingTimeout);
      // validate input
      text = text ? text : '';
      if( force !== true && text.length < settings.minChars ){ clear(); return; }
      
      //clear();
      
      settings.parameters.text = text;
      $.ajax({url: data_resource, type: 'POST', dataType: 'json', data: settings.parameters, success: function(data, status){
        $('body').one('click', function() { clear(); });
        
        if($.isEmptyObject(data)){
          __result_panel.html('<div class="gray-9 corpus">' + T['nothing_found'] + '</div>');
          __this_input.addClass('selecting');
          update_list_style();
          __result_panel.show();
          return; 
        }
        
        var items = '';
        var v;
        
        size = 0;
        for(v in data){
          size++;
          items += '<li value="'+data[v]+'">'+v+'</li>';
        }
        
        // add items to container
        __result_list.html(items);
        __result_list.highlight(text, true); //TODO: ? nada posmotret' chto tam
        __result_panel.html(__result_list);
        //__result_list.scroll(function(e){ e.stopPropagation(); });
        
        // on mouse hover over elements set selected class and on click set the selected value and close __result_list
        __result_list.children().hover(
          function(){ $(this).siblings().removeClass('selected'); $(this).addClass('selected'); },
          function(){ $(this).removeClass('selected'); }
        ).click( function(){          
          this_container.val( $(this).attr('value') );
          this_container.trigger('change');
          __this_input.val( $(this).text() );
          clear();
        });
        
        // show
        
        update_list_style();
        __this_input.addClass('selecting');
        __result_panel.show();
      }});
      
      oldText = text;
      
    }
    
    // CLEAR 
    
    function update_list_style(){
      __result_panel.css({'top': Math.ceil(__this_input.offset().top + __this_input.outerHeight()), 'left': __this_input.offset().left, 'min-width': __this_input.innerWidth()});
    }
    
    function clear(){
      __this_input.removeClass('selecting');
      __result_panel.html('');
      __result_panel.hide(); //FIXME: 
      size = 0;
      selected = null;
    }
    
    function clearinput(){
      this_container.val('');
      __this_input.val('');
    }
    
    // EVENTS
    
    // "paste" event
    __this_input.bind('paste', function(e){
      typingTimeout = window.setTimeout(function() { getData(__this_input.val()); }, settings.timeout*3);
    });
    
    // "cut", "copy" events
    
    // "focus" event
    __this_input.bind('focus', function(e){
      if(!this_container.val() && __this_input.val() !== ''){
        typingTimeout = window.setTimeout(function() { getData(__this_input.val()); }, settings.timeout*3);
      }
    });
    
    // "blur" event
    //__this_input.bind('blur', function(e){
    //  if(!selectClick){ clear(); }
    //});
    
    __this_input.dblclick(function(){
      typingTimeout = window.setTimeout(function(){ getData(null, true); }, settings.timeout);
      clearinput();
    });
    
    //
    // keypress events    
    //
    __this_input.keydown(function(e){
      window.clearTimeout(typingTimeout);
      switch(e.which){
        case 27: /* escape */
            clear(); break;
        case 8: case 46: /* backspace, delete */
            if(this_container.val()){
              clear(); clearinput();
            } else {
              typingTimeout = window.setTimeout(function() { getData(__this_input.val()); }, settings.timeout);
            }
            break;
        case 13: /* enter */
            if ( !__result_list.is(':visible') ){ getData(__this_input.val()); } 
            else {
              __this_input.val( __result_list.children().removeClass('selected').eq(selected).addClass('selected').text() );
              this_container.val( __result_list.children().eq(selected).attr('value') );
              this_container.trigger('change');
              oldText = __this_input.val();
              clear();
            }
            e.preventDefault();
            return false;
        case 16: case 17: case 18: /* shift, ctrl, alt */ e.preventDefault(); break;
        case 33: case 34: /* page up, page down */ e.preventDefault(); break; 
        case 35: case 36: /* end, home */ break;
        case 9: /* tab */
            if(__result_list.is(':visible')){ e.preventDefault(); if(selected === null){ selected = 0; } }
            __result_list.children().removeClass('selected').eq(selected).addClass('selected');
            break;
        case 38: /* up */
            if(__result_list.is(':visible')){ e.preventDefault(); }
            selected = selected === null ? size - 1 : (selected <= 0 ? size - 1 : selected - 1);
            __result_list.children().removeClass('selected').eq(selected).addClass('selected');
            break;
        case 40: /* down */
            if(__result_list.is(':visible')){ e.preventDefault(); }
            selected = selected === null ? 0 : (selected >= size - 1 ? 0 : selected + 1);
            __result_list.children().removeClass('selected').eq(selected).addClass('selected');
            break;
        case 37: /* left */ break;
        case 39: /* right */ break; 
        default: 
            if(__this_input.val() !== oldText){ this_container.val(''); }
            typingTimeout = window.setTimeout(function() { getData(__this_input.val()); }, settings.timeout);
            break;
      }
    });
  });
};