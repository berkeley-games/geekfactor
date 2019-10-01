/**
 * Created by gperry on 3/31/2016.
 */
package scenes
{
	import architecture.Fonts;
	import architecture.Skins;
	import architecture.game.ColorMap;
	import architecture.game.User;

	import com.greensock.TweenMax;

	import components.BackButton;

	import controls.BlueHeader;
	import controls.ProfileBar;
	import controls.Tabs;
	import controls.TriviaInput;

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;

	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.text.TextField;

	import ten90.components.SpinnerRing;
	import ten90.device.Screen;
	import ten90.scene.SceneController;
	import ten90.scene.StarlingScene;
	import ten90.scene.Transitions;
	import ten90.tools.Help;
	import ten90.tools.Make;
	import ten90.tools.Position;

	import tools.Helper;

	public class Friends extends StarlingScene
	{
		private var spinner:SpinnerRing;

		private var tabs:Tabs;
		private var scroller:ScrollContainer;
		private var thisref:Friends;
		private var txtSearch:TriviaInput;
		private var btnSearch:Button;

		private var noResults:TextField;

		private static var inviteModeEnabled:Boolean = false;

		public override function init():void
		{
			thisref = this;

			var titlebg:BlueHeader = new BlueHeader(this, "Friends");

			tabs = new Tabs(this, Position.bottom(titlebg), 150,
				{ text: "Friends", onClick: loadFriends },
				{ text: "Recent", onClick: loadRecent },
				{ text: "Search", onClick: loadSearch }
			);

			txtSearch = new TriviaInput(this, Position.bottom(tabs) + 100, "Search");
			btnSearch = Helper.GreenButton(this, "Search", 0, txtSearch.y + txtSearch.height, search);
			btnSearch.x = (Screen.stageWidth - btnSearch.width) / 2;
			txtSearch.visible = btnSearch.visible = false;

			scroller = Make.scrollContainer(this, Screen.left, Position.bottom(tabs), Screen.width, Screen.height - Position.bottom(tabs), "vertical", 75, 10);
			scroller.interactionMode = Scroller.INTERACTION_MODE_TOUCH;
			scroller.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			scroller.x = Screen.left;

			Make.quad(this, Screen.left+25, Position.bottom(tabs), Screen.width-50, Skins.dividerStroke, ColorMap.GRAY).alpha = .5;

			Make.quad(scroller, 0, 0, scroller.width, Skins.dividerStroke, 0xFFFFFF).touchable = false;

			spinner = getComponent(SpinnerRing);
		}

		public static function inviteMode():void
		{
			inviteModeEnabled = true;
			SceneController.transition(Friends, Transitions.NONE, 1, false);
		}

		private function search():void
		{
			if(!spinner.visible) spinner.show();
			scroller.visible = false;

			User.search(txtSearch.text, searchResultsReceived);
		}

		public override function ready():void
		{
			loadFriends();

			BackButton.onClick = function():void
			{
				inviteModeEnabled = false;
				if(SceneController.previousScene == Profile) SceneController.transition(Menu);
				else SceneController.transition(SceneController.previousScene);
			};
		}

		private function loadRecent():void
		{
			removeNoResults();

			if(!spinner.visible) spinner.show();
			scroller.visible = false;

			hideSearchControls();

			User.current.getRecentOpponents(opponentsReceived);
			scroller.y = Position.bottom(tabs);
			scroller.height = Screen.height - Position.bottom(tabs);
		}

		private function loadFriends():void
		{
			removeNoResults();

			if(!spinner.visible) spinner.show();
			scroller.visible = false;

			hideSearchControls();

			User.current.getFriends(friendsReceived);

			scroller.y = Position.bottom(tabs);
			scroller.height = Screen.height - Position.bottom(tabs);
		}

		private function loadSearch():void
		{
			removeNoResults();

			ProfileBar.refreshAll();

			txtSearch.visible = btnSearch.visible = true;

			scroller.y = Position.bottom(btnSearch);
			scroller.height = Screen.height - Position.bottom(btnSearch);
		}

		private function searchResultsReceived(users:Vector.<User>):void
		{
			spinner.hide();
			scroller.visible = true;

			if(noResults)
			{
				scroller.removeChild(noResults);
				noResults = null;

				scroller.readjustLayout();
			}

			ProfileBar.refreshAll();

			for each (var u:User in users)
				ProfileBar.create(scroller, 0, u, inviteModeEnabled ? ProfileBar.TYPE_INVITE : ProfileBar.TYPE_ADD_FRIEND_RECENT);

			fadeInResults();

			if(users.length == 0) addNoResults();
		}

		private function opponentsReceived(data:XML):void
		{
			spinner.hide();
			scroller.visible = true;

			ProfileBar.refreshAll();

			var users:Vector.<User> = new Vector.<User>();
			for each (var xml:XML in data.children())
				users.push(new User(xml));

			for each (var u:User in users)
				ProfileBar.create(scroller, 0, u, inviteModeEnabled ? ProfileBar.TYPE_INVITE : ProfileBar.TYPE_ADD_FRIEND_RECENT);

			fadeInResults();

			if(data == "" || data == null) addNoResults();
		}

		private function friendsReceived(data:XML):void
		{
			spinner.hide();
			scroller.visible = true;

			hideSearchControls();

			ProfileBar.refreshAll();

			var users:Vector.<User> = new Vector.<User>();
			for each (var xml:XML in data.children())
				if (!Helper.xmlHasError(xml))
					users.push(new User(xml));

			if (inviteModeEnabled)
				for each (var a:User in users)
					ProfileBar.create(scroller, 0, a, ProfileBar.TYPE_INVITE);
			else
			{
				// List friends first
				for each (var u:User in users)
					if (u.isFriend)
						ProfileBar.create(scroller, 0, u, ProfileBar.TYPE_FRIEND_WINS);

				// Then list friend requests requiring user's attention
				for each (var t:User in users)
					if (!t.isFriend && t.friendStatus == User.STATUS_REQUIRES_CONFIRMATION)
						ProfileBar.create(scroller, 0, t, ProfileBar.TYPE_ACCEPT_REJECT_FRIEND);

				// Then list sent friend requests
				for each (var v:User in users)
					if (!v.isFriend && v.friendStatus == User.STATUS_AWAITING_CONFIRMATION)
						ProfileBar.create(scroller, 0, v, ProfileBar.TYPE_FRIEND_REQUEST_SENT);
			}

			fadeInResults();

			if(data.row && data.row[0] && data.row[0].@Error) addNoResults();
		}

		private function fadeInResults():void
		{
			var i:int;
			var delay:Number = .1;
			var numChildren:int = scroller.numChildren;
			for(i = 0; i < numChildren; i++)
			{
				var child:DisplayObject = scroller.getChildAt(i);
				TweenMax.from(child, .9, {alpha:0, delay:delay});
				delay += .09;
			}
		}

		private function hideSearchControls():void
		{
			txtSearch.text = "";
			txtSearch.visible = btnSearch.visible = false;
		}

		private function addNoResults():void
		{
			if(noResults)
			{
				scroller.removeChild(noResults);
				noResults = null;

				scroller.readjustLayout();
			}

			noResults = Make.text(scroller, 0, 0, scroller.width, 200, "No results!", Fonts.SYSTEM, 48, 0, false, "center");
			TweenMax.from(noResults, .5, {alpha:0});
		}

		private function removeNoResults():void
		{
			if(noResults)
			{
				noResults.parent.removeChild(noResults);
				noResults = null;

				scroller.readjustLayout();
			}

		}
	}
}