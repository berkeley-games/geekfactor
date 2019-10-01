/**
 * Created by wmaynard on 3/3/2016.
 */
package components
{
	import architecture.AudioMap;
	import architecture.game.ColorMap;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import controls.TriviaButton;

	import flash.utils.getDefinitionByName;

	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.network.Browser;
	import ten90.scene.SceneController;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	import tools.TriviaText;

	public class CustomError extends Component
	{
		public static var current:CustomError;

		private const WIDTH:int = 800;
		private const HEIGHT:int = 800;
		private const PADDING:int = 15;
		private const WIDTH_PADDING:int = WIDTH - PADDING * 2;
		private const HEIGHT_PADDING:int = HEIGHT - PADDING * 2;

		public var onDestroy:Function;

		private var bg:Quad;
		private var error:Sprite;
		private var errorMessage:TextField;
		private var centerY:Number;
		private var tapToText:TextField;
		private var button:TriviaButton;
		private var transitionTo:String;

		public override function init():void
		{
			visible = false;

			error = new Sprite();

			Make.shapeImage(error, 0, 0, WIDTH, HEIGHT, true, ColorMap.WHITE, ColorMap.CISCO_BLUE, 9, 85);

			errorMessage = TriviaText.create(error, {
				text: "",
				x:PADDING, w:WIDTH_PADDING, h:HEIGHT_PADDING,
				style: TriviaText.BLACK_MEDIUM,
				valign:"center"
			});

			tapToText = TriviaText.create(error, {
				text: "Tap to Continue",
				x:PADDING, w:WIDTH_PADDING, h:50,
				y:Position.bottom(errorMessage)-50,
				style: TriviaText.BLACK_SMALL, size:35
			});

			button = TriviaButton.pill(error, error.height - 100, "View", ColorMap.CISCO_BLUE, setTransition, true);
			button.x = WIDTH / 2;
			addChild(error);

			error.x = (Screen.width - width) / 2;
			centerY = (Screen.height - height) / 2;

			x = Screen.left;
			y = Screen.top;
			current = this;
		}

		public function show(text:String, transitionTo:String = "", onClose:Function = null):void
		{
			this.transitionTo = transitionTo;

			Audio.play(AudioMap.NOTIFY_UP);

			bg = Make.quad(this, 0, 0, Screen.width, Screen.height, 0, .75);
			Quick.index(bg, 0);

			errorMessage.text = text;

			parent.addChild(this);
			visible = true;

			if(transitionTo && transitionTo != "")
			{
				tapToText.visible = false;
				button.visible = true;
			}
			else
			{
				tapToText.visible = true;
				button.visible = false;
			}

			onDestroy = onClose;

			TweenMax.from(bg, .75, {alpha:0});
			TweenMax.fromTo(error, .75, {alpha:0, y:Screen.bottom}, {alpha:1, y:centerY, ease:Back.easeOut, onComplete:waitForClick});
		}

		private function waitForClick():void
		{
			Quick.click(this, hide);
		}

		public function hide():void
		{
			Quick.call(.2, Audio.play, 0, [AudioMap.NOTIFY_DOWN]);

			TweenMax.to(bg, .75, {delay:.4, alpha:0});
			TweenMax.to(error, .65, {alpha:0, y:Screen.bottom, ease:Back.easeIn.config(.95), onComplete:kill});
		}

		private function setTransition():void
		{
			onDestroy = doTransition;
			hide();
		}

		private function doTransition():void
		{
			var isURL:Boolean = transitionTo.indexOf("http://") > -1;
			var destination:* = isURL ? transitionTo : getDefinitionByName("scenes." + transitionTo) as Class;
			if(isURL) Browser.load(destination);
			else SceneController.transition(destination);
		}

		private function kill():void
		{
			errorMessage.text = "";
			visible = false;
			bg.dispose();

			if (onDestroy) onDestroy();

			onDestroy = null;
		}
	}
}