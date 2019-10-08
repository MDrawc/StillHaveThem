function remove_active_create_coll() {
    UIkit.util.on('#create-coll-modal', 'hide', function() {
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

function changeTheme() {
    $('#change-theme').click(function() {
        if (Cookies.get('theme') == 'theme_dark') {
            $(this).removeClass('active');
            Cookies.set('theme', 'theme_default', {
                expires: 365
            });
            $('#theme-control').attr('href', '/assets/theme_default.self.css');
        } else {
            $(this).addClass('active');
            Cookies.set('theme', 'theme_dark', {
                expires: 365
            });
            $('#theme-control').attr('href', '/assets/theme_dark.self.css');
        }
    });
}

$(function(){
  custom_data_confirm();
});
