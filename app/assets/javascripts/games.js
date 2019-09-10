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
  uc.off();
  uc.click(function() {

    var ucs = $('.uc-s');
    if (ucs.attr('style') != 'display: none;') {
        $('.uc-s').slideUp();
        Cookies.set('ucs_close', 'true');
    } else {
        $('.uc-s').slideDown();
        Cookies.set('ucs_close', 'false');
    }
  });
}

function fitNameInNoCover() {
    textFit(document.getElementsByClassName("no-cover-game-name"), {minFontSize:18, maxFontSize: 24});
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

function removeCoverSpinner() {
    UIkit.util.on(document, 'load', '.game-cover', e => {
        if (!e.target.currentSrc.startsWith('data:')) {
            // $(e.target).addClass('cover-shadow');
            $(e.target).parent().find(".spinner").remove();
        }
    }, true)
}

$(function(){
  removeCoverSpinner();
});
