$(function() {
  // a hack to apply an extra class to the popover
  with($.fn.popover.Constructor) {
    prototype.realSetContent = prototype.setContent;
    prototype.setContent = function() {
      this.realSetContent();
      if(this.tip().is(':has(.popover-title:contains(error))')) {
        this.tip().addClass('popover-error');
      }
    };
  }
  $('[rel=popover]').popover();
  $('[rel=popover-static]').popover('show');
});
