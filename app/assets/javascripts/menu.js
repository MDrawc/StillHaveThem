function remove_active_create_coll() {
    UIkit.util.once('#coll-modal', 'hide', function() {
        $('#m-add-coll').removeClass('active');
    });
}

function hideShowBackToTop() {
    var $button = $('#scroll-up');
    $(window).scroll(function() {
        if ($(window).scrollTop() > 200) {
            $button.fadeIn();
        } else {
            $button.fadeOut();
        }
    });
}

function getDocHeight() {
    var D = document;
    return Math.max(
        D.body.scrollHeight, D.documentElement.scrollHeight,
        D.body.offsetHeight, D.documentElement.offsetHeight,
        D.body.clientHeight, D.documentElement.clientHeight
    );
}

function activateInfoDoc(doc) {
  var $tab = $('#doc-tab');
  var $liments = $tab.find('li')
  $liments.removeClass('uk-active');
  $liments.find('#' + doc).parent().addClass('uk-active');

  $tab.find('a').click(function() {
          $.ajax({
              url: '/doc/',
              data: { doc: $(this).attr('id') }
          });
  });

  var $top_and_back = $('#top_and_back');
  $(window).scroll(function() {
     if($(window).scrollTop() + $(window).height() == getDocHeight()) {
        $top_and_back.css('opacity', 1);
     } else {
        $top_and_back.css('opacity', 0);
     }
  });
}
