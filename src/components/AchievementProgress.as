/**
 * Created by George on 9/26/2016.
 */
package components
{
	import architecture.Fonts;
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.game.ColorMap;

	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.tools.Make;
	import ten90.tools.Position;

	public class AchievementProgress extends Sprite
	{
		private var imageID:String;
		private var level:int;
		private var reward:String;
		private var title:String;
		private var subtitle:String;
		private var progress:String;
		private var threshold:String;
		private var isLast:Boolean;

		private var icon:Image;
		private var progressBG:Quad;
		private var progressFG:Quad;
		private var titleField:TextField;
		private var subtitleField:TextField;
		private var progressField:TextField;
//		private var rewardSubtitle:TextField;
		private var coinImage:Image;
		private var rewardAmount:TextField;
		private var star1:Image;
		private var star2:Image;
		private var star3:Image;

		/**
		 *
		 * @param imageID
		 * @param level
		 * @param reward
		 * @param title
		 * @param subtitle
		 * @param progress
		 * @param threshold
		 * @param isLast
		 */

		public function AchievementProgress(imageID:String, level:int, reward:String, title:String, subtitle:String, progress:String, threshold:String, isLast:Boolean):void
		{
			touchable = false;

			this.imageID = imageID;
			this.level = level;
			this.reward = reward;
			this.title = title;
			this.subtitle = subtitle;
			this.progress = progress;
			this.threshold = threshold;
			this.isLast = isLast;

			if(stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void
		{
			if(e) removeEventListener(Event.ADDED_TO_STAGE, init);

			icon = Make.image(this, imageID + getIconSuffixFromLevel(level));
			Position.left(icon, 25);

			star1 = Make.image(this, getStarImageIDForLevel(1), 0, 25);
			star2 = Make.image(this, getStarImageIDForLevel(2), 0, 25);
			star3 = Make.image(this, getStarImageIDForLevel(3), 0, 25);
			Position.left(star1, Position.right(icon) + 50);
			Position.left(star2, Position.right(star1) + 50);
			Position.left(star3, Position.right(star2) + 50);

//			rewardSubtitle = Make.text(this, 0, 0, 200, 65, "Reward", Fonts.SYSTEM, 30, ColorMap.BLACK, false, "right");
//			Position.top(rewardSubtitle, Position.bottom(star3) + 15);
//			Position.right(rewardSubtitle, Position.right(star3));

			coinImage = Make.image(this, ImageMap.IMG_COIN);
			Position.right(coinImage, Position.right(star3));
//			Position.top(coinImage, Position.bottom(rewardSubtitle) + 15);
//			Position.right(coinImage, Position.right(rewardSubtitle));

			rewardAmount = Make.text(this, 0, 0, 500, coinImage.height, reward, Fonts.SYSTEM, 50, ColorMap.BLACK, false, "right", "center");
			Position.top(rewardAmount, Position.top(coinImage));
			Position.right(rewardAmount, Position.left(coinImage) - 15);

			var progressPadding:int = 150;

			titleField = Make.text(this, 0, 0, Screen.width - Position.right(star3) - progressPadding/2, 100, title, Fonts.SYSTEM, 40, ColorMap.BLACK, true, "center");
			Position.top(titleField, Position.top(icon) - 15);
			Position.left(titleField, Position.right(star3) + progressPadding/4);

			var subtitleFieldFontSize:int = subtitle.length > 45 ? 26 : 32;

			subtitleField = Make.text(this, 0, 0, Screen.width - Position.right(star3) - progressPadding, 100, subtitle, Fonts.SYSTEM, subtitleFieldFontSize, ColorMap.BLACK, false, "center", "top");
			Position.top(subtitleField, Position.bottom(titleField) - 10);
			Position.left(subtitleField, Position.right(star3) + progressPadding/2);

			progressBG = Make.quad(this, 0, 0, subtitleField.width, 30, ColorMap.GRAY);
			Position.top(progressBG, Position.bottom(subtitleField));
			Position.left(progressBG, Position.left(subtitleField));

			var progressFGScaleX:Number = (threshold != "Complete!")
					? Math.min(1, int(progress) / int(threshold))
					: 1;

			progressFG = Make.quad(this, 0, 0, progressBG.width, progressBG.height, ColorMap.GREEN);
			progressFG.scaleX = progressFGScaleX;
			progressFG.x = progressBG.x;
			progressFG.y = progressBG.y;

			var progressFieldText:String = (threshold != "Complete!")
					? progress + " / " + threshold
					: threshold;

			progressField = Make.text(this, 0, 0, subtitleField.width, 75, progressFieldText, Fonts.SYSTEM, 30, ColorMap.BLACK, true, "center");
			Position.top(progressField, Position.bottom(progressBG) + 15);
			Position.left(progressField, Position.left(subtitleField));


			Position.centerY(coinImage, Position.centerY(progressBG));
			Position.top(rewardAmount, Position.top(coinImage));


			if(!isLast) Make.quad(this, 25, Position.bottom(progressField) + 30, Screen.width-50, Skins.dividerStroke, ColorMap.GRAY).alpha = .5;

			flatten();
		}

		private function getStarImageIDForLevel(level:int):String
		{
			return this.level >= level ? ImageMap.ACH_STAR_ON : ImageMap.ACH_STAR_OFF
		}

		private function getIconSuffixFromLevel(level:int):String
		{
			return level > 0 ? "on" : "off";
		}
	}
}
