function filter() {

    function showHideClose() {
        var status = [];
        status.push($('#q_name_dev_cont').val().length == 0);

        if ($('#q_plat_eq').length) {
            status.push($('#q_plat_eq').val().length == 0);
        }

        if ($('#q_physical_eq').length) {
            status.push($("#game_search input[type='radio']:checked").val() == 'on');
        }

        if (status.every(function(e) {
                return (e == true)
            })) {
            $('#search-reset').hide();
        } else {
            if ($('#search-reset').is(':hidden')) {
                $('#search-reset').show();
            }
        }
    }

    function refresh() {
        $.get($("#game_search").attr("action"), $("#game_search").serialize(), null, "script");
        return false;
    }

    $("#q_name_dev_cont").keyup(function() {
        showHideClose();
        refresh();
    });
    $('#q_plat_eq').on('input', function() {
        showHideClose();
        refresh();
    });
    $("#game_search input[type='radio']").on('input', function() {
        showHideClose();
        refresh();
    });
    $('#search-reset').click(function() {
        $("#q_name_dev_cont").val("");
        $('#q_plat_eq').prop('selectedIndex', 0)
        $("#q_physical_eq").prop('checked', true);
        $('.select-input ~ span').text('All Platforms');
        $('#search-reset').hide();
    });
}



