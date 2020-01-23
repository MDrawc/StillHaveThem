function filterGames() {

    function showHideClose() {
        var status = [];
        status.push($('#q_name_dev_cont').val().length == 0);

        var $q_plat = $('#q_plat_eq');
        if ($q_plat.length) {
            status.push($q_plat.val().length == 0);
            status.push($("#game_search").find("input[type='radio']:checked").val() == 'on');
        }

        if (status.every(function(e) {
                return (e === true)
            })) {
            $('#search-reset').hide();
        } else {
            var $search_reset = $('#search-reset');
            if ($search_reset.is(':hidden')) {
                $search_reset.show();
            }
        }
    }

    function refresh() {
        var $game_search = $("#game_search");
        var data = $game_search.serialize();
        if ($('#gsview').val() === 'panels') {
          data += addOpenPanelsData();
        }
        $.get($game_search.attr("action"), data, null, "script");
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

    $("#game_search").find("input[type='radio']").on('input', function() {
        showHideClose();
        refresh();
    });

    $('#search-reset').click(function() {
        $("#q_name_dev_cont").val("");
        $('#q_plat_eq').prop('selectedIndex', 0)
        $("#q_physical_eq").prop('checked', true);
        $('.select-input').next().empty();
        $(this).hide();
    });
}
