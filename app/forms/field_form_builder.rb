class FieldFormBuilder < ActionView::Helpers::FormBuilder
  attr_accessor :method

  def to_s
    method.to_s.humanize
  end
  
  def initialize(method, builder)
    @method = method
    @builder = builder
  end

  def label(text = nil, options = {}, &block)
    @builder.label(method, text, options, &block)
  end

  def text_field(options = {})
    @builder.text_field(method, options)
  end

  def email_field(options = {})
    @builder.email_field(method, options)
  end

  def password_field(options = {})
    @builder.password_field(method, options)
  end

  def text_area(options = {})
    @builder.text_area(method, options)
  end

  def file_field(options = {})
    @builder.file_field(method, options)
  end

  def check_box(options = {}, checked = '1', unchecked = '0')
    @builder.check_box(method, options, checked, unchecked)
  end

  def radio_button(tag_value, options = {})
    @builder.radio_button(method, tag_value, options)
  end

  def select(choices = nil, options = {}, html_options = {}, &block)
    @builder.select(method, choices, options, html_options, &block)
  end
end
