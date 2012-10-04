var Console = function() {
  this.construct.apply(this, arguments)
}

Console.prototype = {
  RETURN: 13,
  UP:     38,
  DOWN:   40,

  bindings: {},

  history: [],

  construct: function(el) {
    _.bindAll(this, 'execute', 'historyNext', 'historyPrev', 'handleEvent', 'sizeInput', 'focus');
    this.on(this.RETURN, this.execute);
    this.on(this.UP, this.historyPrev);
    this.on(this.DOWN, this.historyNext);
    this.el = el;
    this.input = this.el.find('input')
    this.input.on('keypress', this.handleEvent);
    this.el.click(this.focus);
    $(window).on('resize', this.sizeInput);
    this.sizeInput();
    this.resetHistoryPointer();
  },

  on: function(key, cb) {
    this.bindings[key] = cb;
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
      this.el.scrollTop(100000000);
    }
  },

  addMessage: function(text) {
    var message = $('<div>', {class: 'message'});
    message.append($('<span>', {class: 'nick', html: 'tim'}));
    message.append($('<span>', {class: 'text', html: text}));
    message.insertBefore(this.el.find('.command'));
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
    if(b = this.bindings[e.keyCode]) {
      e.preventDefault();
      b();
    }
  },

  sizeInput: function() {
    var width = this.el.width();
    var promptWidth = this.el.find('.prompt').width();
    this.input.width(width - 20 - promptWidth - 8);
  },

  focus: function() {
    this.input[0].focus();
  }
};

$(function() {
  var console = new Console($('.chat-container'));
  console.focus();
});
