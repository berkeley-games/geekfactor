/**
 * Created by wmaynard on 3/3/2016.
 */
package controls
{
	import architecture.Skins;

	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.text.TextField;

	import ten90.scene.SceneController;
	import ten90.tools.Make;

	import tools.TriviaText;

	public class RankingIcon extends DisplayObjectContainer
	{
		public var level:int = 0;

		private var bg:Image;
		private var rank:TextField;

	    public function RankingIcon(parent:*, categoryID:int = 0, level:int = 0)
	    {
		    super();

		    this.level = level + 1;

			switch(level)
			{
				// 1, 2, 3
				case -1:
				case 0:
				case 1:
				case 2:
					bg = Make.image(this, Skins.LEVEL_1_MEDAL_SMALL);
					break;

				// 4, 5, 6, 7
				case 3:
				case 4:
				case 5:
				case 6:
					bg = Make.image(this, Skins.LEVEL_2_MEDAL_SMALL);
					break;

				// 8, 9, 10
				case 7:
				case 8:
				case 9:
					bg = Make.image(this, Skins.LEVEL_3_MEDAL_SMALL);
					break;

				default:
					bg = Make.image(this, Skins.LEVEL_1_MEDAL_SMALL);
					break;
			}

		    rank = TriviaText.create(this,
			    {
				    w:bg.width,
				    h:bg.height,
				    size:72,
				    style:TriviaText.WHITE_MEDIUM,
				    text:String(level+1),
				    bold:true
			    }
		    );

			var className:String = SceneController.currentScene.className;
			if(className == "Leaderboards" || className == "Friends") this.scale = 1.5;

		    if (!categoryID)
		    {
			    this.visible = false;
			    return;
		    }

		    parent.addChild(this);
	    }

		public function levelUp():void
		{
			rank.text = String(++level);

			switch(level - 1)
			{
				// 1, 2, 3
				case -1:
				case 0:
				case 1:
				case 2:
					bg = Make.image(this, Skins.LEVEL_1_MEDAL_SMALL);
					break;

				// 4, 5, 6, 7
				case 3:
				case 4:
				case 5:
				case 6:
					bg = Make.image(this, Skins.LEVEL_2_MEDAL_SMALL);
					break;

				// 8, 9, 10
				case 7:
				case 8:
				case 9:
					bg = Make.image(this, Skins.LEVEL_3_MEDAL_SMALL);
					break;

				default:
					bg = Make.image(this, Skins.LEVEL_1_MEDAL_SMALL);
					break;
			}
		}
	}
}
