var $input = $('#reset-pass-mail');
var $ok_icon = $input.next();
var $error_icon = $ok_icon.next();
$ok_icon.hide();
$error_icon.attr("uk-tooltip", "title: Email address not found; pos: top-left").show();
resetSimpleError($input, $ok_icon, $error_icon);
