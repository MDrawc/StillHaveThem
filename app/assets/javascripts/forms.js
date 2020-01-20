function activateDropdowns() {
    var $buttons = $('.my_dd');
    var $drop = $('#f-lone');

    $buttons.click(function() {
      var mother = $(this).attr('data-mother');
      UIkit.dropdown($drop, { boundary: mother}).show();
    });
}

function resetFormErrors(is_list, id) {
    var reset_elements = ['#collection', '#game_platform', '#game_physical_true', '#game_physical_false','#copy_true', '#copy_false'];

    if (is_list) {
        var $form = $('#t-ops').find('.modal-content');
    } else {
        var $form = $('#f-lone');
    }

    var $errors = $form.find('.add-form-errors');
    var $form_parts = $form.find(reset_elements.join(', '));

    $form_parts.one('input', function() {
        $errors.html('');
    });
}

function resetLoginErrors() {
    $("#login-mail").add('#login-password').on('input', function() {
        var $good = $(".login-ok");
        var $bad = $(".login-er");
        if ($bad.is(':visible')) {
            $bad.hide();
            $good.show();
        }
    });
}

function resetSignupErrors() {
    $("#signup-mail").on('input', function() {
        var $good = $("#mail-icon");
        var $bad = $("#mail-er-icon");
        if ($bad.is(':visible')) {
            $bad.hide();
            $bad.attr('uk-tooltip', 'title:; pos: top-left');
            $good.show();
        }
    });

    $('#signup-password').on('input', function() {
        var $good = $("#key-icon");
        var $bad = $("#key-er-icon");
        if ($bad.is(':visible')) {
            $bad.hide();
            $bad.attr('uk-tooltip', 'title:; pos: top-left');
            $good.show();
        }
    });
}

function resetCollErrors() {
    $('#collection_name').one('input', function() {
        var $good = $('#coll-icon-input');
        var $bad = $('#coll-error');
        if ($bad.is(':visible')) {
            $bad.hide();
            $good.show();
        }
    });
}

function preselectPlatform(is_list, platform) {
    if (is_list) {
        var $form = $('#t-ops').find('.modal-content');
    } else {
        var $form = $('#f-lone');
    }
    var $element = $form.find('#game_platform').find("option[value^='" + platform + ",']");
    $element.attr("selected", "selected");
    $form.find('.cf-platform-icon').attr('class', 'cf-platform-green');
}

function changeButton(is_list, id) {
    if (is_list) {
        var $form = $('#t-ops').find('.modal-content');
    } else {
        var $form = $('#f-lone');
    }

    var $button = $form.find("#cf-cm-button");
    var $radios = $form.find(".action input[type='radio']");

    $radios.on('input', function() {
        $form.find('.c-m').removeClass('chosen')
        var $selected = $radios.filter(":checked");
        $selected.parent().addClass('chosen');
        $button.text($selected.val() === 'true' ? 'Copy' : 'Move');
    });
}

function selectLastColl(is_list, id) {
    var coll_id = Cookies.get('last_coll');

    if (coll_id) {
        if (is_list) {
            var $form = $('#t-ops').find('.modal-content');
        } else {
            var $form = $('#f-lone');
        }
        var $el = $form.find('#collection').find("option[value^='" + coll_id + ",']");
        $el.attr("selected", "selected");
    }
}

function activateForm(is_list, id, is_add = false) {
    if (is_list) {
        var $form = $('#t-ops').find('.modal-content');
    } else {
        var $form = $('#f-lone');
    }

    var select_element = $form.find('#collection');
    var icon = $form.find('.cf-collection-icon');
    var platform_element = $form.find('#platform-option');
    var needs_platform = $form.find('#game_needs_platform');

    // Check auto-chosen collection in add-form:
    if (is_add) {
        var value = select_element.val();
        var cv = value.length ? (value.split(",")[1] == 'true') : 'select';
        if (cv === false) {
            platform_element.hide();
            icon.attr('class', 'cf-collection-green');
            needs_platform.attr('value', 'false');
        }
    }

    select_element.on('input', function() {
        var value = $(this).val();
        var cv = value.length ? (value.split(",")[1] == 'true') : null;

        if (cv === true) {
            platform_element.show();
            icon.attr('class', 'cf-collection-green');
            needs_platform.attr('value', 'true');
        } else if (cv === false) {
            platform_element.hide();
            icon.attr('class', 'cf-collection-green');
            needs_platform.attr('value', 'false');
        } else {
            needs_platform.attr('value', 'false');
            icon.attr('class', 'cf-collection-icon');
            platform_element.hide();
        }
    });
}

function updatePlatformIcon(form_type, id) {
    if (is_list) {
        var $form = $('#t-ops').find('.modal-content');
    } else {
        var $form = $('#f-lone');
    }

    var select_element = $form.find('#game_platform');
    var icon = $form.find('[class^=cf-platform-]');

    select_element.on('input', function() {
        var value = $(this).val();
        if (value.length) {
            icon.attr('class', 'cf-platform-green');
        } else {
            icon.attr('class', 'cf-platform-icon');
        }
    });
}

function paintItBlack(id) {
    var $gs = $('#gs-' + id);
    var $add_form_link = $gs.find('.plus');
    var $game_name = $gs.find('.game-name');

    $add_form_link.addClass('disabled');
    $game_name.addClass('focused');

    UIkit.util.once('#f-lone', 'hide', function() {
        $add_form_link.removeClass('disabled');
        $game_name.removeClass('focused');
    });
}

function passwordUnmask() {
    $('.unmask').on('click', function() {
        if ($(this).prev('input').attr('type') == 'password')
            changeType($(this).prev('input'), 'text');
        else
            changeType($(this).prev('input'), 'password');
        return false;
    });
}
