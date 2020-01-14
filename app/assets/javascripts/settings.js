function resetSetWarningIcon(input_id, icon_id, warning_id) {
    var $no_error = $(icon_id);
    var $error_icon = $(warning_id);

    var $input = $(input_id);
    $input.one('input', function() {
        if ($error_icon.length != 0) {
            $error_icon.remove();
            $no_error.show();
        }
    });
}

function activateChangeEmailPassword() {
    $('#change-mail').add('#change-password').on('input', function() {
        var val = $(this).val();
        var $td_with_button = $(this).parent().next();
        $td_with_button.removeClass('disabled');

        if (val == "") {
            $td_with_button.addClass('disabled');
        }
    });
}

function activateChangeGpv() {
    var $input = $('#user_games_per_view');
    var $counter = $('#gpv-counter');
    var $submit = $('#submit-gpv');
    var def = $input.val();

    $input.on('input', function() {
        var val = $(this).val();
        $counter.removeClass('disabled').text(val);
        $submit.removeClass('disabled');

        if (val == def) {
            $counter.addClass('disabled');
            $submit.addClass('disabled');
        }
    });
}

function activateChangeOrder() {
    var $submit = $('#submit-cord');
    var $ships = $('.cord-ship');
    var $ups = $('.cord-up');
    var $downs = $('.cord-down');
    var max = $ships.length;

    $ups.click(function() {
        var $coll = $(this).parent();
        var coll_top = $coll.css('top').slice(0, -2);
        var sid = Number($coll.attr('data-s'));

        if (sid > 1) {
            var $prev = $ships.filter('[data-s=' + (sid - 1) + ']');

            $coll.css('top', Number(coll_top) - 40);
            $prev.css('top', Number(coll_top));
            $submit.css('top', Number(coll_top));

            $coll.attr('data-s', sid - 1);
            $prev.attr('data-s', sid);
            $submit.removeClass('disabled');
        }
    });

    $downs.click(function() {
        var $coll = $(this).parent();
        var coll_top = $coll.css('top').slice(0, -2);
        var sid = Number($coll.attr('data-s'));

        if (sid < max) {
            var $next = $ships.filter('[data-s=' + (sid + 1) + ']');

            $coll.css('top', Number(coll_top) + 40);
            $next.css('top', Number(coll_top));
            $submit.css('top', Number(coll_top));

            $coll.attr('data-s', sid + 1);
            $next.attr('data-s', sid);
            $submit.removeClass('disabled');
        }
    });

    $submit.click(function() {

        var data = {
            cord: {}
        };

        $ships.each(function() {
            data['cord'][$(this).attr('id').slice(4)] = $(this).attr('data-s');
        });

        $(this).addClass('done').attr('value', 'done');

        $(this).delay(500).queue(function() {
            $(this).removeClass('done').addClass('disabled').attr('value', 'update');
            $(this).dequeue();
        });

        $.ajax({
            url: '/change_order',
            method: 'POST',
            data: data
        });
    });
}
