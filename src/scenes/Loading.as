package scenes
{
	import architecture.AppContext;
	import architecture.AudioMap;
	import architecture.Skins;

	import controls.Setting;

	import ten90.base.Assets;
	import ten90.components.SpinnerRing;
	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.StarlingScene;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	public class Loading extends StarlingScene
	{
		private var nextScene:Class;

		public override function init():void
		{
			Save.init("CiscoTriviaNet", true);
			Setting.loadAll();
			Skins.init();

			getComponent(SpinnerRing).show();

			if(AppContext.isLeaderboard) nextScene = Leaderboards;
			else if(Save.data("gameLaunched") != true)
			{
				Save.data("gameLaunched", true);
				nextScene = Register;
			}
			else nextScene = Login;
		}

		public override function ready():void
		{
			if(!AppContext.isLeaderboard)
				Quick.call(.1, Audio.fadeIn, 0, [AudioMap.LOADING_MUSIC, 2, -1]);

			Assets.queue("res/parts");
			Assets.queue("res/layouts");
			Assets.queue("res/audio/rest");
			Assets.queue("res/sheets/rest");

			Assets.load(loadComplete);
		}

		private function loadComplete():void
		{
			Quick.call(.25, transition, 0, [nextScene]);
		}
	}
}