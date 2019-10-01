/**
 * Created by wmaynard on 4/6/2016.
 */
package architecture.game
{
	import architecture.Database;

	import controls.ProfileBar;

	import scenes.PregameSplash;

	import ten90.scene.SceneController;
	import ten90.scene.Transitions;

	public class Challenge extends XMLClass
	{
		private static const INVITE_ID:String = "InviteID";
		private static const ROOM_ID:String = "RoomID";
		private static const INVITE_CODE:String = "Code";
		private static const CREATED_ON:String = "CreatedOn";
		private static const EXPIRATION:String = "Expiration";

		public var id:int;
		public var roomID:int;
		public var invitePassword:String;
		public var createdOn:String;
		public var expiration:String;

		public var profileBar:ProfileBar;
		private var user:User;

		public function Challenge(xmlChild:XML)
		{
			super(xmlChild);

			id = parseInt(att(INVITE_ID));
			roomID = parseInt(att(ROOM_ID));
			invitePassword = att(INVITE_CODE);
			createdOn = att(CREATED_ON);
			expiration = att(EXPIRATION);

			user = new User(xml);
			profileBar = new ProfileBar(null, 0, user, ProfileBar.TYPE_CHALLENGE, accept, decline);
		}

		public function accept():void
		{
			Database.acceptInvite(User.current.id, id, 0, function(room:XML):void{
				new Room(room, function():void{
					Room.mode = Room.MODE_INVITE;
					SceneController.transition(PregameSplash, Transitions.MANUAL);
//					SceneController.transition(CreateGroup, Transitions.NONE);
				});
			})
		}

		public function decline():void
		{
			Database.rejectInvite(id, function():void{
				profileBar.kill();
			});
		}

		public static function getChallenges(challengeHandler:Function):void
		{
			Database.checkInvites(User.current.id, function(data:XML):void{
				var challenges:Vector.<Challenge> = new Vector.<Challenge>();
				for each (var child:XML in data.children())
					challenges.push(new Challenge(child));
				challengeHandler(challenges);
			});
		}
	}
}