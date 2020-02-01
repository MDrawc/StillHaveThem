function remove_active_create_coll() {
    UIkit.util.once('#coll-modal', 'hide', function() {
        $('#m-add-coll').removeClass('active');
    });
}

function hideShowBackToTop() {
    var $button = $('#scroll-up');
    $(window).scroll(function() {
        if ($(window).scrollTop() > 200) {
            $button.fadeIn();
        } else {
            $button.fadeOut();
        }
    });
}

function cancelCollDelete() {
    $('#coll-uff').one('click', function() {
        UIkit.modal($("#coll-del-modal")).hide();
    });
}

function getDocHeight() {
    var D = document;
    return Math.max(
        D.body.scrollHeight, D.documentElement.scrollHeight,
        D.body.offsetHeight, D.documentElement.offsetHeight,
        D.body.clientHeight, D.documentElement.clientHeight
    );
}
