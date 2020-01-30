function set_offc() {
    if (Cookies.get('offc_right') === 'true') {
        $(document.body).addClass('uk-offcanvas-flip');
    }
}

function flip_offc() {
    var $body = $(document.body);
    var $flip = $('#flip');

    if ($body .hasClass('uk-offcanvas-flip')) {
        $flip.addClass('flip-right');
    }

    $flip.click(function() {
        if ($(this).hasClass('flip-right')) {
            $body .removeClass('uk-offcanvas-flip');
            Cookies.set('offc_right', 'false', {
                expires: 365
            });
        } else {
            $body .addClass('uk-offcanvas-flip');
            Cookies.set('offc_right', 'true', {
                expires: 365
            });
        }
        $(this).toggleClass('flip-right');
    });
}
