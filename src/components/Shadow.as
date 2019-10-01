/**
 * Created by gperry on 10/30/2015.
 */
package components
{
	import architecture.game.ColorMap;

	import com.greensock.TweenMax;

	import starling.display.Quad;

	import ten90.components.Component;
	import ten90.device.Screen;

	public class Shadow extends Component
	{
		public override function ready():void
		{
			var box:Quad = new Quad(Screen.width, Screen.height, ColorMap.BLACK);
			addChild(box);

			this.alpha = 0;
			this.visible = false;

			this.x = Screen.left;
			this.y = Screen.top;
		}

		public function show():void
		{
			this.visible = true;
			this.parent.addChildAt(this, 1);
			TweenMax.to(this, .5, {alpha:.5});
		}

		public function hide():void
		{
			TweenMax.to(this, .5, {alpha:0, onComplete:invisible});
		}

		private function invisible():void
		{
			this.visible = false;
		}
	}
}
