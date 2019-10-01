/**
 * Created by georgeperry on 10/26/15.
 */
package components
{
	import architecture.AudioMap;
	import architecture.Database;
	import architecture.Fonts;
	import architecture.game.ColorMap;
	import architecture.game.Question;
	import architecture.game.Room;
	import architecture.game.User;

	import com.greensock.TweenMax;

	import components.Timer;
	import components.Powerups;
	import components.Categories;

	import controls.ProfilePhoto;
	import controls.QuizAnswer;

	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;

	import ten90.base.Application;
	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.SceneController;
	import ten90.tools.Make;
	import ten90.tools.Position;

	import tools.TriviaText;

	public class Quiz extends Component
	{
		public var onGameOver:Function;

		// Other components
		private var categories:Categories;
		private var profile:ProfilePhoto;
		private var timer:Timer;
		private var powerups:Powerups;

		private var questionBG:Quad;
		private var question:TextField;

		private var a1:QuizAnswer;
		private var a2:QuizAnswer;
		private var a3:QuizAnswer;
		private var a4:QuizAnswer;

		private var author:ProfilePhoto;
		private var authorName:TextField;
		private var authorLabel:TextField;
		private var authorContainer:Sprite;
		private var statContainer:Sprite;
		
		private var questionNum:int = 0;

		public override function init():void
		{
			QuizAnswer.destroyAll();
		}

		public override function ready():void
		{
			User.current.score = 0;
			
			statContainer = new Sprite();
			
			categories = parentScene.getComponent(Categories);
			timer = parentScene.getComponent(Timer);

			questionBG = Make.quad(this, 0, 0, Screen.width, 565, ColorMap.QUIZ_BLUE);

			var textPadding:int = 25;

			question = TriviaText.create(this, {
				x: textPadding,
				w: questionBG.width - (textPadding * 2),
				y: Position.bottom(timer) + 45,
				h: 260,
				style: TriviaText.WHITE_MEDIUM_LEFT,
				valign:"top"
			});

			powerups = parentScene.getComponent(Powerups);
			powerups.x = Screen.right - powerups.width - 95;
			powerups.y = 1155;

			categories.show(true, false);

			timer.onTimeout = function():void{
				categories.setStatus(questionNum, false);
			};

			authorContainer = new Sprite();
			addChild(authorContainer);

			this.x = Screen.left;
			this.y = Screen.stageHeight - this.height - 750;

			TweenMax.from(question, .5, {delay:1.1, alpha:0});

			powerups._5050_click = _5050_click;
			powerups.freeze_click = freeze_click;
			powerups.audiences_click = audience_click;
			
			initAnswers();
		}

		public function setProfile(profile:ProfilePhoto):void
		{
			this.profile = profile;
		}

		public function _5050_click():void
		{
			Audio.play(AudioMap.POWERUP_5050);
			if (User.current.has5050s()) QuizAnswer.eliminateTwo();
		}

		public function freeze_click():void
		{
			Audio.play(AudioMap.POWERUP_FREEZE);
			if (User.current.hasFreezes()) timer.freeze();
		}
		
		public function audience_click():void
		{
//			Audio.play(AudioMap.POWERUP_FREEZE);
			if (User.current.hasAudiences())
			{
				//showStats();
				Database.consumeAudience(QuizAnswer.showStats);
			}
		}
		
		public function initAnswers():void
		{
			var startY:int = questionBG.y + questionBG.height;
			var heightAvailable:int = Screen.stageHeight - startY - this.y;

			var h:int = heightAvailable / 2;
			var x1:int = Screen.stageLeft;
			var x2:int = Screen.width / 2;
			var y1:int = startY;
			var y2:int = y1 + h;

			QuizAnswer.questionField = question;
			QuizAnswer.timer = timer;
			QuizAnswer.authorContainer = authorContainer;
			QuizAnswer.onClick = function(correct:Boolean):void
			{
				SceneController.currentScene.touchable = false;
				Audio.play(correct ? AudioMap.CORRECT : AudioMap.INCORRECT);
				timer.complete(correct);
				Question.current.answer(correct);
				if(profile) profile.add(Question.current.score, timer.scoreMask.scaleX * 1.75);
				categories.setStatus(questionNum, correct);
			};

			var vertiquad:Quad = Make.quad(this, x2, y1, 5, heightAvailable, ColorMap.LIGHT_GRAY, 0.5);
			var horizquad:Quad = Make.quad(this, x1, y2, Screen.width, 5, ColorMap.LIGHT_GRAY, 0.5);
			vertiquad.x -= vertiquad.width / 2;
			horizquad.y -= horizquad.height / 2;

			QuizAnswer.onAnimateOut = nextQuestion;
			a1 = new QuizAnswer(this, x1, y1, h);
			a2 = new QuizAnswer(this, x2, y1, h);
			a3 = new QuizAnswer(this, x1, y2, h);
			a4 = new QuizAnswer(this, x2, y2, h);

			TweenMax.allFrom([a1, a2, a3, a4], 1, {delay:1.1, alpha:0}, .25);
		}

		public function nextQuestion():void
		{
			statContainer.removeChildren(0, statContainer.numChildren - 1, true);
			powerups._5050_click = _5050_click;
			powerups.freeze_click = freeze_click;
			powerups.audiences_click = audience_click;
			
			if (questionNum == 10) return;

//			Audio.play(AudioMap.NEW_QUESTION);

			if(!Room.current) return;

			Question.current = Room.current.questions[questionNum++];
			if(Application.debug) trace("---------------ANSWER:", Question.current.correctAnswer);

			timer.reset();
			timer.setIcon(Question.current.categoryID, Question.current.multiplier);
			question.text = Question.current.text;

			question.fontSize = question.text.length > 200 ? 40 : 48;

			var answers:Array = Question.current.getAnswers();
			a1.text = answers[0];
			a2.text = answers[1];
			a3.text = answers[2];
			a4.text = answers[3];

			createAuthor();

			if (questionNum == 10)
			{
				QuizAnswer.onAnimateOut = gameOver;
				timer.onTimeout = gameOver;
			}

			SceneController.currentScene.touchable = false;
			TweenMax.delayedCall(1.25, function():void {
				timer.start();
				SceneController.currentScene.touchable = true;
			});

			// todo: remove
//			QuizAnswer.correctAnswer.field.text = "CORRECT";
		}

		private function createAuthor():void
		{
			if (author) authorContainer.removeChild(author);

			if (Question.current.author)
			{
				author = new ProfilePhoto(authorContainer, Question.current.author, 0, 0, ProfilePhoto.TINY);
				author.y = questionBG.y + 30;
				author.x = Screen.width - author.width - 80;
				author.setOptions(true, true, true, true, true);

				var labelWidth:int = 300;

				if(!authorLabel)
				{
					authorLabel = TriviaText.create(authorContainer, {
						y: 50,
						h: author.photoWidth / 3,
						w: labelWidth,
						x: int(author.x - labelWidth) - 5,
						text: "Submitted by:",
						style: TriviaText.WHITE_RIGHT,
						valign:"bottom"
					});
				}

				if (!authorName)
				{
					authorName = TriviaText.create(authorContainer, {
						y: int(authorLabel.y + authorLabel.height) - 10,
						h: author.photoWidth * .67,
						w: authorLabel.width,
						x: authorLabel.x,
						text: author.user.displayName,
						style: TriviaText.WHITE_SMALL_RIGHT,
						valign:"top"
					});
				}
				else authorName.text = author.user.displayName;

				trace("AUTHOR: ", author.user.displayName);
			}
		}

		private function gameOver():void
		{
			var score:int = 0;
			for each (var q:Question in Room.current.questions)
				score += q.score;

			onGameOver(score);
		}
	}
}