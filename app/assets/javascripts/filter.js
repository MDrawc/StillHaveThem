function showHideClose(form, name, plat, reset) {
    var status = [];
    status.push(name.val().length === 0);

    if (plat.length) {
        status.push(plat.val().length === 0);
        status.push(form.find("input[type='radio']:checked").val() == 'on');
    }

    if (status.every(function(e) {
            return (e === true)
        })) {
        reset.hide();
    } else {
        if (reset.is(':hidden')) {
            reset.show();
        }
    }
}

function refresh(form) {
    var data = form.serialize();
    if ($('#gsview').val() === 'panels') {
        data += addOpenPanelsData();
    }
    $.get(form.attr("action"), data, null, "script");
    return false;
}

function filterGames() {
    var $form = $("#game_search");
    var $reset = $('#search-reset');
    var $name = $("#q_name_dev_cont");
    var $plat = $('#q_plat_eq');

    $name.keyup(function() {
        showHideClose($form, $name, $plat, $reset);
        refresh($form);
    });

    $plat.on('input', function() {
        showHideClose($form, $name, $plat, $reset);
        refresh($form);
    });

    $form.find("input[type='radio']").on('input', function() {
        showHideClose($form, $name, $plat, $reset);
        refresh($form);
    });

    $reset.click(function() {
        $name.val("");
        $plat.prop('selectedIndex', 0)
        $("#q_physical_eq").prop('checked', true);
        $form.find('.select-input').next().empty();
        $(this).hide();
        refresh($form);
    });
}
