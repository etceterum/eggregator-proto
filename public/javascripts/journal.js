agg.Journal = Class.create({

  initialize: function() {
    this.stories = $$('ul.stories li');
    this.stories.each(function(story) {
      Event.observe(story, 'mouseover', function(event) { 
        Element.addClassName(Event.findElement(event, 'li'), 'hover'); 
      });
      Event.observe(story, 'mouseout', function(event) { 
        Element.removeClassName(Event.findElement(event, 'li'), 'hover'); 
      });
    });
  }
});

Event.observe(window, 'load', function() { agg.journal = new agg.Journal(); });

