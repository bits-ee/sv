
$(function(){
  $("#project_synopsys").charCount({
    allowed: 140,
    warning: 20,
        counterText: ($('head').attr('lang') == 'en' ? 'Characters left: ' : 'Осталось символов: '),
        cssWarning: 'counter_warning',
        cssExceeded: 'counter_exceeded'
    });

    $("form #project_status").change(function () {
        var reason = $('form #reason');
        if ($(this).val() == 'REJECTED')
            reason.addClass('block').removeClass('hidden');
        else{
            reason.addClass('hidden').removeClass('block');
        }
    });
});

