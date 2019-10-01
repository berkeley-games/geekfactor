/**
 * Created by wmaynard on 3/29/2016.
 */
package controls
{
	import architecture.Skins;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import starling.display.DisplayObjectContainer;
	import starling.display.Image;

	import ten90.tools.Make;

	public class Check extends DisplayObjectContainer
	{
		private var unselected:Image;
		private var selected:Image;

		public function Check(parent:*, x:int, y:int, enabled:Boolean = false):void
		{
			super();

			unselected = Make.image(this, Skins.CHECK_EMPTY);
			selected = Make.image(this, Skins.CHECK_FULL);

			(enabled ? unselected : selected).scale = 0;
			this.x = x;
			this.y = y;
			parent.addChild(this);
		}

		public function get enabled():Boolean
		{
			return selected.scale == 1;
		}

		public function set enabled(enabled:Boolean):void
		{
			var currentlyEnabled:Boolean = selected.scale == 1;

			if (currentlyEnabled == enabled)
				return;

			TweenMax.to(enabled ? unselected : selected, 0.25, {scale: 0, ease: Back.easeInOut, onComplete: function():void{
				TweenMax.to(enabled ? selected : unselected, 0.25, {scale: 1, ease: Back.easeInOut});
			}});
		}
	}
}
