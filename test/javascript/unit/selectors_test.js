new Test.Unit.Runner({
  testRespondTo: function() {
    this.assertNotNull($$$);
    this.assertMatch(/function/, $$$);
  },
  testUngroupedText: function() {
    elements = $$$('ungrouped text');
    this.assertInstanceOf(Array, elements);
    this.assertEqual(1, elements.size());
    element = elements.first();
    this.assertInstanceOf(HTMLDivElement, element);
    this.assertEqual('ungrouped text', element.getText());
    this.assertEqual('fixtures', element.id);
  },
  testBaseDiv: function() {
    elements = $$$('Hello World');
    this.assertInstanceOf(Array, elements);
    this.assertEqual(1, elements.size());
    element = elements.first();
    this.assertInstanceOf(HTMLDivElement, element);
    this.assertEqual('Hello World', element.getText());
    this.assertEqual('hello_world', element.id);
  },
  testNestedParagraph: function() {
    elements = $$$('Paragraph text');
    this.assertInstanceOf(Array, elements);
    this.assertEqual(1, elements.size());
    element = elements.first();
    this.assertInstanceOf(HTMLParagraphElement, element);
    this.assertEqual('Paragraph text', element.getText());
    this.assertEqual('paragraph', element.id);
  },
  testParagraphWithWhiteLine: function(){
    elements = $$$('White space');
    this.assertInstanceOf(Array, elements);
    this.assertEqual(1, elements.size());
    element = elements.first();
    this.assertInstanceOf(HTMLParagraphElement, element);
    this.assertEqual('White space', element.getText());
    this.assertEqual('white_space_paragraph', element.id);      
  },
  testTable: function() {
    elements = $$$('First Cell');
    this.assertInstanceOf(Array, elements);
    this.assertEqual(1, elements.size());
    element = elements.first();
    this.assertInstanceOf(HTMLTableCellElement, element);
    this.assertEqual('First Cell', element.getText());
    this.assertEqual('first_cell', element.id);
  },
  testList: function() {
    elements = $$$('First Li');
    this.assertInstanceOf(Array, elements);
    this.assertEqual(1, elements.size());
    element = elements.first();
    this.assertInstanceOf(HTMLLIElement, element);
    this.assertEqual('First Li', element.getText());
    this.assertEqual('first_li', element.id);
  },
  testCaseSensitive: function() {
    elements = $$$('hello world');
    this.assertInstanceOf(Array, elements);
    this.assertEqual(0, elements.size());
  }
}, "testlog");
