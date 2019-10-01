/**
 * Created by wmaynard on 4/28/2016.
 */
package architecture.game {
	import architecture.Database;
	import architecture.XMLHelper;

	import com.greensock.TweenMax;

	import components.CustomError;

	import starling.display.Image;

	import starling.display.Sprite;

	import ten90.device.Screen;
	import ten90.tools.Make;
	import ten90.tools.Quick;

	import ten90.utilities.Save;

	import tools.TriviaText;

	// If you want to test out event functionality, join event "Cisco Live", "Cisco Live 2", or "Cisco Live 3".
	// These events are open until May 13, 2017.
	public class GFEvent extends XMLClass
	{
		private static const ID:String = "ID";
		private static const NAME:String = "Name";
		private static const START_DATE:String = "StartDate";
		private static const END_DATE:String = "EndDate";
		private static const WELCOME_MESSAGE:String = "WelcomeMessage";
		private static const SAVE_CURRENT:String = "CurrentEventID";
		private static const FRIENDLY_NAME:String = "FriendlyName";

		// Intended for saving events that the user has joined previously and are still open
		// for easy switching.
		private static const SAVE_HISTORY:String = "PastEvents";

		private var _id:int;
		private var _name:String;
		private var _start:String;
		private var _end:String;
		private var _welcomeMessage:String;
		private var _friendlyName:String;

		private static var _current:GFEvent;

		public function get id():int { return _id; }
		public function get name():String { return _name; }
		public function get start():String { return _start; }
		public function get end():String { return _end; }
		public function get welcomeMessage():String { return _welcomeMessage; }
		public function get friendlyName():String { return _friendlyName; }

		public static function get current():GFEvent { return _current; }
		private static const JOINED_SAVESTATE:String = "EventJoinedID";

		public function GFEvent(root:XML, updateCurrent:Boolean = true)
		{
			super(root);

			_id 			= parseInt(att(ID));
			_name 			= att(NAME);
			_friendlyName	= att(FRIENDLY_NAME);
			_start 			= att(START_DATE);
			_end 			= att(END_DATE);
			_welcomeMessage = att(WELCOME_MESSAGE);
			if (!_welcomeMessage || _welcomeMessage.length == 0)
				_welcomeMessage = "Welcome to " + _name + "!";

			if (!updateCurrent)
				return;

			_current = root ? this : null;

			if (_current) _current.markAsJoined();
			save();
		}

		// eventHandler accepts an Event object as a parameter,
		// which will be null in the event of an error.
		public static function join(name:String, eventHandler:Function):void
		{
			trace("Joining event " + name);
			Database.joinEvent(User.current.id, name, function(data:XML):void
			{
				clearSave();
				new GFEvent(XMLHelper.getError(data) ? null : data);
				eventHandler(_current);
			});
		}

		private function markAsJoined():void
		{
			var name:String = "EventJoined(" + id + ")";
			if (Save.data(name))
				return;

			Save.data(name, true);
			Save.flush();

			CustomError.current.show(_welcomeMessage);
		}

		// Saves the current event so the user can rejoin it on next startup.
		private function save():void
		{
			Save.data(SAVE_CURRENT + User.current.id, name);
			Save.flush();
		}

		public function createSprite(parent:* = null, eventHandler:Function = null, useAltBackground:Boolean = false):Sprite
		{
			var output:Sprite = new Sprite();
			TriviaText.create(output, {
				w: Screen.width,
				text: name,
				style: TriviaText.BLACK_LARGE,
				h: 150
			});
			var bg:Image = Make.shapeImage(output, 0, 0, output.width, output.height, true, useAltBackground ? ColorMap.OFF_WHITE : ColorMap.WHITE);
			Quick.index(bg, 0);
			Quick.click(output, function():void{
				join(name, eventHandler);
				TweenMax.to(output, 0.5, {alpha: 0, onComplete: function():void{
					if (parent)
						parent.removeChild(output);
				}});
			});
			if (parent)
				parent.addChild(output);
			return output;
		}

		public static function getPreviouslyEnteredEvents(onGFEventsLoaded:Function):void
		{
			var currentid:int = _current ? _current.id : 0;
			Database.getPreviouslyEnteredEvents(User.current.id, currentid, function(data:XML):void{
				var events:Vector.<GFEvent> = new Vector.<GFEvent>();
				for each (var child:XML in data.children())
					events.push(new GFEvent(child, false));
				onGFEventsLoaded(events);
			});
		}

		// Join an event guaranteed to produce an error.
		public function leave(onComplete:Function = null):void
		{
			join(null, function(... rest):void{
				if (onComplete)
					onComplete();
			});
		}

		private static function clearSave():void
		{
			Save.data(SAVE_CURRENT + User.current.id, "");
			Save.flush();
		}

		public function getLeaderboard(versusMode:Boolean, onLeaderboardData:Function):void
		{
			Database.getDailyEventLeaderboard(id, User.current.id, versusMode, onLeaderboardData)
		}

		// Load the event name from disk and try to rejoin it.
		// If an error is produced, the save data will be cleared.
		public static function load():void
		{
			join(Save.data(SAVE_CURRENT + User.current.id), function(... rest):void{});
		}

		public static function create(name:String, friendlyName:String, welcomeMessage:String, start:Date, end:Date, onEventData:Function = null, onErrorMessage:Function = null):void
		{
			var dtStart:String = Database.sqlDate(start.fullYear, start.month + 1, start.date, start.hours, start.minutes, start.seconds, start.milliseconds);
			var dtEnd:String = Database.sqlDate(end.fullYear, end.month + 1, end.date, end.hours, end.minutes, end.seconds, end.milliseconds);

			var onComplete:Function = function(data:XML):void
			{
				if (!isError(data) && onEventData)
				{
					var event:GFEvent = new GFEvent(data);
					_current = event;
					onEventData(event);
				}
				else if (onErrorMessage) onErrorMessage(getError(data));
				else trace(getError(data));
			};

			Database.createEvent(User.current.id, name, dtStart, dtEnd, User.localStoredPassword, welcomeMessage, friendlyName, onComplete);
		}
	}
}