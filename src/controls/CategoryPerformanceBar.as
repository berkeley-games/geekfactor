/**
 * Created by wmaynard on 3/10/2016.
 */
package controls {
	import architecture.ImageMap;
	import architecture.game.ColorMap;
	import architecture.game.Question;
	import architecture.game.Room;

	import com.greensock.TweenMax;
	import com.myflashlab.air.extensions.packagemanager.PackageManager;

	import starling.display.DisplayObjectContainer;
	import starling.display.Image;

	import ten90.tools.Make;
	import ten90.tools.Quick;

	public class CategoryPerformanceBar extends DisplayObjectContainer
	{
		private var icon:Image;
		private var bar:Image;
		private var barBG:Image;
		private var enemyBG:Image;
		private var enemyBar:Image;
		private var categoryID:int;

		private static const FILL_COLOR:int = ColorMap.YELLOW;
		private static const ENEMY_FILL_COLOR:int = ColorMap.ORANGE;

		public function CategoryPerformanceBar(parent:*, categoryID:int, percent:int, scaleY:Number, versus:Boolean = false)
		{
			// Scale the icon to be no larger than 100x100.
			var maxD:int = 100;
			icon = Make.image(this, ImageMap.getCategoryIcon(categoryID, true));
			var limiter:int = icon.height > icon.width ? icon.height : icon.width;
			icon.scale = limiter < maxD ? 1 : maxD / limiter;

			this.categoryID = categoryID;

			barBG = Make.shapeImage(this, icon.x + icon.width / 2, 0, maxD / 4, 300 * scaleY, true, FILL_COLOR);
			barBG.x -= barBG.width / 2;
			barBG.alpha = 0.3;

			if (versus)
			{
				barBG.width /= 2;
				enemyBG = Make.shapeImage(this, barBG.x + barBG.width, barBG.y, barBG.width, barBG.height, true, ENEMY_FILL_COLOR);
				enemyBG.alpha = barBG.alpha;
			}

			if (percent > 0)
			{
				bar = Make.shapeImage(this, barBG.x + barBG.width / 2, barBG.y + barBG.height, barBG.width, barBG.height * percent / 100, true, FILL_COLOR);
				Quick.pivot(bar, .5, 1);
				bar.scaleY = 0;
			}

			icon.y = barBG.y + barBG.height + 20;

			trace("Performance in Category", categoryID, ":", percent);

			parent.addChild(this);
		}

		public function animate():void
		{
			if (bar)
				TweenMax.fromTo(bar, 1, {scaleY: 0},  {scaleY: 1});
		}

		public function animateEnemy():void
		{
			if (!enemyBG)
				return;

			var points:int = 0;
			var maxPoints:int = 0;
			for each (var q:Question in Room.current.questions)
				if (q.categoryID == categoryID) {
					// This works, but this is a perfect example of why Player and User need to be merged.
					try
					{
						points += Room.current.getPlayerByID(Room.current.topOpponent.id).getScoreForQuestion(q.numberInSet);
						maxPoints += q.maxScore;
					}
					catch(e:*){}
				}

			try
			{
				enemyBar = Make.shapeImage(this, enemyBG.x + enemyBG.width / 2, enemyBG.y + enemyBG.height, enemyBG.width, enemyBG.height * (points / maxPoints), true, ENEMY_FILL_COLOR);
				Quick.pivot(enemyBar, .5, 1);
				TweenMax.fromTo(enemyBar, 1, {scaleY: 0}, {scaleY: 1});
			}
			catch(e:*)
			{
				trace("The enemy user most likely did not score any points for category " + categoryID);
			}
		}
	}
}