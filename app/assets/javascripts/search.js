function changeSearchBar() {
    var bar = $('#search-igdb-bar');

    $("[id^=search_query_type]").on('input', function() {
        var selectedVal = "";
        var selected = $("input[type='radio']:checked");
        if (selected.length) {
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

function searchWait(type = 'search') {
    $('#no-results').remove();
    var thingy = $('#search-wait');
    var search_anim = '<div class="rotor"><svg id="Layer_1" version="1.1" viewBox="15 15 70 70" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><path clip-rule="evenodd" d="M64.5,44.6c0-11.6-9.4-20.9-20.9-20.9c-11.6,0-20.9,9.4-20.9,20.9  c0,11.6,9.4,20.9,20.9,20.9C55.1,65.6,64.5,56.2,64.5,44.6z M80,79.3l-1.8,1.8l-19-19c-4.2,3.7-9.6,6-15.7,6  c-13,0-23.5-10.5-23.5-23.5c0-13,10.5-23.5,23.5-23.5c13,0,23.5,10.5,23.5,23.5c0,6-2.3,11.5-6,15.7L80,79.3z"/></svg></div><p>Searching</p>';
    var change_view_anim = '<div class="csv_spin"><svg xmlns="http://www.w3.org/2000/svg" id="Layer_1" width="50px" height="50px" version="1.1" viewBox="0 0 128 128" xml:space="preserve"><path d="M96.1 103.6c-10.4 8.4-23.5 12.4-36.8 11.1 -10.5-1-20.3-5.1-28.2-11.8H44v-8H18v26h8v-11.9c9.1 7.7 20.4 12.5 32.6 13.6 1.9 0.2 3.7 0.3 5.5 0.3 13.5 0 26.5-4.6 37-13.2 19.1-15.4 26.6-40.5 19.1-63.9l-7.6 2.4C119 68.6 112.6 90.3 96.1 103.6z"/><path d="M103 19.7c-21.2-18.7-53.5-20-76.1-1.6C7.9 33.5 0.4 58.4 7.7 81.7l7.6-2.4C9 59.2 15.5 37.6 31.9 24.4 51.6 8.4 79.7 9.6 98 26H85v8h26V8h-8V19.7z"/></svg></div><p>Please wait</p>'
    var view_c = $('#view-container');

    if (view_c.length && view_c.attr('view') == 'covers') {
        $('#search-results').addClass('mask2');
    } else {
        $('#search-results').addClass('mask1');
    }

    if (type == 'search') {
        thingy.html(search_anim);
    } else {
        thingy.html(change_view_anim);
    }
    thingy.addClass('front');
}

function activateSearchWait() {
    $('#search').click(function() { searchWait() });
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
        if ($no_results.length) {
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

function checkAllNone(form_id, button_id) {
    var $form = $('#' + form_id);
    var $none = $('#' + button_id + '-none');
    var $all = $('#' + button_id + '-all');

    $none.click(function() {
        $form.find('input').prop('checked', false)
    });

    $all.click(function() {
        $form.find('input').prop('checked', true)
    });
}

function activateSearchRecords() {

    $('.record').click(function() {

        searchWait();
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
                if (e === '0') {
                    $('#search_' + ids[i]).prop('checked', false)
                }
            });
        }

        $('#search-igdb-bar').val(input);
        $('#search_query_type_' + endpoint).prop('checked', true)

        Rails.fire(form, 'submit');
    });

}
