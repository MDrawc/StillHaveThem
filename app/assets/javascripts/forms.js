function resetFormErrors(form_type, id) {
    var form_selector = form_type === 'list' ? "#t-ops .modal-content" : '#' + form_type + '-form-' + id;
    var reset_elements = ['#collection', '#game_platform', '.cf-physical', '.cf-digital','#copy_true', '#copy_false']
    var errors = form_selector + ' ' + '.add-form-errors';

    for (i = 0; i < reset_elements.length; i++) {

        var formPart = form_selector + ' ' + reset_elements[i];

        $(formPart).on('input', function() {
            $(errors).html('');
        });
    }
}

function preselectPlatform(form_type, id, platform) {
    var selector = form_type === 'list' ? "#t-ops .modal-content" : '#' + form_type + '-form-' + id;
    var form = $(selector);
    var element = form.find("#game_platform option[value^='" + platform + ",']");
    element.attr("selected", "selected");
    form.find('.cf-platform-icon').attr('class', 'cf-platform-green');
}

function changeButton(form_type, id) {
    var selector = form_type === 'list' ? "#t-ops .modal-content" : '#' + form_type + '-form-' + id;
    var form = $(selector);
    var element = form.find(".action input[type='radio']");
    var button = form.find(".cf-add-button");
    element.on('input', function() {
        var selected = element.filter(":checked");
        if (selected.length > 0) {
            form.find('.c-m').removeClass('chosen')
            selected.parent().addClass('chosen');
            selected_val = selected.val();
        }
        b_name = eval(selected_val) ? 'Copy' : 'Move';
        button.text(b_name);
    });
}

function selectLastColl(form_type, id) {
    var coll_id = Cookies.get('last_coll');

    if (coll_id) {
        var selector = form_type === 'list' ? "#t-ops .modal-content" : '#' + form_type + '-form-' + id;
        var form_select = $(selector).find('#collection')
        var element = form_select.find("option[value^='" + coll_id + ",']");
        element.attr("selected", "selected");
    }
}

function activateForm(form_type, id) {
    var selector = form_type === 'list' ? "#t-ops .modal-content" : '#' + form_type + '-form-' + id;
    var form = $(selector);
    var select_element = form.find('#collection');
    var icon = form.find('.cf-collection-icon');
    var platform_element = form.find('#platform-option');
    var needs_platform = form.find('#game_needs_platform');

    // Check auto-chosen collection in add-form:
    if (form_type === 'add') {
        var value = select_element.val();
        var cv = value.length != 0 ? (value.split(",")[1] == 'true') : 'select';
        if (cv == false) {
            platform_element.hide();
            icon.attr('class', 'cf-collection-green');
            needs_platform.attr('value', 'false');
        }
    }

    select_element.on('input', function() {
        var value = select_element.val();
        var cv = value.length != 0 ? (value.split(",")[1] == 'true') : 'select';

        if (cv == true) {
            platform_element.show();
            icon.attr('class', 'cf-collection-green');
            needs_platform.attr('value', 'true');
        } else if (cv == false) {
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
    var selector = form_type === 'list' ? "#t-ops .modal-content" : '#' + form_type + '-form-' + id;
    var form = $(selector);
    var select_element = form.find('#game_platform');

    select_element.on('input', function() {
        var value = select_element.val();
        var icon = form.find('[class^=cf-platform-]');
        if (value.length > 0) {
            icon.attr('class', 'cf-platform-green');
        } else {
            icon.attr('class', 'cf-platform-icon');
        }
    });
}

function paintItBlack(id) {
    var add_form_link = $('#gs-' + id + ' .plus');
    var game_name = $('#gs-' + id + ' .game-name');

    add_form_link.addClass('disabled');
    game_name.addClass('focused');

    UIkit.util.on('#add-form-' + id, 'hide', function() {
        add_form_link.removeClass('disabled');
        game_name.removeClass('focused');
    });
}

function changeSearchBar() {
    $("[id^=search_query_type]").on('input', function() {
    var selectedVal = "";
    var selected = $("input[type='radio']:checked");
    if (selected.length > 0) {
        selectedVal = selected.val();
    }

    if (selectedVal === 'char') {
      $('#search-igdb-bar').attr('placeholder', 'Search video game characters...')
    } else if (selectedVal === 'dev') {
      $('#search-igdb-bar').attr('placeholder', 'Search video game developers...')
    } else if (selectedVal === 'game') {
      $('#search-igdb-bar').attr('placeholder', 'Search video games...')
    }

    });
}
