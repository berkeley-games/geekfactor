/**
 * Created by wmaynard on 3/7/2016.
 */
package architecture.game
{
	// A Player object is the most basic form of information on an opponent.
	// It contains nothing but game state critical information.
	// It seemed like a great way to build it at first, but as development continued,
	// it's probably worth it to merge this with User.

	public class Player extends XMLClass
	{
		private static const PLAYER_ID:String = "UserID";
		private static const SCORE:String = "Score";
		private static const IS_COMPLETE:String = "isComplete";
		private static const ANSWERS:String = "Answers";

		private static const SCORES_BY_QUESTION:String = "Scores";

		public var id:int;
		public var score:int;
		public var scoresByQuestion:Array;
		public var isComplete:Boolean;
		public var answers:String;

	    public function Player(xmlChild:XML)
	    {
		    super(xmlChild);

			var idString:String = att(PLAYER_ID);

			if (idString == null) id = -1;
			else id = parseInt(idString);

		    score = parseInt(att(SCORE));
		    isComplete = att(IS_COMPLETE) == "1";
			answers = att(ANSWERS);

			var allScores:String = att(SCORES_BY_QUESTION);

			if (allScores)
			{
				allScores = allScores.substring(0, allScores.length - 1);	// Cut out trailing comma
				scoresByQuestion = allScores.split(',');
			}
	    }

		// Returns 0 if the player has not yet answered a question.
		// Returns the maximum possible score for a question if the player is a 1337 hax0r and has a higher recorded score than is possible.
		public function getScoreForQuestion(questionNo:int):int
		{
			var q:Question;

			try
			{
				q = Room.current.questions[questionNo - 1];
			}
			catch(e:*){}

			if (scoresByQuestion && scoresByQuestion.length >= questionNo)
			{
				var score:int = int(scoresByQuestion[questionNo - 1]);
				if (q && score > q.maxScore) return q.maxScore;
				else return score;
			}
			return 0;
		}

		// Allows client to see an opponent's score up to their current question,
		// so that if their opponent is further along in the game, the scores still
		// look like real-time data.
		public function getScoreUpToQuestion(questionNo:int):int
		{
			var sum:int = 0;

			for (var i:int = 1; i <= questionNo; i++)
				sum += getScoreForQuestion(i);

			return sum;
		}
	}
}