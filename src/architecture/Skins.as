/**
 * Created by gperry on 4/8/2016.
 */
package architecture
{
	import architecture.game.ColorMap;

	import flash.display.Sprite;

	import starling.display.Image;

	import ten90.base.Assets;
	import ten90.device.Screen;
	import ten90.tools.Make;

	public class Skins extends Sprite
	{
		public static const BLUE_HEADER:String = "blueHeader";

		public static const GREEN_PILL:String = "greenPillButton";
		public static const SMALL_GREEN_PILL:String = "smallGreenPillButton";
		public static const CISCO_BLUE_PILL:String = "ciscoBluePillButton";
		public static const SUPER_SMALL_CISCO_BLUE_PILL:String = "smallBluePillButton";
		public static const DARK_BLUE_PILL:String = "darkBluePillButton";
		public static const SETTING_SLIDER_PILL:String = "settingPill";
		public static const SETTING_SLIDER_PILL_GRAY:String = "settingPillGray";

		public static const GRAY_CIRCLE:String = "grayCircle";
		public static const LIGHT_GRAY_CIRCLE:String = "lightGrayCircle";
		public static const DARK_GRAY_CIRCLE:String = "darkGrayCircle";
		public static const GREEN_CIRCLE:String = "greenCircle";
		public static const GREEN_CIRCLE_SMALL:String = "greenCircleSmall";
		public static const GREEN_CIRCLE_TINY:String = "greenCircleTiny";
		public static const GOLD_CIRCLE:String = "goldCircle";
		public static const ORANGE_CIRCLE:String = "orangeCircle";
		public static const ORANGE_SPLASH_CIRCLE:String = "orangeSplashCircle";
		public static const BLUE_SPLASH_CIRCLE:String = "blueSplashCircle";

		public static const BURGER_DOWN:String = "burgerButtonDown";

		public static const CHECK_EMPTY:String = "checkEmpty";
		public static const CHECK_FULL:String = "checkFull";

		public static const LEVEL_3_MEDAL_SMALL:String = "goldMedalSmall";
		public static const LEVEL_3_MEDAL_LARGE:String = "goldMedalLarge";
		public static const LEVEL_2_MEDAL_SMALL:String = "silverMedalSmall";
		public static const LEVEL_2_MEDAL_LARGE:String = "silverMedalLarge";
		public static const LEVEL_1_MEDAL_SMALL:String = "bronzeMedalSmall";
		public static const LEVEL_1_MEDAL_LARGE:String = "bronzeMedalLarge";

		public static const CHECK_BOX_BACKGROUND:String = "checkBoxBackground";
		public static const CHECK_BOX_FOREGROUND:String = "checkBoxForeground";

		public static const CATEGORY_OUTLINE_CORRECT:String = "categoryOutlineCorrect";
		public static const CATEGORY_OUTLINE_INCORRECT:String = "categoryOutlineIncorrect";

		public static var dividerStroke:Number;

		private static var cachedImageNames:Array = [];

        public static function init():void
        {
			dividerStroke = Math.max(1.5/Screen.scaleFactor, 1.5);

	        var pillWidth:int = Screen.width - 100;
	        var smallPillWidth:int = 980;
	        var superSmallPillWidth:int = 750;
	        var pillHeight:int = 135;
	        var pillRounding:int = 125;

			var radiusXLarge:int = 180;
			var radiusLarge:int = 130;
			var radiusMedium:int = 70;
			var radiusSmall:int = 60;
			var radiusTiny:int = 30;

			// Convert the circle radii to height / width for image creation.
			radiusXLarge *= 2;
			radiusLarge *= 2;
			radiusMedium *= 2;
			radiusSmall *= 2;
			radiusTiny *= 2;

			// Pill Buttons

			var tinyPillWidth:int = 80;
			var tinyPillHeight:int = 30;
			var tinyPillRadius:int = 30;

			var settingPill:Image = Make.shapeImage(null, 0, 0, tinyPillWidth, tinyPillHeight, true, ColorMap.CISCO_BLUE, 0, 0, tinyPillRadius);
			Assets.addTexture(SETTING_SLIDER_PILL, settingPill.texture);
			settingPill = null;

			var graySettingPill:Image = Make.shapeImage(null, 0, 0, tinyPillWidth, tinyPillHeight, true, ColorMap.LIGHT_GRAY, 0, 0, tinyPillRadius);
			Assets.addTexture(SETTING_SLIDER_PILL_GRAY, graySettingPill.texture);
			graySettingPill = null;

	        var greenPill:Image = Make.shapeImage(null, 0, 0, pillWidth, pillHeight, true, ColorMap.LIGHT_GREEN, 0, 0, pillRounding);
	        Assets.addTexture(GREEN_PILL, greenPill.texture);
	        greenPill = null;

	        var smallGreenPill:Image = Make.shapeImage(null, 0, 0, smallPillWidth, pillHeight, true, ColorMap.LIGHT_GREEN, 0, 0, pillRounding);
	        Assets.addTexture(SMALL_GREEN_PILL, smallGreenPill.texture);
	        smallGreenPill = null;

	        var superSmallBluePill:Image = Make.shapeImage(null, 0, 0, superSmallPillWidth, pillHeight, true, ColorMap.CISCO_BLUE, 0, 0, pillRounding);
	        Assets.addTexture(SUPER_SMALL_CISCO_BLUE_PILL, superSmallBluePill.texture);
	        superSmallBluePill = null;

	        var bluePill:Image = Make.shapeImage(null, 0, 0, pillWidth, pillHeight, true, ColorMap.CISCO_BLUE, 0, 0, pillRounding);
	        Assets.addTexture(CISCO_BLUE_PILL, bluePill.texture);
	        bluePill = null;

	        var darkBluePill:Image = Make.shapeImage(null, 0, 0, pillWidth, pillHeight, true, ColorMap.BLUE, 0, 0, pillRounding);
	        Assets.addTexture(DARK_BLUE_PILL, darkBluePill.texture);
	        darkBluePill = null;

			// Circles

			var blueSplashCircle:Image = Make.shapeImage(null, 0, 0, radiusXLarge, radiusXLarge, true, ColorMap.BLUE, 0, 0, radiusXLarge);
			Assets.addTexture(BLUE_SPLASH_CIRCLE, blueSplashCircle.texture);
			blueSplashCircle = null;

			var orangeSplashCircle:Image = Make.shapeImage(null, 0, 0, radiusXLarge, radiusXLarge, true, ColorMap.ORANGE, 0, 0, radiusXLarge);
			Assets.addTexture(ORANGE_SPLASH_CIRCLE, orangeSplashCircle.texture);
			orangeSplashCircle = null;

			var orangeCircle:Image = Make.shapeImage(null, 0, 0, radiusMedium, radiusMedium, true, ColorMap.ORANGE, 0, 0, radiusMedium);
			Assets.addTexture(ORANGE_CIRCLE, orangeCircle.texture);
			orangeCircle = null;

			var grayCircle:Image = Make.shapeImage(null, 0, 0, radiusLarge, radiusLarge, true, ColorMap.LIGHT_GRAY, 0, 0, radiusLarge);
			Assets.addTexture(GRAY_CIRCLE, grayCircle.texture);
			grayCircle = null;

	        var lightGrayCircle:Image = Make.shapeImage(null, 0, 0, radiusLarge, radiusLarge, true, ColorMap.WHITE, 0, 0, radiusLarge);
	        Assets.addTexture(LIGHT_GRAY_CIRCLE, lightGrayCircle.texture);
	        lightGrayCircle = null;

			var darkGrayCircle:Image = Make.shapeImage(null, 0, 0, radiusLarge, radiusLarge, true, ColorMap.GRAY, 0, 0, radiusLarge);
			Assets.addTexture(DARK_GRAY_CIRCLE, darkGrayCircle.texture);
			darkGrayCircle = null;

	        var greenCircle:Image = Make.shapeImage(null, 0, 0, radiusLarge, radiusLarge, true, ColorMap.LIGHT_GREEN, 0, 0, radiusLarge);
	        Assets.addTexture(GREEN_CIRCLE, greenCircle.texture);
	        greenCircle = null;

	        var greenCircleSmall:Image = Make.shapeImage(null, 0, 0, radiusSmall, radiusSmall, true, ColorMap.LIGHT_GREEN, 0, 0, radiusSmall);
	        Assets.addTexture(GREEN_CIRCLE_SMALL, greenCircleSmall.texture);
	        greenCircleSmall = null;

			var greenCircleTiny:Image = Make.shapeImage(null, 0, 0, radiusTiny, radiusTiny, true, ColorMap.LIGHT_GREEN, 0, 0, radiusTiny);
			Assets.addTexture(GREEN_CIRCLE_TINY, greenCircleTiny.texture);
			greenCircleSmall = null;

			// Misc Textures

	        var checkEmpty:Image = Make.shapeImage(null, 0, 0, radiusSmall, radiusSmall, true, ColorMap.GRAY, 0, 0, radiusSmall);
	        Assets.addTexture(CHECK_EMPTY, checkEmpty.texture);
	        checkEmpty = null;

	        var checkFull:Image = Make.shapeImage(null, 0, 0, radiusSmall, radiusSmall, true, ColorMap.LIGHT_GREEN, 0, 0, radiusSmall);
	        Assets.addTexture(CHECK_FULL, checkFull.texture);
	        checkFull = null;

	        var blueHeader:Image = Make.shapeImage(null, 0, 0, Screen.width, 150, true, ColorMap.CISCO_BLUE);
	        Assets.addTexture(BLUE_HEADER, blueHeader.texture);
	        blueHeader = null;

			// Ranking Icon Backgrounds

			var smallMedal_1:Image = Make.shapeImage(null, 0, 0, radiusSmall, radiusSmall, true, ColorMap.LEVEL_1, 0, 0, radiusSmall);
			Assets.addTexture(LEVEL_1_MEDAL_SMALL, smallMedal_1.texture);
			smallMedal_1 = null;

			var largeMedal_1:Image = Make.shapeImage(null, 0, 0, radiusLarge, radiusLarge, true, ColorMap.LEVEL_1, 0, 0, radiusLarge);
			Assets.addTexture(LEVEL_1_MEDAL_LARGE, largeMedal_1.texture);
			largeMedal_1 = null;

	        var smallMedal_2:Image = Make.shapeImage(null, 0, 0, radiusSmall, radiusSmall, true, ColorMap.LEVEL_2, 0, 0, radiusSmall);
	        Assets.addTexture(LEVEL_2_MEDAL_SMALL, smallMedal_2.texture);
	        smallMedal_2 = null;

	        var largeMedal_2:Image = Make.shapeImage(null, 0, 0, radiusLarge, radiusLarge, true, ColorMap.LEVEL_2, 0, 0, radiusLarge);
	        Assets.addTexture(LEVEL_2_MEDAL_LARGE, largeMedal_2.texture);
	        largeMedal_2 = null;

			var smallMedal_3:Image = Make.shapeImage(null, 0, 0, radiusSmall, radiusSmall, true, ColorMap.LEVEL_3, 0, 0, radiusSmall);
			Assets.addTexture(LEVEL_3_MEDAL_SMALL, smallMedal_3.texture);
			smallMedal_3 = null;

			var largeMedal_3:Image = Make.shapeImage(null, 0, 0, radiusLarge, radiusLarge, true, ColorMap.LEVEL_3, 0, 0, radiusLarge);
			Assets.addTexture(LEVEL_3_MEDAL_LARGE, largeMedal_3.texture);
			largeMedal_3 = null;

	        // Checkboxes

	        var checkBoxBackground:Image = Make.shapeImage(null, 0, 0, 50, 50, true, ColorMap.WHITE, ColorMap.GRAY, 3);
	        Assets.addTexture(CHECK_BOX_BACKGROUND, checkBoxBackground.texture);
	        checkBoxBackground = null;

	        var checkBoxForeground:Image = Make.shapeImage(null, 0, 0, 28, 28, true, ColorMap.CISCO_BLUE);
	        Assets.addTexture(CHECK_BOX_FOREGROUND, checkBoxForeground.texture);
	        checkBoxForeground = null;


	        // Category circle correct/incorrect outlines
	        var questionCorrect:Image = Make.shapeImage(null, 0, 0, radiusMedium, radiusMedium, false, 0, ColorMap.LIGHT_GREEN, 8, radiusMedium);
	        Assets.addTexture(CATEGORY_OUTLINE_CORRECT, questionCorrect.texture);
	        questionCorrect = null;

	        var questionIncorrect:Image = Make.shapeImage(null, 0, 0, radiusMedium, radiusMedium, false, 0, ColorMap.RED, 5, radiusMedium);
	        Assets.addTexture(CATEGORY_OUTLINE_INCORRECT, questionIncorrect.texture);
	        questionIncorrect = null;

	        var buttonDown:Image = Make.shapeImage(null, 0, 0, 900, 150, false);
	        Assets.addTexture(BURGER_DOWN, buttonDown.texture);
	        buttonDown = null;
        }


		// Caches an image, returns the asset name.
		// onLoaded should take an assetName as a parameter in case the image is already cached.

		public static function createFromURL(parent:*, url:String, onLoaded:Function):String
		{
			var name:String;
			if (url)
			{
				var isJPG:Boolean = url.lastIndexOf(".jpg") > -1;
				name = url.substring(url.lastIndexOf("/") + 1, url.lastIndexOf(isJPG ? ".jpg" : ".png"));

				var complete:Function = function():void
				{
					if (parent) Make.image(parent, name);
					if (onLoaded) onLoaded(name);
				};

				if (cachedImageNames.indexOf(name) == -1)
				{
					cachedImageNames.push(name);

					Assets.queue(url);
					Assets.load(complete);
				}
				else complete();
			}

			return name;
		}
	}
}
