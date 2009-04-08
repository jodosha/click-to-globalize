new Test.Unit.Runner({
  setup: function(){
    url = '/foo/bar';
    element_klass = Element;
  },
  testRespondTo: function() {
    this.assertRespondsTo('createHiddenField', Ajax.InPlaceEditor.prototype);
  },
  testInitialize: function() {
    element = $('paragraph');
    
    ipe = new Ajax.InPlaceEditor(element, url, {});
    this.assertInstanceOf(Ajax.InPlaceEditor, ipe);
    this.assertEqual(element, ipe.element);
    this.assertEqual(url, ipe.url);
  },
  testInitializeCellElement: function() {
    element = $('first_header');
    ipe = new Ajax.InPlaceEditor(element, url, {});
    this.assertInstanceOf(Ajax.InPlaceEditor, ipe);
    this.assertEqual(url, ipe.url);
    span = element.descendants().first();
    this.assertNotNull(span);
    if(Prototype.Browser.Gecko) element_klass = HTMLSpanElement;
    this.assertInstanceOf(element_klass, span);
    this.assertEqual('First Header', span.getText());
    
    element = $('first_cell');
    ipe = new Ajax.InPlaceEditor(element, url, {});
    this.assertInstanceOf(Ajax.InPlaceEditor, ipe);
    this.assertEqual(url, ipe.url);
    span = element.descendants().first();
    this.assertNotNull(span);
    if(Prototype.Browser.Gecko) element_klass = HTMLSpanElement;
    this.assertInstanceOf(element_klass, span);
    this.assertEqual('First Cell', span.getText());
  },
  testCreateForm: function() {
    element = $('paragraph2');
    ipe = new Ajax.InPlaceEditor(element, url, {});

    Event.simulateMouse('paragraph2','click');
    form = ipe._form
    this.assertInstanceOf(HTMLFormElement, form);
    this.assertEqual(4, form.descendants().size());

    input_text = $$('form input[type~=text]').first();
    this.assertInstanceOf(HTMLInputElement, input_text);
    this.assertEqual('paragraph text', input_text.value);

    submit_button = $$('form input[type~=submit]').first();
    if(!Prototype.Browser.Opera) element_klass = HTMLInputElement;
    this.assertInstanceOf(HTMLInputElement, submit_button);
    
    cancel_link = $$('form a').first();
    this.assertInstanceOf(HTMLAnchorElement, cancel_link);
    
    hidden_field = $$('form input[type~=hidden]').first();
    this.assertInstanceOf(HTMLInputElement, hidden_field);
  }
}, "testlog");
