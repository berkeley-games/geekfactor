/**
 * Created by gperry on 10/21/2015.
 */
package components
{
	import architecture.ImageMap;
	import architecture.game.Ad;

	import com.greensock.TweenMax;

	import starling.display.Image;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.network.Browser;
	import ten90.tools.Make;
	import ten90.tools.Quick;

	public class Banner extends Component
	{
		private var banner:Image;

		public override function init():void
		{
//			Ad.loadBanner();

//			banner = Make.image(this, ImageMap.AD_BANNER);
//
//			this.x = Screen.left;
//			this.y = Screen.top;
//			this.scaleX = this.scaleY = Screen.width / this.width;
		}

		public override function ready():void
		{
//			TweenMax.delayedCall(3, function():void {
//				Quick.click(banner, gotoCisco, false);
//			});
		}

		private function gotoCisco():void
		{
//			Browser.load("http://www.cisco.com/");
		}
	}
}
