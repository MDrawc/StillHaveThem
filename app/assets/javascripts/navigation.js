$(function() {

    var addl_hide = $('#addl-hide');
    addl_hide.click(function() {
        $('.addl-info').slideToggle();
    });

    function toggleEditMenu() {
        var g_show = $("#g-show-edit");
        g_show.click(function() {
            if ($(".g-menu").hasClass("out")) {
                $(".g-menu").removeClass('out');
                g_show.removeClass('active');
                Cookies.set("edit_open", "false");
            } else {
                $(".g-menu").addClass('out');
                g_show.addClass('active');
                Cookies.set("edit_open", "true");
            }
        });
    }
    toggleEditMenu();

});
