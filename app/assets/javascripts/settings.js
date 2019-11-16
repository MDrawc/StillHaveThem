function resetSetWarningIcon(input_id, icon_id, warning_id) {
    var $no_error = $(icon_id);
    var $error_icon = $(warning_id);

    var $input = $(input_id);
    $input.one('input', function() {
        if ($error_icon.length != 0) {
            $error_icon.remove();
            $no_error.show();
        }
    });
}

function activateChangeEmailPassword() {
    $('#change-mail').add('#change-password').on('input', function() {
        var val = $(this).val();
        var $td_with_button = $(this).parent().next();
        $td_with_button.removeClass('disabled');

        if (val == "") {
            $td_with_button.addClass('disabled');
        }
    });
}

function activateChangeGpv() {
    var $input = $('#user_games_per_view');
    var $counter = $('#gpv-counter');
    var $submit = $('#submit-gpv');
    var def = $input.val();

    $input.on('input', function() {
        var val = $(this).val();
        $counter.removeClass('disabled').text(val);
        $submit.removeClass('disabled');

        if (val == def) {
            $counter.addClass('disabled');
            $submit.addClass('disabled');
        }
    });
}
