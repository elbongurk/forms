class ModelFormBuilder < ActionView::Helpers::FormBuilder
  def errors
    with_error_text(:base, '')
  end
  
  def field_for(method, options = {}, &block)
    builder = FieldFormBuilder.new(method, self)
    content = @template.capture(builder, &block)
    @template.content_tag(:div, with_error_text(method, content), options)
  end

  def label(method, text = nil, options = {}, &block)
    super(method, text, with_options(method, options), &block)
  end

  def text_field(method, options = {})
    super(method, with_options(method, options))
  end

  def email_field(method, options = {})
    super(method, with_options(method, options))
  end

  def password_field(method, options = {})    
    super(method, with_options(method, options))
  end

  def text_area(method, options = {})
    super(method, with_options(method, options))
  end
    
  def file_field(method, options = {})
    super(method, with_options(method, options))
  end

  def check_box(method, options = {}, checked = '1', unchecked = '0')
    super(method, with_options(method, options), checked, unchecked)
  end

  def radio_button(method, tag_value, options = {})
    super(method, tag_value, with_options(method, options))
  end

  def select(method, choices = nil, options = {}, html_options = {}, &block)
    super(method, choices, options, with_options(method, html_options), &block)
  end
  
  private

  def has_errors(method)
    object.errors[method].present?
  end

  def determine_error(method)
    if method == :base
      object.errors[:base].first
    else
      "#{method.to_s.humanize} #{@object.errors[method].first}"
    end
  end

  def with_error_text(method, content)
    if has_errors(method)
      options = { class: 'field-error' }
      content << @template.content_tag(:p, determine_error(method), options)
    else
      content
    end
  end

  def with_options(method, options)
    if has_errors(method)
      options.merge(class: 'error')
    else
      options
    end
  end
end
