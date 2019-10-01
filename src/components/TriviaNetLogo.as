/**
 * Created by gperry on 10/21/2015.
 */
package components
{
	import architecture.Fonts;
	import architecture.game.ColorMap;

	import components.Banner;

	import starling.display.Sprite;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.tools.Make;

	public class TriviaNetLogo extends Component
	{
		public override function init():void
		{
			var container:Sprite = new Sprite();
			Make.text(container, 0, 0, 300, 150, "Geek", Fonts.SYSTEM, 80, ColorMap.CISCO_BLUE, false, "right");
			Make.text(container, 300, 0, 300, 150, "Factor", Fonts.SYSTEM, 80, ColorMap.BLUE, false, "left");
			container.flatten();

			x = (Screen.stageWidth - width) / 2;

			addChild(container);
		}

		public override function ready():void
		{
			switch(parentScene.className)
			{
				case "Loading":
				case "ForgotPassword":
				case "Register":
				case "Login":
					this.y = 300;
					break;

				case "Pregame":
					var banner:Banner = parentScene.getComponent(Banner);
					this.y = banner.y + banner.height + 25;
					break;

				case "Game":
				case "Results":
					this.scaleX = this.scaleY = .5;
					this.y = Screen.top + 20;
					break;

				case "Friends":
				case "Settings":
				case "Leaderboards":
					this.scaleX = this.scaleY = .5;
					this.y = Screen.top + 80;
					break;

				default: this.y = 25;
			}

			this.x = (Screen.stageWidth - this.width) / 2;
		}
	}
}