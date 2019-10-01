/**
 * Created by wmaynard on 3/4/2016.
 */
package components
{
	import architecture.AudioMap;
	import architecture.ImageMap;
	import architecture.game.Room;

	import scenes.Menu;

	import starling.display.Button;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.SceneController;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	public class BackButton extends Component
	{
		public static var _onClick:Function;
		public static var self:BackButton;

		public var transitionTo:Class;
		public var buttonImage:String = ImageMap.BUTTON_BACK;

		private const PADDING:int = 70;
		private var self:BackButton;

		public override function init():void
		{
			self = this;

			this.x = Screen.left + PADDING;
			this.y = Screen.top + PADDING;

			var button:Button = Make.button(this, 0, 0, buttonImage);
			addChildAt(Make.quad(null, -PADDING, -PADDING, button.width+PADDING*2, button.height+PADDING*2, 0, 0), 0);
		}

		public override function ready():void
		{
			switch(parentScene.className)
			{
				case "CreateGroup":
					addClick(function():void
					{
						if (Room.current) Room.current.leave();
						SceneController.transition(Menu);
					});
					break;

				case "Achievements":
				case "SubmitQuestion":
					addClick(function():void {
						SceneController.transition(Menu);
					});
					break;

				case "PregameSplash":
					// custom solution in class
					break;

				default:
					transitionTo = SceneController.previousScene;
					addClick(function():void{
						if(_onClick) trueOnClick();
						else if(transitionTo) SceneController.transition(transitionTo);
					}, false);
			}
		}

		private function addClick(f:Function, onlyOnce:Boolean = true):void
		{
			Quick.click(this, function():void
			{
				self.touchable = false;

				Quick.call(.25, function():void{
					if(self) self.touchable = true;
				});

				Audio.play(AudioMap.BUTTON_PRESS);
				f();

			}, onlyOnce);
		}

		public static function set onClick(val:Function):void
		{
			_onClick = val;
			if(self) self.touchable = true;
		}

		private function trueOnClick():void
		{
			_onClick();
			_onClick = null;
			if(self) self.touchable = false;
		}
	}
}