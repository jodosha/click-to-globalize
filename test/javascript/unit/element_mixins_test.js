new Test.Unit.Runner({
  testRespondTo: function() {
    element = $('base');
    this.assertRespondsTo('getText', element);
  },
  testGetText: function() {
    base = $('base');
    this.assertInstanceOf(HTMLDivElement, base);
    this.assertEqual('base', base.getText());
    
    empty = $('empty');
    this.assertInstanceOf(HTMLDivElement, empty);
    this.assertEqual('', empty.getText());
    
    nested = $('nested');
    this.assertInstanceOf(HTMLDivElement, nested);
    this.assertEqual('', nested.getText());
    
    nested_child = $('nested_child');
    this.assertInstanceOf(HTMLDivElement, nested_child);
    this.assertEqual('nested', nested_child.getText());      
  }
}, "testlog");
