/**
 * Created by gperry on 10/21/2015.
 */
package components
{
	import architecture.game.ColorMap;

	import starling.display.BlendMode;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.tools.Make;

	public class Background extends Component
	{
		public var color:int = ColorMap.WHITE;

		public override function ready():void
		{
			Make.quad(this, Screen.left, Screen.top, Screen.width, Screen.height, color);
			parentScene.addChildAt(this, 0);
			touchable = false;
			blendMode = BlendMode.NONE;
		}
	}
}
