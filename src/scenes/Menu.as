package scenes
{
	import architecture.AudioMap;
	import architecture.ImageMap;
	import architecture.game.Achievement;
	import architecture.game.Ad;
	import architecture.game.GFEvent;
	import architecture.game.Notification;
	import architecture.game.Room;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import components.CustomError;
	import components.ModeSelector;
	import components.Tutorial;

	import controls.ProfilePhoto;

	import starling.display.Button;
	import starling.events.Event;

	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.SceneController;
	import ten90.scene.StarlingScene;
	import ten90.scene.Transitions;
	import ten90.tools.Make;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	import tools.Helper;

	public class Menu extends StarlingScene
	{
		public static const PROFILE_Y:int = Screen.top + 275;

		public static var showRankDialog:Boolean = true;

		public var profile:ProfilePhoto;
		public var modeSelector:ModeSelector;
		public var shopButton:Button;
		public var eventButton:Button;

		private var tutorial:Tutorial;

		public override function init():void
		{
			touchable = false;
			componentContainer.touchable = false;

			modeSelector = getComponent(ModeSelector);
			modeSelector.touchable = false;

			shopButton = Make.button(this, 0, 885, ImageMap.BUTTON_STORE);
			eventButton = Make.button(this, 0, 885, ImageMap.BUTTON_EVENT);

			profile = new ProfilePhoto(this, User.current, 0, PROFILE_Y, ProfilePhoto.LARGE, false, true);
			profile.addPhotoClick(function():void{
				transition(Profile);
			});

			Quick.hide([modeSelector, shopButton, eventButton, profile]);

			profile.x = (Screen.stageWidth - profile.photoWidth) / 2;

			if (Ad.current && Ad.current.isBanner) Ad.current.show();
			else Ad.loadBanner();
		}

		public override function ready():void {}

		public override function script(e:Event = null):void
		{
			Room.current = null;

			if(!Audio.isPlaying(AudioMap.MENU))
				Audio.crossFade(AudioMap.lastSong, AudioMap.MENU_MUSIC, .5, -1);

			Quick.call(4, Notification.recurringCheck);

			Quick.removeClick(shopButton);
			Quick.click(shopButton, shopClicked);

			Quick.removeClick(eventButton);
			Quick.click(eventButton, eventClicked);

			profile.fadeText(true);

			if(SceneController.previousScene != PregameSplash)
			{
				if(SceneController.previousScene != Store)
					TweenMax.fromTo(profile, .85, {alpha:0, y:PROFILE_Y-35}, {y:PROFILE_Y, alpha:1, delay:.4, ease:Back.easeOut});

				TweenMax.fromTo(shopButton, .75, {x:Screen.right}, {alpha:1, delay:.5, x:Screen.right - shopButton.width - 35, ease:Back.easeOut});
				TweenMax.fromTo(eventButton, .75, {x:Screen.left - eventButton.width}, {alpha:1, delay:.5, x:Screen.left + 35, ease:Back.easeOut});

				Quick.show([modeSelector, shopButton, eventButton, profile]);
			}

			TweenMax.fromTo(modeSelector, .85, {y:Screen.bottom + 50}, {alpha:1, y:Screen.bottom - modeSelector.height + 1050, delay:.6, ease:Back.easeOut.config(.75), onComplete:function():void
			{
				modeSelector.touchable = true;

				if(Save.data("achievementDataInitialized" + User.current.id) != true)
				{
					Save.data(Achievement.SAVE_ACHIEVEMENT_WIN_A_CHALLENGE, 0);
					Save.data(Achievement.SAVE_ACHIEVEMENT_MAKE_FRIENDS, 0);
					Save.data(Achievement.SAVE_ACHIEVEMENT_QUESTIONS_IN_A_CATEGORY, 0);
					Save.data(Achievement.SAVE_ACHIEVEMENT_QUESTIONS_IN_A_ROW, 0);
					Save.data(Achievement.SAVE_ACHIEVEMENT_CREATE_GAME, 0);
					Save.data(Achievement.SAVE_ACHIEVEMENT_SUBMIT_A_QUESTION, 0);

					Save.data("correctAnswersIn_1" + User.current.id, 0);
					Save.data("correctAnswersIn_2" + User.current.id, 0);
					Save.data("correctAnswersIn_3" + User.current.id, 0);
					Save.data("correctAnswersIn_4" + User.current.id, 0);
					Save.data("correctAnswersIn_5" + User.current.id, 0);
					Save.data("correctAnswersIn_6" + User.current.id, 0);

					Save.data("achievementDataInitialized" + User.current.id, true);
				}

				// show tutorial
				if(Save.data("tutorialWatched" + User.current.id) != true) // undefined
				{
					tutorial = getComponent(Tutorial);
					tutorial.onComplete = tutorialComplete;
					tutorial.create();

					TweenMax.from(tutorial, 1, {alpha:0});

					Save.data("tutorialWatched" + User.current.id, true);
				}
				// explain events?
				else
				{
					if(Save.data("eventExplained" + User.current.id) != true && GFEvent.current)
					{
						getComponent(CustomError).show("Play Versus or Group ranked matches to climb the event leaderboard!");
						Save.data("eventExplained" + User.current.id, true);
					}
				}

				touchable = true;
				componentContainer.touchable = true;
			}});

			if(Ad.current && Ad.current.sprite)
			{
				Ad.current.sprite.touchable = false;
				Quick.call(1, function():void {
					if(Ad.current) Ad.current.sprite.touchable = true;
				});
			}

			if (showRankDialog) {}

			User.current.getFriends(function(data:XML):void
			{
				var friends:int = 0;

				for each (var xml:XML in data.children())
					if (!Helper.xmlHasError(xml)) friends++;

				Save.data(Achievement.SAVE_ACHIEVEMENT_MAKE_FRIENDS, friends);
			});

			checkAchievements();
		}

		/**
		* TODO: i don't think this works if you get multiple achievements at once,
		*   we need to push them into a queue and show them one by one
		*/
		private function onRank(message:String = ""):void
		{
			User.current.loadAchievements(Achievements.onData);
			getComponent(CustomError).show(message, "", checkAchievements);
		}

		private function checkAchievements():void
		{
			for each(var ach:Achievement in User.current.achievements)
			{
				if(ach.thresholds.length > ach.rank)
				{
					User.current.checkAchievementForRankUp
					(
						ach.name,
						User.current.getProgressForAchievement(ach.name),
						onRank
					);
				}
			}
		}

		public override function terminate():void {}

		private function tutorialComplete():void
		{
			TweenMax.to(tutorial,.35, {alpha:0, onComplete:function():void
			{
				tutorial.parent.removeChild(tutorial);
				tutorial = null;
			}});
		}

		private function eventClicked():void
		{
			Audio.play(AudioMap.BUTTON_PRESS);
			animateOut(gotoEvents);
		}

		private function shopClicked():void
		{
			Audio.play(AudioMap.BUTTON_PRESS);
			animateOut(gotoStore);
		}

		private function gotoStore():void
		{
			transition(Store, Transitions.NONE, 1, false);
		}

		private function gotoEvents():void
		{
			transition(Events, Transitions.NONE, 1, false);
		}

		public function animateOut(callback:Function):void
		{
			TweenMax.to(shopButton, .75, {x:Screen.right, ease:Back.easeIn});
			TweenMax.to(eventButton, .75, {x:Screen.left - eventButton.width, ease:Back.easeIn});

			profile.fadeText();

			modeSelector.animateOut(callback)();
		}
	}
}