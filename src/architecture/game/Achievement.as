/**
 * Created by wmaynard on 8/18/2016.
 */
package architecture.game
{
	import architecture.Database;

	public class Achievement extends XMLClass
	{
		// These constants correspond to the Name field of the achievements on the database.
		// Update the backend first before modifying any of these.
		// These are used to find an achievement by its name in User.checkAchievementForRankUp.

		public static const ACHIEVEMENT_GAMES_WON:String = "Gladiator";
		public static const ACHIEVEMENT_QUESTIONS_IN_A_ROW:String = "Genius";
		public static const ACHIEVEMENT_PLAYER_LEVEL:String = "Knowledge is Power";
		public static const ACHIEVEMENT_QUESTIONS_IN_A_CATEGORY:String = "Well-rounded";
		public static const ACHIEVEMENT_MAKE_FRIENDS:String = "Outgoing";
		public static const ACHIEVEMENT_CREATE_GAME:String = "Host";
		public static const ACHIEVEMENT_WIN_A_CHALLENGE:String = "Challenger";
		public static const ACHIEVEMENT_SUBMIT_A_QUESTION:String = "Inquisitive";

		public static const ACHIEVEMENT_NAMES:Array =
		[
			ACHIEVEMENT_GAMES_WON,
			ACHIEVEMENT_QUESTIONS_IN_A_ROW,
			ACHIEVEMENT_PLAYER_LEVEL,
			ACHIEVEMENT_QUESTIONS_IN_A_CATEGORY,
			ACHIEVEMENT_MAKE_FRIENDS,
			ACHIEVEMENT_CREATE_GAME,
			ACHIEVEMENT_WIN_A_CHALLENGE,
			ACHIEVEMENT_SUBMIT_A_QUESTION
		];

		public static var SAVE_ACHIEVEMENT_GAMES_WON:String;
		public static var SAVE_ACHIEVEMENT_QUESTIONS_IN_A_ROW:String;
		public static var SAVE_ACHIEVEMENT_PLAYER_LEVEL:String;
		public static var SAVE_ACHIEVEMENT_QUESTIONS_IN_A_CATEGORY:String;
		public static var SAVE_ACHIEVEMENT_MAKE_FRIENDS:String;
		public static var SAVE_ACHIEVEMENT_CREATE_GAME:String;
		public static var SAVE_ACHIEVEMENT_WIN_A_CHALLENGE:String;
		public static var SAVE_ACHIEVEMENT_SUBMIT_A_QUESTION:String;

		private static const USER_ID:String = "UserID";
		private static const ID:String = "ID";
		private static const RANK:String = "Rank";
		private static const INSTRUCTIONS:String = "Instructions";
		private static const NAME:String = "Name";
		private static const THRESHOLDS:String = "RankThresholds";
		private static const COIN_REWARDS:String = "CoinRewards";

		public var userID:int;
		public var id:int;
		public var rank:int;
		public var instructions:String;
		public var name:String;
		public var thresholds:Vector.<int>;
		public var coinRewards:Vector.<int>;
		private var user:User;

		// To access achievements for the user, use User.current.achievements[foo].
		private static var list:Vector.<Achievement> = new Vector.<Achievement>();

		public function Achievement(child:XML, user:User = null)
		{
			super(child);

			id = parseInt(att(ID));
			userID = parseInt(att(USER_ID));
			rank = parseInt(att(RANK));
			name = att(NAME);
			instructions = att(INSTRUCTIONS);
			this.user = user;

			var string:String;

			thresholds = new Vector.<int>();
			var temp:String = att(THRESHOLDS);

			if (temp != null)
				for each (string in temp.split(','))
					thresholds.push(parseInt(string));

			coinRewards = new Vector.<int>();
			temp = att(COIN_REWARDS);

			if (temp != null)
				for each (string in temp.split(','))
					coinRewards.push(parseInt(string));
		}

		private function complete(userid:int, password:String, messageHandler:Function = null):void
		{
			if (!messageHandler) messageHandler = function(msg:String):void {
				trace("Achievement complete: " + msg);
			};

			Database.completeAchievement(userid, password, id, function(data:XML):void
			{
				var message:String;
				for each (var xml:XML in data.children())
					message = getAttribute(xml, "Message");

				messageHandler(message ? message : "");
			});

			rank++;
		}

		// Checks to see if a threshold has been exceeded.  If true, the backend also ranks up the user for this particular
		// Achievement.  To handle notifications to the user or animations when this happens, use the messageHandler parameter.
		// messageHandler should accept one String as a parameter, which is the message that will be returned by the
		// database, e.g. "You were awarded 10,000 coins for completing rank 3 of Don't Suck!"
		//
		// It is used primarily by the User class in checkAchievementForRankUp, which allows us to use a constant to
		// make sure we're not ranking up achievements by arbitrary indexes.
		//
		// Example usage: User.current.achievements[0].hasExceededThreshold(25);

		public function hasExceededThreshold(value:int, messageHandler:Function = null):Boolean
		{
			var output:Boolean = thresholds.length > rank && value >= thresholds[rank];
			if (output && user) complete(user.id, User.localStoredPassword, messageHandler);
			return output;
		}

		public static function setID(id:int):void
		{
			SAVE_ACHIEVEMENT_GAMES_WON = ACHIEVEMENT_GAMES_WON + id;
			SAVE_ACHIEVEMENT_QUESTIONS_IN_A_ROW = ACHIEVEMENT_QUESTIONS_IN_A_ROW + id;
			SAVE_ACHIEVEMENT_PLAYER_LEVEL = ACHIEVEMENT_PLAYER_LEVEL + id;
			SAVE_ACHIEVEMENT_QUESTIONS_IN_A_CATEGORY = ACHIEVEMENT_QUESTIONS_IN_A_CATEGORY + id;
			SAVE_ACHIEVEMENT_MAKE_FRIENDS = ACHIEVEMENT_MAKE_FRIENDS + id;
			SAVE_ACHIEVEMENT_CREATE_GAME = ACHIEVEMENT_CREATE_GAME + id;
			SAVE_ACHIEVEMENT_WIN_A_CHALLENGE = ACHIEVEMENT_WIN_A_CHALLENGE + id;
			SAVE_ACHIEVEMENT_SUBMIT_A_QUESTION = ACHIEVEMENT_SUBMIT_A_QUESTION + id;
		}
	}
}