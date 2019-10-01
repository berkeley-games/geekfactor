/**
 * Created by wmaynard on 5/11/2016.
 */
package architecture.game
{
	import architecture.Database;

	import com.greensock.TweenMax;
	import com.greensock.easing.CustomEase;

	import components.Burger;
	import components.CustomError;
	import components.RankDialog;

	import scenes.Menu;

	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.scene.SceneController;

	import tools.TriviaText;

	public class Notification extends XMLClass
	{
		private static const ID:String = "ID";
		private static const MESSAGE:String = "Message";
		private static const READ:String = "Read";
		private static const CREATED_ON:String = "CreatedOn";
		private static const EXPIRATION:String = "Expiration";
		private static const BUTTON_TARGET:String = "ButtonTarget";

		public static var enabled:Boolean = true;

		public var message:String;
		public var createdOn:String;
		public var buttonTarget:String;

		private static var showing:Boolean = false;

		public static const queue:Vector.<Notification> = new Vector.<Notification>();

		public function Notification(child:XML)
		{
			super(child);

			message = att(MESSAGE);
			createdOn = att(CREATED_ON);
			buttonTarget = att(BUTTON_TARGET);

			queue.push(this);
		}

		public function show():void
		{
			var thisref:Notification = this;

			function nextify():void
			{
				showing = false;
				queue.removeAt(queue.indexOf(thisref));
				showNext();
			}

			var error:CustomError = SceneController.currentScene.getComponent(CustomError);
			error.onDestroy = nextify;
			error.show(message, buttonTarget, function():void{	// TODO: This is a hacky way to get the rank dialog to show up when a queued match is finished.
				if (message.indexOf("Game Complete") > -1)
					RankDialog.current.show();
			});

			showing = true;
		}

		public static function showNext():void
		{
			if (queue.length > 0) queue[0].show();
		}

		public static function check():void
		{
			if (!enabled) return;

			Database.checkNotifications(User.current.id, function(data:XML):void
			{
				for each (var xml:XML in data.children())
					new Notification(xml);

				if (!showing) showNext();
			});
		}

		public static function recurringCheck():void
		{
			if (!enabled) return;
			if(!(SceneController.currentScene is Menu)) return;

			check();

			TweenMax.delayedCall(10, recurringCheck);
		}
	}
}