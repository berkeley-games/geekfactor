/**
 * Created by gperry on 3/3/2016.
 */
package components
{
	import architecture.AudioMap;
	import architecture.game.ColorMap;
	import architecture.game.PlayerLevelThreshold;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import controls.RankingIcon;

	import controls.TriviaButton;

	import flash.utils.getDefinitionByName;

	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.network.Browser;
	import ten90.scene.SceneController;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	import tools.Helper;

	import tools.TriviaText;

	public class RankDialog extends Component
	{
		private const WIDTH:int = 800;
		private const HEIGHT:int = 800;
		private const PADDING:int = 15;
		private const WIDTH_PADDING:int = WIDTH - PADDING * 2;
		private const HEIGHT_PADDING:int = HEIGHT - PADDING * 2;

		public var onDestroy:Function;

		private var bg:Quad;
		private var dialogContainer:Sprite;
		private var centerY:Number;

		private var youHaveGained:TextField;
		private var rankScoreChange:TextField;
		private var rankPoints:TextField;
		private var rankIcon:RankingIcon;
		private var rankBarBG:Quad;
		private var rankBarFG:Quad;
		private var pointsNeeded:TextField;
		private var tapToText:TextField;
		private var leftOverScale:Number;

		public static var current:RankDialog;

		public override function init():void
		{
			current = this;
			visible = false;

			dialogContainer = new Sprite();

			Make.shapeImage(dialogContainer, 0, 0, WIDTH, HEIGHT, true, ColorMap.WHITE, ColorMap.CISCO_BLUE, 9, 85);

			var scoreDelta:int = User.current.xp - User.current.previousXP;
			youHaveGained = TriviaText.create(dialogContainer, {
				text: (scoreDelta >= 0) ? "You have gained" : "You have lost",
				y:50,
				x:PADDING, w:WIDTH_PADDING, h:100,
				style: TriviaText.BLACK_MEDIUM,
				valign:"center"
			});

			rankScoreChange = TriviaText.create(dialogContainer, {
				text: (scoreDelta >= 0 ? "+" : "") + scoreDelta,
				y:Position.bottom(youHaveGained),
				x:PADDING, w:WIDTH_PADDING, h:140,
				style: TriviaText.BLACK_LARGE,
				size:140,
				bold:true,
				valign:"center"
			});

			rankPoints = TriviaText.create(dialogContainer, {
				text:"rank points",
				y:Position.bottom(rankScoreChange),
				x:PADDING, w:WIDTH_PADDING, h:75,
				style: TriviaText.BLACK_SMALL,
				valign:"center"
			});

			rankIcon = new RankingIcon(dialogContainer, 1, User.current.level-1);
			rankIcon.x = PADDING + 10;
			rankIcon.y = Position.bottom(rankPoints);

			rankBarBG = Make.quad(dialogContainer, Position.right(rankIcon) - 5, 0, 625, 30, ColorMap.ICY_BLUE);
			Position.centerY(rankBarBG, Position.centerY(rankIcon));

			rankBarFG = Make.quad(dialogContainer, rankBarBG.x, rankBarBG.y, rankBarBG.width, rankBarBG.height, ColorMap.CISCO_BLUE);

			pointsNeeded = TriviaText.create(dialogContainer, {
				text:"Only " + Helper.formatNumber(User.pointsToNextLevel) + " points\nuntil you level up!",
				y:Position.bottom(rankBarBG) + 50,
				x:PADDING, w:WIDTH_PADDING, h:200,
				style: TriviaText.BLACK_MEDIUM,
				valign:"center"
			});

			tapToText = TriviaText.create(dialogContainer, {
				text: "Tap to Continue",
				x:PADDING, w:WIDTH_PADDING, h:50,
				y:HEIGHT - PADDING - 50,
				style: TriviaText.BLACK_SMALL, size:35
			});

			Quick.index(rankIcon, dialogContainer.numChildren-1);
			addChild(dialogContainer);

			dialogContainer.x = (Screen.width - width) / 2;
			centerY = (Screen.height - height) / 2;

			x = Screen.left;
			y = Screen.top;
		}

		public function show():void
		{
			bg = Make.quad(this, 0, 0, Screen.width, Screen.height, 0, .75);
			Quick.index(bg, 0);
			parent.addChild(this);

			var scoreDelta:int;

			User.current.update(function():void
			{
				Audio.play(AudioMap.NOTIFY_UP);

				scoreDelta = User.current.xp - User.current.previousXP;
				rankScoreChange.text = (scoreDelta >= 0 ? "+" : "") + scoreDelta;
				pointsNeeded.text = "Only " + Helper.formatNumber(User.pointsToNextLevel) + " points\nuntil you level up!";
				rankBarFG.scaleX = beginFillScale;

				visible = true;

				var callback:Function = waitForClick;
				var endScale:Number = endFillScale;
				if(endScale >= 1)
				{
					leftOverScale = endScale - 1;
					endScale = 1;

					callback = doLevel;
				}

				TweenMax.from(bg, .75, {alpha:0});
				TweenMax.fromTo(dialogContainer, .75, {alpha:0, y:Screen.bottom}, {alpha:1, y:centerY, ease:Back.easeOut});
				TweenMax.to(rankBarFG, 1, {scaleX:endScale, delay:.5, onComplete:callback});
			});
		}

		private function doLevel():void
		{
			rankIcon.levelUp();
			TweenMax.fromTo(rankBarFG, 1, {scaleX:0}, {scaleX:leftOverScale, onComplete:waitForClick});
		}

		private function waitForClick():void
		{
			Quick.click(this, hide);
		}

		private function get beginFillScale():Number	// The amount of fill to start with based on previous XP.
		{
			return (User.current.previousXP - PlayerLevelThreshold.scoreForCurrent) / (PlayerLevelThreshold.scoreForNext - PlayerLevelThreshold.scoreForCurrent);
		}

		private function get endFillScale():Number		// The amount of fill to end with based current XP.
		{
			return (User.current.xp - PlayerLevelThreshold.scoreForCurrent) / (PlayerLevelThreshold.scoreForNext - PlayerLevelThreshold.scoreForCurrent);
		}

		public function hide():void
		{
			Quick.call(.2, Audio.play, 0, [AudioMap.NOTIFY_DOWN]);

			TweenMax.to(bg, .75, {delay:.4, alpha:0});
			TweenMax.to(dialogContainer, .65, {alpha:0, y:Screen.bottom, ease:Back.easeIn.config(.95), onComplete:kill});
		}

		private function kill():void
		{
			visible = false;
			bg.dispose();

			if (onDestroy) onDestroy();

			onDestroy = null;
		}
	}
}