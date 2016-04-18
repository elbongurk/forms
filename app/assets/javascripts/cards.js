$(document).on('submit', 'form#new_card', function(event) {
  event.preventDefault();
  var $form = $(this);
  $form.find("input[type='submit']").prop('disabled', true);
  Stripe.card.createToken($form, function(status, response) {
    if (response.error) {
      $form.find(".base-error").text(response.error.message);
      $form.find("input[type='submit']").prop('disabled', false);        
    }
    else {
      $form.append($('<input type="hidden" name="token">').val(response.id));
      $form.get(0).submit();
    }
  });
  return false;
});
