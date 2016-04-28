module EmbeddedAssetHelper
  def embedded_svg(filename)
    embedded_asset(filename)
  end
  
  def embedded_asset(filename)
    raw StaticAssetFinder.find_asset(filename).source
  end

  class StaticAssetFinder
    class FileNotFound < IOError; end
    UNREADABLE_PATH = ''
  
    def self.find_asset(filename)
      new(filename)
    end

    def initialize(filename)
      @filename = filename
    end

    def pathname
      if ::Rails.application.config.assets.compile
        ::Rails.application.assets[@filename].pathname
      else
        manifest = ::Rails.application.assets_manifest
        asset_path = manifest.assets[@filename]
        unless asset_path.nil?
          ::Rails.root.join(manifest.directory, asset_path)
        end
      end
    end
    
    def source
      File.read(pathname || UNREADABLE_PATH)
    rescue Errno::ENOENT
      raise FileNotFound.new("Asset not found: #{pathname}")
    end
  end
end
