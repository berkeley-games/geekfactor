/**
 * Created by George on 10/20/2015.
 */
package scenes
{
	import architecture.AudioMap;
	import architecture.game.Room;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import components.Quiz;
	import components.VersusProfiles;
	import components.Timer;
	import components.Powerups;
	import components.Categories;

	import controls.ProfileBar;

	import controls.ProfilePhoto;

	import ten90.components.SpinnerRing;

	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.SceneController;
	import ten90.scene.StarlingScene;
	import ten90.tools.Quick;

	public class Game extends StarlingScene
	{
		private var profile:ProfilePhoto;
		private var quiz:Quiz;
		private var timer:Timer;
		private var categories:Categories;
		private var versusProfiles:VersusProfiles;
		private var powerups:Powerups;

		public override function init():void
		{
			ProfileBar.refreshAll();

			SceneController.disposeScene(Menu);

			if(Room.mode != Room.MODE_VERSUS && Room.mode != Room.MODE_VERSUS_REMATCH)
			{
				profile = new ProfilePhoto(this, User.current, 0, 75, ProfilePhoto.MEDIUM, false, false, false, false);
				profile.x = (Screen.stageWidth - profile.width) / 2;
				profile.setOptions(true, true, false, true, true);
				profile.score = 0;
			}

			quiz = getComponent(Quiz);
			quiz.setProfile(profile);
			quiz.onGameOver = onGameOver;

			timer = getComponent(Timer);
			categories = getComponent(Categories);
			versusProfiles = getComponent(VersusProfiles);
			powerups = getComponent(Powerups);

			switch (Room.mode)
			{
				case Room.MODE_SINGLE:
					break;

				case Room.MODE_VERSUS_REMATCH:
				case Room.MODE_VERSUS:
				case Room.MODE_GROUP_PRIVATE:
				case Room.MODE_GROUP_RANKED:
					Room.current.pingDB(true, onRoomUpdate);
					break;
			}

			stage.touchable = false;
			Quick.call(2, startGame);
		}

		public override function ready():void
		{
			Audio.crossFade(AudioMap.lastSong, AudioMap.GAME_MUSIC, 1, -1);
		}

		private function startGame():void
		{
			quiz.nextQuestion();

			Quick.call(1.4, function():void{ // hotfix
				stage.touchable = true;
			});
		}

		private function onGameOver(score:Number):void
		{
			var spinner:SpinnerRing = getComponent(SpinnerRing);
			spinner.show();

			TweenMax.from(spinner, .5, {delay:2, alpha:0});

			var animatedTargets:Array = [versusProfiles, categories, timer, powerups, quiz];
			if(profile) animatedTargets.unshift(profile);
			TweenMax.allTo(animatedTargets, .5, {y:"+=10", alpha:0, delay:1.5});

			Room.current.uploadScore(score, function():void
			{
				TweenMax.delayedCall(3.5, function():void
				{
					spinner.hide();
					SceneController.transition(Results);
				});
			});
		}

		private function onRoomUpdate():void
		{

		}
	}
}
