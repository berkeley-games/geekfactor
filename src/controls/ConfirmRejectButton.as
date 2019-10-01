/**
 * Created by wmaynard on 3/31/2016.
 */
package controls
{
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.game.ColorMap;

	import com.greensock.TweenMax;

	import starling.display.Button;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;

	import ten90.tools.Make;
	import ten90.tools.Quick;

	import tools.Helper;

	public class ConfirmRejectButton extends DisplayObjectContainer
	{
		private var a:Sprite;
		private var r:Sprite;

		public function ConfirmRejectButton(parent:*, x:int, y:int, onAccept:Function, onReject:Function)
		{
			super();

			a = new Sprite();
			r = new Sprite();

			var bg:Image = Make.image(r, Skins.ORANGE_CIRCLE);
			var fg:Image = Make.image(r, ImageMap.ICON_CHALLENGE_DECLINE);
			bg.width = bg.height = fg.width * 2.5;
			fg.x = (r.width - fg.width) / 2;
			fg.y = (r.height - fg.height) / 2;
			r.visible = onReject != null;
			addClick(r, onReject);

			bg = Make.image(a, Skins.GREEN_CIRCLE_SMALL);
			bg.width = bg.height = fg.width * 2.5;
			fg = Make.image(a, onReject ? ImageMap.ICON_CHALLENGE_ACCEPT : ImageMap.ICON_ADD_FRIEND);
			fg.x = (a.width - fg.width) / 2;
			fg.y = (a.height - fg.height) / 2;
			a.x = r.width * 1.1;
			addClick(a, onAccept);

			this.x = x;
			this.y = y;
			this.addChild(a);
			this.addChild(r);
			parent.addChild(this);
		}

		private function addClick(obj:*, onClick:Function):void
		{
			Quick.click(obj, function():void{
				TweenMax.to([a, r], 0.25, {alpha: 0});
				Helper.Try(onClick);
			});
		}
	}
}
