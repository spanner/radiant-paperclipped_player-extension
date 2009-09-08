module PlayableAsset      # for inclusion into Asset
  
  def self.included(base)

    base.class_eval {
      extend TaggablePage::ClassMethods
      include TaggablePage::InstanceMethods
    }
  end

  module ClassMethods
    register_type :playable, Mime::Video.all_types + Mime::Audio.all_types
  end

  module InstanceMethods

  end
end