/**
 * Created by wmaynard on 3/18/2016.
 */
package scenes
{
	import architecture.Fonts;
	import architecture.game.Challenge;

	import com.greensock.TweenMax;

	import components.BackButton;

	import controls.BlueHeader;

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;

	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.scene.SceneController;
	import ten90.scene.StarlingScene;
	import ten90.tools.Make;

	public class Challenges extends StarlingScene
	{
		private var titlebg:BlueHeader;
		private var scroller:ScrollContainer;
		private var noResults:TextField;

		public override function init():void
		{
			titlebg = new BlueHeader(this, "Challenges");

			scroller = Make.scrollContainer(this, Screen.left, titlebg.y + titlebg.height * 1.5, Screen.width, Screen.height - titlebg.height, "vertical", 25);
			scroller.interactionMode = Scroller.INTERACTION_MODE_TOUCH;

			Challenge.getChallenges(function(list:Vector.<Challenge>):void
			{
				for each (var c:Challenge in list)
					scroller.addChild(c.profileBar);

				if(list.length == 0)
				{
					noResults = Make.text(scroller, 0, 0, scroller.width, 200, "No results!", Fonts.SYSTEM, 48, 0, false, "center");
					TweenMax.from(noResults, .5, {alpha:0});
				}
				else if(noResults)
				{
					noResults.parent.removeChild(noResults);
				}
			});
		}

		public override function ready():void
		{
			getComponent(BackButton).transitionTo = MultiplayerMenu;
		}
	}
}