/**
 * Created by wmaynard on 3/8/2016.
 */
package architecture.game {
	import architecture.Database;
	import architecture.Skins;

	import scenes.CreateGroup;

	import starling.events.Event;

	import ten90.utilities.Save;

	import tools.Encrypt;

	// A User object contains everything we'd want to know about someone playing
	// TriviaNet.  Profile photo, names, wins and losses, score, how many times they've
	// gone to the bathroom today....
	public class User extends XMLClass
	{
		public static var fromFacebook:Boolean = false;

		private static var cachedImageNames:Array = [];

		private static const LEVEL:String = "DifficultyLevel";
		private static const ICON_ID:String = "IconID";
		private static const USER_ID:String = "ID";
		private static const USERS_ID:String = "UsersID";
		private static const IS_ADMIN:String = "isAdmin";
		private static const COINS:String = "LifetimeScore";
		private static const LIFETIME_EARNINGS:String = "LifetimeEarnings";
		private static const RANKED_GROUP_LOSSES:String = "RankedGroupLosses";
		private static const RANKED_GROUP_WINS:String = "RankedGroupWins";
		private static const RANKED_WINS:String = "RankedWins";
		private static const RANKED_LOSSES:String = "RankedLosses";
		private static const LIFETIME_WINS:String = "LifetimeWins";
		private static const LIFETIME_LOSSES:String = "LifetimeLosses";
		private static const LIFETIME_GROUP_WINS:String = "LifetimeGroupWins";
		private static const LIFETIME_GROUP_LOSSES:String = "LifetimeGroupLosses";
		private static const TIES:String = "Ties";
		private static const EMAIL:String = "Username";
		private static const PHOTO_URL:String = "PhotoURL";
		private static const FIFTY_FIFTY:String = "FiftyFifty";
		private static const FREEZE:String = "Freeze";
		private static const ASK_AUDIENCE:String = "ShowStats";
		private static const OPEN_CHALLENGES:String = "OpenChallenges";
		private static const BEST_CATEGORY:String = "BestCategory";
		private static const ANSWERS:String = "Answers";
		private static const FIRST_NAME:String = "FirstName";
		private static const LAST_NAME:String = "LastName";
		private static const DISPLAY_NAME:String = "DisplayName";
		private static const PASSWORD:String = "Password";
		private static const LAST_LOGON:String = "LastLogon";
		private static const CURRENT_EVENT_NAME:String = "CurrentEventName";
		private static const CURRENT_EVENT_FRIENDLY_NAME:String = "CurrentEventFriendlyName";

		public var level:int;
		public var iconID:int;
		public var id:int;
		public var usersID:int;
		public var coins:int;

		public var rankedWins:int;
		public var rankedGroupWins:int;
		public var rankedLosses:int;
		public var rankedGroupLosses:int;
		public var lifetimeEarnings:int;
		public var lifetimeWins:int;
		public var lifetimeLosses:int;
		public var lifetimeGroupWins:int;
		public var lifetimeGroupLosses:int;
		public var ties:int;

		public var email:String;
		public var firstName:String;
		public var lastName:String;
		public var displayName:String;
		public var fullName:String;
		public var photo:String;
		public var photoFileName:String;
		public var answers:String;
		public var lastLogon:String;

		public var fiftyfifties:int;
		public var freezes:int;
		public var audiences:int;
		public var openChallenges:int;
		public var bestCategory:int;

		public var score:int;

		private var isAdmin:Boolean;
		public var photoLoaded:Boolean;
		public var password:String;

		public var currentEventName:String;
		public var currentEventFriendlyName:String;

		public static var current:User;

		// Leaderboard-specific fields
		private static const RANKED_SCORE:String = "VersusScore";
		private static const RANKED_GROUP_SCORE:String = "GroupScore";
		private static const RANK_VERSUS:String = "VersusRank";
		private static const RANK_GROUP:String = "GroupRank";
		private static const LIFETIME_RANKED_SCORE:String = "LifetimeVersusScore";
		private static const LIFETIME_GROUP_SCORE:String = "LifetimeGroupScore";
		private static const RANK_LIFETIME_VERSUS:String = "LifetimeVersusRank";
		private static const RANK_LIFETIME_GROUP:String = "LifetimeGroupRank";

		public var rankedScore:int;
		public var rankedGroupScore:int;
		public var versusRank:int;
		public var groupRank:int;
		public var lifetimeRankedScore:int;
		public var lifetimeGroupScore:int;
		public var lifetimeVersusRank:int;
		public var lifetimeGroupRank:int;

		// Friends List-specific fields
		public static const STATUS_REQUIRES_CONFIRMATION:String = "Requires Confirmation";
		public static const STATUS_AWAITING_CONFIRMATION:String = "Awaiting Confirmation";
		private static const STATUS:String = "Status";
		private static const FRIENDS_SINCE:String = "FriendsSince";

		public var isFriend:Boolean;
		public var friendStatus:String;
		public var friendsSince:String;

		private function get xpKey():String
		{
			return "User" + id + "XP";
		}

		public function get previousXP():int
		{
			if (!_previousXP)
				_previousXP = Save.data(xpKey);
			if (_previousXP >= 0)
				return _previousXP;
			return xp;
		}

		public var _previousXP:int;

		public function get xp():int
		{
			return lifetimeGroupScore + lifetimeRankedScore;
		}

		public function storeXP():void
		{
			_previousXP = xp;
			Save.data(xpKey, _previousXP);
		}

		private static const SAVED_LEVEL:String = "UserLevel";

		public function get totalGames():int
		{
			return lifetimeWins + lifetimeGroupWins + lifetimeLosses + lifetimeGroupLosses;
		}

		public static function get pointsToNextLevel():int
		{
			return pointsForNextLevel - (current.lifetimeGroupScore + current.lifetimeRankedScore);
		}

		public static function get pointsForNextLevel():int	// Note: will only return points for the current user.
		{
			return PlayerLevelThreshold.scoreForNext;
		}

		public var achievements:Vector.<Achievement> = new Vector.<Achievement>();

		public function User(xmlRoot:XML, onComplete:Function = null, setAsCurrent:Boolean = false)
		{
			super(xmlRoot);

			if (setAsCurrent)
				User.current = this;

			updateFromXML(null, onComplete);
		}

		public function update(onComplete:Function = null):void
		{
			Database.getUserData(id, function(data:XML):void{
				updateFromXML(data, onComplete);
			});
		}

		public function updateRank():void
		{
			if (xp > PlayerLevelThreshold.scoreForNext)
				level++;
		}

		public function updateFromXML(xml:XML, onComplete:Function = null):void
		{
			this.xml = xml ? xml : this.xml;

			password			= att(PASSWORD);
			firstName 			= att(FIRST_NAME);
			lastName 			= att(LAST_NAME);
			level 				= parseInt(att(LEVEL));
			iconID 				= parseInt(att(ICON_ID));
			id 					= parseInt(att(USER_ID));
			usersID             = parseInt(att(USERS_ID));
			coins 				= parseInt(att(COINS));
			lifetimeEarnings	= parseInt(att(LIFETIME_EARNINGS));
			rankedWins 			= parseInt(att(RANKED_WINS));
			rankedLosses 		= parseInt(att(RANKED_LOSSES));
			rankedGroupWins 	= parseInt(att(RANKED_GROUP_WINS));
			rankedGroupLosses 	= parseInt(att(RANKED_GROUP_LOSSES));
			ties 				= parseInt(att(TIES));
			email 				= att(EMAIL);
			displayName			= att(DISPLAY_NAME);

			if (displayName == null || displayName.length == 0 || displayName == "")
				displayName 	= firstName ? firstName
					: (email && email.indexOf('@') > 0) ? email.substring(0, email.indexOf('@'))
					: email;

			fullName 			= firstName && lastName ? firstName + ' ' + lastName : displayName;
			fiftyfifties 		= parseInt(att(FIFTY_FIFTY));
			freezes 			= parseInt(att(FREEZE));
			audiences           = parseInt(att(ASK_AUDIENCE));
			openChallenges 		= parseInt(att(OPEN_CHALLENGES));
			bestCategory 		= parseInt(att(BEST_CATEGORY));
			rankedScore 		= parseInt(att(RANKED_SCORE));
			rankedGroupScore 	= parseInt(att(RANKED_GROUP_SCORE));
			answers 			= att(ANSWERS);
			photo 				= att(PHOTO_URL);
			versusRank 			= parseInt(att(RANK_VERSUS));
			groupRank 			= parseInt(att(RANK_GROUP));
			friendStatus		= att(STATUS);
			isFriend			= friendStatus != STATUS_REQUIRES_CONFIRMATION && friendStatus != STATUS_AWAITING_CONFIRMATION;
			friendsSince		= att(FRIENDS_SINCE);

			lifetimeWins 		= parseInt(att(LIFETIME_WINS));
			lifetimeLosses 		= parseInt(att(LIFETIME_LOSSES));
			lifetimeGroupWins 	= parseInt(att(LIFETIME_GROUP_WINS));
			lifetimeGroupLosses = parseInt(att(LIFETIME_GROUP_LOSSES));

			lifetimeRankedScore = parseInt(att(LIFETIME_RANKED_SCORE));
			lifetimeGroupScore	= parseInt(att(LIFETIME_GROUP_SCORE));
			lifetimeVersusRank	= parseInt(att(RANK_LIFETIME_VERSUS));
			lifetimeGroupRank	= parseInt(att(RANK_LIFETIME_GROUP));

			lastLogon			= att(LAST_LOGON);

			photoFileName       = Skins.createFromURL(null, photo, onPhotoLoad);

			currentEventName     = att(CURRENT_EVENT_NAME);
			currentEventFriendlyName = att(CURRENT_EVENT_FRIENDLY_NAME);

			saveLevel();

			if (password)
			{
				Save.data("username", email);
				Save.data("password" + email, password);
				Save.flush();
			}

			if (onComplete) onComplete();
		}

		public function saveLevel():void
		{
			if (this != current) return;

			var savedLevel:int = Save.data(SAVED_LEVEL);
			savedLevel = savedLevel ? savedLevel : 1;

			if (savedLevel < level) onRankUp();
			else if (savedLevel > level) onRankDown();
			else return;

			Save.data(SAVED_LEVEL, level);
			Save.flush();
		}

		private function onRankUp():void
		{
			trace("Show something indicating a rank up.");
		}

		private function onRankDown():void
		{
			trace("Show something indicating a rank down.");
		}


		public function updateIcon(id:int):void
		{
			Database.changeIcon(User.current.id, id, null);
		}

		public static function createFromPlayer(player:Player, outputHandler:Function):void
		{
			Database.getUserData(player.id, function(data:XML):void{
				outputHandler(new User(data));
			});
		}

		public static function createFromID(userID:int, outputHandler:Function):void
		{
			Database.getUserData(userID, function(data:XML):void{
				outputHandler(new User(data));
			});
		}

		private function onPhotoLoad(assetName:String = null):void
		{
			photoLoaded = true;
			dispatchEvent(new Event("photoLoaded"));
		}

		public function has5050s():Boolean
		{
			Database.consume5050();
			return fiftyfifties;
		}

		public function hasFreezes():Boolean
		{
			Database.consumeFreeze();
			return freezes;
		}

		public function hasAudiences():Boolean
		{
			return audiences;
		}


		public function addFriend(friendID:int, onComplete:Function = null):void
		{
			Database.addFriend(id, friendID, onComplete);
		}

		public function rejectFriend(friendID:int, onComplete:Function = null):void
		{
			Database.rejectFriend(id, friendID, onComplete);
		}

		public function getFriends(onComplete:Function):void
		{
			Database.getFriendsList(id, onComplete);
		}

		public function getRecentOpponents(onComplete:Function):void
		{
			Database.getRecentUsers(id, onComplete);
		}

		public static function search(terms:String, userVectorHandler:Function):void
		{
			var userList:Vector.<User> = new Vector.<User>();
			var onData:Function = function(data:XML):void
			{
				for each (var x:XML in data.children())
					if (!isError(x))
						userList.push(new User(x));
				userVectorHandler(userList);
			};
			Database.searchForUser(terms, current.id, onData);
		}

		public function invite(userid:int):void
		{
			Database.invite(Room.current.id, id, userid);

			// TODO: This probably belongs somewhere else.
			// The goal is to maintain a list of players we've invited on the client side
			// rather than create a huge mess on the backend, and use that information
			// to prevent a user from being invited twice.
			CreateGroup.saveInvite(userid);
		}

		public function hasBeenInvited():Boolean
		{
			for each (var s:String in Save.data("invites").split('|'))
				if (parseInt(s) == id)
					return true;
			return false;
		}

		public static function get localStoredPassword():String
		{
			return Encrypt.password(Save.data("password" + Save.data("username")));
		}

		public function updateDisplayName(name:String, onComplete:Function):void
		{
			Database.updateDisplayName(id, localStoredPassword, name, function(data:XML):void{
				User.current.updateFromXML(data, onComplete);
			});
		}

		public function transferOut(transferHandler:Function):void
		{
			Database.transferProfile(email, password, null, function(data:XML):void{
				transferHandler(new ProfileTransfer(data));
			});
		}

		// achievementsHandler will accept a parameter of Vector.<Achievement>.
		// This parameter can be used to populate the future Achievements scene, or it can be done
		// using User.current.achievements.
		public function loadAchievements(achievementsHandler:Function = null):void
		{
			var thisref:User = this;
			while (achievements.length > 0)
				achievements.removeAt(0);
			Database.getUserAchievements(id, function(data:XML):void{
				for each (var x:XML in data.children())
					achievements.push(new Achievement(x, thisref));
				if (achievementsHandler)
					achievementsHandler(achievements);
			});
		}

		// Checks to see if an achievement with a given name has been exceeded.  Use Achievement constants for names.
		// Examples:
		//		User.current.checkAchievementForRankUp(Achievements.ACHIEVEMENT_GAMES_PLAYED, User.current.totalGames, onRankUp);
		//		User.current.checkAchievementForRankUp(Achievements.ACHIEVEMENT_POINTS_SCORED, User.lifetimeEarnings, onRankUp);
		// If the threshold is exceeded, the achievement will rank itself up.
		// onRankUp should accept a String as a parameter, which will be the message returned by the database.
		public function checkAchievementForRankUp(name:String, value:int, onRankUp:Function = null):Boolean
		{
			for each (var a:Achievement in achievements)
				if (a.name == name) return a.hasExceededThreshold(value, onRankUp);
			return false;
		}


		public function getProgressForAchievement(name:String):int
		{
			switch(name)
			{
				case Achievement.ACHIEVEMENT_CREATE_GAME: //
					return Save.data(Achievement.SAVE_ACHIEVEMENT_CREATE_GAME);
					break;

				case Achievement.ACHIEVEMENT_GAMES_WON: //
					return User.current.lifetimeWins;
					break;

				case Achievement.ACHIEVEMENT_MAKE_FRIENDS: //
					return Save.data(Achievement.SAVE_ACHIEVEMENT_MAKE_FRIENDS);
					break;

				case Achievement.ACHIEVEMENT_PLAYER_LEVEL: //
					return User.current.level;
					break;

				case Achievement.ACHIEVEMENT_QUESTIONS_IN_A_CATEGORY:
					return Save.data(Achievement.SAVE_ACHIEVEMENT_QUESTIONS_IN_A_CATEGORY);
					break;

				case Achievement.ACHIEVEMENT_QUESTIONS_IN_A_ROW: //
					return Save.data(Achievement.SAVE_ACHIEVEMENT_QUESTIONS_IN_A_ROW);
					break;

				case Achievement.ACHIEVEMENT_SUBMIT_A_QUESTION: //
					return Save.data(Achievement.SAVE_ACHIEVEMENT_SUBMIT_A_QUESTION);
					break;

				case Achievement.ACHIEVEMENT_WIN_A_CHALLENGE: //
					return Save.data(Achievement.SAVE_ACHIEVEMENT_WIN_A_CHALLENGE);
					break;
			}

			return 0;
		}
	}
}