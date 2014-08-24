module Agg
  module Widget
    
    class Base
      attr_reader :title, :decoration, :css_class

      def initialize(controller, options = { :title => nil, :decoration => nil, :css_class => nil })
        @controller = controller
        @title = options[:title] || 'Widget'
        @decoration = options[:decoration] || 'standard'
        @css_class = options[:css_class]
      end
      
      def render
        render_decoration_template 
      end

      protected

      def render_body_template(template_name, locals = nil)
        @controller.render :partial => "shared/widget/body/#{template_name}", :locals => locals
      end

      private
      
      def render_decoration_template
        @controller.render :partial => "shared/widget/decoration/#{@decoration}", :locals => { :widget => self }
      end
      
    end
    
    class MyJournals < Base
      
      def body
        render_body_template @body_template, :journals => @user.journals
      end
      
      def initialize(controller, user, options = { :decoration => nil })
        super(controller, options.merge({ :title => 'My Journals', :css_class => 'my-journals' }))
        @user = user
        @body_template = 'my_journals'
      end
      
    end
  end
end
