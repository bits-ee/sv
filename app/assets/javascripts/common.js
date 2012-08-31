// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function force_mime_json(url){
  if (/\.json/.test(url)) { return url; } 
  else if (/\?/.test(url)) { return url.replace('?','.json?'); } 
  else { return url+'.json'; }
}

function force_mime_js(url){
  if (/\.js/.test(url)) { return url; } 
  else if (/\?/.test(url)) { return url.replace('?','.js?'); } 
  else { return url+'.js'; }
}

$.fn.clearForm = function() {
  return this.each(function() {
    var type = this.type, tag = this.tagName.toLowerCase();
    if (tag === 'form'){ return $(':input', this).clearForm(); }
    if (type === 'text' || type === 'password' ||  tag === 'textarea'){ this.value = ''; }
    else if (type === 'checkbox' || type === 'radio'){ this.checked = false; }
    else if (tag === 'select'){ this.selectedIndex = -1; }
  });
};

$.fn.highlight = function(strings, split){
  function findText(node, string){
    if($.trim(string) === ''){ return 0; } // TODO: might aswell check for minimum length    
    if(node.nodeType === 3){
       return searchText(node, string);
    }else if(node.nodeType === 1 && node.childNodes && !(/(script|style)/i.test(node.tagName))){
      for(var i = 0; i < node.childNodes.length; ++i){
        i += findText(node.childNodes[i], string);
      }
    }
    return 0;
  }
  
  function searchText(node, string){
    var position = node.data.toUpperCase().indexOf(string);
    if(position >= 0){ return highlight(node, position, string); }else{ return 0; }
  }
  
  function highlight(node, position, string){
    var spannode = document.createElement('span');
    spannode.className = 'highlight';
    var middlebit = node.splitText(position);
    var endbit = middlebit.splitText(string.length);
    var middleclone = middlebit.cloneNode(true);
    spannode.appendChild(middleclone);
    middlebit.parentNode.replaceChild(spannode, middlebit);
    return 1;
  }
  
  return this.each(function(){
    // FIXME?
    if(typeof(strings) === 'string'){
      if(split === true){ strings = strings.split(' '); }
      else{ findText(this, strings.toUpperCase()); }
    }
    for(var i = 0; i < strings.length; i++){ findText(this, strings[i].toUpperCase()); }
  });
};

