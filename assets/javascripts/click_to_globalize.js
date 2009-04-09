Element.addMethods({
	getText: function(element){
		element = $(element);
		return ((element.firstChild && element.firstChild.nodeValue) ? element.firstChild.nodeValue : '').strip();
	}
});

function $$$(value) {
  return $(document.body).descendants().select(function(element){
    if($w('text/javascript textarea').include(element.type)) return false;
    return $(element).getText() == value;
  });
}

Ajax.InPlaceEditor.prototype = Object.extend(Ajax.InPlaceEditor.prototype,{
  createHiddenField: function(){
    var textField = document.createElement("input");
    textField.obj = this;
    textField.type = 'hidden';
    textField.name = 'key';
    textField.value = this.options.hiddenValue;
    var size = this.options.size || this.options.cols || 0;
    if (size != 0) textField.size = size;
    this._form.appendChild(textField);
  }
});

// Fix for: http://dev.rubyonrails.org/ticket/4579
Ajax.InPlaceEditor.prototype.initialize = Ajax.InPlaceEditor.prototype.initialize.wrap(
	function(proceed, element, url, options) {
		element = $(element);
    if($w('TD TH').include(element.tagName)){
			element.observe('click',     this.enterEditMode.bindAsEventListener(this));
			element.observe('mouseover', this.enterHover.bindAsEventListener(this));
			element.observe('mouseout',  this.leaveHover.bindAsEventListener(this));
      element.innerHTML = "<span>" + element.textContent + "</span>";
      element = element.down();
    }
		proceed(element, url, options);
	}
);

Ajax.InPlaceEditor.prototype.createForm = Ajax.InPlaceEditor.prototype.createForm.wrap(
  function(proceed) {
	  proceed();
  	this.createHiddenField();
  }
);

var ClickToGlobalize = Class.create({
	initialize: function(authenticityToken, requestForgeryProtectionToken){
		this.options = Object.extend(ClickToGlobalize.DefaultOptions, arguments[2] || { });
		this.authenticityToken = encodeURIComponent(authenticityToken);
		this.requestForgeryProtectionToken = encodeURIComponent(requestForgeryProtectionToken);
		document.observe('dom:loaded', function(){ this.createEditors(); }.bind(this));
  },
	createEditors: function(){
		this.getTranslations();
		this.translations.keys().each(function(key){
      text = this.translations.get(key);
      $$$(text).each(function(element){
        this.bindEditor(element, key, text);
      }.bind(this));
    }.bind(this));
	},
	getTranslations: function() {
    new Ajax.Request(this.options.translationsUrl, {
      onSuccess: function(transport) {
        this.translations = $H(transport.responseText.evalJSON());
        this.translations = this.translations.inject($H({}), function(result,pair){
          result.set(pair.key, pair.value.stripTags());
          return result;
        });
      }.bind(this),
      method: 'get',
      // Set on false, cause we have to wait until the end of the request
      // to add the events to the elements.
      asynchronous: false
    });
  },
  bindEditor: function(element, key, text) {
    var size = text.stripTags().length > this.options.textLength ? this.options.textArea : this.options.inputText;
    new Ajax.InPlaceEditor(element, this.options.translateUrl+this.protectFromForgeryTokenParameter('?'), {
      hiddenValue: key,
      rows: size.rows,
      cols: size.cols,
      ajaxOptions: {method: this.options.httpMethod, asynchronous: this.options.asynchronous},
      clickToEditText: this.options.clickToEditText,
      onComplete: function(transport, element) {
        if(transport) {
          this.unbindEditor(element);
          this.bindEditor(element, key, transport.responseText);
        }
      }.bind(this)
    });
  },
  unbindEditor: function(element) {
		element.stopObserving('click');
  	element.stopObserving('mouseover');
		element.stopObserving('mouseout');
  },
	protectFromForgeryTokenParameter: function(separator) {
		if(this.requestForgeryProtectionToken.blank()) {
			return '';
		} else {
			return separator+this.requestForgeryProtectionToken+'='+this.authenticityToken;
		}
	}
});

Object.extend(ClickToGlobalize, {
  DefaultOptions: {
	  translateUrl:    '/translations/save',
	  translationsUrl: '/translations',
	  httpMethod:      'post',
	  asynchronous:    true,
 	  textArea:        {rows: 5, cols: 40},
 	  inputText:       {rows: 1, cols: 20},
	  textLength:      160,
	  clickToEditText: 'Click to globalize'
  }
});
