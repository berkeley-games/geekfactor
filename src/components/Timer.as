/**
 * Created by georgeperry on 10/26/15.
 */
package components
{
	import architecture.AudioMap;
	import architecture.game.Achievement;
	import architecture.game.ColorMap;
	import architecture.game.Question;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;

	import components.*;

	import controls.CategoryIcon;

	import starling.display.Quad;
	import starling.text.TextField;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.SceneController;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	import tools.TriviaText;

	public class Timer extends Component
	{
		public var onTimeout:Function;
		public var points:TextField;
		public var scoreBarBG:Quad;
		public var scoreMask:Quad;
		public var icon:CategoryIcon;

		private var quiz:Quiz;
		private var scoreBar:Quad;
		private var multiplier:int;
		private var tween:TweenMax;
		private var versusProfiles:VersusProfiles;

		public override function init():void
		{
			var _w:int = Screen.stageWidth - _x * 2;

			var _h:int = 30;

			points = TriviaText.create(this, {
				x: Screen.left + 125,
				y: 25,
				text: "2000 pts",
				style: TriviaText.WHITE_XLARGE_LEFT
			});

			icon = new CategoryIcon(this, Screen.left + 35, 125, 1, 1, CategoryIcon.CATEGORY_CIRCLE, false, true);
			Quick.pivot(icon, 0, .5, true);
			//icon.scale = .75;

			var _x:int = Position.right(icon) - 15;
			_w = Screen.width - (icon.width * 2) + 25;
			scoreBarBG = Make.quad(this, _x, 0, _w, _h, ColorMap.LIGHT_GREEN, 0.25);
			scoreBarBG.y = icon.y - scoreBarBG.height / 2;

			scoreBar = Make.quad(this, scoreBarBG.x, scoreBarBG.y, scoreBarBG.width, scoreBarBG.height, ColorMap.LIGHT_GREEN);
			Quick.index(scoreBar, 0);
			Quick.index(scoreBarBG, 0);

			scoreMask = new Quad(scoreBar.width, scoreBar.height);
			scoreMask.x = scoreBar.x;
			scoreMask.y = scoreBar.y;
			scoreBar.mask = scoreMask;
			addChild(scoreMask);
		}

		public override function ready():void
		{
			quiz = parentScene.getComponent(Quiz);
			versusProfiles = parentScene.getComponent(VersusProfiles);

			TweenMax.from(scoreMask, 1, {delay:1.5, scaleX:0});

			this.y = parentScene.getComponent(Quiz).y;
		}

		private var questionID:int = -1;
		public function freeze():void
		{
			tween.pause();
			questionID = Question.current.id;
			Quick.call(3, function():void{
				if(Question.current.id == questionID)
					tween.resume();
			});
		}

		public function pause():void
		{
			tween.pause(0);
		}

		public function play():void
		{
			tween.play();
		}

		public function start():void
		{
			tween = TweenMax.to(scoreMask, 20, {scaleX:0, ease:Linear.easeNone, onUpdate:updateScore, onComplete:youSuck});
		}

		private function youSuck():void
		{
			var saveID:String = Achievement.SAVE_ACHIEVEMENT_QUESTIONS_IN_A_ROW;
			var streakID:String = "questionStreak" + User.current.id;
			var streak:int = Save.data(streakID);

			if(streak > Save.data(saveID)) Save.data(saveID, streak);
			Save.data(streakID, 0);


			onTimeout();
			SceneController.currentScene.touchable = false;
			Audio.play(AudioMap.INCORRECT);
			Question.current.answeredCorrectly = false;
			Quick.call(1, quiz.nextQuestion);
		}

		public function reset():void
		{
			TweenMax.killTweensOf(scoreMask);

			scoreBar.alpha = 1;
			scoreMask.scaleX = 1;
			scoreBar.color = scoreBarBG.color = ColorMap.LIGHT_GREEN;
			points.text = Question.current.maxScore + " pts";

			TweenMax.from(scoreBar, .5, {delay:.5, alpha:0})
		}

		public function complete(correct:Boolean):void
		{
			questionID = -1;
			TweenMax.killTweensOf(scoreMask);
			var score:int = parseInt(points.text);
			Question.current.possiblePoints = score;

			if(correct)
			{
				User.current.score = User.current.score ? User.current.score + score : score;
				TweenMax.to(scoreMask, scoreMask.scale * 1.75,
					{
						delay:.5,
						scaleX:0,
						ease:Linear.easeNone,
						onStart:Audio.play,
						onStartParams:[AudioMap.POINTS],
						onComplete:Audio.kill,
						onCompleteParams:[AudioMap.POINTS],
						onUpdate:function():void {
							var pts:int = Math.round(scoreMask.scaleX * (2000 * multiplier));
							if(pts > 0) points.text = String(pts) + " pts";
							else points.text = "";
						}
					});
			}
			else
			{
				points.text = "0 pts";
				scoreBar.color = scoreBarBG.color = ColorMap.RED;
				TweenMax.to(scoreBar, .5, {alpha:0});
			}

			versusProfiles.update();
		}

		public function setIcon(category:int, multiplier:int):void
		{
			this.multiplier = multiplier;
			icon.change(category, multiplier, true);
		}

		private function updateScore():void
		{
			checkColor();

			var pts:int = Math.round(scoreMask.scaleX * (2000 * multiplier));
			points.text = String(pts) + " pts";
		}

		private function checkColor():void
		{
			if(scoreMask.scaleX > .65)
			{
				if(scoreBar.color != ColorMap.LIGHT_GREEN)
					scoreBar.color = scoreBarBG.color = ColorMap.LIGHT_GREEN;
			}
			else if(scoreMask.scaleX > .34)
			{
				if(scoreBar.color != ColorMap.YELLOW)
					scoreBar.color = scoreBarBG.color = ColorMap.YELLOW;
			}
			else if(scoreBar.color != ColorMap.RED)
				scoreBar.color = scoreBarBG.color = ColorMap.RED;
		}
	}
}
