function shortSummary(id) {
    var dots = document.getElementById("dots-" + id);
    var moreText = document.getElementById("more-" + id);
    if (dots.style.display === "none") {
        dots.style.display = "inline";
        moreText.style.display = "none";
    } else {
        dots.style.display = "none";
        moreText.style.display = "inline";
    }
}

function morePlatforms() {
    $('.mp').each(function() {
        var id = $(this).attr('gameid');
        var p_drop = $('#mp-' + id);
        $(this).off();
        $(this).click(function() {
            if (p_drop.is(':hidden')) {
                p_drop.slideDown('fast');
            } else {
                p_drop.slideUp('fast');
            }
        });
    });
}

function activateHidee(hidee, drop) {
    hidee.click(function() {
        if (drop.is(':visible')) {
            hidee.hide();
            drop.slideUp('fast');
        }
    });
}

function activatePreHidee(r_ids) {
    var r_ids_length = r_ids.length;
    if (r_ids_length) {
        for (var i = 0; i < r_ids_length; i++) {
            var $hidee = $('#g-hide-' + r_ids[i]);
            activateHidee($hidee, $hidee.parent());
        }
    }
}

function moreInfo() {
    $('.g-click').click(function() {
        var id = $(this).attr('gameid');
        var igdb_id = $(this).attr('igdb_id');
        var drop = $('#g-drop-' + id);
        if (drop.hasClass('empty')) {
            $.ajax({
                url: '/ps/' + igdb_id + '/' + id
            });
        } else if (drop.is(':hidden')) {
            drop.slideDown('fast');
            $('#g-hide-' + id).show();
        } else {
            $('#g-hide-' + id).hide();
            drop.slideUp('fast');
        }
    });
}

function findOpenPanels() {
    var open_ids = [];
    $('.g-drop').filter(':visible').each(function() {
        open_ids.push($(this).attr('id').slice(7));
    });
    return open_ids;
}

function addOpenPanelsData() {
    var open = '';
    var prefix = '&reopen%5B%5D=';
    $('.g-drop').filter(':visible').each(function() {
        open += prefix + $(this).attr('id').slice(7);
    });
    return open;
}

function disableSortLinks() {
    $('.sort_link').addClass('not-active');
}

function listLight(game_id, el_id) {
    var $list = $('#t-' + game_id);
    $list.addClass('focus-fill');

    UIkit.util.once('#' + el_id, 'hide', function() {
        $list.removeClass('focus-fill');
    });
}

function fitNameInNoCover() {
    textFit(document.getElementsByClassName("no-cover-game-name"), {
        minFontSize: 18,
        maxFontSize: 24
    });
    $(".no-cover-game-name").addClass('fitted');
}

function listHover() {
    if ($('.list-grid').length) {
        $('.t-game').hover(function() {
            $(this).addClass('hover-fill');
        }, function() {
            $(this).removeClass('hover-fill');
        });
    }
}

function presentShadow() {
    $("#ts-img").one("load", function() {
        $(this).addClass('cover-shadow');
    });
}

function removeCoverSpinner() {
    UIkit.util.on(document, 'load', '.game-cover', function(e) {
        if (!e.target.currentSrc.startsWith('data:')) {
            $(e.target).parent().find(".spinner").remove();
        }
    }, true)
}

function updatePlatformsFilter(platform) {
    var $form_select = $('#q_plat_eq');
    var $options = $form_select.children();

    var values = [];
    $options.each(function() {
        values.push($(this).val());
    });

    if (!values.includes(platform)) {
        var option = '<option value="' + platform + '">' + platform + '</option>';
        $form_select.append(option);
    }
}

function addRqRsToData(data) {
    var $rq = $('#r-q');
    var rs = $rq.next().text();
    var rq = $rq.text();
    if (rq != ',,on' && rq != ',,') {
        var search = rq.split(',');
        data['q'] = {
            name_dev_cont: search[0],
            plat_eq: search[1],
            physical_eq: search[2],
        };
    }

    if (rs.length) {
        if (data['q']) {
            data['q']['s'] = rs;
        } else {
            data['q'] = {
                s: rs
            };
        }
    }

    return data
}

$(function() {
    removeCoverSpinner();
});
