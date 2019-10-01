/**
 * Created by wmaynard on 3/21/2016.
 */
package scenes
{
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.game.Achievement;
	import architecture.game.ColorMap;
	import architecture.game.Room;
	import architecture.game.User;

	import com.greensock.TweenMax;

	import components.BackButton;

	import controls.BlueHeader;
	import controls.CategoryIcon;
	import controls.ProfileBar;
	import controls.TriviaInput;

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;

	import starling.display.Button;
	import starling.display.Quad;
	import starling.text.TextField;

	import ten90.components.SpinnerRing;
	import ten90.device.Screen;
	import ten90.scene.SceneController;
	import ten90.scene.StarlingScene;
	import ten90.scene.Transitions;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	import tools.Helper;
	import tools.TriviaText;

	public class CreateGroup extends StarlingScene
	{
		public static var isHost:Boolean = false;

		private var lblCurrentCategory:TextField;
		private var lblSelectedCategory:TextField;
		private var categoryIcon:CategoryIcon;
		private var scroller:ScrollContainer;
		private var create:Button;
		private var btnInvite:Button;
		private var started:Boolean = false;
		private var spinner:SpinnerRing;
		private var line1:Quad;
		private var line2:Quad;

		public override function init():void
		{
			var title:BlueHeader = new BlueHeader(this, "Create a Game");

			BackButton.onClick = function():void
			{
				if(Room.current)
				{
					TweenMax.killDelayedCallsTo(repeatUpdateRoom);
					Room.current.leave(Room.current.close);
					Room.current.stopPing();
				}

				transition(MultiplayerMenu, Transitions.NONE);
			};

			btnInvite = Helper.GreenButton(this, "Invite Players", 0, title.height * 1.5 + 250, Friends.inviteMode);
			btnInvite.x = (Screen.stageWidth - btnInvite.width) / 2;

			create = Helper.GreenButton(this, "Start Game", Screen.stageWidth / 2, Screen.stageHeight, create_click);
			create.x -= create.width / 2;
			create.y -= create.height + 25;

			create.alpha = .5;
			create.touchable = false;

			lblCurrentCategory = TriviaText.create(this, {
				x: 0,
				y:  int(title.height * 1.5),
				w: Screen.stageWidth / 2,
				text: "Current Category",
				size:34,
				color:ColorMap.GRAY,
				halign:"right"
			});

			lblSelectedCategory = TriviaText.create(this, {
				x: 0,
				y: lblCurrentCategory.y + lblCurrentCategory.height,
				w: Screen.stageWidth / 2,
				text: ImageMap.getCategoryName(Room.selectedCategory, true),
				style: TriviaText.GRAY_MEDIUM_RIGHT
			});

			categoryIcon = new CategoryIcon(this, 0, lblCurrentCategory.y - 25, Room.selectedCategory, 1, CategoryIcon.GROUP_CREATION);
			Position.right(categoryIcon, Position.right(btnInvite) - 50);
			Position.right(lblCurrentCategory, Position.left(categoryIcon) - 25);
			lblSelectedCategory.x = lblCurrentCategory.x;

			var scrollerPadding:int = 25;
			scroller = Make.scrollContainer(this, Screen.left, Position.bottom(btnInvite) + scrollerPadding, Screen.width, 50, "vertical", 30);
			scroller.height = (Position.top(create) - scrollerPadding) - (Position.bottom(btnInvite) + scrollerPadding);
			scroller.interactionMode = Scroller.INTERACTION_MODE_TOUCH;
			scroller.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			Make.quad(scroller, 0, 0, scroller.width, 1, 0xFFFFFF).touchable = false;

			line1 = Make.quad(this, Screen.left+25, scroller.y, Screen.width-50, Skins.dividerStroke, ColorMap.GRAY);
			line2 = Make.quad(this, Screen.left+25, Position.bottom(scroller), Screen.width-50, Skins.dividerStroke, ColorMap.GRAY);

			line1.alpha = line2.alpha = .5;

			spinner = getComponent(SpinnerRing);
			spinner.show([lblCurrentCategory, lblSelectedCategory, btnInvite, create, categoryIcon, line1, line2]);

			if (isHost) Room.joinGroupMatch(onRoomJoin);
			else onRoomJoin();	// User already joined in via the invite functionality.

			for each (var t:* in [lblSelectedCategory, lblCurrentCategory, btnInvite, line1, line2])
				t.alpha = 0;

			clearSavedInvites();
		}

		public static function clearSavedInvites():void
		{
			Save.data("invites", '');
		}

		public static function saveInvite(invitedUserID:int):void
		{
			var data:String = Save.data("invites");
			data += (data.length ? '|' : '') + invitedUserID;
			Save.data("invites", data);
		}

		// TODO: This function isn't a good idea anymore.
		// The original purpose was that every player would see the CreateGroup screen,
		// and only the host would have the privilege to start the game.
		// Now that invited players are taken directly to PregameSplash, there isn't any purpose to this.
		public static function host():void
		{
			isHost = true;
			SceneController.transition(CreateGroup);
		}

		private function onRoomJoin():void
		{
			spinner.hide();
			updateRoom();
		}

		private var bars:Vector.<ProfileBar> = new Vector.<ProfileBar>();

		private function updateRoom():void
		{
			if(!(SceneController.currentScene is CreateGroup) && !(SceneController.currentScene is Friends))
				return;

			Room.current.isFull(create_click);

			for each (var u:User in Room.current.users)
			{
				var toAdd:Boolean = true;

				for each (var bar:ProfileBar in bars)
					if (bar.user.id == u.id)
						toAdd = false;

				if (!toAdd) continue;

				var b:ProfileBar = new ProfileBar(scroller, 0, u, ProfileBar.TYPE_READY);
				bars.push(b);

				TweenMax.from(b, 0.5, {alpha: 0});

				if(bars.length > 1)
				{
					create.alpha = 1;
					create.touchable = true;
				}
			}

			if (!started) Quick.call(4, repeatUpdateRoom);
		}

		private function repeatUpdateRoom():void
		{
			if(!(SceneController.currentScene is CreateGroup)) return;
			if (!started) Room.current.update(updateRoom);
		}

		private function create_click():void
		{
			started = true;
			touchable = false;

			if (isHost && !Room.current.isFull())
			{
				Room.current.fill(function():void
				{
					PregameSplash.showDetails = false;

					transition(PregameSplash, Transitions.MANUAL);
				});
			}
			isHost = false;
		}

		public override function ready():void
		{
			TweenMax.to(lblCurrentCategory,.25, {delay: 0, alpha: 1});
			TweenMax.to(lblSelectedCategory,.25, {delay:.1, alpha: 1});
			TweenMax.to(categoryIcon,.5, {delay:.3, alpha: 1});
			TweenMax.to(btnInvite,.5, {delay:.5, alpha: 1});
			TweenMax.to(line1,.5, {delay:.55, alpha: 1});
			TweenMax.to(line2,.5, {delay:.65, alpha: 1});
			TweenMax.from(create,.5, {delay:.75, alpha: 0});
		}
	}
}
