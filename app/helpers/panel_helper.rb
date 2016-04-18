module PanelHelper
  def panel_for(obj, &block)
    panels_for([obj], &block)
  end
  
  def panels_for(objs, &block)
    template = capture(&block)
    Panel.new(objs).render template
  end

  class Panel
    include ActionView::Helpers
    include Rails.application.routes.url_helpers
    
    def self.root_title
      Rails.application.class.to_s.split('::').first
    end

    def initialize(objs = nil)
      @objs = objs
    end

    def render(template)
      content = body(template)
      
      titles.reverse.each_with_index do |title, index|
        content = panel_for(content, title: title, level: index)
      end
      
      content
    end

    private

    def body(template)
      content_tag(:div, template, class: 'panel-body')
    end

    def titles
      titles = []

      @objs[0...-1].each do |item|
        titles << title_for(item)
      end
      titles << title_for(@objs[-1], link: false)

      titles
    end

    def title_for(obj, options = {})
      opts = { link: true }.merge(options)
      if opts[:link]
        link_to title_text_for(obj), title_path_for(obj)
      else
        title_text_for(obj)
      end
    end

    # TODO: perhaps use content_for or yield this object so we can do this in the template
    def title_text_for(obj)
      case obj
      when :root
        self.class.root_title
      when Form
        obj.name
      when Submission
        'Submission'
      when User
        'Account'
      when Subscription
        'Subscription'
      when :cards
        'Payment Methods'
      when String
        obj
      else
        raise ArgumentError.new("argument '#{obj}' passed to #{__method__} can't be handled")
      end
    end
    
    # TODO: http://api.rubyonrails.org/classes/ActionDispatch/Routing/PolymorphicRoutes.html
    def title_path_for(obj)
      case obj
      when :root
        root_path
      when Form
        form_path(obj)
      when Submission
        form_submission_path(obj.form, obj)
      when User
        edit_account_path
      when Subscription
        account_subscription_path
      when :cards
        account_cards_path
      else
        raise ArgumentError.new("argument '#{obj}' passed to #{__method__} can't be handled")
      end
    end

    def panel_for(content, options = {})
      title = options[:title] || root
      level = options[:level] || 0

      header = content_tag(:header, content_tag(:h2, title))
      content = header + content

      tag_options = {}
      if level.zero?
        tag_options[:class] = 'panel'
      else
        tag_options[:class] = 'panel-wrapper'
        tag_options[:data] = { children: level }
      end

      content_tag(:div, content, tag_options)
    end
  end
end
