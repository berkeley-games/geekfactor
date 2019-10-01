/**
 * Created by wmaynard on 3/9/2016.
 */
package controls
{
	import architecture.Fonts;
	import architecture.game.Achievement;
	import architecture.game.ColorMap;
	import architecture.game.Question;
	import architecture.game.User;

	import com.greensock.TweenMax;

	import components.Timer;

	import starling.display.Button;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.VAlign;

	import ten90.device.Screen;
	import ten90.tools.Make;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	import tools.TriviaText;

	public class QuizAnswer extends DisplayObjectContainer
	{
		public static var questionField:TextField;
		public static var onClick:Function;
		public static var timer:Timer;
		public static var authorContainer:Sprite;

		private static var onNext:Function;
		public static var correctAnswer:QuizAnswer;
		private static var answers:Vector.<QuizAnswer> = new Vector.<QuizAnswer>();
		private static var gameOver:Function;
		private static var endGame:Boolean = false;

		public var field:TextField;

		private var incorrect:Quad;
		private var correct:Quad;
		private var button:Button;
		private var answer_text:String;
		private var prefix:String;
		private var percent:TextField;
		private var percentFill:Quad;

		public function QuizAnswer(parent:*, x:int, y:int, height:int)
		{
//			this.onNext = onNext;

			var padding:int = 25;
			var width:int = Screen.width / 2;
			field = TriviaText.create(this, {
				x: padding,
				y: 50,
				w: Screen.width / 2 - padding * 2,
				h: height - padding * 2,
				style: TriviaText.BLUE_SMALL_LEFT,
				valign: VAlign.TOP
			});

			button = Make.emptyButton(this, 0, 0, width, height);

			correct = Make.quad(this, 0, 0, width, height, ColorMap.LIGHT_GREEN);
			incorrect = Make.quad(this, 0, 0, width, height, ColorMap.RED);
			correct.alpha = incorrect.alpha = 0;

			correct.touchable = incorrect.touchable = field.touchable = false;

			for each (var q:Quad in [correct, incorrect])
				Quick.index(q, 0);

			enableClick();

			this.x = x;
			this.y = y;
			parent.addChild(this);
			prefix = String.fromCharCode(answers.length + 65) + ". ";
			answers.push(this);
		}

		protected function checkAnswer(userInput:Boolean = true):void
		{
			disableClicks();

			var isCorrect:Boolean = correctAnswer == this;

			if (userInput)
			{
				onClick(isCorrect);
				Question.current.selectedAnswer = answer_text;
			}

			field.color = ColorMap.WHITE;

			var bestStreakID:String = Achievement.SAVE_ACHIEVEMENT_QUESTIONS_IN_A_ROW;
			var streakID:String = "questionStreak" + User.current.id;
			var streak:int = Save.data(streakID);

			if (isCorrect)
			{
				if(userInput)
				{
					// Save the question streak if its higher than previous best
					Save.data(streakID, streak += 1);
					if(streak > Save.data(bestStreakID)) Save.data(bestStreakID, streak);

					// Increment the correct answers in specific category by 1
					var correctSaveID:String = "correctAnswersIn_" + Question.current.categoryID + User.current.id;
					var correctAnswers:int = Save.data(correctSaveID);
					Save.data(correctSaveID, correctAnswers + 1);

					// Save the lowest value from all of the categories
					var lowestCategory:int = int.MAX_VALUE;
					for(var i:int = 1; i < 7; i++)
					{
						var saveValue:int = Save.data("correctAnswersIn_" + i +  User.current.id);
						if(saveValue < lowestCategory) lowestCategory = saveValue;
					}

					Save.data(Achievement.SAVE_ACHIEVEMENT_QUESTIONS_IN_A_CATEGORY, lowestCategory);
				}

				TweenMax.to(correct, .5, {alpha: 1});
				Quick.call(1.5, next);
			}
			else
			{
				// Reset the correct answers streak to 0
				Save.data(streakID, 0);

				TweenMax.to(incorrect, .5, {alpha: 1});
				correctAnswer.checkAnswer(false);
			}
		}

		public static function eliminateTwo():void
		{
			var wrongAnswers:Array = [];
			for each(var a:QuizAnswer in answers)
				if (a != correctAnswer)
					wrongAnswers.push(a);

			var count:int = 2;
			while (count-- > 0)
			{
				var rand:int = Math.ceil(Math.random() * wrongAnswers.length) - 1;
				TweenMax.to(wrongAnswers[rand], 0.5, {alpha: 0.3});
				wrongAnswers[rand].touchable = false;
				wrongAnswers.removeAt(rand);
			}
		}

		protected function enableClick():void
		{
			touchable = true;
			Quick.click(button, checkAnswer);
		}

		protected function disableClick():void
		{
			Quick.removeClick(button);
		}

		public static function disableClicks():void
		{
			for each (var a:QuizAnswer in answers)
				a.disableClick();
		}

		private function next():void
		{
			if (onNext)
			{
				Quick.call(1, animateOut, 0, [onNext]);
				Quick.call(2.35, animateIn);
			}
			else
			{
				for each (var a:QuizAnswer in answers) a.disableClick();
				gameOver();
			}
		}

		protected function reset():void
		{
			if(percent)
			{
				removeChild(percent);
				removeChild(percentFill);
			}
			
			correct.alpha = incorrect.alpha = 0;
			field.color = ColorMap.BLUE;
			Quick.call(.5, enableClick);
		}

		// Static functions

		public function set text(text:String):void
		{
			answer_text = text;
			field.text = prefix + text;
			if (Question.current.checkAnswer(text)) correctAnswer = this;
		}
		
		public static function animateIn():void
		{
			TweenMax.to(timer.points, .5, {delay:.1, alpha: 1});
			TweenMax.to(timer.icon, .5, {delay:.135, alpha: 1});
			TweenMax.to(timer.scoreBarBG, .5, {delay:.175, alpha: .25});
			TweenMax.to(authorContainer, .5, {delay:.2, alpha: 1});
			TweenMax.to(questionField, .5, {delay:.3, alpha: 1});

			var delay:Number = .3;
			for each (var a:QuizAnswer in answers) TweenMax.to(a, .5, {alpha: 1, delay:delay+=.1});
		}

		protected static function animateOut(onComplete:Function):void
		{
			if (endGame) return;
			
			TweenMax.to(timer.points, .5, {delay:.1, alpha: 0});
			TweenMax.to(timer.icon, .5, {delay:.135, alpha: 0});
			TweenMax.to(timer.scoreBarBG, .5, {delay:.175, alpha: 0});
			TweenMax.to(authorContainer, .5, {delay:.2, alpha: 0});
			TweenMax.to(questionField, .5, {delay:.3, alpha: 0});

			var delay:Number = .3;
			for each (var a:QuizAnswer in answers) TweenMax.to(a, .5, {alpha: 0, delay:delay+=.1, onComplete: a.reset});

			if (onComplete) Quick.call(1.25, onComplete);
		}

		public static function destroyAll():void
		{
			for each (var a:QuizAnswer in answers) a.dispose();
			while (answers.length) answers.removeAt(0);
			endGame = false;
		}

		public static function set onAnimateOut(f:Function):void
		{
			if (!onNext) onNext = f;
			else
			{
				endGame = true;
				onNext = null;
				gameOver = f;
			}
		}
		
		public static function showStats(data:XML):void
		{
			var answer1:QuizAnswer = answers[0];
			var answer2:QuizAnswer = answers[1];
			var answer3:QuizAnswer = answers[2];
			var answer4:QuizAnswer = answers[3];
			
			var percent1:Number = (data.QuestionStats[0].@Correct_Answer);
			var percent2:Number = (data.QuestionStats[0].@Wrong_Answer_1);
			var percent3:Number = (data.QuestionStats[0].@Wrong_Answer_2);
			var percent4:Number = (data.QuestionStats[0].@Wrong_Answer_3);
			
			answer1.fill(percent1);
			answer2.fill(percent2);
			answer3.fill(percent3);
			answer4.fill(percent4);
		}
		
		public function fill(percentage:Number):void
		{
			percent = Make.text(this, correct.width - 85, correct.height - 75, 75, 75, percentage + "%", Fonts.SYSTEM, 33, ColorMap.CISCO_BLUE, true, "right");
			
			percentFill = Make.quad(this, 1, 1, correct.width-2, correct.height-2, ColorMap.ICY_BLUE);
			Quick.pivot(percentFill, .5, 1, true);
			percentFill.parent.setChildIndex(percentFill, 0);
			
			TweenMax.fromTo(percentFill, .75, {scaleY:0}, {delay:.25, scaleY:percentage/100});
		}
	}
}
