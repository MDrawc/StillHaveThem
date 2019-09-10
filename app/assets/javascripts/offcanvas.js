function set_offc(user_id) {
    if (Cookies.get(user_id + '-offc_right') === 'true') {
        $('body').addClass('uk-offcanvas-flip');
    }
}

function flip_offc(user_id) {

    if ($('body').hasClass('uk-offcanvas-flip')) {
        $('.flip').addClass('flip-right');
    }

    $('.flip').click(function() {
        if ($(this).hasClass('flip-right')) {
            $('body').removeClass('uk-offcanvas-flip');
            Cookies.set(user_id + '-offc_right', 'false', {
                expires: 365
            });
        } else {
            $('body').addClass('uk-offcanvas-flip');
            Cookies.set(user_id + '-offc_right', 'true', {
                expires: 365
            });
        }
        $('.flip').toggleClass('flip-right');
    });
}

function cleanOffcanvas() {
    $("[id^=i-]").remove();
}
