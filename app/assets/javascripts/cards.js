$(document).on('keyup', 'form#new_card .input-cc-number', function(event) {
  var $number = $(this)
  var $wrapper= $number.parent();
  var number = $number.val().replace(/\D/g,'');

  switch (Stripe.card.cardType(number)) {
  case 'Visa':
    $wrapper.removeClass('input-cc-number-generic input-cc-number-mastercard input-cc-number-amex input-cc-number-discover').addClass('input-cc-number-visa');
    break;
  case 'MasterCard':
    $wrapper.removeClass('input-cc-number-generic input-cc-number-visa input-cc-number-amex input-cc-number-discover').addClass('input-cc-number-mastercard');
    break;
  case 'American Express':
    $wrapper.removeClass('input-cc-number-generic input-cc-number-visa input-cc-number-mastercard input-cc-number-discover').addClass('input-cc-number-amex');
    break;
  case 'Discover':
    $wrapper.removeClass('input-cc-number-generic input-cc-number-visa input-cc-number-mastercard input-cc-number-amex').addClass('input-cc-number-discover');
    break;
  default:
    $wrapper.removeClass('input-cc-number-visa input-cc-number-mastercard input-cc-number-amex input-cc-number-discover').addClass('input-cc-number-generic');
    break;
  }
});

$(document).on('submit', 'form#new_card', function(event) {
  var $form = $(this);
  $form.find("input[type='submit']").prop('disabled', true);
  var params = {
    number: $form.find('.input-cc-number').val().replace(/\D/g,''),
    cvc: $form.find('.input-cc-cvc').val().replace(/\D/g,''),    
    exp_month: $form.find('.input-cc-exp-month').val().replace(/\D/g,''),
    exp_year: $form.find('.input-cc-exp-year').val().replace(/\D/g,''),
  };
  Stripe.card.createToken(params, function(status, response) {
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
