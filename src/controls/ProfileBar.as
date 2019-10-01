/**
 * Created by wmaynard on 3/29/2016.
 */
package controls
{
	import architecture.game.ColorMap;
	import architecture.game.Room;
	import architecture.game.User;

	import com.greensock.TweenMax;

	import flash.profiler.profile;

	import scenes.Leaderboards;

	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.VAlign;

	import ten90.device.Screen;
	import ten90.tools.Make;
	import ten90.tools.Position;

	import tools.Helper;
	import tools.TriviaText;

	public class ProfileBar extends DisplayObjectContainer
	{
		public static const TYPE_READY:String = "ready";
		public static const TYPE_INVITE:String = "invite";
		public static const TYPE_CHALLENGE:String = "challenge";
		public static const TYPE_LEADERBOARD:String = "leaderboard";

		public static const TYPE_SCORE:String = "score";
		public static const TYPE_OPEN_SEAT:String = "open_seat";
		public static const SORT_GAME_SCORE:String = "game_score";
		public static const SORT_RANKED_WINS:String = "ranked_wins";
		public static const SORT_RANKED_GROUP_WINS:String = "ranked_group_wins";

		public static const TYPE_FRIEND_WINS:String = "friend";
		public static const TYPE_ACCEPT_REJECT_FRIEND:String = "add_friend";
		public static const TYPE_ADD_FRIEND_RECENT:String = "add_friend_recent";
		public static const TYPE_FRIEND_REQUEST_SENT:String = "friend_request_sent";

		public static const TYPE_GROUP_LEADERBOARD:String = "group_leaderboard";
		public static const TYPE_EVENT_LEADERBOARD:String = "event_leaderboard";

		public static const TYPE_LEADERBOARD_ALL_TIME:String = "leaderboard_alltime";
		public static const TYPE_GROUP_LEADERBOARD_ALL_TIME:String = "group_leaderboard_alltime";
		public static const TYPE_EVENT_LEADERBOARD_ALL_TIME:String = "event_leaderboard_alltime";

		public static var bars:Vector.<ProfileBar> = new Vector.<ProfileBar>();

		public var photo:ProfilePhoto;
		public var accept:Function;
		public var reject:Function;
		public var displayName:TextField;

		private var rightComponent:*;
		private var _user:User;
		private var _type:String;
		private var newY:int;
		private var rankText:TextField;
		private var thisref:ProfileBar;
		private var xOffset:int = 40;

		public function ProfileBar(parent:*, y:int, user:User, barType:String, accept:Function = null, reject:Function = null)
		{
			super();

			thisref = this;

			this._user = user;
			this._type = barType;

			photo = new ProfilePhoto(this, user, xOffset-5, 0, ProfilePhoto.SMALL, true);
			photo.setOptions(true, true, true, true, false);

			var name_x:int = photo.x + photo.photoWidth + 20;

			displayName = TriviaText.create(this, {
				x: name_x,
				h: this.height,
				text: user.displayName,
				style: TriviaText.TURQ_SMALL_LEFT
			});

			if(displayName.text.length > 12) displayName.fontSize *= .85;

			if (!accept) accept = function():void{trace("No action set for this profile bar.");};
			this.accept = accept;
			this.reject = reject;

			if (parent) parent.addChild(this);

			generateRightComponent(barType, accept);

			this.x = Screen.left;
			this.y = y;
		}

		public function set user(u:User):void
		{
			throw new Error("ProfileBar.user property is read-only.");
		}

		public function get user():User
		{
			return _user;
		}

		// TODO: Add type to mark for destruction, or destroy on changeType(null).
		public function changeType(newType:String, remove:Boolean = false):void
		{
			if (this._type == newType) return;

			var self:ProfileBar = this;

			TweenMax.to(this, 0.5, {alpha: 0, onComplete: function():void
			{
				var p:* = self.parent;
				var y:int = self.y;
				var u:User = self.user;
				var listIndex:int = bars.indexOf(self);

				// Remove this from parents and the static bars container
				if (listIndex > -1) bars.removeAt(listIndex);

				self.parent.removeChild(self);
				self.dispose();

				// If we want it gone, we're done
				if (remove) return;

				// Otherwise, re-create the bar.
				self = new ProfileBar(p, y, u, newType);
				if (listIndex > -1) bars.push(self);

				TweenMax.fromTo(self, 0.5, {alpha: 0}, {alpha: 1});
			}});
		}

		public function kill():void
		{
			changeType(null, true);
		}

		public function updateScore(score:int):void
		{
			if(rightComponent) Helper.updateTextField(rightComponent, Helper.formatNumber(score));
		}

		private function generateRightComponent(type:String, onClick:Function):void
		{
			switch(type)
			{
				case TYPE_READY:
					rightComponent = new Check(this, Screen.width - xOffset, 0);
					rightComponent.x -= rightComponent.width;
					rightComponent.visible = false;
					break;

				case TYPE_SCORE:
					rightComponent = TriviaText.create(this, {
						w: 500,
						x: Screen.width - 550,
						text: Helper.formatNumber(user.score),
						style: TriviaText.GREEN_MEDIUM_RIGHT
					});
					break;

				case TYPE_FRIEND_REQUEST_SENT:
					rightComponent = TriviaText.create(this, {
						w: 500,
						x:Screen.width-550,
						text: "Pending",
						style: TriviaText.BLACK_SMALL_RIGHT
					});
					break;

				case TYPE_ACCEPT_REJECT_FRIEND:
					accept = function():void{
						User.current.addFriend(user.id);
						changeType(TYPE_FRIEND_WINS);
					};
					reject = function():void{
						User.current.rejectFriend(user.id);
						kill();
					};

				// Deliberate fall-through to TYPE_CHALLENGE

				case TYPE_CHALLENGE:
					rightComponent = new ConfirmRejectButton(this, Screen.width, 0, accept, reject);
					rightComponent.x -= rightComponent.width + xOffset;
					break;

				case TYPE_ADD_FRIEND_RECENT:
					accept = function():void{
						User.current.addFriend(user.id);
						changeType(TYPE_FRIEND_REQUEST_SENT);
					};
					rightComponent = new ConfirmRejectButton(this, Screen.width, 0, accept, null);
					rightComponent.x -= rightComponent.width + xOffset;
					break;

				case TYPE_INVITE:
					var alreadyInGame:Boolean = false;
					for each (var u:User in Room.current.users)
						if (u.id == user.id) alreadyInGame = true;

					if (user.hasBeenInvited() || alreadyInGame)
					{
						rightComponent = TriviaText.create(this, {
							w: 500,
							x:Screen.width-550,
							text: alreadyInGame ? "In Game" : "Invited",
							valign: VAlign.TOP,
							style:  TriviaText.GRAY_LARGE_RIGHT
						});
					}
					else
					{
						accept = function ():void {
							User.current.invite(user.id);

							// Changing _type to null is a kluge to force a refresh to "Invited" status.
							_type = null;
							changeType(TYPE_INVITE);
						};
						rightComponent = new ConfirmRejectButton(this, Screen.width, 0, accept, null);
						rightComponent.x -= rightComponent.width + xOffset;
					}
					break;

				case TYPE_LEADERBOARD:
				case TYPE_LEADERBOARD_ALL_TIME:
					var isWeeklyAllTime:Boolean = type == TYPE_LEADERBOARD_ALL_TIME;
					rightComponent = TriviaText.create(this, {
						w: 500,
						x:Screen.width-550,
						text: isWeeklyAllTime ? Helper.formatNumber(user.lifetimeRankedScore) : Helper.formatNumber(user.rankedScore),
						valign: VAlign.TOP,
						style:  TriviaText.GRAY_LARGE_RIGHT
					});
					break;

				case TYPE_GROUP_LEADERBOARD:
				case TYPE_GROUP_LEADERBOARD_ALL_TIME:
					var isGroupAllTime:Boolean = type == TYPE_GROUP_LEADERBOARD_ALL_TIME;
					rightComponent = TriviaText.create(this, {
						w: 500,
						x: Screen.width - 550,
						text: isGroupAllTime ? Helper.formatNumber(user.lifetimeGroupScore) : Helper.formatNumber(user.rankedGroupScore),
						valign: VAlign.TOP,
						style: TriviaText.GRAY_LARGE_RIGHT
					});
					break;

				case TYPE_EVENT_LEADERBOARD:
				case TYPE_EVENT_LEADERBOARD_ALL_TIME:
					var isEventAllTime:Boolean = type == TYPE_EVENT_LEADERBOARD_ALL_TIME;
					rightComponent = TriviaText.create(this, {
						w: 500,
						x: Screen.width - 550,
						text: isEventAllTime ?  Helper.formatNumber(user.lifetimeRankedScore + user.lifetimeGroupScore) : Helper.formatNumber(user.rankedGroupScore + user.rankedScore),
//						text: Helper.formatNumber(user.rankedScore),
						valign: VAlign.TOP,
						style: TriviaText.GRAY_LARGE_RIGHT
					});
					break;

				case TYPE_FRIEND_WINS:
					rightComponent = TriviaText.create(this, {
						w: 500,
						x: Screen.width - 550,
						text: Helper.formatNumber(user.rankedScore + user.rankedGroupScore),
						valign: VAlign.TOP,
						style: TriviaText.GRAY_LARGE_RIGHT
					});
					break;
			}

			rightComponent.y = (this.height - rightComponent.height) / 2;
		}

		public function updateRank(rank:int = 1):void
		{
			if (rankText)
			{
				removeChild(rankText);
				rankText.dispose();
			}

			photo.x = xOffset * 3;
			displayName.x = photo.x + photo.photoWidth + 20;

			rankText = TriviaText.create(this, {
				x: 25,
				height:140,
				text: rank + '.',
				style: TriviaText.BLUE_SMALL_LEFT
			});

			var digits:int = rankText.text.length - 1;
			if(digits >= 3) rankText.fontSize *= .85;
			if(digits >= 4)
			{
				var xAdjust:int = (digits - 3) * 10;

				photo.x += xAdjust;
				displayName.x += xAdjust;
			}
		}

		public static function create(parent:*, startY:int, user:User, type:String, onClick:Function = null):ProfileBar
		{
			if (!bars) bars = new Vector.<ProfileBar>();

//			for each (var b:ProfileBar in bars)		// Do not allow duplicate profiles.
//				if (b.user.id == user.id)
//					return null;

			//trace("Creating Bar for user " + user.id);

			var y:int = bars.length ? bars[0].y : startY;

			var bar:ProfileBar = new ProfileBar(parent, y + (bars.length ? bars[0].height * bars.length : 0), user, type, onClick);
			bars.push(bar);
			return bar;
		}

		public static function showRanks(type:String = "", lifetime:Boolean = false):void
		{
			bars.forEach(function(b:ProfileBar, i:int, vec:Vector.<ProfileBar>):void
			{
				var rank:int;
				if(type != "")
				{
					if (lifetime)
						rank = (type == Leaderboards.MODE_VERSUS) ? b.user.lifetimeVersusRank
							: (type == Leaderboards.MODE_GROUP) ? b.user.lifetimeGroupRank
							: b.user.versusRank;
					else
						rank = (type == Leaderboards.MODE_VERSUS) ? b.user.versusRank
							: (type == Leaderboards.MODE_GROUP) ? b.user.groupRank
							: b.user.versusRank;
				}
				else rank = i + 1;

				b.updateRank(rank);
			});
		}

		public static function getBarByUserID(id:int):ProfileBar
		{
			for each (var b:ProfileBar in bars)
				if (b.user.id == id)
					return b;
			return null;
		}

		public static function sort(sortType:String = SORT_GAME_SCORE):void
		{
			if (!bars) return;

			// Comments everywhere because I've been struggling with the redraw a bit.

			var redraw:Boolean = false;						// If true by the end of the function, we need to tween objects out / in to update.
			var startY:int = int.MAX_VALUE;					// The minimum Y value in the list of ProfileBar objects, required for redrawing.
			var order:Vector.<int> = new Vector.<int>();	// The original order of the bars - holds user ids.

			for each (var b:ProfileBar in bars) {			// Find the minimum Y and store the original order.
				startY = b.y < startY ? b.y : startY;
				order.push(b.user.id);
			}

			// This is a kluge for the sort function - it likes to re-order elements even if everything returns 0.
			// If everything returns 0, nothing (should have) moved, and we shouldn't redraw the list.
			var allZero:Boolean = true;

			// Using Vector's built in sort, we can efficiently reorder our ProfileBars.
			// In a callback function(<T>, <T>), return -1 if the first element should be listed first, 0 if equal,
			// or 1 if it should appear after the second element.
			switch(sortType)
			{
				case SORT_GAME_SCORE:
					bars.sort(function(a:ProfileBar, b:ProfileBar):Number
					{
						var output:Number = a.user.score < b.user.score ? 1 : a.user.score == b.user.score ? 0 : -1;
						allZero &&= output == 0;
						return output;
					});
					break;

				case SORT_RANKED_WINS:
					bars.sort(function(a:ProfileBar, b:ProfileBar):Number
					{
						var output:Number = a.user.rankedScore < b.user.rankedScore ? 1 : a.user.rankedScore == b.user.rankedScore ? 0 : -1;
						allZero &&= output == 0;
						return output;
					});
					break;
			}

			// Check to see if the sort function moved anything around.
			for (var i:int = 0; i < bars.length; i++)
				redraw ||= order[i] != bars[i].user.id;

//			trace("------ BAR USERS ------");
//			for each(var t:ProfileBar in bars)
//				trace(t, t.user.displayName, t.user.id);

			// Rebuild all ProfileBars.
			var rebuild:Function = function():void
			{
				// Give each profile bar its new y position.  It may be the same as the existing y.
				var barks:Array = [];
				for each (var b:ProfileBar in bars)
				{
					var index:int = bars.indexOf(b);
					barks[index] = b;
				}

				var lastY:Number = startY;
				for(var i:int = 0; i< barks.length; i++)
				{
					var bar:ProfileBar = barks[i];

					var isUserContainer:Boolean = (bar.user.id == User.current.id);
					if(!isUserContainer)
					{
						if(i == 0) lastY += 50;
						bar.updateRank(i + 1);
					}

					bar.newY = lastY;

					lastY += bar.height + 50;
				}

				// Tween
				bars.forEach(function(b:ProfileBar, index:int, bars:Vector.<ProfileBar>):void
				{
					var newText:String = null;

					// Grab the new text, if applicable, for the ProfileBar (e.g. score change)
					switch(b._type)
					{
						case TYPE_SCORE:
							newText = Helper.formatNumber(b.user.score);
							newText = b.rightComponent.text == newText ? null : newText;
							break;
					}

					// Redraw a ProfileBar if either the y position or text has changed.
					// Other bars should not be tweened.
					if (b.y != b.newY || newText)
						TweenMax.to(b, 0.25, {alpha: 0, onComplete: function():void
						{
							b.y = b.newY;
							if (newText) b.rightComponent.text = newText;
							TweenMax.to(b, 0.25, {alpha: 1});
						}});
				});
			};

			if (redraw && !allZero) rebuild();
		}

		public static function refreshAll():void
		{
			for each (var bar:ProfileBar in bars)
			{
				bar.parent.removeChild(bar);
				bar.dispose();
			}
			bars = null;
		}

		public static function get defaultType():String
		{
			if (bars && bars.length)
				return bars[0]._type;
			return TYPE_SCORE;
		}
	}
}