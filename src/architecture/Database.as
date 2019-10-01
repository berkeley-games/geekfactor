/**
 * Created by gperry on 9/23/2015.
 */
package architecture
{
	import architecture.game.Question;
	import architecture.game.Room;
	import architecture.game.User;

	import components.Powerups;

	import ten90.network.HTTP;

	import tools.Encrypt;
	import tools.Helper;

	public class Database
	{
//		private static const SERVER_URL:String 				    = "http://db.ten90studios.com/TriviaNet/Services/TriviaNet.svc/";
//		private static const SERVER_URL:String					= "https://geekfactor.cisco.com/Services/TriviaNet.svc/";
//		private static const SERVER_URL:String					= "http://geekfactor-int.cisco.com/Services/TriviaNet.svc/";		// Only use this for debugging.  This ignores the reverse proxy.  Requires Cisco connection to use.
		private static const SERVER_URL:String					= "https://geekfactor.us/Services/TriviaNet.svc/";

		/********************************************************** Web Service URLs **********************************************************/
		private static const ACCEPT_INVITE:String				= SERVER_URL + "AcceptInvite/?";
		private static const ADD_FRIEND:String					= SERVER_URL + "AddFriend/?";
		private static const APPROVE_QUESTION:String			= SERVER_URL + "ApproveQuestion/?";							// Admin Tool
		private static const BEGIN_PASSWORD_RESET:String		= SERVER_URL + "BeginPasswordReset/?";
		private static const CANCEL_TRANSFER:String				= SERVER_URL + "CancelTransfer/?";
		private static const CHANGE_ICON:String					= SERVER_URL + "ChangeIcon/?";								// Deprecated
		private static const CHANGE_PASSWORD:String 			= SERVER_URL + "ChangePassword/?";
		private static const CHECK_INVITES:String				= SERVER_URL + "CheckInvites/?";
		private static const COMPLETE_ACHIEVEMENT:String		= SERVER_URL + "CompleteAchievement/?";
		private static const COMPLETE_QUESTION_SET:String		= SERVER_URL + "CompleteQuestionSet/?";
		private static const CONSUME_FIFTY_FIFTY:String			= SERVER_URL + "ConsumeFiftyFifty/?";
		private static const CONSUME_FREEZE:String				= SERVER_URL + "ConsumeFreeze/?";
		private static const CONSUME_SHOW_STATS:String			= SERVER_URL + "ConsumeShowStats/?";						// Future release
		private static const CREATE_EVENT:String				= SERVER_URL + "CreateEvent/?";								// Future release
		private static const CREATE_PRIVATE_ROOM:String			= SERVER_URL + "CreatePrivateRoom/?";
		private static const DECLINE_REMATCH:String				= SERVER_URL + "DeclineRematch/?";
		private static const EXIT_APPLICATION:String			= SERVER_URL + "ExitApplication/?";
		private static const FILL_ROOM:String					= SERVER_URL + "FillRoom/?";
		private static const GET_ACHIEVEMENTS:String			= SERVER_URL + "GetAchievements/?";
		private static const GET_APP_VAR:String					= SERVER_URL + "GetAppVar/?";
		private static const GET_EVENT_DETAILS:String			= SERVER_URL + "GetEventDetails/?";
		private static const GET_DAY_EVENT_LEADERBOARD:String	= SERVER_URL + "GetEventLeaderboard/?";
		private static const GET_FRIENDS:String					= SERVER_URL + "GetFriends/?";
		private static const GET_LEADERBOARD:String				= SERVER_URL + "GetLeaderboard/?";
		private static const GET_LIFE_EVENT_LEADERBOARD:String	= SERVER_URL + "GetLifetimeEventLeaderboard/?";
		private static const GET_NOTIFICATIONS:String			= SERVER_URL + "CheckNotifications/?";
		private static const GET_OPEN_ROOMS:String				= SERVER_URL + "GetOpenRooms/";								// Future release
		private static const GET_PLAYER_LEVEL_THRESHOLDS:String = SERVER_URL + "GetPlayerLevelThresholds/";
		private static const GET_PREVIOUS_EVENTS:String			= SERVER_URL + "GetPreviouslyEnteredEvents";
		private static const GET_QUESTION_SET_BY_ID:String 		= SERVER_URL + "GetQuestionSetByID/?";						// Deprecated
		private static const GET_RANKING_REWARDS:String			= SERVER_URL + "GetRankingRewards/?";
		private static const GET_STANDALONE_EVENT_LEADER:String = SERVER_URL + "GetStandaloneEventLeaderboard/?";
		private static const GET_RECENT_USERS:String			= SERVER_URL + "GetRecentUsers/?";
		private static const GET_REMATCH:String					= SERVER_URL + "GetRematchStatus/?";
		private static const GET_ROOM_INFO:String               = SERVER_URL + "GetRoomInfo/?";
		private static const GET_STATS_BY_CATEGORY:String		= SERVER_URL + "GetCategoryStats/?";
		private static const GET_STORE_ITEMS:String				= SERVER_URL + "GetStoreItems/";
		private static const GET_TARGETED_AD:String				= SERVER_URL + "GetTargetedAd/?";
		private static const GET_TRANSFER_STATUS:String			= SERVER_URL + "GetTransferStatus/?";
		private static const GET_USER_ACHIEVEMENTS:String		= SERVER_URL + "GetUserAchievements/?";
		private static const GET_USER_DATA:String				= SERVER_URL + "GetUserData/?";
		private static const INVITE_PLAYER:String				= SERVER_URL + "InvitePlayer/?";
		private static const JOIN_EVENT:String					= SERVER_URL + "JoinEvent/?";
		private static const JOIN_RANKED_REMATCH:String			= SERVER_URL + "JoinRankedRematch/?";
		private static const JOIN_ROOM:String					= SERVER_URL + "JoinRoom/?";
		private static const LEAVE_ROOM:String					= SERVER_URL + "LeaveRoom/?";
		private static const LOGIN:String 						= SERVER_URL + "Login/?";
		private static const LOGIN_FB:String					= SERVER_URL + "FBLogin/?";
		private static const NOTIFY_ON_GAME_COMPLETE:String		= SERVER_URL + "NotifyOnGameComplete/?";
		private static const NOTIFY_USERS:String				= SERVER_URL + "NotifyUsers/?";
		private static const PURCHASE_REWARD:String				= SERVER_URL + "PurchaseReward/?";
		private static const REGISTER:String					= SERVER_URL + "Register/?";
		private static const REJECT_FRIEND:String				= SERVER_URL + "RejectFriend/?";
		private static const REJECT_INVITE:String				= SERVER_URL + "RejectInvite/?";
		private static const REQUEST_REMATCH:String				= SERVER_URL + "RequestRematch/?";
		private static const REVIEW_QUESTION:String				= SERVER_URL + "ReviewQuestion/?";							// Admin Tool
		private static const SEARCH_FOR_USER:String				= SERVER_URL + "SearchForUser/?";
		private static const SEND_QUESTION_STATS:String			= SERVER_URL + "SendQuestionStats/?";
		private static const TRANSFER_PROFILE:String			= SERVER_URL + "TransferProfile/?";
		private static const UPDATE_DISPLAY_NAME:String			= SERVER_URL + "ChangeDisplayName/?";
		private static const UPDATE_SCORE:String 				= SERVER_URL + "UpdateScore/?";
		private static const UPLOAD_QUESTION:String				= SERVER_URL + "UploadQuestion/?";

		/***************************************************** Calls to Web Services URLs *****************************************************/
		public static function acceptInvite(userid:int, inviteid:int, eventid:int, onRoomData:Function):void {
			HTTP.request(ACCEPT_INVITE, {userid: userid, inviteid: inviteid, eventid: eventid, token: User.localStoredPassword}, onRoomData);
		}
		public static function addFriend(userid:int, friendid:int, onComplete:Function = null):void {
			HTTP.request(ADD_FRIEND, {userid: userid, friendid: friendid, token: User.localStoredPassword}, runOnComplete(onComplete));
		}
		public static function beginPasswordReset(username:String, password:String, callback:Function):void{
			HTTP.request(BEGIN_PASSWORD_RESET, {username: username, password: Encrypt.password(password)}, callback);
		}
		public static function cancelTransfer(userID:int, token:String):void
		{
			HTTP.request(CANCEL_TRANSFER, {userid: userID, token: token}, function():void{});
		}
		public static function changeIcon(userID:int, iconID:int, callback:Function):void {
			HTTP.request(CHANGE_ICON, {userid:userID, iconid:iconID}, runOnComplete(callback));
		}
		public static function changePassword(password:String, callback:Function):void {
			HTTP.request(CHANGE_PASSWORD, {password: password}, callback);
		}
		public static function checkInvites(userid:int, onData:Function):void {
			HTTP.request(CHECK_INVITES, {userid: userid, token: User.localStoredPassword}, onData);
		}
		public static function checkNotifications(userid:int, onNotificationData:Function):void {
			HTTP.request(GET_NOTIFICATIONS, {userid: userid, token: User.localStoredPassword}, onNotificationData);
		}
		public static function completeAchievement(userid:int, password:String, achievementID:int, onComplete:Function):void {
			HTTP.request(COMPLETE_ACHIEVEMENT, {userid: userid, token: password, achievementid: achievementID}, onComplete ? onComplete: doNothing);
		}
		public static function completeQuestionSet(setID:int, userID:int, score:int, isRanked:Boolean, callback:Function):void {
			HTTP.request(COMPLETE_QUESTION_SET, {questionSet:setID, user:userID, isRanked: isRanked, score:score, token: User.localStoredPassword}, callback);
		}
		public static function consume5050(onComplete:Function = null):void {
			HTTP.request(CONSUME_FIFTY_FIFTY, {userid: User.current.id, token: User.localStoredPassword}, function(data:*):void{
				User.current.fiftyfifties--;
				Powerups.current.update();
				if (onComplete) onComplete();
			});
		}
		public static function consumeFreeze(onComplete:Function = null):void {
			HTTP.request(CONSUME_FREEZE, {userid: User.current.id, token: User.localStoredPassword}, function(data:*):void{
				User.current.freezes--;
				Powerups.current.update();
				if (onComplete) onComplete();
			});
		}
		public static function consumeAudience(onComplete:Function = null):void {
			HTTP.request(CONSUME_SHOW_STATS, {questionid:Question.current.id, userid: User.current.id, token: User.localStoredPassword}, function(data:*):void{
				User.current.audiences--;
				Powerups.current.update();
				if (onComplete) onComplete(data);
			});
		}
		public static function createEvent(userid:int, name:String, start:String, end:String, password:String, welcomeMessage:String, friendlyName:String, onComplete:Function):void {
			HTTP.request(CREATE_EVENT, {userid: userid, name: name, startTime: start, endTime: end, token: password, message: welcomeMessage, friendlyName: friendlyName}, onComplete);
		}
		public static function exitApplication(userid:int, roomid:int, score:int, isRanked:Boolean, stats:String, token:String, onComplete:Function):void
		{
			HTTP.request(EXIT_APPLICATION, {userid: userid, roomid: roomid, score: score, isRanked: isRanked, statString: stats, token: token}, onComplete);
		}
		public static function fbLogin(username:String, password:String, firstName:String, lastName:String, photoURL:String, fbToken:String, xmlHandler:Function):void {
			HTTP.request(LOGIN_FB, {username: username, password: password, firstName: firstName, lastName: lastName, photoURL: photoURL, fbToken: fbToken}, xmlHandler);
		}
		public static function fillRoom(roomID:int, onRoomData:Function = null):void {
			HTTP.request(FILL_ROOM, {questionSet: roomID}, function(data:XML):void{
				if (onRoomData) onRoomData(data);
			});
		}
		public static function getAchievements(onComplete:Function = null):void {
			HTTP.request(GET_ACHIEVEMENTS, {}, onComplete ? onComplete : doNothing);
		}
		public static function getAppVar(name:String, onStringValue:Function):void {
			HTTP.request(GET_APP_VAR, {name: name}, function(data:XML):void	{
				onStringValue(data.children()[0].attribute("Value"));
			});
		}
		public static function getEventDetails(id:int, onEventData:Function):void {
			HTTP.request(GET_EVENT_DETAILS, {eventid: id}, onEventData);
		}
		public static function getDailyEventLeaderboard(eventid:int, userid:int, headToHead:Boolean, onComplete:Function):void {
			HTTP.request(GET_DAY_EVENT_LEADERBOARD, {eventid: eventid, userid: userid, prioritizeGroup: !headToHead}, onComplete);
		}
		public static function getLifetimeEventLeaderboard(eventid:int, userid:int, headToHead:Boolean, onComplete:Function):void {
			HTTP.request(GET_LIFE_EVENT_LEADERBOARD, {eventid: eventid, userid: userid, prioritizeGroup: !headToHead}, onComplete);
		}
		public static function getStandaloneEventLeaderboard(eventname:String, lifetime:Boolean, onLeaderboardData:Function):void {
			HTTP.request(GET_STANDALONE_EVENT_LEADER, {eventname: eventname, lifetime: lifetime}, onLeaderboardData);
		}
		public static function getFriendsList(userid:int, onComplete:Function):void {
			HTTP.request(GET_FRIENDS, {userid:userid, token: User.localStoredPassword}, onComplete);
		}
		public static function getLeaderboard(userid:int, groupMode:Boolean, lifetimeMode:Boolean, onComplete:Function):void {
			HTTP.request(GET_LEADERBOARD, {userid: userid, prioritizeGroup: groupMode, prioritizeLifetime: lifetimeMode}, onComplete);
		}
		public static function getPlayerLevelThresholds(onData:Function):void{
			HTTP.request(GET_PLAYER_LEVEL_THRESHOLDS, {}, onData ? onData : function(data:XML):void{});
		}
		public static function getPreviouslyEnteredEvents(userid:int, currentEventID:int, onData:Function):void {
			HTTP.request(GET_PREVIOUS_EVENTS, {userid: userid, currentEventID: currentEventID}, onData);
		}
		public static function getRecentUsers(userid:int, onComplete:Function):void {
			HTTP.request(GET_RECENT_USERS, {userid: userid, token: User.localStoredPassword}, onComplete);
		}
		public static function getRematch(xmlHandler:Function):void {
			HTTP.request(GET_REMATCH, {roomid: Room.current.id}, xmlHandler);
		}
		public static function getQuestionSet(id:int, callback:Function):void {
			HTTP.request(GET_QUESTION_SET_BY_ID, {id:id}, callback);
		}
		public static function getRoomInfo(questionSet:int, callback:Function):void {
			HTTP.request(GET_ROOM_INFO, {questionset:questionSet}, callback);
		}
		public static function getStoreItems(onComplete:Function):void {
			HTTP.request(GET_STORE_ITEMS, {}, onComplete);
		}
		public static function getTargetedAd(userid:int, isBanner:Boolean, isTablet:Boolean, categoryID:*, isPriority:Boolean, onAdData:Function):void {
			HTTP.request(GET_TARGETED_AD, {userid: userid, isBanner: isBanner, isTablet: isTablet, categoryID: categoryID, priority: isPriority}, onAdData);
		}
		public static function getTransferStatus(id:int, userid:int, token:String, onData:Function):void{
			HTTP.request(GET_TRANSFER_STATUS, {transferid: id, userid: userid, token: token}, onData);
		}
		public static function getUserAchievements(userid:int, onComplete:Function = null):void {
			HTTP.request(GET_USER_ACHIEVEMENTS, {userid: userid}, onComplete ? onComplete : doNothing);
		}
		public static function getUserData(userID:int, callback:Function):void {
			HTTP.request(GET_USER_DATA, {userid:userID}, callback);
		}
		public static function invite(roomid:int, userid:int, playerid:int, onComplete:Function = null):void {
			HTTP.request(INVITE_PLAYER, {questionset: roomid, userid: userid, playerid: playerid, token: User.localStoredPassword}, runOnComplete(onComplete));
		}
		public static function joinEvent(userid:int, eventName:String, onEventData:Function):void {
			HTTP.request(JOIN_EVENT, {userid: userid, name: eventName, token: User.localStoredPassword}, onEventData);
		}
		public static function joinPrivateRoom(userid:int, categoryID:int, onRoomData:Function, eventid:int = -1):void {
			HTTP.request(CREATE_PRIVATE_ROOM, {userid: userid, categoryID: categoryID, numPlayers: 15, eventid: eventid, token: User.localStoredPassword}, onRoomData);
		}
		public static function joinRankedRematch(eventid:int, xmlHandler:Function):void {
			HTTP.request(JOIN_RANKED_REMATCH, {userid: User.current.id, roomid: Room.current.id, eventid: eventid, token: User.localStoredPassword}, xmlHandler);
		}
		public static function joinRoom(userID:int, maxPlayers:int, categoryID:int, eventid:int, createRoom:Boolean, callback:Function):void {
			HTTP.request(JOIN_ROOM, {userid:userID, numPlayers:maxPlayers, eventid:eventid, createRoom: createRoom ? 1 : 0, categoryID: categoryID, token: User.localStoredPassword}, callback ? callback : function(data:*):void{});
		}
		public static function leaveRoom(userid:int, roomid:int, isRanked:Boolean, onComplete:Function):void {
			HTTP.request(LEAVE_ROOM, {userid: userid, roomid: roomid, isRanked: isRanked, token: User.localStoredPassword}, runOnComplete(onComplete));
		}
		public static function login(username:String, password:String, callback:Function, onFailure:Function):void {
			password = Encrypt.password(password);
			HTTP.request(LOGIN, {username: username, password: password}, callback, onFailure);
		}
		public static function notifyOnGameComplete(userid:int, password:String, roomid:int, onComplete:Function = null):void{
			HTTP.request(NOTIFY_ON_GAME_COMPLETE, {userid: userid, token: password, roomid: roomid}, function():void{
				if (onComplete) onComplete();
			});
		}
		public static function notifyUsers(userid:int, password:String, message:String, eventid:int = -1, onComplete:Function = null):void
		{
			HTTP.request(NOTIFY_USERS, {userid: userid, token: password, message: message, eventid: eventid > 0 ? eventid : null}, function():void{
				if (onComplete) onComplete();
			});
		}
		public static function purchaseStoreItem(itemID:int, onUserData:Function):void {
			HTTP.request(PURCHASE_REWARD, {userid:User.current.id, rewardid:itemID, token: User.localStoredPassword}, onUserData);
		}

		public static function register(username:String, callback:Function):void {
			HTTP.request(REGISTER, {username:username}, callback);
		}
		public static function rejectFriend(userid:int, friendid:int, onComplete:Function = null):void {
			HTTP.request(REJECT_FRIEND, {userid: userid, friendid: friendid, token: User.localStoredPassword}, runOnComplete(onComplete));
		}
		public static function rejectInvite(inviteID:int, onComplete:Function = null):void {
			HTTP.request(REJECT_INVITE, {inviteID: inviteID}, onComplete ? onComplete : doNothing);
		}
		public static function requestRematch(accept:Boolean = true, onComplete:Function = null):void {
			HTTP.request(accept ? REQUEST_REMATCH : DECLINE_REMATCH, {userid: User.current.id, roomid: Room.current.id, token: User.localStoredPassword}, runOnComplete(onComplete));
		}
		public static function searchForUser(terms:String, userid:int, onUserData:Function):void {
			HTTP.request(SEARCH_FOR_USER, {username: terms, firstName: terms, lastName: terms, displayName: terms, userid: userid}, onUserData);
		}
		public static function transferProfile(username:String, token:String, code:String, onData:Function):void {
			HTTP.request(TRANSFER_PROFILE, {username: username, token: token, code: code}, onData);
		}
		public static function updateDisplayName(userid:int, password:String, name:String, onUserData:Function):void {
			HTTP.request(UPDATE_DISPLAY_NAME, {userid: userid, password: password, displayName: name}, function(data:XML):void{
				if (Helper.xmlHasError(data)) trace("Error updating display name.");
				else if (onUserData) onUserData(data);
			});
		}
		public static function updateScore(setID:int, userID:int, totalScore:int, questionPoints:int, onComplete:Function = null):void {
			HTTP.request(UPDATE_SCORE, {questionSet:setID, user:userID, score:totalScore, points: questionPoints, token: User.localStoredPassword}, runOnComplete(onComplete));
		}
		public static function uploadQuestion(userid:int, question:String, correct:String, wrong1:String, wrong2:String, wrong3:String, categoryID:int, level:int, order:String, onComplete:Function):void {
			HTTP.request(UPLOAD_QUESTION, {
				userid: userid,
				question: question,
				correctAnswer: correct,
				wrongAnswer1: wrong1,
				wrongAnswer2: wrong2,
				wrongAnswer3: wrong3,
				categoryID: categoryID,
				level: level,
				order: order,
				token: User.localStoredPassword
			}, runOnComplete(onComplete));
		}
		public static function uploadStats(statString:String, callback:Function = null):void {
			HTTP.request(SEND_QUESTION_STATS, {userid: User.current.id, questionSet: Room.current.id, answers: statString, token: User.localStoredPassword}, runOnComplete(callback));
		}



		/********************************************************** Helper Functions **********************************************************/

		private static function doNothing(data:XML):void {}

		private static function runOnComplete(onComplete:Function):Function{
			return function(data:XML = null):void{ if (onComplete) onComplete(); }
		}

		// Creates a SQL-friendly string representation of a Datetime.  SQL Server will cast this string into a Datetime, and if the string
		// is not formatted correctly, the cast will fail.
		public static function sqlDate(year:int = -1, month:int = -1, dayOfMonth:int = -1, hour:int = -1, minute:int = -1, second:int = -1, ms:int = -1):String
		{
			/* There was some confusion here around day versus date, so a comment should be left here in case it ever comes up again.

			 In AS3, a Date object has two fields: day and date.  Day returns 0-6 and date returns 1-31.
			 In C#, a DateTime object's equivalent fields are DayOfWeek and Day respectively.

			 It's important to remember that we need the AS3 date for this function. The day variable has been renamed
			 to dayOfMonth to avoid confusion.
			 */

			var now:Date = new Date();

			if (year <= 0) year = now.fullYear;
			if (month <= 0) month = now.month + 1;		// Date.month is zero-indexed
			if (dayOfMonth <= 0) dayOfMonth = now.date;
			if (minute < 0) minute = now.minutes;
			if (second < 0) second = now.seconds;
			if (ms < 0) ms = now.milliseconds;

			second += ms / 1000;
			minute += second / 60;
			hour += minute / 60;
			dayOfMonth += hour / 24;
			// TODO: dayOfMonth rollover
			year += month / 12;

			ms %= 1000;
			second %= 60;
			minute %= 60;
			hour %= 24;
			// TODO: dayOfMonth rollover
			month %= 12;

			if (dayOfMonth > 31)
				throw new Error("dayOfMonth has not yet been idiot-proofed.");

			// Converts an integer to a string and adds leading zeroes if necessary.
			var stringify:Function  = function(i:int, digits:int = 2):String
			{
				var output:String = "" + i;

				while (output.length < digits)
					output = '0' + output;

				if (output.length > digits)
					throw new Error("Field has too many digits: " + i);

				return output;
			};

			var output:String =
				"" + stringify(year, 4)
				+ '-' + stringify(month)
				+ '-' + stringify(dayOfMonth)
				+ ' ' + stringify(hour)
				+ ':' + stringify(minute)
				+ ':' + stringify(second)
				+ '.' + stringify(ms, 3);
			return output;
		}
	}
}