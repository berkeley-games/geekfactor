/**
 * Created by wmaynard on 4/11/2016.
 */
package controls
{
	import architecture.AudioMap;
	import architecture.Skins;
	import architecture.game.ColorMap;

	import com.greensock.TweenMax;

	import starling.display.DisplayObjectContainer;
	import starling.display.Image;

	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.tools.Make;
	import ten90.tools.Quick;

	import tools.Helper;
	import tools.TriviaText;

	public class TriviaButton extends DisplayObjectContainer
	{
		private var bg:Image;
		private var self:TriviaButton;
		private var removeOnComplete:Boolean;
		private var clicked:Boolean = false;

		public function TriviaButton(parent:*, x:int, y:int, bg:String, fg:String, onClick:Function, removeOnComplete:Boolean = false)
		{
			super();
			self = this;
			this.x = x;
			this.y = y;
			this.background = bg;
			this.foreground = fg;
			this.removeOnComplete = removeOnComplete;
			if(onClick) this.onClick = onClick;
			Helper.center(this);
			Helper.Try(function():void
			{
				parent.addChild(self);
			});
		}

		private function set onClick(onClick:Function):void
		{
			Helper.Try(function():void
			{
				Quick.removeClick(self);
			});

			Quick.click(self, function():void
			{
				if(removeOnComplete && clicked == true)
				{
					touchable = false;
					return;
				}

				clicked = true;

				var prevScale:Number = self.scale;
				Audio.play(AudioMap.BUTTON_PRESS);
				TweenMax.to(self, .1, {scale: prevScale*.95, onComplete: function():void
				{
					TweenMax.to(self, .1, {scale: prevScale, onComplete:function():void
					{
						Helper.Try(onClick);
					}});
				}});
			}, false);
		}

		public function listen():void
		{
			touchable = true;
			clicked = false;
		}
		
		private function set background(skin:String):void
		{
			this.bg = Make.image(this, skin);
		}

		private function set foreground(textOrImage:String):void
		{
			try
			{
				var i:Image = Make.image(this, textOrImage, 0, 0);
				i.x = (this.width - i.width) / 2;
				i.y = (this.height - i.height) / 2;
			}
			catch(e:*)
			{
//				trace(this.bg.height);
				TriviaText.create(this,
				{
					w: this.width,
					h: 135, //this.height, <- randomly causes the text to be off center
					text: textOrImage,
					style: TriviaText.WHITE_MEDIUM
				});
			}
		}

		public static function pill(parent:*, y:int, text:String, color:int = -1, onClick:Function = null, small:Boolean = false, removeOnComplete:Boolean = false):TriviaButton
		{
			var skin:String;
			color = color == -1 ? ColorMap.LIGHT_GREEN : color;
			switch(color)
			{
				case ColorMap.LIGHT_GREEN:
					skin = small ? Skins.SMALL_GREEN_PILL : Skins.GREEN_PILL;
					break;
				case ColorMap.BLUE:
					skin = Skins.DARK_BLUE_PILL;
					break;
				default:
					skin = small ? Skins.SUPER_SMALL_CISCO_BLUE_PILL : Skins.CISCO_BLUE_PILL;
					break;
			}
			return new TriviaButton(parent, Screen.stageWidth / 2, y, skin, text, onClick, removeOnComplete);
		}

		public static function circle(parent:*, textOrImage:String, x:int = 0, y:int = 0, color:int = -1, onClick:Function = null, removeOnComplete:Boolean = false):TriviaButton
		{
			var skin:String;

			color = color == -1 ? ColorMap.LIGHT_GREEN : color;
			switch(color)
			{
				case ColorMap.LIGHT_GREEN:
					skin = Skins.GREEN_CIRCLE;
					break;
				case ColorMap.YELLOW:
					skin = Skins.LEVEL_3_MEDAL_LARGE;
					break;
			}
			return new TriviaButton(parent, x, y, skin, textOrImage, onClick, removeOnComplete);
		}
	}
}