$(function() {
  $('[rel=popover]').popover();
  $('[rel=popover-static]').popover('show');
  $('.popover:has(.popover-title:contains(error))').addClass('popover-error')
});
