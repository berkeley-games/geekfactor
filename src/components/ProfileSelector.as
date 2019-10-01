/**
 * Created by wmaynard on 3/24/2016.
 */
package components {
	import architecture.ImageMap;
	import architecture.game.ColorMap;
	import architecture.game.User;

	import com.greensock.TweenMax;

	import controls.ProfilePhoto;

	import starling.display.Button;
	import starling.display.Image;
	import starling.text.TextField;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.tools.Make;
	import ten90.tools.Quick;

	import tools.TriviaText;

	public class ProfileSelector extends Component
	{
		private var overlay:Image;
		private var profile:ProfilePhoto;
		private var btn1:Button;
		private var btn2:Button;
		private var btn3:Button;
		private var iconChosen:int;

		public override function init():void
		{
			overlay = Make.shapeImage(this, Screen.left, Screen.top, Screen.width, Screen.height, true, ColorMap.BLACK);
			overlay.alpha = 0.6;

			profile = new ProfilePhoto(this, User.current);
			profile.setOptions(false, true, true, false, true);
			profile.x = (Screen.stageWidth - profile.width) / 2;

			var instructions:TextField = TriviaText.create(this, {
				x: Screen.stageLeft,
				y: profile.y + profile.height,
				text: "Choose a default",
				style: TriviaText.BLACK_MEDIUM
			});

			btn1 = Make.button(this, 0, 0, ImageMap.ICON_PROFILE_DEFAULT_1);
			btn2 = Make.button(this, 0, 0, ImageMap.ICON_PROFILE_DEFAULT_2);
			btn3 = Make.button(this, 0, 0, ImageMap.ICON_PROFILE_DEFAULT_3);

			btn1.x = Screen.stageWidth / 4 - btn1.width / 2;
			btn2.x = (Screen.stageWidth - btn2.width) / 2;
			btn3.x = Screen.stageRight - btn1.x - btn3.width;

			btn1.y = btn2.y = btn3.y = instructions.y + instructions.height;
			this.alpha = 0;
			this.touchable = false;
		}

		public override function ready():void
		{
			Quick.click(overlay, fadeOut, false);

			Quick.click(btn1, function():void{
				User.current.iconID = 1;
				profile.defaultImage = ImageMap.ICON_PROFILE_DEFAULT_1;
				iconChosen = 1;
			}, false);

			Quick.click(btn2, function():void{
				User.current.iconID = 2;
				profile.defaultImage = ImageMap.ICON_PROFILE_DEFAULT_2;
				iconChosen = 2;
			}, false);

			Quick.click(btn3, function():void{
				User.current.iconID = 3;
				profile.defaultImage = ImageMap.ICON_PROFILE_DEFAULT_3;
				iconChosen = 3;
			}, false);
		}

		public function fadeIn():void
		{
			var thisref:* = this;
			TweenMax.to(this, 0.25, {alpha: 1, onComplete: function():void{
				thisref.touchable = true;
			}});
		}

		public function fadeOut():void
		{
			this.touchable = false;
			TweenMax.to(this, 0.25, {alpha: 0});
			User.current.updateIcon(iconChosen);
		}
	}
}
