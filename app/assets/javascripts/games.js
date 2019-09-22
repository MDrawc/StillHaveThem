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

function moreInfo() {
    $('.g-click').each(function() {
        var id = $(this).attr('gameid');
        var hidee = $('#g-hide-' + id);
        var drop = $('#g-drop-' + id);

        $(this).off();
        hidee.off();

        $(this).click(function() {
            if (drop.is(':hidden')) {
                hidee.show();
                drop.slideDown('fast');
            } else {
                hidee.hide();
                drop.slideUp('fast');
            }
        });


        hidee.click(function() {
            if (drop.is(':visible')) {
                hidee.hide();
                drop.slideUp('fast');
            }
        });
    });
    // $('.g-drop').slideUp();
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
            Cookies.set('ucs_closed', 'false');

        } else {

            ucs.addClass('hidden');

            var menu = $('.c-menu');
            if (menu.hasClass('hidden')) {
                shr.addClass('hidden');
            }

            Cookies.set('ucs_closed', 'true');
        }
    });
}

function listLight(game_id, el_id) {
    $('#t-' + game_id).addClass('focus-fill');
    UIkit.util.on('#' + el_id, 'hide', function() {
        $('#t-' + game_id).removeClass('focus-fill');
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
    if ($('.list-grid').length != 0) {
        $('.t-game').hover(function() {
            $(this).addClass('hover-fill');
        }, function() {
            $(this).removeClass('hover-fill');
        });
    }
}

function getIdsOfOpenPanels() {
    var ids = [];
    var arr = $('.g-drop');
    arr.each(function() {
        if ($(this).attr('style') == 'display: block;') {
            ids.push($(this).attr('id'));
        }
    });
    return ids;
}

function openPanels(ids) {
    ids.forEach(id => $('#' + id).show());
}

function presentShadow() {
    $("#ts-img").one("load", function() {
        $(this).addClass('cover-shadow');
    });
}

function removeCoverSpinner() {
    UIkit.util.on(document, 'load', '.game-cover', e => {
        if (!e.target.currentSrc.startsWith('data:')) {
            $(e.target).parent().find(".spinner").remove();
        }
    }, true)
}

$(function() {
    removeCoverSpinner();
});
