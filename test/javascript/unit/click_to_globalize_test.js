var TestUtil = {
  DefaultOptions: {
	  translateUrl:    '/translations/save',
	  translationsUrl: '/translations',
	  httpMethod:      'post',
	  asynchronous:    true,
	  textArea:        {rows: 5, cols: 40},
	  inputText:       {rows: 1, cols: 20},
	  textLength:      160,
	  clickToEditText: 'Click to globalize'
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
      {translationsUrl: '/fixtures/translations.json'});
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
    this.assertEqual(TestUtil.DefaultOptions.translateUrl,    ClickToGlobalize.DefaultOptions.translateUrl);
    this.assertEqual(TestUtil.DefaultOptions.translationsUrl, ClickToGlobalize.DefaultOptions.translationsUrl);
    this.assertEqual(TestUtil.DefaultOptions.httpMethod,      ClickToGlobalize.DefaultOptions.httpMethod);
    this.assertEqual(TestUtil.DefaultOptions.asynchronous,    ClickToGlobalize.DefaultOptions.asynchronous);
    this.assertEqual(TestUtil.DefaultOptions.textArea,        ClickToGlobalize.DefaultOptions.textArea);
    this.assertEqual(TestUtil.DefaultOptions.inputText,       ClickToGlobalize.DefaultOptions.inputText);
    this.assertEqual(TestUtil.DefaultOptions.textLength,      ClickToGlobalize.DefaultOptions.textLength);
    this.assertEqual(TestUtil.DefaultOptions.clickToEditText, ClickToGlobalize.DefaultOptions.clickToEditText);
  },
  testInitialize: function(){
    TestUtil.resetDefaultOptions();
    this.assertEqual(authenticityToken, clickToGlobalize.authenticityToken);
    this.assertEqual(requestForgeryProtectionToken, clickToGlobalize.requestForgeryProtectionToken);
    this.assertEqual(TestUtil.DefaultOptions, clickToGlobalize.options);
  },
  testGetTranslations: function() {
    expected = $H({ hello_world: "Hello World", hello_moon: "en, hello_moon" });
    this.assertEqual(expected.size(), clickToGlobalize.translations.size());
    expected.each(function(pair){
      this.assertEqual(pair.value, clickToGlobalize.translations.get(pair.key));
    }.bind(this));
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
    this.assertNull(ipe._form);
  },
  testProtectFromForgeryTokenParameter: function(){
    this.assertEqual('?'+requestForgeryProtectionToken+'='+authenticityToken,
      clickToGlobalize.protectFromForgeryTokenParameter('?'));
    this.assertEqual('', (new ClickToGlobalize('', '')).protectFromForgeryTokenParameter());
  }
}, "testlog");