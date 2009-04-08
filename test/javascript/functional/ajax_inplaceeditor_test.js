var Fixtures = {
  one:   'paragraph one',
  two:   '_paragraph two_',
  three: 'paragraph three',
  four:  '_paragraph four_',
  five:  '_*paragraph five*_',
  six:   '_*paragraph six*_',
  seven: '_paragraph seven_',
  eight: 'paragraph eight',
  lorem: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.',
  lorem_area: 'lorem'
};
var Results = {
  one:   'paragraph one',
  two:   '<em>paragraph two</em>',
  three: 'paragraph three',
  four:  '<em>paragraph four</em>',
  five:  '<em><strong>paragraph five</strong></em>',
  six:   '<em><strong>paragraph six</strong></em>',
  seven: '<em>paragraph seven</em>',
  eight: 'paragraph eight',
  lorem: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.',
  lorem_area: 'lorem'
};

var TestUtil = {
  bindElement: function(id, text, selector) {
    text     = text || 'paragraph '+id;
    selector = selector || 'input[type~=text]';
    ClickToGlobalize.DefaultOptions.translateUrl            = 'fixtures/translate_'+id+'.xml';
    ClickToGlobalize.DefaultOptions.translateUnformattedUrl = 'fixtures/translate_unformatted_'+id+'.xml';
    
    element = $$$(text).first();

    (new ClickToGlobalize('')).bindEditor(element, id, element.getText());
    Event.simulateMouse(element,'click');
    form = $(id+'-inplaceeditor');

    input_text = form.getElementsBySelector(selector).first();
    submit_button = form.getElementsBySelector('input[type~=submit]').first();

    input_text.value = Fixtures[id];
    Event.simulateMouse(submit_button,'click');
  },
  getHTML: function(id) {
    element = $(id);
    html = element.getText() ? element.getText() : element.descendants().last().getText();
    element.descendants().reverse(false).each(function(element){
      nodeName = element.inspect().match(/\w+/);
      html = new Template('<#{element}>#{html}</#{element}>').evaluate({element: nodeName, html: html});
    });
    return html;
  }
};

// This allows to execute tests with Rake.
ClickToGlobalize.DefaultOptions.httpMethod  = 'get';
ClickToGlobalize.DefaultOptions.asynchronous = false;

new Test.Unit.Runner({
  testParagraphOne: function() {
    TestUtil.bindElement('one');
    html = TestUtil.getHTML('one');
    this.assertEqual(Results.one, html);
    this.assertEqual(html.stripTags(), html);
  },
  testParagraphTwo: function() {
    TestUtil.bindElement('two');
    html = TestUtil.getHTML('two');
    this.assertEqual(Results.two, html);
    this.assertNotEqual(html.stripTags(), html);
  },
  testParagraphThree: function() {
    TestUtil.bindElement('three');
    html = TestUtil.getHTML('p_three');
    this.assertEqual(Results.three, html);
    this.assertEqual(html.stripTags(), html);
  },
  testParagraphFour: function() {
    TestUtil.bindElement('four');
    html = TestUtil.getHTML('p_four');
    this.assertEqual(Results.four, html);
    this.assertNotEqual(html.stripTags(), html);
  },
  testParagraphFive: function() {
    TestUtil.bindElement('five');
    html = TestUtil.getHTML('p_five');
    this.assertEqual(Results.five, html);
    this.assertNotEqual(html.stripTags(), html);
  },
  testParagraphSix: function() {
    TestUtil.bindElement('six');
    html = TestUtil.getHTML('p_six');
    this.assertEqual(Results.six, html);
    this.assertNotEqual(html.stripTags(), html);
  },
  testParagraphSeven: function() {
    TestUtil.bindElement('seven');
    html = TestUtil.getHTML('p_seven');
    this.assertEqual(Results.seven, html);
    this.assertNotEqual(html.stripTags(), html);
  },
  testParagraphEight: function() {
    TestUtil.bindElement('eight');
    html = TestUtil.getHTML('p_eight');
    this.assertEqual(Results.eight, html);
    this.assertEqual(html.stripTags(), html);
  },
  testTextFieldToTextArea: function() {
    TestUtil.bindElement('lorem');
    element = $('lorem');
    Event.simulateMouse(element,'click');
    form = $(element.id+'-inplaceeditor');
    text_area = form.getElementsBySelector('textarea').first();
    cancel_link = form.getElementsBySelector('a').first();
    this.assertNotNull(text_area);
    this.assertInstanceOf(HTMLTextAreaElement, text_area);
    this.assertEqual(Results.lorem, text_area.value);
    this.assertEqual(5, text_area.getAttribute('rows'));
    this.assertEqual(40, text_area.getAttribute('cols'));
    Event.simulateMouse(cancel_link,'click');
  },
  testTextAreaToTextField: function() {
    text = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.';
    TestUtil.bindElement('lorem_area', text, 'textarea');
    element = $('lorem_area');
    Event.simulateMouse(element,'click');
    form = $(element.id+'-inplaceeditor');
    text_field = form.getElementsBySelector('input[type~=text]').first();
    cancel_link = form.getElementsBySelector('a').first();
    this.assertNotNull(text_field);
    this.assertInstanceOf(HTMLInputElement, text_field);
    this.assertEqual(Results.lorem_area, text_field.value);
    this.assertNull(text_field.getAttribute('rows'));
    this.assertEqual(20, text_field.getAttribute('size'));
    Event.simulateMouse(cancel_link,'click');
  }
}, "testlog");
