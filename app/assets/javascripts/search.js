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

function searchWait() {
    $('#search').click(function() {
        var thingy = $('#search-wait');
        var search_anim = '<div class="rotor"><span class="glass" uk-icon="icon: search; ratio: 4"></span></div><p>Searching</p>';
        var view_c = $('#view-container');

        if (view_c.length != 0) {
            switch (view_c.attr('view')) {
                case 'covers':
                    $('#search-results').addClass('mask2');
                    break;
                default:
                    $('#search-results').addClass('mask1');
            }
        } else {
            $('#search-results').addClass('mask1');
        }

        thingy.html(search_anim);
        thingy.addClass('front');
    });
}

function clearSearchWait() {
    var thingy = $('#search-wait');
    thingy.empty();
    thingy.removeClass('front');
    $('#search-results').removeClass();
}

function clearNoResults() {
    var $search_form = $('.search-form input');

    $search_form.on('input', function() {
        var $no_results = $('#no-results');
        if ($no_results.length != 0) {
            $no_results.remove();
        }
    });
}
