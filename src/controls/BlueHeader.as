/**
 * Created by wmaynard on 4/8/2016.
 */
package controls
{
	import architecture.game.ColorMap;

	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.tools.Make;
	import ten90.tools.Position;

	import tools.TriviaText;

	public class BlueHeader extends DisplayObjectContainer
	{
		public var subtitle:TextField;

		private var bg:Quad;
		private var title:TextField;

		public function BlueHeader(parent:*, text:String, subtitleText:String = "")
		{
			super();

			this.x = Screen.left;
			this.y = Screen.top;

			bg = Make.quad(this, 0, 0, Screen.width, 200, ColorMap.CISCO_BLUE);

			title = TriviaText.create(this, {
				x:0,
				y:0,
				h: bg.height,
				w: bg.width,
				text: text,
				style: TriviaText.WHITE_LARGE
			});

			subtitle = TriviaText.create(this, {
				x:0,
				y:Position.bottom(title)-75,
				h: 75,
				w: bg.width,
				text: subtitleText,
				style: TriviaText.WHITE_SMALL
			});

			if (parent) parent.addChild(this);
		}
	}
}
