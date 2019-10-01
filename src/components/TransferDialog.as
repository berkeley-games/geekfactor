/**
 * Created by wmaynard on 3/3/2016.
 */
package components
{
	import architecture.game.ColorMap;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import controls.TriviaButton;

	import controls.TriviaInput;

	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	import tools.TriviaText;

	public class TransferDialog extends Component
	{
		public var onDestroy:Function;

		private var bg:Quad;
		private var dialog:Sprite;
		private var centerY:Number;

		private var usernameField:TriviaInput;
		private var codeField:TriviaInput;
		private var submit:TriviaButton;

		public override function init():void
		{
			touchable = false;
			visible = false;

			dialog = new Sprite();

			Make.quad(dialog, 0, 0, 1000, 1000, 0xFFFFFF);

			TriviaText.create(dialog, {
				y:100,
				w: dialog.width,
				text: "Transfer Profile",
				style: TriviaText.GRAY_LARGE
			});

			usernameField = new TriviaInput(dialog, 350, "username", "", 800, false, 100);
			codeField = new TriviaInput(dialog, 550, "transfer code", "", 800, false, 100);

			submit = TriviaButton.pill(dialog, dialog.height - 100, "Submit", ColorMap.CISCO_BLUE, hide, true);
			submit.x = 500;
			addChild(dialog);

			dialog.x = (Screen.width - width) / 2;
			centerY = (Screen.height - height) / 2;

			x = Screen.left;
			y = Screen.top;
		}

		public function show(callback:Function):void
		{
			bg = Make.quad(this, 0, 0, Screen.width, Screen.height, 0, .75);
			Quick.index(bg, 0);

			onDestroy = callback;

			parent.addChild(this);

			visible = true;

			TweenMax.from(bg, .75, {alpha:0});
			TweenMax.fromTo(dialog, .75, {alpha:0, y:Screen.bottom}, {alpha:1, y:centerY, ease:Back.easeOut, onComplete:waitForClick});
		}

		private function waitForClick():void
		{
			touchable = true;
			Quick.click(bg, hide);
		}

		public function hide():void
		{
			TweenMax.to(bg, .75, {delay:.4, alpha:0});
			TweenMax.to(dialog, .65, {alpha:0, y:Screen.bottom, ease:Back.easeIn.config(.95), onComplete:kill});
		}

		private function kill():void
		{
			if(onDestroy) onDestroy();

			visible = false;

			bg.dispose();
		}

		public function get username():String
		{
			return usernameField.text;
		}

		public function get code():String
		{
			return codeField.text;
		}
	}
}