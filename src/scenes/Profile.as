/**
 * Created by George on 8/12/2016.
 */
package scenes
{
	import architecture.Database;
	import architecture.Fonts;
	import architecture.ImageMap;
	import architecture.game.Achievement;
	import architecture.game.ColorMap;
	import architecture.game.ColorMap;
	import architecture.game.GFEvent;
	import architecture.game.User;
	
	import components.CustomError;
	
	import controls.BlueHeader;

	import controls.ProfilePhoto;
	import controls.RankingIcon;

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;

	import starling.display.BlendMode;

	import starling.display.Image;

	import starling.display.Quad;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;

	import ten90.device.Screen;

	import ten90.scene.StarlingScene;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;
	
	import tools.Helper;

	import tools.TriviaText;

	public class Profile extends StarlingScene
	{
		// who are we looking at?
		public static var user:User;

		private const PADDING:int = 20;
		
		private var addFriend:TextField;
		private var levelLabel:TextField;

		public override function init():void
		{
			var header:BlueHeader = new BlueHeader(this, "Player Profile");

			var photo:ProfilePhoto = new ProfilePhoto(this, user, 0, Menu.PROFILE_Y, ProfilePhoto.LARGE, false, true);
			photo.x = (Screen.stageWidth - photo.photoWidth) / 2;
			photo.setOptions(false, true, true, false);

			var currentEvent:String =
				    user.currentEventFriendlyName && user.currentEventFriendlyName.length > 0 ? user.currentEventFriendlyName
					    : user.currentEventName&& user.currentEventName.length > 0 ? user.currentEventName
					    : "No Event";

			var inEvent:Boolean = currentEvent != "No Event";

			var quadColor:uint = inEvent ? ColorMap.CISCO_BLUE : ColorMap.LIGHT_GRAY;
			var quad:Quad = Make.quad(this, Screen.left, Position.bottom(photo) - 65, Screen.width, 225, quadColor);
			var eventImage:Image = Make.image(this, ImageMap.BUTTON_EVENT, Screen.left + PADDING);
			Position.centerY(eventImage, Position.centerY(quad));

			var eventColor:uint = inEvent ? ColorMap.WHITE : ColorMap.GRAY;
			var eventField:TextField = TriviaText.create(this, {color:eventColor, size:90, x:Screen.left,
				y:quad.y, height:quad.height, width:Screen.width, text:currentEvent});

			const LEFT_TEXT_X:int = Screen.left + PADDING;
			const RIGHT_TEXT_X:int = Screen.right - PADDING;

			var winPercentage:* = int(user.lifetimeWins / (user.lifetimeWins + user.lifetimeLosses) * 100) / 100;
			if(winPercentage == 1) winPercentage = "1.000";
			if(String(winPercentage).charAt(0) == "0") winPercentage = String(winPercentage).substr(1, String(winPercentage).length) + "0";

			var winsLabel:TextField = TriviaText.create(this, {color:ColorMap.GRAY, size:50, x:LEFT_TEXT_X, y:Position.bottom(quad) + 100, width:Screen.width, text:"Rank Record", halign:"left"});
			var winsScore:TextField = Make.text(this, 0, winsLabel.y, 500, winsLabel.height, Helper.formatNumber(user.lifetimeWins) + " - " + Helper.formatNumber(user.lifetimeLosses) + " (" + winPercentage + ")", Fonts.SYSTEM, 50, ColorMap.GRAY, false, "right");
			Position.right(winsScore, RIGHT_TEXT_X);

			var leaderLabel:TextField = TriviaText.create(this, {color:ColorMap.GRAY, size:50, x:LEFT_TEXT_X, y:Position.bottom(winsLabel) + 60, width:Screen.width, text:"Rank Score", halign:"left"});
			var userScore:TextField = Make.text(this, 0, leaderLabel.y, 200, leaderLabel.height, Helper.formatNumber(user.lifetimeRankedScore + user.lifetimeGroupScore), Fonts.SYSTEM, 50, ColorMap.GRAY, false, "right");
			Position.right(userScore, RIGHT_TEXT_X-60);

			var rankLogo:Image = Make.image(this, ImageMap.SCORE);
			Position.right(rankLogo, RIGHT_TEXT_X);
			Position.centerY(rankLogo, Position.centerY(userScore) - 1);

			var earningLabel:TextField = TriviaText.create(this, {color:ColorMap.GRAY, size:50, x:LEFT_TEXT_X, y:Position.bottom(leaderLabel) + 60, width:Screen.width, text:"Lifetime Earnings", halign:"left"});
			var userMoney:TextField = Make.text(this, 0, earningLabel.y, 200, earningLabel.height, Helper.formatNumber(user.lifetimeEarnings), Fonts.SYSTEM, 50, ColorMap.GRAY, false, "right");
			Position.right(userMoney, RIGHT_TEXT_X-60);

			var coinLogo:Image = Make.image(this, ImageMap.IMG_COIN);
			Position.right(coinLogo, RIGHT_TEXT_X);
			Position.centerY(coinLogo, Position.centerY(userMoney) - 1);

			var categoryLabel:TextField = TriviaText.create(this, {color:ColorMap.GRAY, size:50, x:LEFT_TEXT_X, y:Position.bottom(earningLabel) + 60, width:Screen.width, text:"Best Category", halign:"left"});
			var img:Image = Make.image(this, ImageMap.getCategoryIcon(user.bestCategory, true, true));
			img.scale = 1.25;

			Position.centerY(img, Position.centerY(categoryLabel));
			Position.right(img, RIGHT_TEXT_X - 5);

			levelLabel = TriviaText.create(this, {color:ColorMap.GRAY, size:50, x:LEFT_TEXT_X, y:Position.bottom(categoryLabel) + 60, text:"Achievements", halign:"left"});
			levelLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;

			addFriend = TriviaText.create(this,
			{
				style:TriviaText.WHITE_LARGE,
				text:"+",
				size:85
			});
			
			Position.right(addFriend, Screen.right - 60);
			Position.top(addFriend, Screen.top + 35);
			
			if(User.current.id == user.id)
			{
				addFriend.visible = false;
				onData(user.achievements);
			}
			else user.loadAchievements(onData);
		}

		public override function ready():void
		{
			Quick.click(addFriend, friendRequest);
		}
		
		private function friendRequest():void
		{
			Database.addFriend(User.current.id, user.id, friendAdded);
		}
		
		private function friendAdded():void
		{
			addFriend.text = "✓";
			getComponent(CustomError).show("Friend request sent!")
		}

		private function onData(list:Vector.<Achievement>):void
		{
			var scroller:ScrollContainer = Make.scrollContainer(this, Position.right(levelLabel), Position.top(levelLabel)-10, Screen.width-Position.right(levelLabel), levelLabel.height+20, "horizontal", 10, 0, "", NaN, 0, 0, "top", "right");
			scroller.interactionMode = Scroller.INTERACTION_MODE_TOUCH;
			scroller.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;

			for each(var ach:Achievement in list)
				if(ach.rank > 0) Make.image(scroller, ImageMap.achievementFromName(ach.name) + "on").scale = .4;

			if(scroller.numChildren == 0)
				Make.text(scroller, 0, 0, 200, scroller.height, "None", Fonts.SYSTEM, 50, ColorMap.GRAY, false, "right");

			Make.quad(scroller, 0, 0, 5, scroller.height, ColorMap.WHITE).blendMode = BlendMode.NONE;
		}
	}
}
