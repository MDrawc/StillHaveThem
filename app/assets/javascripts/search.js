function changeSearchBar() {
    $("[id^=search_query_type]").on('input', function() {
    var selectedVal = "";
    var selected = $("input[type='radio']:checked");
    if (selected.length > 0) {
        selectedVal = selected.val();
    }

    if (selectedVal === 'char') {
      $('#search-igdb-bar').attr('placeholder', 'Search video game characters...')
    } else if (selectedVal === 'dev') {
      $('#search-igdb-bar').attr('placeholder', 'Search video game developers...')
    } else if (selectedVal === 'game') {
      $('#search-igdb-bar').attr('placeholder', 'Search video games...')
    }

    });
}

function searchWait() {
  $('#search').click(function() {
    var thingy = $('#search-wait');
    thingy.html('ELLO!!!');
  });
}

function clearSearchWait() {
  $('#search-wait').remove();
}
