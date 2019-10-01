/**
 * Created by wmaynard on 3/8/2016.
 */
package controls
{
	import com.greensock.TweenMax;

	import starling.display.Button;
	import starling.display.DisplayObjectContainer;
	import starling.text.TextField;

	import ten90.tools.Make;
	import ten90.tools.Quick;

	import tools.Helper;

	public class PowerupIcon extends DisplayObjectContainer
	{
		private var image:Button;
		private var countField:PowerupIconCount;

		private static const FADED:Number = 0.2;

		public function get count():int{
			return parseInt(countField.field.text);
		}
		public function set count(num:int):void{
			var field:TextField = countField.field;

			if (num == count)
				return;

			TweenMax.to(field, 0.25, {alpha: 0, onComplete: function():void{
				field.text = String(num < 100 ? num : 99);
				TweenMax.to(field, 0.25, {alpha: 1});
			}});

		}

		public function PowerupIcon(parent:*, x:int, y:int, imageString:String, count:int, hideCount:Boolean = false)
		{
			super();

			image = Make.button(this, 0, 0, imageString);

			countField = new PowerupIconCount(this, image.width, 0, count);

			var offset:int = countField.width / 3;
			countField.x -= offset;
			countField.y += offset;

			Helper.center(countField);

			this.touchable = false;

			this.x = x;
			this.y = y;

			if (hideCount) hideCountGraphics();

			parent.addChild(this);

			this.scale = .7;
		}

		private function hideCountGraphics():void
		{
			countField.alpha = 0;
		}

		public function set onClick(onClick:Function):void
		{
			if ((onClick != null) && count > 0)
			{
				this.touchable = true;
				TweenMax.to(image, 0.25, {alpha: 1});
				TweenMax.to(countField, 0.25, {alpha: 1});

				var self:PowerupIcon = this;
				
				Quick.click(image, function():void{
					Quick.removeClick(image);
					self.touchable = false; // Giggity.
					onClick();
					TweenMax.to(image, 0.25, {alpha: FADED});
					TweenMax.to(countField, 0.25, {alpha: FADED});
				});
			}
			else
			{
				this.touchable = false;
				TweenMax.to(image, 0.25, {alpha: FADED});
				TweenMax.to(countField, 0.25, {alpha: FADED});
			}
		}
	}
}