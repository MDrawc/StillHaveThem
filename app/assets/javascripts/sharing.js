function resetForm(form_id){
    $(':input','#' + form_id)
      .not(':button, :submit, :reset, :hidden')
      .val('')
      .prop('checked', false)
      .prop('selected', false);
}
