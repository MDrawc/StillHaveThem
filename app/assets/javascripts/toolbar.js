function modifyToolbar(view) {
    $('.change-my-view').removeClass('active');
    $('#' + view).addClass('active');

    switch (view) {
        case 'covers':
            $('#close-panels').parent().hide();
            $('#undercover').parent().show();
            break;
        case 'panels':
            $('#undercover').parent().hide();
            $('#close-panels').parent().show();
            break;
        default:
            $('#undercover').parent().hide();
            $('#close-panels').parent().hide();
    }
}

function activateSearchToolbar(view, type) {

    var $toolbar = $('#toolbar');
    $toolbar.removeClass('waiting');

    $('.change-s-view', $toolbar).removeClass('active');
    $('#' + view).addClass('active');
    if (view === 'panel_view') {
        $('#close-panels').parent().show();
    } else {
        $('#close-panels').parent().hide();
    }

    var $addl = $('#addl-hide');

    if (type != 'game') {
        $addl.parent().show();
        $addl.off();

        $addl.click(function() {
            if ($(this).hasClass('active')) {
                $(this).removeClass('active');
                var $addl_info = $('.xif');
                $addl_info.slideDown();
                Cookies.set('addl_hidden', 'false')
            } else {
                $(this).addClass('active');
                var $addl_info = $('.xif');
                $addl_info.slideUp();
                Cookies.set('addl_hidden', 'true')
            }
        });
    } else {
        $addl.off();
        $addl.parent().hide();
    }
}

function underCover(shared) {
    var cookie = shared ? 'sh_ucs_closed' : 'ucs_closed';
    var uc = $('#undercover');
    uc.off();
    uc.click(function() {
        var shr = $('.shr');
        var menu = shr.next();
        var ucs = menu.next();
        if (ucs.hasClass('hidden')) {
            if (shr.hasClass('hidden')) {
                shr.removeClass('hidden');
            }
            ucs.removeClass('hidden');
            uc.addClass('active');
            Cookies.set(cookie, 'false');
        } else {
            ucs.addClass('hidden');
            if (menu.hasClass('hidden')) {
                shr.addClass('hidden');
            }
            uc.removeClass('active');
            Cookies.set(cookie, 'true');
        }
    });
}

function closeAllPanels() {
    var $switch = $('#close-panels');
    $switch.off();
    $switch.click(function() {
        $('.g-hide').hide();
        $('.g-drop').slideUp('fast');
    });
}

function changeMyView(shared) {
    if (shared) {
        var url = '/sh_collections/';
        var cookie = 'shared_view';
    } else {
        var url = '/collections/';
        var cookie = 'my_view';
    }

    var $changers = $('.change-my-view');

    $changers.off();
    $changers.click(function() {

        var view = $(this).attr('id');
        var coll_id = $(this).attr('coll_id');

        Cookies.set(cookie, view, {
            expires: 365
        });

        var data = {
            view: view
        };

        data = addRqRsToData(data);

        var $pagi = $('#pr').find('em.current');

        if ($pagi.length) {
            var current_page = $pagi.text();
            data['page'] = current_page;
        }

        $.ajax({
            url: url + coll_id,
            data: data
        });
    });
}

function changeSearchView() {
    var $changers = $('.change-s-view')
    $changers.off();
    $changers.click(function() {

        searchWait('change-view');

        $changers.removeClass('active');
        $(this).addClass('active');

        var view = $(this).attr('id');

        Cookies.set("s_view", view, {
            expires: 365
        });

        var data = {
            view: view
        };

        var last_form = $('#last-form');

        if (last_form.length) {

            last_form = last_form.text().split(',');

            data['search'] = {
                inquiry: last_form[0],
                query_type: last_form[1],
                console: last_form[2],
                arcade: last_form[3],
                portable: last_form[4],
                pc: last_form[5],
                linux: last_form[6],
                mac: last_form[7],
                mobile: last_form[8],
                computer: last_form[9],
                other: last_form[10],
                only_released: last_form[11],
                dlc: last_form[12],
                expansion: last_form[13],
                bundle: last_form[14],
                standalone: last_form[15],
                erotic: last_form[16]
            }
        }

        $.ajax({
            url: '/search_games',
            data: data
        });

    });
}

function showHideToolbar(shared) {
    var cookie = shared ? 'sh_tb_open' : 'tb_open';
    var $toolbar = $('#toolbar');
    var $on = $('#tool-show', $toolbar);
    var $off = $('#tool-hide', $toolbar);

    $on.click(function() {
        $(this).hide();
        $toolbar.addClass('open');
        Cookies.set(cookie, 'open')
    });

    $off.click(function() {
        $on.show();
        $toolbar.removeClass('open');
        Cookies.set(cookie, '')
    });
}

function toggleEditMenu() {
    var show = $("#g-show-edit");
    var menu;

    show.click(function() {
        if ((menu = $(".g-menu")).length) {
            var added = menu.next();
            added.addClass('move');
            var menu_shadow = menu.find(".g-menu-shadow");
            if (menu.hasClass("out")) {
                menu.removeClass('out');
                added.removeClass('out');
                menu_shadow.removeClass('out');
                show.removeClass('active');
                Cookies.set("edit_open", "false");
            } else {
                menu.addClass('out');
                added.addClass('out');
                menu_shadow.addClass('out');
                show.addClass('active');
                Cookies.set("edit_open", "true");
            }
        } else if ((menu = $(".t-menu")).length) {
            var added = menu.prev();
            var menu_shadow = menu.find(".menu-shadow");
            if (menu.hasClass("out")) {
                menu.removeClass('out');
                added.removeClass('out');
                menu_shadow.removeClass('out');
                show.removeClass('active');
                Cookies.set("edit_open", "false");
            } else {
                menu.addClass('out');
                added.addClass('out');
                menu_shadow.addClass('out');
                show.addClass('active');
                Cookies.set("edit_open", "true");
            }
        } else {
            menu = $(".c-menu");
            var shr = menu.prev();

            if (menu.hasClass('hidden')) {

                if (shr.hasClass('hidden')) {
                    shr.removeClass('hidden');
                }

                menu.removeClass('hidden');
                show.addClass('active');
                Cookies.set("edit_open", "true");

            } else {

                menu.addClass('hidden');

                var ucs = menu.next();
                if (ucs.hasClass('hidden')) {
                    shr.addClass('hidden');
                }

                show.removeClass('active');
                Cookies.set("edit_open", "false");

            }
        }
    });
}

function activateGraphForm() {
    $('#graph_collection').on('input', function(){
        var form = document.getElementById('graph-form');
        Rails.fire(form, 'submit');
    });
}

function labelsHiders() {
    var $hiders = $('.hide-labels')

    $hiders.click(function() {
        var chart_ids = $(this).attr('chart_id').split(', ');

        for (var i in chart_ids) {
            var chart = Chartkick.charts[chart_ids[i]].getChartObject();
            var datasets = chart.data.datasets;
            var disp = datasets[0].datalabels['opacity'];

            if (disp == 1) {

                for (var i = 0; i < datasets.length; i++) {
                    datasets[i].datalabels['opacity'] = 0;
                }
                $(this).text('show labels');
            } else {

                for (var i = 0; i < datasets.length; i++) {
                    datasets[i].datalabels['opacity'] = 1;
                }
                $(this).text('hide labels');
            }
            chart.update();
        }
    });
}
