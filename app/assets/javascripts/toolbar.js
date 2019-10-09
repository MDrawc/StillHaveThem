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
    $('#toolbar').removeClass('waiting');
    $('.change-s-view').removeClass('active');
    $('#' + view).addClass('active');
    if (view == 'panel_view') {
        $('#close-panels').parent().show();
    } else {
        $('#close-panels').parent().hide();
    }

    if (type != 'game') {
        var $addl = $('#addl-hide');
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
        var $addl = $('#addl-hide');
        $addl.off();
        $addl.parent().hide();
    }
}

function underCover() {
    var uc = $('#undercover');
    uc.off();
    uc.click(function() {
        var shr = $('.shr');
        var ucs = $('.uc-s');
        if (ucs.hasClass('hidden')) {

            if (shr.hasClass('hidden')) {
                shr.removeClass('hidden');
            }

            $('.uc-s').removeClass('hidden');
            uc.addClass('active');
            Cookies.set('ucs_closed', 'false');

        } else {

            ucs.addClass('hidden');

            var menu = $('.c-menu');
            if (menu.hasClass('hidden')) {
                shr.addClass('hidden');
            }
            uc.removeClass('active');
            Cookies.set('ucs_closed', 'true');
        }
    });
}

function closeAllPanels() {
    var $switch = $('#close-panels');
    $switch.off();
    $switch.click(function() {
        var $arrows = $('.g-hide');
        var $drops = $('.g-drop');
        $arrows.hide();
        $drops.slideUp('fast');
    });
}

function changeMyView() {
    $('.change-my-view').off();
    $('.change-my-view').click(function() {

        var view = $(this).attr('id');
        var coll_id = $(this).attr('coll_id');

        Cookies.set("my_view", view, {
            expires: 365
        });

        var data = {
            view: view
        };

        if ($('#r-q').text().length != 0 && $('#r-s').text().length != 0) {
            search = $('#r-q').text().split(',');
            data['q'] = {
                name_dev_cont: search[0],
                plat_eq: search[1],
                physical_eq: search[2],
                s: $('#r-s').text()
            };
        } else if ($('#r-q').text().length != 0) {
            search = $('#r-q').text().split(',');
            data['q'] = {
                name_dev_cont: search[0],
                plat_eq: search[1],
                physical_eq: search[2]
            };
        } else if ($('#r-s').text().length != 0) {
            data['q'] = {
                s: $('#r-s').text()
            };
        }

        if ($('.pr em.current').length != 0) {
            var current_page = $('.pr em.current').text();
            data['page'] = current_page;
        }

        $.ajax({
            url: '/collections/' + coll_id,
            data: data
        });
    });
}

function changeSearchView() {
    $('.change-s-view').off();
    $('.change-s-view').click(function() {

        searchWait('change-view');
        var view = $(this).attr('id');

        Cookies.set("s_view", view, {
            expires: 365
        });

        var data = {
            view: view
        };

        var last_form = $('#last-form');

        if (last_form.length > 0) {

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

function showHideToolbar() {
    var $on = $('#tool-show');
    var $off = $('#tool-hide');
    var $toolbar = $('#toolbar');

    $on.click(function() {
        $on.hide();
        $toolbar.addClass('open');
        Cookies.set('tb_open', 'open')
    });

    $off.click(function() {
        $on.show();
        $toolbar.removeClass('open');
        Cookies.set('tb_open', '')
    });

}

function toggleEditMenu() {
    var show = $("#g-show-edit");
    var menu;

    show.click(function() {
        if ((menu = $(".g-menu")).length != 0) {
            var added = $(".g-right")
            var menu_shadow = $(".g-menu-shadow")
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
        } else if ((menu = $(".t-menu")).length != 0) {
            var added = $(".t-added")
            var menu_shadow = $(".menu-shadow")
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
            var shr = $('.shr');

            if (menu.hasClass('hidden')) {

                if (shr.hasClass('hidden')) {
                    shr.removeClass('hidden');
                }

                menu.removeClass('hidden');
                show.addClass('active');
                Cookies.set("edit_open", "true");

            } else {

                menu.addClass('hidden');

                var ucs = $('.uc-s');
                if (ucs.hasClass('hidden')) {
                    shr.addClass('hidden');
                }

                show.removeClass('active');
                Cookies.set("edit_open", "false");

            }
        }
    });
}
