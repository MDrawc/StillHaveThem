var $icon = $('#password-icon');
var $warning = $icon.next();
$icon.hide();
$warning.attr("uk-tooltip", "title: Wrong password; pos: top-left");
$warning.show();
resetSetWarningIcon('#enter-password', $icon, $warning);
