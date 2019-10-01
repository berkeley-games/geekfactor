/**
 * Created by wmaynard on 4/6/2016.
 */
package scenes
{
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.game.Challenge;
	import architecture.game.ColorMap;
	import architecture.game.Room;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import components.BackButton;

	import controls.TriviaButton;

	import starling.display.Image;

	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;

	import ten90.device.Screen;
	import ten90.scene.StarlingScene;
	import ten90.scene.Transitions;
	import ten90.tools.Make;
	import ten90.tools.Position;

	import tools.Helper;
	import tools.TriviaText;

	public class MultiplayerMenu extends StarlingScene
	{
		private var btnMultiplayer:TriviaButton;
		private var container:Sprite;

		private var btnCreate:TriviaButton;
		private var btnChallenges:TriviaButton;
		private var btnMatchmaking:TriviaButton;

		public override function init():void
		{
			container = new Sprite();

			var blueBG:Shape = new Shape();
			var radius:int = Screen.stageWidth / 2;
			blueBG.graphics.beginFill(ColorMap.CISCO_BLUE);
			blueBG.graphics.drawCircle(radius, radius, radius);
			blueBG.graphics.drawRect(0, blueBG.height / 2, blueBG.width, Screen.stageHeight * 0.75);
			blueBG.graphics.endFill();
			blueBG.y = 300;
			container.addChild(blueBG);

			btnMultiplayer = TriviaButton.circle(blueBG, ImageMap.ICON_MULTIPLAYER, Screen.stageWidth / 2, blueBG.y - 100, ColorMap.LIGHT_GREEN);

			btnMatchmaking = TriviaButton.pill(blueBG, btnMultiplayer.y + btnMultiplayer.height * 1.2 + 175, "Ranked Match", ColorMap.LIGHT_GREEN, animateOut(PregameSplash, Transitions.MANUAL), true, true);
			btnCreate = TriviaButton.pill(blueBG, btnMatchmaking.y + btnMatchmaking.height * 1.2, "Create a Game", ColorMap.LIGHT_GREEN, animateOut(CategorySelection), true, true);
			btnChallenges = TriviaButton.pill(blueBG, btnCreate.y + btnCreate.height * 1.2, "Challenges", ColorMap.LIGHT_GREEN, animateOut(Challenges), true, true);

			Helper.center(btnMultiplayer);

			addChild(container);

			TweenMax.from(container, .85, {delay:.2, y:Screen.bottom, ease:Back.easeOut.config(.75)});

			Challenge.getChallenges(showChallengeCount);
		}

		private function showChallengeCount(challenges:Vector.<Challenge>):void
		{
			if (!challenges.length)
				return;

			var circle:Image = Make.image(btnChallenges.parent, Skins.ORANGE_CIRCLE, Position.right(btnChallenges), Position.top(btnChallenges));
			circle.scale = .75;
			circle.x -= circle.width  * .8;
			circle.y -= circle.height * .2;

			TriviaText.create(circle.parent, {
				x: circle.x,
				y: circle.y,
				w: circle.width,
				h: circle.height,
				text: "" + challenges.length,
				style: TriviaText.WHITE_MEDIUM
			});
		}

		public override function ready():void {}

		public override function script(e:Event = null):void
		{
			BackButton.onClick = animateOut(Menu);
		}

		private function animateOut(Scene:Class, Transition:int = 0):Function
		{
			return function():void
			{
				if(Scene == CategorySelection) Room.mode = Room.MODE_INVITE;
				TweenMax.to(container, .85, {y:Screen.bottom, ease:Back.easeIn.config(.75), onComplete:transition, onCompleteParams:[Scene, Transition]});
			}
		}
	}
}
