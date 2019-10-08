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
            $(this).removeClass('sun');
            $(this).html('<svg xmlns="http://www.w3.org/2000/svg" height="20" version="1.1" viewBox="-1.5 -44.5 66 66" width="20" xml:space="preserve"><path d="M49.1 3.3c-17.9 0-32.4-14.5-32.4-32.4 0-4.8 1-9.3 2.9-13.3C8.3-37.4 0.4-26.1 0.4-12.9c0 17.9 14.5 32.4 32.4 32.4 13.2 0 24.5-7.8 29.6-19.1C58.4 2.2 53.9 3.3 49.1 3.3z" fill="none" stroke="#999" stroke-linejoin="round" stroke-miterlimit="10" stroke-width="3.5"/></svg>');
            Cookies.set('theme', 'theme_default', {
                expires: 365
            });
            $('#theme-control').attr('href', '/assets/theme_default.self.css');
        } else {
            $(this).addClass('sun');
            $(this).html('<?xml version="1.0" ?><svg width="22" height="22" version="1.1" viewBox="0 0 50 50" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><path d="M25,38c7.168,0,13-5.832,13-13s-5.832-13-13-13s-13,5.832-13,13S17.832,38,25,38z M25,14c6.065,0,11,4.935,11,11   s-4.935,11-11,11s-11-4.935-11-11S18.935,14,25,14z"/><rect height="7" width="2.5" x="24" y="1"/><rect height="7" width="2.5" x="24" y="42"/><rect height="2.5" width="7" x="42" y="24"/><rect height="2.5" width="7" x="1" y="24"/><rect height="2.5" transform="matrix(0.7071 -0.7071 0.7071 0.7071 4.1413 31.0062)" width="7" x="35.996" y="9.505"/><rect height="2.5" transform="matrix(0.7071 -0.7071 0.7071 0.7071 -24.852 18.9973)" width="7" x="7.004" y="38.496"/><rect height="7" transform="matrix(0.7071 -0.7071 0.7071 0.7071 -16.3595 39.4958)" width="2.5" x="38.496" y="35.995"/><rect height="7" transform="matrix(0.7071 -0.7071 0.7071 0.7071 -4.3511 10.5042)" width="2.5" x="9.504" y="7.004"/></svg>');
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
