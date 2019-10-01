/**
 * Created by wmaynard on 3/8/2016.
 */
package controls
{
	import architecture.Skins;

	import flash.filters.GlowFilter;

	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.text.TextField;

	import ten90.tools.Make;
	import ten90.tools.Quick;

	import tools.TriviaText;

	public class PowerupIconCount extends DisplayObjectContainer
	{
		private var bg:Image;
		public var field:TextField;

		public function PowerupIconCount(parent:*, x:int, y:int, count:int)
		{
			super();

			bg = Make.image(this, Skins.GREEN_CIRCLE_TINY);
			bg.scale = 1.25;

			field = TriviaText.create(this, {
				x: bg.x,
				w: bg.width,
				h: bg.height,
				text:String(count >= 100 ? 99 : count),	// The text gets wonky if user has more than 99 powerups.
				style: TriviaText.WHITE_SMALL,
				bold:true
			});

//			field.filter = new GlowFilter()

			this.x = x;
			this.y = y;
			parent.addChild(this);
		}
	}
}
