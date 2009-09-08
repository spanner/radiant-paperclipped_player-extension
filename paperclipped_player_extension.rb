# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class PaperclippedPlayerExtension < Radiant::Extension
  version "0.1"
  description "Adds audio and video player tags to paperclipped and some useful conditionals around them"
  url "http://spanner.org/radiant/paperclipped_player"
  
  extension_config do |config|
    config.extension 'paperclipped'
  end

  def activate
    Asset.send :register_type, :playable, Mime::VIDEO.all_types + Mime::AUDIO.all_types
    Page.send :include, AssetPlayerTags
    AssetsHelper.send :include, AssetPlayerHelper
    Admin::AssetsHelper.send :include, AssetPlayerHelper
  end

end
