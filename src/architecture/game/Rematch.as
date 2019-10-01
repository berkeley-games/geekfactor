/**
 * Created by wmaynard on 3/17/2016.
 */
package architecture.game {
	import architecture.Database;

	import scenes.PregameSplash;
	import scenes.Results;

	import ten90.scene.SceneController;
	import ten90.scene.Transitions;

	public class Rematch extends XMLClass
	{
		private static const USER_ID:String = "UserID";
		private static const Room_ID:String = "RoomID";
		private static const ACCEPTED:String = "Accepted";
		private static const DECLINED:String = "Declined";

		private var userID:int;
		private var roomID:int;
		private var accepted:Boolean;
		private var declined:Boolean;

		private static var responses:Vector.<Rematch> = new Vector.<Rematch>();

		public function Rematch(xmlChild:XML) {
			super(xmlChild);

			userID = parseInt(att(USER_ID));
			roomID = parseInt(att(Room_ID));
			accepted = att(ACCEPTED) == "1";
			declined = att(DECLINED) == "1";
		}

		public static function getStatus(onEnemyRequest:Function, onDecline:Function, onCheckComplete:Function = null):void
		{
			while (responses.length)
				responses.pop();

			var xmlHandler:Function = function(data:XML):void{
				for each (var x:XML in data.children())
				{
					var r:Rematch = new Rematch(x);
					var add:Boolean = true;
					for each (var response:Rematch in responses)
						if (r.userID == response.userID)
							add = false;
					if (add)
						responses.push(r);
//					responses.push(new Rematch(x));
				}

				var declined:Boolean = false;

				var acceptedCount:int = 0;

				// Check to see if the opponent has requested a rematch or moved on.
				for each (var q:Rematch in responses)
				{
					if (q.userID == Room.current.topOpponent.id)
						onEnemyRequest(q.accepted);
					declined ||= q.declined;
					acceptedCount += (q.accepted ? 1 : 0);
				}

				if (declined)
					onDecline();
				// Everyone has responded to the rematch.
				else if (acceptedCount == Room.current.players.length)
					start();

				else if (onCheckComplete)
					onCheckComplete();
			};

			Database.getRematch(xmlHandler);
		}

		public static function request(onComplete:Function = null):void
		{
			Database.requestRematch(true, onComplete);
		}

		public static function decline(onComplete:Function = null):void
		{
			Database.requestRematch(false, onComplete);
		}

		// Begins the rematch.  The room join functionality will be handled there.
		private static function start():void
		{
			Room.mode = Room.MODE_VERSUS_REMATCH;
			Results.declineRematchOnExit = false;
			SceneController.currentScene.transition(PregameSplash, Transitions.MANUAL);
		}
	}
}