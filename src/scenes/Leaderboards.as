/**
 * Created by gperry on 3/31/2016.
 */
package scenes
{
	import architecture.AudioMap;
	import architecture.Database;
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.game.ColorMap;
	import architecture.game.GFEvent;
	import architecture.game.GFEvent;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import components.BackButton;

	import controls.BlueHeader;
	import controls.ProfileBar;
	import controls.Tabs;

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.events.FeathersEventType;

	import starling.display.Button;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;

	import ten90.components.SpinnerRing;
	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.network.HTTP;
	import ten90.scene.StarlingScene;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	public class Leaderboards extends StarlingScene
	{
		public static const MODE_VERSUS:String = "versus";
		public static const MODE_GROUP:String = "group";
		public static const MODE_EVENT:String = "event";

		private const BOTTOM_HEIGHT:int = 300;

		private var spinner:SpinnerRing;

		private var scroller:ScrollContainer;
		private var selected:String;
		private var barType:String;
		private var divider:Quad;
		private var tabs:Tabs;

		private var userBar:ProfileBar;

		private var timelineButton:Button;
		private var weeklyImage:Image;
		private var allTimeImage:Image;

		private var isLifetime:Boolean = false;

		private var scrollerEndPadding:Quad;

		private var header:BlueHeader;

		private var isEvent:Boolean = false;

		public override function init():void
		{
			header = new BlueHeader(this, "Leaderboard", "Weekly");

			tabs = new Tabs(this, Position.bottom(header), 150,
					{ text: "Versus", onClick: versus_clicked },
					{ text: "Group", onClick: group_clicked },
					{ text: "Event", onClick: event_clicked }
			);

			tabs.enable(3, GFEvent.current);

			BackButton.onClick = null;
			var backButton:BackButton = getComponent(BackButton);
			backButton.transitionTo = Menu;

			scroller = Make.scrollContainer(this, Screen.left, Position.bottom(tabs), Screen.width, Screen.height - Position.bottom(tabs) - BOTTOM_HEIGHT, "vertical", 75, 10);
			scroller.interactionMode = Scroller.INTERACTION_MODE_TOUCH;
			scroller.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			scroller.x = Screen.left;

			Make.quad(this, Screen.left+25, Position.bottom(tabs), Screen.width-50, Skins.dividerStroke, ColorMap.GRAY).alpha = .5;

			Make.quad(scroller, 0, 0, scroller.width, 1, 0xFFFFFF).touchable = false;

			scrollerEndPadding = Make.quad(null, 0, 0, scroller.width, 1, 0xFFFFFF);
			scrollerEndPadding.touchable = false;

			divider = Make.quad(this, Screen.left+25, Position.bottom(scroller), Screen.width-50, Skins.dividerStroke, ColorMap.GRAY);
			divider.visible = false;

			spinner = getComponent(SpinnerRing);

			weeklyImage = Make.image(this, ImageMap.LEADERBOARD_WEEKLY, Screen.right - 100, backButton.y);
			allTimeImage = Make.image(this, ImageMap.LEADERBOARD_ALL_TIME, Screen.right - 100, backButton.y);
			timelineButton = Make.emptyButton(this, weeklyImage.x - 50, weeklyImage.y - 50, 100 + weeklyImage.width, 100 + weeklyImage.height);

			Quick.pivot(weeklyImage, .5, .5, true);
			Quick.pivot(allTimeImage, .5, .5, true);

			allTimeImage.scale = 0;
		}

		public override function ready():void
		{
			versus_clicked();

			Quick.click(timelineButton, timelineClicked);
		}

		public function versus_clicked():void
		{
			isEvent = false;

			if(!spinner.visible) spinner.show();

			if(isLifetime) header.subtitle.text = "All-Time";
			else header.subtitle.text = "Weekly";

			timelineButton.touchable = true;

			scroller.visible = false;
			divider.visible = false;
			if(userBar) userBar.visible = false;
			scroller.scrollToPosition(0, 0, 0);

			barType = isLifetime ? ProfileBar.TYPE_LEADERBOARD_ALL_TIME : ProfileBar.TYPE_LEADERBOARD;
			Database.getLeaderboard(User.current.id, false, isLifetime, onData);
			selected = MODE_VERSUS;
		}

		public function group_clicked():void
		{
			isEvent = false;

			showSpinner();

			if(isLifetime) header.subtitle.text = "All-Time";
			else header.subtitle.text = "Weekly";

			timelineButton.touchable = true;

			barType = isLifetime ? ProfileBar.TYPE_GROUP_LEADERBOARD_ALL_TIME : ProfileBar.TYPE_GROUP_LEADERBOARD;
			Database.getLeaderboard(User.current.id, true, isLifetime, onData);
			selected = MODE_GROUP;
		}

		public function event_clicked():void
		{
			isEvent = true;

			showSpinner();

			if(isLifetime) header.subtitle.text = "All-Time";
			else header.subtitle.text = "Daily";

			var isGroup:Boolean = (barType == ProfileBar.TYPE_GROUP_LEADERBOARD)
				|| (barType == ProfileBar.TYPE_GROUP_LEADERBOARD_ALL_TIME)
				|| (barType == ProfileBar.TYPE_EVENT_LEADERBOARD_ALL_TIME);

			barType =  isLifetime ? ProfileBar.TYPE_EVENT_LEADERBOARD_ALL_TIME : ProfileBar.TYPE_EVENT_LEADERBOARD;
			if(isLifetime) Database.getLifetimeEventLeaderboard(GFEvent.current.id, User.current.id, !isGroup, onData);
			else Database.getDailyEventLeaderboard(GFEvent.current.id, User.current.id, !isGroup, onData);
			selected = MODE_EVENT;
		}

		private function timelineClicked():void
		{
			tabs.touchable = false;

			isLifetime = !isLifetime;
			if(isLifetime) header.subtitle.text = "All-Time";
			else if(isEvent) header.subtitle.text = "Daily";
			else header.subtitle.text = "Weekly";

			Audio.play(AudioMap.BUTTON_PRESS);

			var target1:Image = isLifetime ? weeklyImage :  allTimeImage;
			var target2:Image = !isLifetime ? weeklyImage :  allTimeImage;

			TweenMax.to(target1, .35, {scale:0, ease:Back.easeIn});
			TweenMax.to(target2, .35, {delay:.35, scale:1, ease:Back.easeOut, onComplete:function():void
			{
				Quick.click(timelineButton, timelineClicked);

				var isGroup:Boolean = (barType == ProfileBar.TYPE_GROUP_LEADERBOARD)
					|| (barType == ProfileBar.TYPE_GROUP_LEADERBOARD_ALL_TIME)
					|| (barType == ProfileBar.TYPE_EVENT_LEADERBOARD_ALL_TIME);

				barType = isGroup
						? isLifetime
							? ProfileBar.TYPE_GROUP_LEADERBOARD_ALL_TIME
							: ProfileBar.TYPE_GROUP_LEADERBOARD
						: isLifetime // but not group
							? ProfileBar.TYPE_LEADERBOARD_ALL_TIME
							: ProfileBar.TYPE_LEADERBOARD;

				if(isEvent) barType = isLifetime ? ProfileBar.TYPE_EVENT_LEADERBOARD_ALL_TIME : ProfileBar.TYPE_EVENT_LEADERBOARD;

				if(!isEvent) Database.getLeaderboard(User.current.id, isGroup, isLifetime, onData);
				else
				{
					if(isLifetime) Database.getLifetimeEventLeaderboard(GFEvent.current.id, User.current.id, !isGroup, onData);
					else Database.getDailyEventLeaderboard(GFEvent.current.id, User.current.id, !isGroup, onData);
				}
			}});

			showSpinner();
		}

		private function showSpinner():void
		{
			if(!spinner.visible) spinner.show();

			scroller.visible = false;
			divider.visible = false;
			if(userBar) userBar.visible = false;
			scroller.scrollToPosition(0, 0, 0);
		}

		private function onData(data:XML):void
		{
			spinner.hide();
			scroller.visible = true;

			ProfileBar.refreshAll();

			var delay:Number = .1;
			var totalChildren:int = data.children().length();
			var isLeader:Boolean = totalChildren <= 25;

			if(isLeader)
			{
				divider.visible = false;
				scroller.height = Screen.height - Position.bottom(tabs);
			}
			else
			{
				divider.visible = true;
				scroller.height = Screen.height - Position.bottom(tabs) - BOTTOM_HEIGHT;
				TweenMax.fromTo(divider, 1, {alpha:0}, {alpha:1, delay:.5})
			}

			for each (var user:XML in data.children())
			{
				var u:User = new User(user);

				var isCurrent:Boolean = (u.id == User.current.id) || (u.usersID == User.current.id);
				var parent:DisplayObjectContainer = (isCurrent && !isLeader) ? this : scroller;

				var bar:ProfileBar = ProfileBar.create(parent, 0, u, barType);

				if(isCurrent)
				{
					if(isLeader)
					{
						bar.photo.animate(true);
					}
					else
					{
						userBar = bar;
						bar.y = Position.bottom(divider) + (Screen.bottom - Position.bottom(divider) - bar.height) / 2;
					}
				}

				//bar.touchable = false;

				var realDelay:Number = (isCurrent && !isLeader) ? .7 : delay;
				TweenMax.from(bar, .9, {alpha:0, delay:realDelay});
				delay += .09;
			}

			scroller.addChild(scrollerEndPadding);

			ProfileBar.showRanks(selected, isLifetime);
			scroller.verticalScrollPosition = 25;
			tabs.touchable = true;
		}
	}
}
