function changeLogo() {

    $('#logo').click(function() {
        var $el = $(this);
        var $input = $('<input type="text">').val($el.text());
        $el.html($input);

        function transformTitle(input) {
            var words = input.toLocaleLowerCase().split(' ');
            var result = '';

            words.forEach(function(element) {
                if (element != '') {
                    result += element.charAt(0).toUpperCase() + element.slice(1);
                    result += ' '
                }
            });

            return result.trimEnd();
        }

        var save = function() {

            if ($input.val() === '') {
                var logo = 'still have them';
                Cookies.remove('title');
            } else {
                var logo = $input.val();
                Cookies.set('title', logo, {
                expires: 365
            });
            }

            $input.replaceWith(logo);
            var title = logo;
            $('title').text(transformTitle(title));
        };

        $input.one('blur', save).focus();

        $input.on('keypress', function(event) {
            var keycode = (event.keyCode ? event.keyCode : event.which);
            if (keycode == '13') {
                save();
                $input.off();
            }
        });
    });
}

$(function() {
    changeLogo();
});
