function changeSearchBar() {

    var bar = $('#search-igdb-bar');

    $("[id^=search_query_type]").on('input', function() {
        var selectedVal = "";
        var selected = $("input[type='radio']:checked");
        if (selected.length > 0) {
            selectedVal = selected.val();
        }

        if (selectedVal === 'char') {
            bar.attr('placeholder', 'Search video game characters...')
        } else if (selectedVal === 'dev') {
            bar.attr('placeholder', 'Search video game developers...')
        } else if (selectedVal === 'game') {
            bar.attr('placeholder', 'Search video games...')
        }

    });
}

function searchWait() {
    $('#search').click(function() {

        $('#no-results').remove();
        var thingy = $('#search-wait');
        var search_anim = '<div class="rotor"><svg id="Layer_1" version="1.1" viewBox="15 15 70 70" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><path clip-rule="evenodd" d="M64.5,44.6c0-11.6-9.4-20.9-20.9-20.9c-11.6,0-20.9,9.4-20.9,20.9  c0,11.6,9.4,20.9,20.9,20.9C55.1,65.6,64.5,56.2,64.5,44.6z M80,79.3l-1.8,1.8l-19-19c-4.2,3.7-9.6,6-15.7,6  c-13,0-23.5-10.5-23.5-23.5c0-13,10.5-23.5,23.5-23.5c13,0,23.5,10.5,23.5,23.5c0,6-2.3,11.5-6,15.7L80,79.3z"/></svg></div><p>Searching</p>';
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
    var $search_form = $('#search-igdb-bar');

    $search_form.on('input', function() {
        var $no_results = $('#no-results');
        if ($no_results.length != 0) {
            $no_results.remove();
        }
    });
}

function switchSearchBarTabs() {
    var $f_switch = $('#switch_to_f');
    var $h_switch = $('#switch_to_h');

    var $filters = $('#bar-search');
    var $history = $('#bar-history');

    $h_switch.click(function() {
        $f_switch.removeClass('active');
        $(this).addClass('active');
        $filters.hide();
        $history.show();
    });

    $f_switch.click(function() {
        $h_switch.removeClass('active');
        $(this).addClass('active');
        $history.hide();
        $filters.show();
    });

}

function manipulatePlatforms() {
    var $none = $('#p-none');
    var $all = $('#p-all');

    $none.click(function() {
        $('#platforms-grid').find('input').prop('checked', false)
    });

    $all.click(function() {
        $('#platforms-grid').find('input').prop('checked', true)
    });
}

function activateSearchRecords() {

    $('.record').click(function() {
        var input = $(this).attr('i');
        var endpoint = $(this).attr('e');
        var custom = $(this).attr('cf');

        var form = document.getElementById('search-form');
        form.reset();


        if (custom === 'true') {

            var ids = ['console', 'arcade', 'portable', 'pc', 'linux', 'mac', 'mobile',
                'computer', 'other', 'only_released', 'dlc', 'expansion', 'bundle', 'standalone',
                'erotic'
            ];

            var filters = $(this).attr('f').split(' ');

            filters.forEach(function(e, i) {
                if (e === '0')  {
                    $('#search_' + ids[i]).prop('checked', false)
                }
            });
        }

        $('#search-igdb-bar').val(input);
        $('#search_query_type_' + endpoint).prop('checked', true)

        Rails.fire(form, 'submit');
    });

}
