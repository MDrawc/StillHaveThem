var $icon = $('#reset-ok');
var $warning = $icon.next();
$icon.hide();
$warning.attr("uk-tooltip", "title: Email address not found; pos: top-left");
$warning.show();
resetSetWarningIcon('#reset-pass-mail', $icon, $warning);
