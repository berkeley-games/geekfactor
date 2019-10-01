/**
 * Created by wmaynard on 4/18/2016.
 */
package controls
{
	import architecture.game.*;
	import architecture.Skins;

	import com.greensock.TweenMax;

	import scenes.Credits;

	import starling.display.Image;
	import starling.display.Sprite;

	import ten90.device.Screen;

	import ten90.media.Audio;
	import ten90.scene.SceneController;
	import ten90.tools.Make;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	import tools.TriviaText;

	// Hopefully this version of the is at least a little better than the kluge-y one from before.
	// The GUI assets are not required to load or create Setting objects,
	// but the GUI for each setting can still be generated from within the class.
	public class Setting
	{
		public static const NOTIFICATIONS:String = "Notifications";
		public static const SOUND:String = "Sound";

		private var saveString_enabled:String = "SettingEnabled";

		private var _enabled:Boolean = true;
		private var _type:String;

		public function Setting(type:String)
		{
			_type = type;

			saveString_enabled += _type;
		}

		// Generates a bar for the selected setting consisting of:
		// 		A text field for the setting name
		//		A slider that moves moves when clicked, enabling / disabling the setting on Tween end
		public function createSprite(parent:*):Sprite
		{
			var xOffset:int = 150;
			var baseSprite:Sprite = new Sprite();
			TriviaText.create(baseSprite, {
				x: xOffset,
				text: _type,
				style: TriviaText.GRAY_MEDIUM_LEFT
			});

			var slider:Sprite = new Sprite();

			var sliderBG:Image = Make.image(slider, Skins.SETTING_SLIDER_PILL);
			var sliderCircle:Image = Make.image(slider, Skins.BLUE_SPLASH_CIRCLE);

			sliderCircle.width = sliderCircle.height = sliderBG.height * 2;
			sliderBG.x += sliderCircle.width / 2;
			sliderBG.y += (sliderCircle.height - sliderBG.height) / 2;

			// The comps show that when disabled, the slider should be grayscale.  We will fade out the blue slider to reveal the gray parts.
			var graySliderBG:Image = Make.image(slider, Skins.SETTING_SLIDER_PILL_GRAY);
			var graySliderCircle:Image = Make.image(slider, Skins.DARK_GRAY_CIRCLE);

			graySliderCircle.width = graySliderCircle.height = sliderCircle.height;
			graySliderBG.x = sliderBG.x;
			graySliderBG.y = sliderBG.y;

			// Positioning
			var offX:int = 0;
			var onX:int = sliderBG.width;
			graySliderCircle.x = sliderCircle.x = _enabled ? onX : offX;
			sliderCircle.alpha = sliderBG.alpha = _enabled ? 1 : 0;

			Quick.index(graySliderCircle, 0);
			Quick.index(sliderBG, 0);
			Quick.index(graySliderBG, 0);

			Quick.click(slider, function():void{
				var currentlyEnabled:Boolean = sliderCircle.x == onX;
				var x:int = currentlyEnabled ? offX : onX;
				var alpha:Number = currentlyEnabled ? 0 : 1;

				TweenMax.to([graySliderCircle, sliderCircle], 0.25, {x: x, onComplete: function():void{
					enabled = !currentlyEnabled;
				}});
				TweenMax.to([sliderCircle, sliderBG], 0.25, {alpha: alpha});
			}, false);

			slider.x = Screen.stageWidth - (xOffset + sliderBG.width + sliderCircle.width / 2);
			slider.y = (baseSprite.height - slider.height) / 2;
			parent.addChild(baseSprite);
			baseSprite.addChild(slider);
			return baseSprite;
		}

		// TODO: antipattern
		public function set enabled(value:Boolean):void
		{
			_enabled = value;

			switch (_type)
			{
				case NOTIFICATIONS:
					Notification.enabled = _enabled;
					break;

				case SOUND:
					Audio.setVolume(_enabled ? .35 : 0);
					break;
			}

			save();
		}

		private function save():void
		{
			Save.data(saveString_enabled, _enabled);
			Save.flush();
		}

		private function load():void
		{
			var savedEnabled:* = Save.data(saveString_enabled);
			if (savedEnabled != null && savedEnabled != undefined) enabled = savedEnabled;
			else enabled = true;
		}

		// Loads the settings from disk and applies them.
		// If a parent is provided, sprites for the settings are created.
		public static function loadAll(parent:* = null):void
		{
			var output:Vector.<Setting> = new Vector.<Setting>();
			for each (var type:String in [NOTIFICATIONS, SOUND])
			{
				var setting:Setting = new Setting(type);
				setting.load();
				output.push(setting);
			}

			if (parent)
				for each (var s:Setting in output)
					s.createSprite(parent);
		}
	}
}