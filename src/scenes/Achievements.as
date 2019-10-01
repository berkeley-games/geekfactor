/**
 * Created by gperry on 9/21/2016.
 */
package scenes
{
	import architecture.ImageMap;
	import architecture.game.Achievement;
	import architecture.game.User;

	import components.AchievementProgress;

	import controls.BlueHeader;

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;

	import ten90.components.SpinnerRing;

	import ten90.device.Screen;
	import ten90.scene.StarlingScene;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.utilities.Save;

	import tools.Helper;

	public class Achievements extends StarlingScene
	{
		private static var achievementList:Vector.<Achievement>;

		private var scroller:ScrollContainer;
		private var spinner:SpinnerRing;

		public override function init():void
		{
			var header:BlueHeader = new BlueHeader(this, "Achievements");

			spinner = getComponent(SpinnerRing);

			scroller = Make.scrollContainer(this, Screen.left, Position.bottom(header), Screen.width, Screen.height - Position.bottom(header), "vertical", 75, 10);
			scroller.interactionMode = Scroller.INTERACTION_MODE_TOUCH;
			scroller.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;

			Make.quad(scroller, 0, 0, scroller.width, 1, 0xFFFFFF).touchable = false;

			if(!User.current.achievements)
			{
				spinner.show();
				User.current.loadAchievements(function(list:Vector.<Achievement>):void
				{
					spinner.hide();
					onData(list, createList);
				});
			}
			else createList();
		}

		public static function onData(list:Vector.<Achievement>, callback:Function = null):void
		{
			achievementList = list;
			if(callback) callback();
		}

		private function createList():void
		{
			if(!achievementList)
			{
				if(User.current.achievements) achievementList = User.current.achievements;
				else return;
			}

			for (var i:int = 0; i < achievementList.length; i++)
			{
				var ach:Achievement = achievementList[i];

				if(ImageMap.achievementFromName(ach.name))
				{
					var threshold:String = (ach.rank < ach.thresholds.length)
							? Helper.formatNumber(ach.thresholds[ach.rank])
							: "Complete!";

					var reward:String = (ach.rank < ach.coinRewards.length)
							? Helper.formatNumber(ach.coinRewards[ach.rank])
							: Helper.formatNumber(ach.coinRewards[ach.rank - 1]);

					var progress:String = Save.data(ach.name + User.current.id);
					if(ach.name == Achievement.ACHIEVEMENT_GAMES_WON) progress = String(User.current.lifetimeWins);
					else if(ach.name == Achievement.ACHIEVEMENT_PLAYER_LEVEL) progress = String(User.current.level);
					else if(ach.name == Achievement.ACHIEVEMENT_QUESTIONS_IN_A_CATEGORY)
					{
						var tempThreshold:int = (threshold == "Complete!")
								? ach.thresholds[ach.rank-1]
								: ach.thresholds[ach.rank];

						var runningTotal:int = 0;
						for(var j:int = 1; j < 7; j++)
							runningTotal += Math.min(Save.data("correctAnswersIn_" + j + User.current.id), tempThreshold);

						progress = String(int((runningTotal / (tempThreshold * 6)) * 10));
					}

					var item:AchievementProgress = new AchievementProgress
					(
							ImageMap.achievementFromName(ach.name),
							ach.rank,
							reward,
							ach.name,
							ach.instructions,
							progress,
							threshold,
							i == achievementList.length - 1
					);

					scroller.addChild(item);
				}
			}
		}
	}
}
