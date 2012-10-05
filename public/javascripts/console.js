var Console = Backbone.View.extend({
  keys: {
    return: 13,
    up:     38,
    down:   40,
  },

  history: [],

  events: {
    'keypress input': 'handleEvent',
    'click':          'focus',
  },

  initialize: function() {
    _.bindAll(this, 'execute', 'historyNext', 'historyPrev', 'handleEvent', 'sizeInput', 'focus');
    this.on('return', this.execute);
    this.on('up', this.historyPrev);
    this.on('down', this.historyNext);
    this.input = this.$el.find('input')
    this.resetHistoryPointer();
    this.sizeInput();
    $(window).on('resize', this.sizeInput);
  },

  historyPrev: function() {
    this.historyPointer++;
    this.checkHistoryPointer();
    this.input.val(this.history[this.historyPointer]);
  },

  historyNext: function() {
    this.historyPointer--;
    this.checkHistoryPointer();
    this.input.val(this.history[this.historyPointer]);
  },

  execute: function() {
    var val;
    if(val = this.input.val()) {
      if(this.history.length == 0 || this.history[0] != val) this.history.unshift(val);
      this.addMessage(val);
      this.input.val('');
      this.resetHistoryPointer();
      this.$el.scrollTop(100000000);
    }
  },

  addMessage: function(text) {
    var message = $('<div>', {class: 'message'});
    message.append($('<span>', {class: 'nick', html: 'tim'}));
    message.append($('<span>', {class: 'text', html: text}));
    message.insertBefore(this.$el.find('.command'));
  },

  resetHistoryPointer: function() {
    this.historyPointer = -1;
  },

  checkHistoryPointer: function() {
    if(this.historyPointer < 0) this.historyPointer = this.history.length - 1;
    else if(this.historyPointer >= this.history.length) this.historyPointer = 0;
  },

  handleEvent: function(e) {
    var b;
    if(_.chain(this.keys).values().contains(e.keyCode).value()) {
      e.preventDefault();
      this.trigger(_.invert(this.keys)[e.keyCode], e);
    }
  },

  sizeInput: function() {
    var width = this.$el.width();
    var promptWidth = this.$el.find('.prompt').width();
    this.input.width(width - 20 - promptWidth - 8);
  },

  focus: function() {
    this.input[0].focus();
  }
});

$(function() {
  var console = new Console({el: $('.chat-container')});
  console.focus();
});
