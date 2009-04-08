var TestUtil = {
  DefaultOptions: {
	  translateUrl:             '/locales/translate',
	  translateUnformattedUrl:  '/locales/translate_unformatted',
	  translationsUrl:          '/locales/translations',
	  httpMethod:               'post',
	  asynchronous:              true,
	  textileElements:  [ 'a', 'acronym', 'blockquote', 'bold', 'cite', 'code',
	                      'del', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'i',
	                      'img', 'ins', 'span', 'strong', 'sub', 'sup', 'table',
	                    ].collect(function(element){return element.toUpperCase();}),
	  textArea:          {rows: 5, cols: 40},
	  inputText:         {rows: 1, cols: 20},
	  textLength:        160,
	  clickToEditText:   'Click to globalize'
  },
  resetDefaultOptions: function(){
    ClickToGlobalize.DefaultOptions = this.DefaultOptions;
  }
};

new Test.Unit.Runner({
  setup: function() {
    authenticityToken = '45c0a7bf277d5e40d490438f41a67069e5334d96';
    requestForgeryProtectionToken = 'authenticity_token';
    clickToGlobalize  = new ClickToGlobalize(authenticityToken, requestForgeryProtectionToken, 
      {translationsUrl: 'fixtures/translations.json'});
    document.fire("dom:loaded");
  },
  testRespondTo: function() {
    this.assertRespondsTo('initialize',      clickToGlobalize);
    this.assertRespondsTo('createEditors',   clickToGlobalize);
    this.assertRespondsTo('getTranslations', clickToGlobalize);
    this.assertRespondsTo('bindEditor',      clickToGlobalize);      
    this.assertRespondsTo('unbindEditor',    clickToGlobalize);
  },
  testOptions: function() {
    TestUtil.resetDefaultOptions();
    this.assertHashEqual(TestUtil.DefaultOptions, ClickToGlobalize.DefaultOptions);
  },
  testInitialize: function(){
    TestUtil.resetDefaultOptions();
    this.assertEqual(authenticityToken, clickToGlobalize.authenticityToken);
    this.assertEqual(requestForgeryProtectionToken, clickToGlobalize.requestForgeryProtectionToken);
    this.assertHashEqual(TestUtil.DefaultOptions, clickToGlobalize.options);
  },
  testGetTranslations: function() {
    this.assertHashEqual({hello_world: 'Hello World'}, clickToGlobalize.translations);
  },
  testCreateEditors: function() {
    this.assertEqual(TestUtil.DefaultOptions.clickToEditText, $('paragraph').getAttribute('title'));
  },
  testBindEditor: function() {
    clickToGlobalize.bindEditor($('paragraph2'), 'paragraph_text', 'paragraph text');
    this.assertEqual(TestUtil.DefaultOptions.clickToEditText, $('paragraph2').getAttribute('title'));
  },
  testUnbindEditor: function() {
    element = $('paragraph3');
    ipe = new Ajax.InPlaceEditor(element, TestUtil.DefaultOptions.clickToEditText, {});
    clickToGlobalize.unbindEditor(element, ipe);
    Event.simulateMouse('paragraph3','click');
    this.assertNullOrUndefined(ipe._form);
  },
  testProtectFromForgeryTokenParameter: function(){
    this.assertEqual('?'+requestForgeryProtectionToken+'='+authenticityToken,
      clickToGlobalize.protectFromForgeryTokenParameter('?'));
    this.assertEqual('', (new ClickToGlobalize('', '')).protectFromForgeryTokenParameter());
  }
}, "testlog");