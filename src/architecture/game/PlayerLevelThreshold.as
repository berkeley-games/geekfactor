/**
 * Created by wmaynard on 8/24/2016.
 */
package architecture.game
{
	import architecture.Database;

	public class PlayerLevelThreshold extends XMLClass
	{
		private static const LEVEL:String = "Level";
		private static const SCORE_REQUIRED:String = "ScoreRequired";

		public static var list:Vector.<PlayerLevelThreshold> = new Vector.<PlayerLevelThreshold>();

		public var level:int;
		public var scoreRequired:int;

		public function PlayerLevelThreshold(child:XML)
		{
			super(child);

			level = parseInt(att(LEVEL));
			scoreRequired = parseInt(att(SCORE_REQUIRED));
		}

		public static function load():void
		{
			Database.getPlayerLevelThresholds(function(data:XML):void{
				while (list.length)
					list.removeAt(0);
				for each (var x:XML in data.children())
					list.push(new PlayerLevelThreshold(x));
			});
		}

		public static function get current():PlayerLevelThreshold
		{
			try
			{
				for each (var p:PlayerLevelThreshold in list)
					if (p.level == User.current.level)
						return p;
				return list[list.length - 1];
			}
			catch(e:*){}

			return null;
		}

		public static function get scoreForCurrent():int
		{
			var p:PlayerLevelThreshold = current;
			return p ? p.scoreRequired : 0;
		}

		public static function get next():PlayerLevelThreshold
		{
			try
			{
				for each (var p:PlayerLevelThreshold in list)
					if (p.level == User.current.level + 1)
						return p;
				return list[list.length - 1];
			}
			catch(e:*){}

			return null;
		}
		public static function get scoreForNext():int
		{
			var p:PlayerLevelThreshold = next;
			return p ? p.scoreRequired : 0;
		}
	}
}