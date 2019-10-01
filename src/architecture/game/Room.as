/**
 * Created by wmaynard on 3/7/2016.
 */
package architecture.game {
	import architecture.*;

	import com.greensock.TweenMax;

	import components.PlayerList;
	import components.VersusProfiles;

	import controls.CategoryPerformanceBar;

	import ten90.scene.SceneController;
	import ten90.tools.Quick;

	public class Room extends XMLClass
	{
		private static const QUESTION_SET_ID:String = "QuestionSetID";
		private static const CATEGORY_ID:String = "CategoryID";

		public static const MODE_SINGLE:String = "single";
		public static const MODE_VERSUS:String = "versus";
		public static const MODE_GROUP_RANKED:String  = "multi";
		public static const MODE_VERSUS_REMATCH:String = "rematch";
		public static const MODE_INVITE:String = "invite";
		public static const MODE_GROUP_PRIVATE:String = "group";

		public var ID:int;
		public var categoryID:int;
		public var questions:Vector.<Question> = new Vector.<Question>();
		public var players:Vector.<Player> = new Vector.<Player>();
		public var users:Vector.<User> = new Vector.<User>();
		private var isRanked:Boolean;
		public static var mode:String;

		public static var current:Room;
		public var localUserScore:int;
		public var topOpponent:User;
		public var seats:int;

		public static var selectedCategory:int;

		public function get id():int { return ID; }
	    public function Room(xmlRoot:XML, onComplete:Function = null)
	    {
		    super(xmlRoot);

			current = this;

		    ID = parseInt(att(QUESTION_SET_ID));
		    categoryID = parseInt(att(CATEGORY_ID));

			switch (mode)
			{
				case MODE_GROUP_RANKED:
				case MODE_VERSUS_REMATCH:
				case MODE_VERSUS:
					isRanked = categoryID <= 0;
					break;

				default:
					isRanked = false;
					break;
			}

			seats = xmlRoot.children().length();

		    for each (var x:XML in xml.children())
		        players.push(new Player(x));


			while (players.length && players[players.length - 1].id < 0)
				players.pop();

			loadQuestions(function():void{
				populateUsers(onComplete);
			});
	    }

		private function retryPlayerListUpdate(user:User):void
		{
			try
			{
				SceneController.currentScene.getComponent(PlayerList).add(user);
			}
			catch(e:*)
			{
				Quick.call(1, function():void{
					retryPlayerListUpdate(user);
				});
			}

		}

		private function createUsersFromIDs(ids:Array = null, onComplete:Function = null):void
		{
			var playerList:PlayerList;
			try
			{
				playerList = SceneController.currentScene.getComponent(PlayerList);
			}
			catch(e:*){}

			if(ids && ids.length)
			{
				User.createFromID(ids.pop(), function(user:User):void
				{
					users.push(user);
					createUsersFromIDs(ids, onComplete);
					if (playerList)
						playerList.add(user);
					else
						retryPlayerListUpdate(user);
				});
			}
			else if (onComplete) onComplete();
		}

		public function getUserByID(id:int):User
		{
			for each (var u:User in users)
				if (u.id == id) return u;

			return null;
		}

		public function getPlayerByID(id:int):Player
		{
			for each (var p:Player in players)
				if (p.id == id) return p;

			return null;
		}

		private function populateUsers(onComplete:Function):void
		{
			var ids:Array = [];
			var foo:Function = function():void
			{
				updateScores();
				getTopOpponent(onComplete);
			};

			if (players.length > users.length)
			{
				for each (var p:Player in players)
				{
					var found:Boolean = false;

					for each (var u:User in users)
						if (u.id == p.id)
							found = true;

					if (!found)
						ids.push(p.id);
				}
				createUsersFromIDs(ids, foo);
			}
			else foo();
		}

		private function updateScores():void
		{
			for each (var p:Player in players)
			{
				for each (var u:User in users)
				{
					if (u.id == p.id)
					{
						u.score = p.score;
						u.answers = p.answers;
					}
				}
			}
		}

		public function loadQuestions(onComplete:Function):void
		{
			// Load the questions
			Database.getQuestionSet(ID, function(data:XML):void
			{
				for each (var x:XML in data.children())
					questions.push(new Question(x));

				onComplete();
			});
		}

		public function uploadScore(score:int, onComplete:Function):void
		{
			localUserScore = score;
			var statsString:String = "";

			for each (var q:Question in questions)
				statsString += q.getStatIndex() + ",";

			statsString = statsString.substring(0, statsString.length - 1);

			Database.uploadStats(statsString, function():void
			{
				Database.completeQuestionSet(ID, User.current.id, score, isRanked, function(data:XML):void
				{
					User.current.updateFromXML(data);

					update(onComplete);
				});
			});
		}

		public function leaveAndUpload(score:int, onComplete:Function):void
		{
			localUserScore = score;
			var statsString:String = "";

			for each (var q:Question in questions)
				statsString += q.getStatIndex() + ",";

			statsString = statsString.substring(0, statsString.length - 1);

			onComplete = onComplete ? onComplete : function():void{};
			Database.exitApplication(User.current.id, id, score, isRanked, statsString, User.localStoredPassword, onComplete);
		}

		public function getTopOpponent(onComplete:Function = null):User
		{
			var top:User;

			for each (var u:User in Room.current.users)
			{
				if (u.id != User.current.id && (!top || u.score > top.score))
					top = u;
			}

			topOpponent = top ? top : VersusProfiles.oppUser;

			if (onComplete) onComplete();

			return top;
		}

		private var pinger:TweenMax;
		private var stop:Boolean = true;

		public function pingDB(repeat:Boolean = false, onUpdateComplete:Function = null):void
		{
			if(repeat) stop = false;

			if(stop) return;

			update(onUpdateComplete);

			pinger = TweenMax.delayedCall(5, pingDB, [!stop, onUpdateComplete]);
		}

		public function stopPing():void
		{
			stop = true;
			if (pinger) pinger.kill();
		}

		public function get correct():String
		{
			var count:int = 0;

			for each (var q:Question in questions)
				if (q.answeredCorrectly) count++;

			return "" + count + "/" + questions.length;
		}

		// onComplete: default behavior when DB calls are finished.
		public function update(onComplete:Function = null):void
		{
			Database.getRoomInfo(ID, function(data:XML):void{
				updateFromXML(data, onComplete);
			});
		}

		public function updateFromXML(data:XML, onComplete:Function = null):void
		{
			xml = data;

			seats = xml.children().length();

			players.length = 0;

			for each (var x:XML in xml.children())
				players.push(new Player(x));

			try
			{
//				for each(var p:Player in players)
//					if(p.id < 0) players.splice(players.indexOf(p), 1);

				while (players[players.length - 1].id < 0) players.pop();

				updateUserScores();

				populateUsers(onComplete);

				for(var i:int = 0; i < Room.current.users; i++)
				{
					if(Room.current.users.length > 1 && VersusProfiles.hasOpponent == false)
					{
						if(Room.current.users[i].id != -1 && Room.current.users[i].id != User.current.id)
							VersusProfiles.addOpponent(Room.current.users[i]);

						trace(Room.current.users[i].id);
					}
				}
			}
			catch(e:*)
			{
				trace("An error occurred updating the current room from xml: ", xml);
				if (onComplete) onComplete();
			}
		}

		private function updateUserScores():void
		{
			for each (var p:Player in players)
			{
				for each (var u:User in users)
				{
					if (p.id == u.id)
					{
						u.score = p.score;
						break;
					}
				}
			}
		}

		public function generatePerformanceBars(parent:*, barScaleY:Number = 1, startX:int = 0, y:int = 0, xSpacing:int = 0, enemySet:Boolean = false):Vector.<CategoryPerformanceBar>
		{
			var bars:Vector.<CategoryPerformanceBar> = new Vector.<CategoryPerformanceBar>();

			// Array of arrays in the following format: [catID, runningTotal, maxPossible]
			var temp:Array = [];
			for each (var q:Question in questions)
			{
				var cat:int = q.categoryID;
				var score:int = q.score;
				var maxScore:int = q.maxScore;

				var found:Boolean = false;
				for (var i:int = 0; i < temp.length; i++)
					if (temp[i][0] == cat)
					{
						found = true;
						temp[i][1] += score;
						temp[i][2] += maxScore;
					}

				// Add the category if it's not in our array already
				if (!found) temp.push([cat, score, maxScore]);
			}

			// Sort the categories by categoryID ascending.
			for (var a:int = 0; a < temp.length; a++)
				for (var b:int = 0; b < temp.length; b++)
					if (temp[a][0] < temp[b][0])
					{
						var c:Array = temp[a];
						temp[a] = temp[b];
						temp[b] = c;
					}

//			var enemyTemp:Array = [];
//			for each (var t:Array in temp)
//				enemyTemp.push([t[0], 0, 0]);

			// Create the performance bars.
			for each (var d:Array in temp)
			{
				var percent:Number = 100;
				percent *= d[1];
				percent /= d[2];
				bars.push(new CategoryPerformanceBar(parent, d[0], percent, barScaleY, enemySet));
			}

			for each (var bar:CategoryPerformanceBar in bars)
			{
				bar.y = y;
				bar.x = startX;
				startX += xSpacing;
			}

			return bars;
		}

		public static function join(playerCount:int = 2, categoryID:int = -1, createRoom:Boolean = true, onComplete:Function = null):void
		{
			if (Room.current && Room.current.pinger) Room.current.stopPing();

			var eventid:int = GFEvent.current ? GFEvent.current.id : 0;
			Database.joinRoom(User.current.id, playerCount, categoryID, eventid, createRoom, function(data:XML):void{
				new Room(data, onComplete);
			});
		}

		public static function practice(onComplete:Function = null, categoryID:int = -1):void
		{
			mode = MODE_SINGLE;
			join(1, categoryID, true, onComplete);
		}

		public static function joinRanked(onComplete:Function = null, eventID:int = -1):void
		{
			mode = MODE_VERSUS;
			join(2, -1, true, onComplete);
		}

		public static function joinRankedRematch(onComplete:Function = null):void
		{
			mode = MODE_VERSUS_REMATCH;
			var eventid:int = GFEvent.current ? GFEvent.current.id : 0;
			Database.joinRankedRematch(eventid, function(data:XML):void{
				new Room(data, onComplete);
			});
		}

		public static function joinRankedGroupMatch(onComplete:Function = null, eventID:int = -1):void
		{
			mode = MODE_GROUP_RANKED;
			join(10, -1, true, onComplete);
		}

		public static function joinGroupMatch(onComplete:Function = null):void
		{
			mode = MODE_INVITE;

			Database.joinPrivateRoom(User.current.id, Room.selectedCategory, function(data:XML):void{
				new Room(data, onComplete);
			}, GFEvent.current ? GFEvent.current.id : 0);
		}

		public function notifyOnComplete(onComplete:Function = null):void
		{
			Database.notifyOnGameComplete(User.current.id, User.localStoredPassword, id, onComplete);
		}

		public function close():void
		{
			Database.fillRoom(id, updateFromXML);
		}

		public function leave(onComplete:Function = null):void
		{
			Database.leaveRoom(User.current.id, id, isRanked, onComplete);
		}

		public function forfeit(onComplete:Function = null):void
		{
			uploadScore(0, onComplete);
		}

		public function isComplete():Boolean
		{
			for each (var p:Player in players)
				if (!p.isComplete) return false;

			return true;
		}

		public function fill(onComplete:Function = null):void
		{
			Database.fillRoom(id, onComplete);
		}

		public function isFull(onFull:Function = null):Boolean
		{
			var full:Boolean = users.length == seats;
			if (full && onFull) onFull();
			return full;
		}
	}
}