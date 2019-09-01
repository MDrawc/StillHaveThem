function toggleAddlInfo() {
    $('#addl-hide').click(function() {
        $('.addl-info').slideToggle();
    });
}

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

