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

function removeCoverSpinner() {
    UIkit.util.on(document, 'load', '.game-cover', e => {
        if (!e.target.currentSrc.startsWith('data:')) {
            $(e.target).parent().find(".spinner").remove()
        }
    }, true)
}

$(function(){
  removeCoverSpinner();
});
