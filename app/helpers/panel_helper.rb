module PanelHelper
  def panels(&block)
    template = capture(&block)
    Panel.new.render template
  end
  
  def panels_for(obj, &block)
    template = capture(&block)
    Panel.new(obj).render template
  end

  class Panel
    include ActionView::Helpers
    include Rails.application.routes.url_helpers
    
    def self.root_title
      Rails.application.class.to_s.split('::')[1]
    end

    def initialize(obj = nil)
      @obj = obj
    end

    def render(template)
      content = body(template)
      
      titles.reverse.each_with_index do |title, index|
        content = panel_for(content, title: title, level: index)
      end
      
      content
    end

    private

    def obj?
      @obj.present?
    end
    
    def body(template)
      content_tag(:div, template, class: 'panel-body')
    end

    def titles
      titles = []

      # add our root
      titles << title_for(self.class.root_title, link: obj?)
      
      if obj = @obj
        # add links to any intermediate items
        if obj.is_a? Array
          obj[0...-1].each do |item|
            titles << title_for(item)
          end
          obj = obj[-1]
        end
        # add our last item but not as a link
        titles << title_for(obj, link: false)
      end

      titles
    end

    def title_for(obj, options = {})    
      link = options[:link].nil? ? true : options[:link]

      if obj.is_a? String
        if link
          link_to obj, root_path
        else
          obj
        end
      elsif obj.is_a? Form
        if link
          link_to obj.name, form_path(obj)
        else
          obj.name
        end
      elsif obj.is_a? Submission
        if link
          link_to "Submission", form_submission_path(obj.form, obj)
        else
          "Submission"
        end
      else
        raise ArgumentError "arguments passed to panels_for can't be handled"
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
