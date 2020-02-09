function show_notification(message) {
    UIkit.notification({
        message: $('<div/>').html(message).text(),
        status: 'warning',
        pos: 'top-right',
        timeout: 5000
    });
}

function activateDropdowns($more) {
    var $buttons = $more ? $more.find('.my_dd') : $('.my_dd');
    var $drop = $('#f-lone');

    $buttons.click(function() {
        var mother = $(this).attr('data-mother');
        UIkit.dropdown($drop, {
            boundary: mother
        }).show();
    });
}

function resetFormErrors(is_list) {
    var reset_elements_ids = ['#collection',
     '#game_platform', '#game_physical_true',
      '#game_physical_false', '#copy_true', '#copy_false'];

    var $form = is_list ? $('#t-ops') : $('#f-lone');
    var $error = $form.find('.add-form-errors');
    var $form_parts = $form.find(reset_elements_ids.join(', '));
    $form_parts.one('input', function() {
        $error.hide();
    });
}

function handleAddFormErrors(view, msg) {
    if (view === 'list') {
        var $error = $("#t-ops").find(".add-form-errors");
        var is_list = true;
    } else {
        var $error = $("#f-lone").find(".add-form-errors");
        var is_list = false;
    }
    $error.find('span').text(msg);
    $error.show();
    resetFormErrors(is_list);
}

function resetSimpleError(inputs, ok_icon, error_icon) {
    inputs.one('input', function() {
        if (error_icon.is(':visible')) {
            error_icon.hide();
            ok_icon.show();
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

function selectLastColl(is_list) {
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

function activateForm(is_list, is_add = false) {
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
        var $eye = $(this).find('.eye');
        var $eye_hidden = $(this).find('.eye-hidden');
        var $input = $(this).prev('input')
        if ($input.attr('type') == 'password') {
            changeType($input, 'text');
            $eye.hide();
            $eye_hidden.show();
        }
        else {
            changeType($input, 'password');
            $eye_hidden.hide();
            $eye.show();
        }
        return false;
    });
}
