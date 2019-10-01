/**
 * Created by gperry on 4/8/2016.
 */
package components
{
	import architecture.ImageMap;

	import starling.display.Image;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.tools.Make;

	public class CiscoLogo extends Component
	{
		public override function ready():void
		{
			Make.image(this, ImageMap.ICON_CISCO);
			x = (Screen.stageWidth - width) / 2;
			y = (Screen.bottom - height) - 125;
		}
	}
}
