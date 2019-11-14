function remove_active_create_coll() {
    UIkit.util.once('#coll-modal', 'hide', function() {
        $('#m-add-coll').removeClass('active')
    });
}

function custom_data_confirm() {

    var handleConfirm = function(element) {
        if (!allowAction(this)) {
            Rails.stopEverything(element)
        }
    }
    var allowAction = function(element) {
        if (element.getAttribute('data-confirm') === null) {
            return true
        }
        showConfirmDialog(element);
        return false
    }
    var confirmed = function(element, result) {
        if (result.value) {
            element.removeAttribute('data-confirm')
            element.setAttribute('data-remote', true)
            element.click()
        }
        return false
    }

    var showConfirmDialog = function(link) {
        var message = $(link).attr('data-confirm');
        UIkit.modal.confirm(message).then(function() {
            confirmed(link, {
                value: true
            });
        });
        $('.uk-button-primary').html('<span uk-icon="trash"></span>')
    }

    $("a[data-confirm]").on('click', handleConfirm);
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

$(function(){
  custom_data_confirm();
});
