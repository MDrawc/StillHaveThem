function resetForm(form_id) {
    $(':input', '#' + form_id)
        .not(':button, :submit, :reset, :hidden')
        .val('')
        .prop('checked', false)
        .prop('selected', false);
}

function copyShareLinks() {
    $('a.cp-share-link').click(function() {
        var $link = $('#' + $(this).attr('target'));
        $link.prop('disabled', false);
        $link.select();
        document.execCommand("copy");
        document.getSelection().removeAllRanges();
        $link.prop('disabled', true);
    });
}

function disableEnableForm(disable, form_id) {
    var $form = $('#' + form_id);
    disable ? $form.addClass('disabled') : $form.removeClass('disabled');
    $(':input', $form).prop('disabled', disable);
}

function cancelEditForm(share_id){
    var $btn = $('#sh-ud-cancel-' + share_id);
    $btn.click(function() {
        var $form = $btn.parent().parent();
        $form.trigger('reset');
        Rails.fire($form[0], 'submit');
    });
}

function resetShWarningIcon(name, input) {
    var no_error = "<span id='" + name + "-icon' class='sh-input-icon' uk-icon='tag'>";
    var $error_icon = $('#' + name + '-icon');

    $(input).on('input', function() {
        if ($error_icon.hasClass('warning-icon')) {
            $error_icon.replaceWith(no_error);
        }
    });
}
