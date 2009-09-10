module AssetPlayerTags
  include Radiant::Taggable
  
  class TagError < StandardError; end
  
  desc %{
    Renders a flash-based media player suitable to the current asset file. This works for audio and video but currently is only tested with .flv and .mp3 files. An error will appear if the asset is not audio or video.
    
    With video, you can specify a pre-roll image with the parameter image="asset id". If none is specified then we'll use the first image attached to the same page.
    
    Other parameters you can pass through to the player:
    
    * width (in pixels. default is 400)
    * height (in pixels. default is 27 for audio, 327 for video. 27px is the height of the controls)
    * frontcolor (default is #4d4e53. aka Cool Grey 11)
    * backcolor (default is white)
    * allowFullScreen (whether permitted. default is true for video, false for audio)
    * autoplay (default is false)
    * version (flash player version required. default is 9)

    And make sure your layout brings in javascripts/swfobject.js.
    
    The flash file is the 'MPW player' by GrupoSistemas. See http://sourceforge.net/projects/mpwplayer.
    
  }    
  tag 'assets:player' do |tag|
    options = tag.attr.dup
    asset = find_asset(tag, options)
    if asset.playable?
      url = asset.asset.url
      width = options['width'] || 400
      height = options['height'] || asset.movie? ? 327 : 27
      fc = options['frontcolor'] || '4d4e53'
      bc = options['backcolor'] || 'ffffff'
      version = options['version'] || '9'
      autoplay = options['autoplay'] || 'false'
      
      result = %{
<div id="player_#{asset.id}"></div>
<script type="text/javascript">
  //<![CDATA[
    var so = new SWFObject("/flash/mpw_player.swf", "swfplayer_#{asset.id}", "#{width}", "#{height}", "#{version}", "#{bc}"); so.addVariable("backcolor","#{bc}"); so.addVariable("frontcolor","#{fc}"); so.addVariable("fullscreen","false"); so.addVariable("autoplay","#{autoplay}");}
      if asset.movie?
        result << %{so.addVariable("flv", "#{url}");}
        result << %{so.addParam("allowFullScreen", "#{true unless options['allowFullScreen'] == 'false'}");}
        if options['image'] && cover = Asset.find_by_id(options['image'])
          result << %{so.addVariable("jpg", "#{cover.thumbnail('video')}");}
        elsif cover = tag.locals.page.assets.images.first
          result << %{so.addVariable("jpg", "#{cover.thumbnail('video')}");}
        end
      else
        result << %{so.addVariable("mp3", "#{url}");}
        result << %{so.addParam("allowFullScreen", "#{false unless options['allowFullScreen'] == 'true'}");}
      end
      result << %{
    so.write("player_#{asset.id}");
  //]]>
</script>}
    else
      raise TagError, "Asset is not audio or video"
    end
  end


  desc %{
    Renders the contained elements only if the current asset is playable (ie. suitable for dropping in with a flash player)
    
    *Usage:* 
    <pre><code><r:assets:if_playable>...</r:assets:if_playable></code></pre>
  }    
  tag "assets:if_playable" do |tag|
    tag.expand if tag.locals.asset && tag.locals.asset.playable?
  end

  desc %{
    Renders the contained elements only if the current asset is not playable.
    
    *Usage:* 
    <pre><code><r:assets:unless_playable>...</r:assets:unless_playable></code></pre>
  }    
  tag "assets:unless_playable" do |tag|
    tag.expand unless tag.locals.asset && tag.locals.asset.playable?
  end

  desc %{
    Renders the contained elements only if the current page has attached playable assets.
    
    *Usage:* 
    <pre><code><r:if_playable_assets>...</r:if_playable_assets></code></pre>
  }    
  tag "if_playable_assets" do |tag|
    tag.expand if tag.locals.page.assets.playables.count > 0
  end
  
  desc %{
    Renders the contained elements only if the current page has no attached playable assets.
    
    *Usage:* 
    <pre><code><r:unless_playable_assets>...</r:unless_playable_assets></code></pre>
  }    
  tag "unless_playable_assets" do |tag|
    tag.expand unless tag.locals.page.assets.playables.count > 0
  end
  
  desc %{
    Cycles through all playable assets attached to the current page.  
    Other options exactly as for r:assets:each.
  }    
  tag "assets:each_playable" do |tag|
    tag.locals.assets ||= tag.locals.page.assets.playables.find(:all, assets_find_options(tag))
    tag.locals.assets.each do |asset|
      tag.locals.asset = asset
      result << tag.expand
    end
    result
  end
  
  desc %{
    References the first playable asset attached to the current page. If there is no such asset, nothing is rendered.
  }    
  tag "assets:first_playable" do |tag|
    tag.expand if tag.locals.asset = tag.locals.page.assets.playables.find(:first)
  end
  
  desc %{
    Returns the first child of the current page to which a playable asset has been attached. 
    The usual sort options determine what is 'first'.
    This is a very inefficient tag that you wouldn't want to overuse, but it has its place.

    *Usage:*

    <pre><code><r:children:first_with_playable>...</r:children:first_with_playable></code></pre>
  }
  tag "children:first_with_playable" do |tag|
    options = children_find_options(tag)
    children = tag.locals.children.find(:all, options)
    if first = children.select{|child| child.assets.playables.count > 0}.first
      tag.locals.page = first
      tag.expand
    end
  end
  
end
