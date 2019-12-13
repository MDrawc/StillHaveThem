function remove_active_create_coll() {
    UIkit.util.once('#coll-modal', 'hide', function() {
        $('#m-add-coll').removeClass('active')
    });
}

function hideShowBackToTop() {
    var $button = $('#scroll-up');
    $(window).scroll(function() {
        if ($(window).scrollTop() > 200) {
            $button.fadeIn()
        } else {
            $button.fadeOut()
        }
    });
}

function cancelCollDelete() {
    $('#coll-uff').one('click', function() {
        UIkit.modal($("#coll-del-modal")).hide();
    });
}
