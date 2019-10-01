/**
 * Created by gperry on 10/21/2015.
 */
package components
{
	import architecture.ImageMap;
	import architecture.game.ColorMap;
	import architecture.game.Room;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import controls.TriviaButton;

	import scenes.CategorySelection;
	import scenes.MultiplayerMenu;
	import scenes.PregameSplash;

	import starling.display.Shape;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.scene.SceneController;
	import ten90.scene.Transitions;
	import ten90.tools.Quick;

	public class ModeSelector extends Component
	{
		public var singleMode:TriviaButton;
		public var versusMode:TriviaButton;
		public var multiMode:TriviaButton;

		public override function ready():void
		{
			var blueBG:Shape = new Shape();
	        var radius:int = Screen.stageWidth / 2;
	        blueBG.graphics.beginFill(ColorMap.CISCO_BLUE);
	        blueBG.graphics.drawCircle(radius, radius, radius);
	        blueBG.graphics.drawRect(0, blueBG.height / 2, blueBG.width, Screen.stageHeight * 0.75);
	        blueBG.graphics.endFill();
			addChild(blueBG);

			singleMode = TriviaButton.circle(this, ImageMap.ICON_SINGLE_PLAYER, Screen.stageWidth / 3, 315, ColorMap.LIGHT_GREEN, animateOut(singleClicked), true);
			versusMode = TriviaButton.circle(this, ImageMap.ICON_VERSUS, Screen.stageWidth * 2 / 3, singleMode.y, ColorMap.LIGHT_GREEN, animateOut(rankedClicked), true);
			multiMode = TriviaButton.circle(this, ImageMap.ICON_MULTIPLAYER, Screen.stageWidth / 2, singleMode.y + 285, ColorMap.LIGHT_GREEN, animateOut(multiplayerClicked), true);

			this.x = (Screen.stageWidth - this.width) / 2;
			this.y = Screen.bottom - this.height + 1050;
		}

		private function singleClicked():void
		{
			Room.mode = Room.MODE_SINGLE;
			showCats();
		}

		private function rankedClicked():void
		{
			Room.selectedCategory = 0;
			Room.mode = Room.MODE_VERSUS;
			SceneController.transition(PregameSplash, Transitions.MANUAL, 1, false);
		}

		private function multiplayerClicked():void
		{
			Room.mode = Room.MODE_GROUP_RANKED;
			SceneController.transition(MultiplayerMenu, Transitions.NONE, 1, false);
		}

		public function animateOut(callback:Function):Function
		{
			var self:ModeSelector = this;
			return function():void
			{
				Quick.call(1, function(callback2:Function):void
				{
					if(callback2 == singleClicked) singleMode.listen();
					else if(callback2 == rankedClicked) versusMode.listen();
					else if(callback2 == multiplayerClicked) multiMode.listen()

				}, 0, [callback]);

				TweenMax.to(self, .75, {ease:Back.easeIn.config(1), y:Screen.bottom+50, onComplete:function():void{
					Quick.call(.1, callback);
				}});
			}
		}

		private function showCats():void
		{
			SceneController.transition(CategorySelection, Transitions.NONE, 1, false);
		}
	}
}
