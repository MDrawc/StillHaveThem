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
}

function disableSortLinks() {
    $('a.sort_link').addClass('not-active');
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
    ids.forEach(function(id) {
        $('#' + id).show();
    });
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

$(function() {
    removeCoverSpinner();
});
