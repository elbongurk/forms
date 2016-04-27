module SvgHelper
  def embedded_svg(filename, options = {})
    @sprockets ||= Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)
    file = @sprockets.find_asset(filename).source.force_encoding("UTF-8")
    doc = Nokogiri::HTML::DocumentFragment.parse file
    if options[:class].present?
      svg = doc.at_css "svg"
      svg["class"] = options[:class]
    end
    raw doc
  end
end