// STANDARD
$(function(){
  
  $.ajaxSetup({  headers: { "X-CSRF-Token": $("meta[name='csrf-token']").attr('content') }});
  
  $('.ajax-inline-string').livequery(function(){
    var this_container = $(this);
    
    this_container.click(function(){
      // validations
      if(this_container.attr('data-action') && this_container.attr('data-form') && this_container.attr('data-attribute')){ /*ok*/ }else{ return false; }
      
      var data_action = this_container.attr('data-action');
      var data_form = this_container.attr('data-form');
      var data_attribute = this_container.attr('data-attribute');
      var data_style = this_container.attr('style');
      
      if($('input:text', this_container).length === 0){ 
        var __old_content = this_container.html();
        //var t_html = $("<form method='put' action='"+data_action+"' name='"+data_form+"' class='ajax-form inline' data-target='#"+this_container.attr('id')+"' data-settings='insert'><input type='text' id='"+data_form+"_"+data_attribute+"' name='"+data_form+"["+data_attribute+"]"+"' autocomplete='off' value='"+__old_content+"'/><span class='nowrap'><input type='submit' value='"+COMMON['save']+"'/> "+COMMON['or']+" <a href='#' class='cancel'>"+COMMON['cancel']+"</a></span></form>");
        var t_html = $("<form method='put' action='"+data_action+"' name='"+data_form+"' class='ajax-form inline' data-target='#"+this_container.attr('id')+"' data-settings='insert'><input type='text' id='"+data_form+"_"+data_attribute+"' name='"+data_form+"["+data_attribute+"]"+"' autocomplete='off' value='"+__old_content+"' style='"+data_style+"'/></form>");

        this_container.html(t_html);
        
        this_container.delegate('input', 'keydown focusout', function(e){ 
          if( e.type === 'keydown' && e.which === 27 ){
            this_container.html(__old_content);
            return;
          }
          if( e.type === 'focusout' ){
            this_container.html(__old_content);
            return;
          }
        });
        
        $('input:text', this_container).focus();
      }
    });
  });
  
  $('.ajax-autocomplete').livequery(function(){
    var $this = $(this);    
    var data_settings = $this.attr('data-settings');
    $this.autocomplete( {timeout:200} );
    if(/focus/i.test(data_settings)){ $('input[data-for="'+$this.attr('id')+'"]').focus(); }
  });
  
  $('.ajax-toggle').livequery(function(){ 
    var this_cb = $(this);
    
    //
    if(this_cb.attr('data-resource')/* && this_cb.attr('data-target')*/){
      var data_resource = this_cb.attr('data-resource');
      //var data_target = this_cb.attr('data-target');
    }else{ return; }
    
    //
    //var data_with = this_cb.attr('data-with') ? this_cb.attr('data-with') : 'active'; // 'active' - лишняя зависимость
    var data_attribute = this_cb.attr('data-attribute') ? this_cb.attr('data-attribute') : null;
    
    //
    this_cb.click(function(e){
      e.preventDefault();
      $.ajax({
        type: "POST",
        data: "force=true&attr="+data_attribute,
        url: force_mime_js(data_resource),
        beforeSend: function(){
          this_cb.attr('disabled', 'disabled');
        },
        success: function(response){ // should be either 'true' or 'false'
          this_cb.removeAttr('disabled');
          if(response === 'true'){
            // if(data_target){
            //   $(data_target).addClass(data_with).removeClass(data_with+'_');
            // }
            this_cb.attr('checked', 'checked');
          }else{
            // if(data_target){
            //   $(data_target).addClass(data_with+'_').removeClass(data_with);
            // }
            this_cb.removeAttr('checked');
          }
        }
      });
    });
  });
  
  $('.ajax-form').livequery(function(){
    var this_container = $(this);
    // validations
    if(this_container.attr('data-target')){ /* ok! TODO: form name and action are now assumed to be present */
    }else{ return false; }
    
    var data_target = $(this_container.attr('data-target'));
    var data_success = this_container.attr('data-success');
    var form_name = this_container.attr('name');
    var form_action = force_mime_js(this_container.attr('action')); // FIXME? mime dep.
    var form_method = ($('input[name="_method"]', this_container).length > 0 ? $('input[name="_method"]', this_container).val() : this_container.attr('method')).toUpperCase(); // FIXME? ne ochen' akkuratno vygljadit
    var data_settings = this_container.attr('data-settings'); //

    this_container.submit(function(e){
      var this_submit_button = $('input:submit', this_container);
      $.ajax({
        type: form_method,
        cache: false,
        url: form_action,
        data: this_container.serialize(),
        beforeSend: function(){
          this_submit_button.attr('disabled', 'disabled');
        },
        error: function(xhr, status, error){
          if($.trim(xhr.responseText) === ''){ return; }
          var error_fields = eval('('+xhr.responseText+')'); // {:field_name : value} object
          if(typeof(error_fields) == 'object'){
            // TODO: перед добавлением ошибок стереть все классы ошибок старых
            $('input, textfield', this_container).removeClass('field_with_errors');
            for ( var key in error_fields ) {
              // TODO: избавиться от формнейм
              $('#'+form_name+'_'+key+':visible, input[data-for="'+form_name+'_'+key+'"]:visible', this_container).addClass('field_with_errors');
            }
          }
        },      
        success: function(data, status){
          
          var __data;
          var data_filter = eval('('+this_container.attr('data-filter')+')');
          
          if(typeof(data_filter) == "function" ) { 
            __data = data_filter(data);
          }else{
            switch(typeof(data)) {
              //case 'string': break;
              case 'object':
                var __first_value;
                for(var key in data) {
                  if(data.hasOwnProperty(key)) {
                    __data = data[key];
                    break;
                  }
                }
                break;
              default: __data = data;
            }
          }
          
          if(typeof(data_filter) == "function" ) { __data = data_filter(__data); }
          //
          
          if(data_success){
            eval(data_success+'('+data+')');
          }else{
            //DOM insertion switch
            switch(true) {
              case (/prepend/i.test(data_settings)) : data_target.prepend(__data); break;
              case (/append/i.test(data_settings)) : data_target.append(__data); break;
              case (/insert/i.test(data_settings)) : data_target.html(__data); break;
              case (/after/i.test(data_settings)) : data_target.after(__data); break;
              case (/before/i.test(data_settings)) : data_target.before(__data); break;
              default: data_target.replaceWith(__data); break;
            }
          }
          
          // form cleanup
          $('.field_with_errors', this_container).removeClass('field_with_errors');
          if(/reset/i.test(data_settings)){ this_container.clearForm(); }
          if(/close/i.test(data_settings)){ this_container.hide(); }     
          //return false;
        },
        complete: function(){
          this_submit_button.removeAttr('disabled');
        }
      });
      return false;
    });
  });
  
  $('.ajax-destroy').livequery(function(){
    var $this = $(this);
    $this.click(function(e){
      if( !$this.attr('href') || !$this.attr('data-target') ){ return false; }
      var this_action = $this.attr('href');
      var $data_target = $($this.attr('data-target'));
      var data_success = $this.attr('data-success');
      var confirm_message = $this.attr('data-confirm') ? T[$this.attr('data-confirm')] : null;
      var alert_message = $this.attr('data-alert') ? T[$this.attr('data-alert')] : null;
      
      if( (confirm_message && confirm(confirm_message)) || !confirm_message ){
        $.ajax({
          type: "DELETE", data: "force=true", url: force_mime_js(this_action),
          success: function(data, status){ 
            if(data_success){
              eval(data_success+'.apply($this, ['+data+'])');
            }else{
              $data_target.remove();
            }          
          },
          error: function(){
            if(alert_message){ alert(alert_message); }
          }
        });
      }
      return false;
    });
  });

  $('.data-table').delegate('td, th', 'mouseover mouseleave', function(e) {
    if (e.type == 'mouseover') {
      $(this).parent().addClass('hover');
      $('colgroup', $(this).closest('table')).eq($(this).index()).addClass('hover');
    } else {
      $(this).parent().removeClass('hover');
      $('colgroup', $(this).closest('table')).eq($(this).index()).removeClass('hover');
    }
  });
  
  $('.chart-table').delegate('td, th', 'mouseover mouseleave', function(e) {
    if (e.type == 'mouseover') {
      //$(this).parent().addClass('hover');
      $('colgroup', $(this).closest('table')).eq($(this).index()).addClass('hover');
    } else {
      //$(this).parent().removeClass('hover');
      $('colgroup', $(this).closest('table')).eq($(this).index()).removeClass('hover');
    }
  });
});
