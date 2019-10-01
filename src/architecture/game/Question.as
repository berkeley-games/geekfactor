/**
 * Created by wmaynard on 3/7/2016.
 */
package architecture.game {
	import architecture.Database;
	import architecture.ImageMap;

	public class Question extends XMLClass
	{
		private static const QUESTION_ID:String = "Question_ID";
		private static const MULTIPLIER:String = "Multiplier";
		private static const QUESTION_NO:String = "Question_No";
		private static const CATEGORY_ID:String = "Category_ID";
		private static const QUESTION_TEXT:String = "Question";
		private static const CORRECT_ANSWER:String = "Correct_Answer";
		private static const WRONG_ANSWER_1:String = "Wrong_Answer_1";
		private static const WRONG_ANSWER_2:String = "Wrong_Answer_2";
		private static const WRONG_ANSWER_3:String = "Wrong_Answer_3";
		private static const UPLOADED_BY:String = "UploadedBy";
		private static const QUESTION_ORDER:String = "QuestionOrder";
		private static const LEVEL:String = "Difficulty";

		private static const BASE_MAX_SCORE:int = 2000;

		public var id:int;
		public var multiplier:int;
		public var numberInSet:int;
		public var categoryID:int;
		public var categoryName:String;
		public var text:String;
		public var correctAnswer:String;
		public var incorrectAnswers:Array;
		public var difficulty:int;

		private var points:int;
		public var answeredCorrectly:Boolean;
		public var selectedAnswer:String;
		public var possiblePoints:int;
		public var author:User;
		public var authorID:int;

		public var questionOrder:String;
		public var shuffle:Boolean;

		public static var current:Question;

	    public function Question(xmlChild:XML)
	    {
		    super(xmlChild);

		    id = parseInt(att(QUESTION_ID));
		    multiplier = parseInt(att(MULTIPLIER));
		    numberInSet = parseInt(att(QUESTION_NO));
		    categoryID = parseInt(att(CATEGORY_ID));
		    categoryName = ImageMap.getCategoryName(categoryID);
		    text = att(QUESTION_TEXT);
		    correctAnswer = att(CORRECT_ANSWER);
		    incorrectAnswers = [att(WRONG_ANSWER_1), att(WRONG_ANSWER_2), att(WRONG_ANSWER_3)];
		    difficulty = parseInt(att(LEVEL));
			questionOrder = att(QUESTION_ORDER);
			authorID = parseInt(att(UPLOADED_BY));
			shuffle = questionOrder == null;

//		    trace(authorID);

			if (authorID)
				author = new User(xml);
	    }

		// Returns answer choices, randomizing them if no strict order is specified.
		public function getAnswers():Array
		{
			var output:Array = [];

			if (!shuffle) {
				var tempOrder:String = questionOrder;
				var order:Array = tempOrder.split(',');
				while (order.length) {
					switch (order.pop()) {
						case "W1":
							output.insertAt(0, incorrectAnswers[0]);
							break;
						case "W2":
							output.insertAt(0, incorrectAnswers[1]);
							break;
						case "W3":
							output.insertAt(0, incorrectAnswers[2]);
							break;
						case "C":
							output.insertAt(0, correctAnswer);
							break;
					}
				}
			}
			else
			{
				output.push(correctAnswer);
				for each (var i:String in incorrectAnswers)
					output.push(i);

				for (var j:int = 0; j < 100; j++)
					try
					{
						var a:int = Math.random() * 4;
						var b:int = Math.random() * 4;
						var temp:String = output[a];
						output[a] = output[b];
						output[b] = temp;
					}
					catch (e:*){}
			}
			return output;
		}

		public function getDBFieldForAnswer():String
		{
			switch (selectedAnswer)
			{
				case correctAnswer:
					return CORRECT_ANSWER;
				case incorrectAnswers[0]:
					return WRONG_ANSWER_1;
				case incorrectAnswers[1]:
					return WRONG_ANSWER_2;
				case incorrectAnswers[2]:
					return WRONG_ANSWER_3;
				default:
					return null;
			}
		}

		// Used to provide stats to the DB for our "ask the audience" powerup.
		public function getStatIndex():int
		{
			switch (selectedAnswer)
			{
				case correctAnswer:
					return 0;
				case incorrectAnswers[0]:
					return 1;
				case incorrectAnswers[1]:
					return 2;
				case incorrectAnswers[2]:
					return 3;
				default:
					return -1;
			}
		}

		// If correct, attributes the earned score to the question and sends an update to the
		// database so that other players can see the user's score.
		public function answer(correct:Boolean):void
		{
			answeredCorrectly = correct;
			if (correct)
				points = possiblePoints;
			Database.updateScore(Room.current.ID, User.current.id, User.current.score, points);
		}

		// Returns true if the text matches the correct answer.
		// Used to determine whether or not a QuizAnswer is the right one.
		// Do not use when user selects an answer.
		public function checkAnswer(answer:String):Boolean
		{
			return answer == correctAnswer;
		}

		public function get score():int
		{
			return points;
		}

		public function get maxScore():int
		{
			return BASE_MAX_SCORE * multiplier;
		}

		public static function upload(questionText:String, correctAnswer:String, wrong1:String, wrong2:String, wrong3:String, categoryID:int, level:int, order:String, onComplete:Function):void
		{
			Database.uploadQuestion(User.current.id, questionText, correctAnswer, wrong1, wrong2, wrong3, categoryID, level, order, onComplete);
		}
	}
}