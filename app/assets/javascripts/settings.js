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
