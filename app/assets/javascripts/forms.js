function resetFormErrors(form_type, id) {
    var reset_elements = ['#collection', '#game_platform', '#game_physical_true', '#game_physical_false','#copy_true', '#copy_false'];

    if (form_type === 'list') {
        var $form = $('#t-ops').find('.modal-content');
    } else {
        var $form = $('#' + form_type + '-form-' + id);
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

function preselectPlatform(form_type, id, platform) {
    if (form_type === 'list') {
        var $form = $('#t-ops').find('.modal-content');
    } else {
        var $form = $('#' + form_type + '-form-' + id);
    }
    var $element = $form.find('#game_platform').find("option[value^='" + platform + ",']");
    $element.attr("selected", "selected");
    $form.find('.cf-platform-icon').attr('class', 'cf-platform-green');
}

function changeButton(form_type, id) {
    if (form_type === 'list') {
        var $form = $('#t-ops').find('.modal-content');
    } else {
        var $form = $('#' + form_type + '-form-' + id);
    }
    var $element = $form.find(".action input[type='radio']");
    var $button = $form.find(".cf-cm-button");
    $element.on('input', function() {
        var selected = $element.filter(":checked");
        if (selected.length) {
            $form.find('.c-m').removeClass('chosen')
            selected.parent().addClass('chosen');
        }
        b_name = selected.val() === 'true' ? 'Copy' : 'Move';
        $button.text(b_name);
    });
}

function selectLastColl(form_type, id) {
    var coll_id = Cookies.get('last_coll');

    if (coll_id) {
        if (form_type === 'list') {
            var $form = $('#t-ops').find('.modal-content');
        } else {
            var $form = $('#' + form_type + '-form-' + id);
        }
        var $el = $form.find('#collection').find("option[value^='" + coll_id + ",']");
        $el.attr("selected", "selected");
    }
}

function activateForm(form_type, id) {
    if (form_type === 'list') {
        var $form = $('#t-ops').find('.modal-content');
    } else {
        var $form = $('#' + form_type + '-form-' + id);
    }

    var select_element = $form.find('#collection');
    var icon = $form.find('.cf-collection-icon');
    var platform_element = $form.find('#platform-option');
    var needs_platform = $form.find('#game_needs_platform');

    // Check auto-chosen collection in add-form:
    if (form_type === 'add') {
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
    if (form_type === 'list') {
        var $form = $('#t-ops').find('.modal-content');
    } else {
        var $form = $('#' + form_type + '-form-' + id);
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

    UIkit.util.once('#add-form-' + id, 'hide', function() {
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
