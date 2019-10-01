package
{
	import architecture.AppContext;
	import architecture.Database;
	import architecture.game.ColorMap;

	import com.mesmotronic.ane.AndroidFullScreen;

	import components.Components;

	import scenes.Loading;

	import ten90.base.Application;
	import ten90.base.Assets;
	import ten90.device.System;
	import ten90.utilities.ane.Facebook;
	import ten90.utilities.ane.PushNotification;

	public class Main extends Application
	{
		public function Main()
		{
			gestouch = true;
			stageWidth = 1080;
			stageHeight = 1920;
			color = ColorMap.WHITE;
			initialScene = Loading;
			idleMode = "keepAwake";
			fullScreenNoStretch = true;
			onExit = AppContext.onAppExit;
			onInvoke = AppContext.onAppInvoke;
			fullScreen = AppContext.isLeaderboard;

			if(System.isMobile)
			{
				onDeactivate = AppContext.onAppExit;
				onActivate = AppContext.onAppReturn;

				Database.getAppVar("FacebookSecret", function(secret:String):void {
					Facebook.init(secret);
				});

				if(System.isAndroid)
				{
					onSuspend = AppContext.onAppExit;
					AndroidFullScreen.immersiveMode();

					// server key: AIzaSyBmEASR8cMqMN4df7Zm9nxPbr7gBFG9XuM
					PushNotification.init("747399574859", null);
				}
			}
			else if(!AppContext.isLeaderboard)
			{
				windowScale = .85;
				windowX = 150;
				windowY = 65;
			}

			super();
		}

		public override function ready():void
		{
			Components.init();

			Assets.queue("res/sheets/loading");
			Assets.queue("res/audio/loading");

			Assets.load(start);
		}
	}
}