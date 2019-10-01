/**
 * Created by gperry on 3/31/2016.
 */
package scenes
{
	import architecture.AudioMap;
	import architecture.Database;
	import architecture.Fonts;
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.XMLHelper;
	import architecture.game.ColorMap;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import components.CustomError;

	import controls.BlueHeader;
	import controls.ProfileBar;
	import controls.TriviaButton;
	import controls.TriviaInput;

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;

	import starling.display.Button;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.text.TextField;

	import ten90.components.SpinnerRing;
	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.StarlingScene;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	public class StandaloneLeaderboard extends StarlingScene
	{
		private var spinner:SpinnerRing;

		private var scroller:ScrollContainer;
		private var selected:String;
		private var barType:String;
		private var divider:Quad;
		private var title:TextField;

		private var nameInput:TriviaInput;
		private var btnSubmit:TriviaButton;

		private var userBar:ProfileBar;

		private var timelineButton:Button;
		private var weeklyImage:Image;
		private var allTimeImage:Image;
		private var isLifetime:Boolean = false;

		private var header:BlueHeader;

		public override function init():void
		{
			header = new BlueHeader(this, "Leaderboard");
			header.subtitle.text = "Daily";

			title = Make.text(this, Screen.left, Position.bottom(header), Screen.width, 150, "", Fonts.SYSTEM, 72, ColorMap.BLACK, false, "center");

			scroller = Make.scrollContainer(this, Screen.left, Position.bottom(title), Screen.width, Screen.height - Position.bottom(title), "vertical", 75, 10);
			scroller.interactionMode = Scroller.INTERACTION_MODE_TOUCH;
			scroller.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			scroller.x = Screen.left;

			nameInput = new TriviaInput(this, Screen.stageHeight / 2, "Event Name", null, Screen.stageWidth / 2);
			btnSubmit = TriviaButton.pill(this, nameInput.y + nameInput.height * 1.5, "Load", ColorMap.CISCO_BLUE, loadEvent, true, true);

			Make.quad(this, Screen.left+25, Position.bottom(title), Screen.width-50, Skins.dividerStroke, ColorMap.GRAY).alpha = .5;

			Make.quad(scroller, 0, 0, scroller.width, 1, 0xFFFFFF).touchable = false;

			spinner = getComponent(SpinnerRing);

			weeklyImage = Make.image(this, ImageMap.LEADERBOARD_WEEKLY, Screen.right - 100, 75);
			allTimeImage = Make.image(this, ImageMap.LEADERBOARD_ALL_TIME, Screen.right - 100, 75);
			timelineButton = Make.emptyButton(this, weeklyImage.x - 50, weeklyImage.y - 50, 100 + weeklyImage.width, 100 + weeklyImage.height);

			Quick.pivot(weeklyImage, .5, .5, true);
			Quick.pivot(allTimeImage, .5, .5, true);

			allTimeImage.scale = 0;

			showInput(0);
		}

		public override function ready():void
		{
			Quick.click(timelineButton, timelineClicked);
		}

		private function timelineClicked():void
		{
			isLifetime = !isLifetime;
			if(isLifetime) header.subtitle.text = "All-Time";
			else header.subtitle.text = "Daily";

			Audio.play(AudioMap.BUTTON_PRESS);

			var target1:Image = isLifetime ? weeklyImage :  allTimeImage;
			var target2:Image = !isLifetime ? weeklyImage :  allTimeImage;

			TweenMax.to(target1, .35, {scale:0, ease:Back.easeIn});
			TweenMax.to(target2, .35, {delay:.35, scale:1, ease:Back.easeOut, onComplete:function():void
			{
				Quick.click(timelineButton, timelineClicked);

				if(isLifetime) Database.getStandaloneEventLeaderboard(nameInput.text, isLifetime, onData);
				else Database.getDailyEventLeaderboard(1, 1, isLifetime, onData);
			}});

			showSpinner();
		}

		private function showSpinner():void
		{
			if(!spinner.visible) spinner.show();

			scroller.visible = false;
			if(userBar) userBar.visible = false;
			scroller.scrollToPosition(0, 0, 0);
		}

		private function loadEvent():void
		{
			if(isLifetime) Database.getStandaloneEventLeaderboard(nameInput.text, isLifetime, onData);
			else Database.getDailyEventLeaderboard(1, 1, isLifetime, onData);

			Quick.call(30, updateLeaderboard, -1);
		}

		private function updateLeaderboard():void
		{
			if(isLifetime) Database.getStandaloneEventLeaderboard(nameInput.text, isLifetime, onData);
			else Database.getDailyEventLeaderboard(1, 1, isLifetime, onData);
		}

		private function showInput(t:Number = .5):void
		{
			TweenMax.to([btnSubmit, nameInput], t, {alpha: 1, onComplete: function():void{
				TweenMax.to([title, scroller], t, {alpha: 0, onComplete: function():void{}})
			}});
		}

		private function hideInput(t:Number = .5):void
		{
			TweenMax.to([btnSubmit, nameInput], t, {alpha: 0, onComplete: function():void{
				TweenMax.to([title, scroller], t, {alpha: 1, onComplete: function():void{}})
			}});
		}

		private function onData(data:XML):void
		{
			if (XMLHelper.getError(data))
			{
				CustomError.current.show("No event found with that name.");
				return;
			}

			hideInput();
			title.text = nameInput.text;

			spinner.hide();
			scroller.visible = true;

			ProfileBar.refreshAll();

			var delay:Number = 0;

			scroller.height = Screen.height - Position.bottom(title);

			for each (var user:XML in data.children())
			{
				var u:User = new User(user);
				var parent:DisplayObjectContainer = scroller;

				var bar:ProfileBar = ProfileBar.create(parent, 0, u, ProfileBar.TYPE_EVENT_LEADERBOARD);
				userBar = bar;

				TweenMax.from(bar, .5, {alpha:0, delay:delay});
				delay += .035;
			}

			ProfileBar.showRanks(selected);
			scroller.verticalScrollPosition = 25;
		}
	}
}