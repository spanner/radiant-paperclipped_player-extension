module AssetPlayerHelper

  def self.included(base)
    base.module_eval {
      
        def player_for(asset)
          if asset.playable?
            include_javascript 'swfobject' 
            url = asset.asset.url
            height = asset.movie? ? 327 : 27
            result = %{
      <div id="player_#{asset.id}"></div>
      <script type="text/javascript">
        //<![CDATA[
          var so = new SWFObject("/flash/mpw_player.swf", "swfplayer_#{asset.id}", "400", "#{height}", "9", "ffffff"); so.addVariable("backcolor","ffffff"); so.addVariable("frontcolor","4d4e53"); so.addVariable("fullscreen","false"); so.addVariable("autoplay","false");}
            if asset.movie?
              result << %{so.addVariable("flv", "#{url}");}
              result << %{so.addParam("allowFullScreen", "true");}
            else
              result << %{so.addVariable("mp3", "#{url}");}
              result << %{so.addParam("allowFullScreen", "false");}
            end
            result << %{
          so.write("player_#{asset.id}");
        //]]>
      </script>}
          end
        end

      }
    end

  end

