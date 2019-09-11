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

function moreInfo() {
    $('.g-click').each(function() {
        var id = $(this).attr('gameid');
        var hidee = $('#g-hide-' + id);
        var drop = $('#g-drop-' + id);
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
}

function underCover() {
    var uc = $('#undercover');

    console.log('function on');

    uc.off();
    uc.click(function() {

console.log('clicked');

        var shr = $('.shr');
        var ucs = $('.uc-s');
        if (ucs.hasClass('hidden')) {

            console.log('is hidden');

            if (shr.hasClass('hidden')) {
                shr.removeClass('hidden');
            }

            $('.uc-s').removeClass('hidden');
            Cookies.set('ucs_closed', 'false');

        } else {

console.log('is visible');

            ucs.addClass('hidden');

            var menu = $('.c-menu');
            if (menu.hasClass('hidden')) {
                shr.addClass('hidden');
            }

            Cookies.set('ucs_closed', 'true');
        }
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
