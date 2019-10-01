/**
 * Created by George on 9/27/2016.
 */
package architecture
{
	import architecture.game.Room;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.mesmotronic.ane.AndroidFullScreen;

	import flash.events.Event;

	import scenes.Game;

	import scenes.Menu;


	import ten90.base.Application;

	import ten90.device.System;
	import ten90.media.Audio;
	import ten90.scene.SceneController;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	public class AppContext
	{
		public static var isLeaderboard:Boolean = false;

		public static function onAppExit(e:Event):void
		{
			e.preventDefault();

			try
			{
				Save.flush();

				//TODO: Remove System.isDesktop to work on the task in function "reset"
				if(System.isDesktop && Room.current && SceneController.currentScene is Game)
				{
					transitionTo = Menu;
					TweenMax.killAll();
					Quick.removeAllCalls();
					Room.current.leaveAndUpload(User.current.score, reset);
				}
				else if(System.isDesktop) Application.exit(false);

				Application.starlingInstance.stop();

				if(AudioMap.lastSong && System.isAndroid)
					Audio.pause(AudioMap.lastSong);
			}
			catch(e:*)
			{
				trace(e);
			}
		}

		private static var transitionTo:Class;
		private static function reset(e:*):void
		{
			Room.current = null;
			if(System.isDesktop) Application.exit();
			else
			{
				//TODO: fix bug where playing a game after getting kicked out locks up the quiz
			}
		}

		public static function onAppReturn(e:Event):void
		{
			Application.starlingInstance.start();

			if(System.isAndroid) AndroidFullScreen.immersiveMode();

			if(transitionTo)
			{
				SceneController.transition(transitionTo);
				transitionTo = null;
			}
			else
			{
				if(AudioMap.lastSong && System.isAndroid && !Audio.isPlaying(AudioMap.lastSong))
					Audio.play(AudioMap.lastSong, -1);
			}
		}

		public static function onAppInvoke(e:*):void
		{

		}
	}
}
