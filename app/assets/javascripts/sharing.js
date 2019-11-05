function resetForm(form_id) {
    $(':input', '#' + form_id)
        .not(':button, :submit, :reset, :hidden')
        .val('')
        .prop('checked', false)
        .prop('selected', false);
}

function copyShareLinks() {
    $('a.cp-share-link').click(function() {
        var $link = $('#' + $(this).attr('target'));
        $link.prop('disabled', false);
        $link.select();
        document.execCommand("copy");
        document.getSelection().removeAllRanges();
        $link.prop('disabled', true);
    });
}
