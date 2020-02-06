function resetShForm(form_id) {

    $inputs = $(':input', '#' + form_id)

    $inputs
        .not(':button, :submit, :reset, :hidden, :checkbox')
        .val('');

    $inputs
        .filter(':checkbox')
        .prop('checked', false);
}

function copyShareLinks() {
    $('.cp-share-link').click(function() {
        var $link = $('#' + $(this).attr('target'));
        $link.prop('disabled', false);
        $link.select();
        document.execCommand("copy");
        document.getSelection().removeAllRanges();
        $link.prop('disabled', true);

        $(this).addClass('copied').text('Done');
        $(this).delay(500).queue(function() {
            $(this).removeClass('copied').text('Copy');
            $(this).dequeue();
        });
    });
}

function disableEnableForm(disable, form_id) {
    var $form = $('#' + form_id);
    disable ? $form.addClass('disabled') : $form.removeClass('disabled');
    $(':input', $form).prop('disabled', disable);
}

function cancelEditForm(share_id) {
    var $btn = $('#sh-ud-cancel');
    var $form = $btn.parents('.sh_edit_form');
    var $share = $('#share-' + share_id);
    var $edit_btn = $('#sh-edit-' + share_id);

    $btn.click(function() {
        $form.remove();
        $share.find('.share-info').show();
        $edit_btn.parent().removeClass('disabled');
    });
}

function resetShErrorsWithResetButton(type) {
    var $reset_btn =  $('#' + type + 'sh-reset');
    $reset_btn.off();
    $reset_btn.one('click', function() {
        var fields = ['title', 'message', 'shared'];
        var f_length = fields.length;
        for (var i = 0; i < f_length; i++) {
            var $ok_icon = $('#' + type + fields[i] + '-icon');
            var $error_icon = $ok_icon.next();
            if ($error_icon.is(':visible')) {
                $error_icon.hide();
                $ok_icon.show();
            }
        }
    });
}

function activateEditShLink() {
    $btn = $('.sh-edit');
    $btn.off();
    $btn.click(function() {
        $(this).parent().toggleClass('disabled');
    });
}

function convertTimeToLocal(selector) {
    $(selector).each(function() {

        if ($(this).hasClass('need-converting')) {
            var val = $(this).text();
            var d = new Date(parseFloat(val));
            $(this).text(d.toLocaleString()).removeClass('need-converting');
        }
    });
}
