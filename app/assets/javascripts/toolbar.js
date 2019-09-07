function toggleAddlInfo() {
    $('#addl-hide').click(function() {
        $('.addl-info').slideToggle();
    });
}

function toggleEditMenu() {
    var g_show = $("#g-show-edit");

    g_show.click(function() {
        var g_menu = $(".g-menu");
        if (g_menu.length != 0) {
            if (g_menu.hasClass("out")) {
                g_menu.removeClass('out');
                g_show.removeClass('active');
                Cookies.set("edit_open", "false");
            } else {
                g_menu.addClass('out');
                g_show.addClass('active');
                Cookies.set("edit_open", "true");
            }
        } else {
            var t_menu = $(".t-menu");
            if (t_menu.length != 0) {
                var t_added = $(".t-added")
                var menu_shadow = $(".menu-shadow")
                if (t_menu.hasClass("out")) {
                    t_menu.removeClass('out');
                    t_added.removeClass('out');
                    menu_shadow.removeClass('out');
                    g_show.removeClass('active');
                    Cookies.set("edit_open", "false");
                } else {
                    t_menu.addClass('out');
                    t_added.addClass('out');
                    menu_shadow.addClass('out');
                    g_show.addClass('active');
                    Cookies.set("edit_open", "true");
                }
            }
        }
    });
}

// function showHideScroll() {
//     $(window).scroll(function() {
//         if ($(window).scrollTop() > 200) {
//             $('.scroll-up').fadeIn()
//         } else {
//             $('.scroll-up').fadeOut()
//         }
//     });
// }

// $(function(){
//   showHideScroll();
// });

