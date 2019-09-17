function changeTheme() {
    $('#change-theme').click(function() {
        if (Cookies.get('theme') === 'theme_dark') {
            Cookies.set("theme", "theme_default", { expires: 365 });
            $('#theme-control').attr('href', '/assets/theme_default.self.css');
        } else {
            Cookies.set("theme", "theme_dark", { expires: 365 });
            $('#theme-control').attr('href', '/assets/theme_dark.self.css');
        }
    });
}

function toggleAddlInfo() {
    $('#addl-hide').click(function() {
        $('.addl-info').slideToggle();
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
