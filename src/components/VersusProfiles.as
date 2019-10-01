/**
 * Created by georgeperry on 10/26/15.
 */
package components
{
	import architecture.Fonts;
	import architecture.game.Player;
	import architecture.game.Question;
	import architecture.game.Room;
	import architecture.game.User;

	import controls.ProfilePhoto;

	import scenes.Game;

	import starling.text.TextField;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.scene.SceneController;
	import ten90.tools.Help;
	import ten90.tools.Position;

	import tools.TriviaText;

	public class VersusProfiles extends Component
	{
		private static var self:VersusProfiles;

		public static var hasOpponent:Boolean;
		public static var oppUser:User;

		private var player:ProfilePhoto;
		private var enemy:ProfilePhoto;

		private var logo:TextField;
		private var rankedText:TextField;

		public override function init():void
		{
			self = this;
			hasOpponent = false;

			if (!isNeeded) return;

			this.x = Screen.left;
			this.y = Screen.top;

			logo = TriviaText.create(this, {
				x: Screen.width / 2,
				y: 105,
				text: "VERSUS",
				font: Fonts.ROBOTO,
				bold: true,
				italic: true,
				style: TriviaText.BLUE_MEDIUM
			});

			logo.x -= logo.width/2;

			rankedText = TriviaText.create(this, {
				x: logo.x,
				y: Position.bottom(logo),
				text: "RANKED\nMATCH",
				font: Fonts.ROBOTO,
				bold: true,
				italic: true,
				style: TriviaText.ORANGE_MEDIUM
			});

			var inGame:Boolean = SceneController.currentScene is Game;

			player = new ProfilePhoto(this, User.current, rankedText.x / 2, logo.y-15, ProfilePhoto.MEDIUM, false, false, false, false);
			player.x -= player.width / 2;

			oppUser = null;

			if(Room.current.topOpponent)
			{
				hasOpponent = true;
				oppUser = Room.current.topOpponent;
			}
			else
			{
				oppUser = new User(null);
				oppUser.displayName = "Searching";
				oppUser.bestCategory = 1;
				oppUser.coins = 0;
				oppUser.level = 1;
				oppUser.id = -1;
			}

			enemy = new ProfilePhoto(this, oppUser, rankedText.x / 2 + Position.right(rankedText), player.y, ProfilePhoto.MEDIUM, false, false, false, false);
			enemy.x -= enemy.width / 2;
		}

		public function animateWin(currentUserWon:Boolean = true):void
		{
			if (!isNeeded) return;

			player.animate(currentUserWon);
			enemy.animate(!currentUserWon);
		}

		public override function ready():void
		{
			if (!isNeeded) return;

			switch (Help.getClassName(parentScene))
			{
				case "Game":
					player.score = enemy.score = 0;
					player.setOptions(true, true, false, true, true);
					enemy.setOptions(true, true, false, true, true);
					break;

				case "Results":
					player.setOptions(false, true, true);
					enemy.setOptions(false, true, true);
					break;
			}

		}

		public function update():void
		{
			if (!isNeeded) return;

			var topDog:User = Room.current.getTopOpponent();
			player.score = User.current.score;
			if(!topDog) topDog = oppUser;

			if(enemy.user.id == topDog.id)
			{
				var p:Player = Room.current.getPlayerByID(enemy.user.id);

				if(!p || topDog.id == -1)
				{
//					enemy.txtScore.fontSize = 28;
//					enemy.txtScore.text = "";
					return;
				}
				enemy.score = p.getScoreUpToQuestion(Question.current.numberInSet);

				var currentQNo:int = Question.current.numberInSet;
				var currentScore:int = p.getScoreUpToQuestion(currentQNo);
			}
			else enemy.changeUser(topDog);
		}

		private function get isNeeded():Boolean
		{
			if(Room.mode == Room.MODE_VERSUS || Room.mode == Room.MODE_VERSUS_REMATCH) return true;
			else if (Room.mode == Room.MODE_GROUP_RANKED && SceneController.currentScene is Game) return false;
			return false;
		}

		public static function addOpponent(user:User):void
		{
			self.enemy.changeUser(user);
			hasOpponent = true;
		}
	}
}