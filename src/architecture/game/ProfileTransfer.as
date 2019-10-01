/**
 * Created by wmaynard on 6/16/2016.
 */
package architecture.game
{
	import architecture.Database;

	import components.CustomError;

	import ten90.scene.SceneController;

	import ten90.tools.Quick;
	import ten90.utilities.Save;

	public class ProfileTransfer extends XMLClass
	{
		private static const ID:String = "ID";
		private static const USER_ID:String = "UserID";
		private static const CODE:String = "Code";
		private static const SUCCESS:String = "Success";
		private static const EXPIRATION:String = "Expiration";

		public var id:int;
		public var userID:int;
		public var code:String;
		public var success:Boolean;
		public var expiration:String;

		private var canceled:Boolean = false;

		public static var current:ProfileTransfer;

		public function ProfileTransfer(root:XML)
		{
			super(root);

			id = parseInt(att(ID));
			userID = parseInt(att(USER_ID));
			code = att(CODE);
			success = att(SUCCESS) == "1";
			expiration = att(EXPIRATION);

			current = this;
		}

		private function checkSuccess(onSuccess:Function):void
		{
			Database.getTransferStatus(id, User.current.id, User.localStoredPassword, function(data:XML):void
			{
				success = (getAttribute(data, SUCCESS) == "1") || (getAttribute(data, "Error") == "Invalid Credentials");

				if(canceled) return;

				if(success) onSuccess();
				else
				{
					Quick.call(2, function():void{
						checkSuccess(onSuccess);
					});
				}
			});
		}

		public static function start(onSuccess:Function, transferCodeHandler:Function):void
		{
			Database.transferProfile(User.current.email, User.localStoredPassword, null, function(data:XML):void
			{
				new ProfileTransfer(data).checkSuccess(onSuccess);
				transferCodeHandler(current.code);
			});
		}

		public static function complete(username:String, code:String, onSuccess:Function):void
		{
			Database.transferProfile(username, null, code, function(data:XML):void
			{
				var error:String = getAttribute(data, "Error");
				if (error) SceneController.currentScene.getComponent(CustomError).show(error);
				else
				{
					var password:String = getAttribute(data, "NewPassword");
					trace("Old Password: " + User.localStoredPassword);
					trace("New Password: " + password);
					Save.data("username", username);
					Save.data("password" + username, password);
					Save.flush();
					onSuccess();
				}
			});
		}

		public function cancel():void
		{
			canceled = true;
			Database.cancelTransfer(User.current.id, User.localStoredPassword);
		}
	}
}
