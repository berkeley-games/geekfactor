/**
 * Created by wmaynard on 3/4/2016.
 */
package controls
{
	import architecture.Fonts;
	import architecture.Skins;
	import architecture.game.ColorMap;

	import feathers.controls.TextInput;

	import starling.events.Event;

	import ten90.device.Screen;
	import ten90.tools.Make;
	import ten90.tools.Quick;

	public class TriviaInput extends TextInput
	{
		public static const EMAIL:RegExp = /^([\S]){5,14}$/;
		public static const PASSWORD:RegExp = /^([\S]){5,14}$/;
		public static const QUESTION:RegExp = /^.{1,140}$/;
		public static const ANSWER:RegExp = /^.{1,60}$/;

		public static var editFactory:Function = Make.textFactory(Fonts.SYSTEM, 48, ColorMap.BLACK, false, "center");
		public static var promFactory:Function =  Make.promptFactory(Fonts.SYSTEM, 48, ColorMap.LIGHT_GRAY, false, false, "center");
		
		public static var editFactory2:Function = Make.textFactory(Fonts.SYSTEM, 72, ColorMap.BLACK, false, "center");
		public static var promFactory2:Function =  Make.promptFactory(Fonts.SYSTEM, 72, ColorMap.LIGHT_GRAY, false, false, "center");
		
		
		private var _regex:RegExp;

	    public function TriviaInput(parent:*, y:int, prompt:String = null, text:String = null, w:int = -1, center:Boolean = true, x:int = 0)
	    {
		    super();

		    if (w == -1) w = Screen.width - 100;

		    this.x = x;
		    this.y = y;
		    this.width = w;
		    this.height = 100;
		    this.prompt = prompt;

		    textEditorFactory = editFactory;
		    promptFactory = promFactory;

		    if (text) this.text = text;

		    maxChars = 30;
		    paddingTop = 5;
		    paddingBottom = 5;
		    paddingLeft = 12;
		    paddingRight = 5;

		    Make.quad(this, 0, height, width, Skins.dividerStroke, ColorMap.LIGHT_GRAY);

		    if (center) TriviaInput.center([this]);
		    parent.addChild(this);
	    }

		public function disallow(chars:String):void
		{
			addKeyboardListener(function():void
			{
				for (var i:int = 0; i < chars.length; i++)
				{
					var c:String = chars.charAt(i);
					text = text.replace(c, '');
				}
			});
		}

		public function showValidState(func:Function = null):void
		{
			addKeyboardListener(func ? func : function(e:*):void{
//				greenCheck.visible = isValid();
			});
		}

		public function addKeyboardListener(func:Function):void
		{
			addEventListener(Event.CHANGE, func);
		}

		public function set regex(input:RegExp):void
		{
			this._regex = input;
		}

		public function isValid(regex:RegExp = null):Boolean
		{
			var r:RegExp = regex ? regex : this._regex;
			if (!r)
			{
				trace("Warning: no regex set, so no validation can take place on this text field.  (text = '" + text + "')");
				return true;
			}

//			trace("Regex test result (" + text + "): " + r.test(text));
			return r.test(text);
		}

		public static function center(array:Array):void
		{
			for each (var i:* in array)
			{
				i.x = Screen.stageWidth / 2;
				Quick.pivot(i, .5, .5);
			}
		}
	}
}
