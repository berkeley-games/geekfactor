/**
 * Created by wmaynard on 4/12/2016.
 */
package controls
{
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.game.ColorMap;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.tools.Make;
	import ten90.tools.Quick;

	import tools.TriviaText;

	public class CategoryIcon extends DisplayObjectContainer
	{
		private var bg:Image;
		private var multiplier:int;
		private var multiplierBG:Image;
		private var multiplierText:TextField;
		private var icon:Image;
		private var _type:String;
		private var outline:Image;

		public static const CATEGORY_CIRCLE:String = "category_circle";
		public static const WHEEL:String = "wheel";
		public static const SPLASH:String = "splash";
		public static const GROUP_CREATION:String = "group";

		public function CategoryIcon(parent:*, x:int, y:int, categoryID:int, multiplier:int = 1, type:String = CATEGORY_CIRCLE, hideIcon:Boolean = false, grey:Boolean = false)
		{
			// this aint no javascript
			//type = type ? type : CATEGORY_CIRCLE;

			// mother of god
			bg = Make.image(this, grey ? Skins.LIGHT_GRAY_CIRCLE : (type == GROUP_CREATION) ? Skins.ORANGE_CIRCLE : Skins.GRAY_CIRCLE);
			icon = Make.image(this, ImageMap.getCategoryIcon(categoryID));
			multiplierBG = Make.image(this, Skins.ORANGE_CIRCLE);

			this.multiplier = multiplier;
			_type = type;
			size(type);
			if (!multiplierText)
				multiplierText = TriviaText.create(multiplierBG, {
					w: multiplierBG.width,
					h: multiplierBG.height,
					text: "x" + multiplier,
					style: TriviaText.WHITE_TINY
				});

			this.x = x;
			this.y = y;

			if (hideIcon) hideStuff();
			if (multiplier <= 1) hideMultipliers();
			if (parent) parent.addChild(this);
		}

		private function size(type:String):void
		{
			var max:int = Screen.stageWidth / 12;

			switch(type)
			{
				case CATEGORY_CIRCLE:
					bg.height = bg.width = max;
					break;

				case GROUP_CREATION:
					max *= 2;
					bg.height = bg.width = max;
					break;

				default:
					bg.alpha = 0;
					hideMultipliers();
					break;
			}

			var temp:int = (icon.width > icon.height ? icon.width : icon.height) * 1.75;
			icon.scale = bg.width / temp;
			multiplierBG.width = multiplierBG.height = bg.height * .5;

			position();
		}

		public function animateIn(delay:Number = 0):void
		{
			this.visible = true;
			var destY:int = this.y;
			this.y -= 25;
			TweenMax.to(this, .25, {delay: delay, y: destY, alpha: 1, ease: Back.easeOut});
		}

		private function hideStuff():void
		{
			icon.alpha = 0;
			this.visible = false;
			this.alpha = 0;
			hideMultipliers();
		}

		private function hideMultipliers():void
		{
			try
			{
				multiplierBG.alpha = 0;
				multiplierText.alpha = 0;
			}
			catch(e:*){}
		}

		public function onQuestionAnswer(correct:Boolean = false):void
		{
			if(correct)
			{
				outline = Make.image(this, Skins.CATEGORY_OUTLINE_CORRECT);
				TweenMax.to([bg, icon], .25, {alpha: 0.65});
			}
			else
			{
				outline = Make.image(this, Skins.CATEGORY_OUTLINE_INCORRECT);
				multiplierBG.visible = multiplierText.visible = false;
				TweenMax.to([bg, icon], .25, {alpha: 0.5});
			}
			
			Quick.scale(outline, bg.width, bg.height);
			Quick.index(outline, 1);
			Quick.pivot(this, .5, .5, true);

			TweenMax.to(this, .4, {scale:scale * 1.1, yoyo:true, repeat:1});
		}

		public function popIn(delay:Number = 0):void
		{
			if (icon.alpha == 1) return;
			icon.alpha = 1;

			TweenMax.fromTo(icon, .25, {delay: delay, alpha: 0}, {alpha:1, ease:Back.easeOut});
			if (multiplier > 1)
			{
				TweenMax.to(multiplierBG, .25, {delay: delay + .25, alpha: 1});
				TweenMax.to(multiplierText, .25, {delay: delay + .25, alpha: 1});
			}
		}

		private function position():void
		{
			icon.x = (bg.width - icon.width) / 2;
			icon.y = (bg.height - icon.height) / 2;

			multiplierBG.x = bg.width - (multiplierBG.width  * 3 / 4);
			multiplierBG.y -= (multiplierBG.width / 4);
		}

		public function change(categoryID:int, multiplier:int, grey:Boolean = false):void
		{
			var thisref:CategoryIcon = this;
			TweenMax.to(icon, .2, {alpha: 0, onComplete: function():void
			{
				removeChild(icon);
				icon = Make.image(thisref, ImageMap.getCategoryIcon(categoryID, true, grey));
				size(thisref._type);
				thisref.multiplier = multiplier;
				thisref.multiplierText.text = "x" + multiplier;
				popIn();
			}});
		}

	}
}
