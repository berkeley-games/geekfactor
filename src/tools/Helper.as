/**
 * Created by wmaynard on 3/4/2016.
 */
package tools
{
	import architecture.AudioMap;
	import architecture.Fonts;
	import architecture.Skins;
	import architecture.game.ColorMap;

	import com.greensock.TweenMax;

	import flash.globalization.NumberFormatter;

	import starling.display.Button;
	import starling.display.Shape;
	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.tools.Make;
	import ten90.tools.Quick;

	public class Helper
	{
		public static function center(element:*, x:int = -1, y:int = -1):void
		{
			if(isArray(element))
			{
				for each (var e:* in element) center(e);
				return;
			}

			Quick.pivot(element, .5, .5);

			if (x != -1) element.x = x;
			if (y != -1) element.y = y;
		}

		private static function isArray(input:*):Boolean
		{
			var output:Boolean = false;
			try { output = input[0]; }
			catch(e:*){}
			return output;
		}

		public static function centerX(element:*):void
		{
			if (isArray(element)) for each (var e:* in element) centerX(e);
			else Quick.pivot(element, .5, 0);
		}

		public static function centerY(element:*):void
		{
			if (isArray(element)) for each (var e:* in element) centerY(e);
			else Quick.pivot(element, 0, .5);
		}

		public static function xmlHasError(xml:XML):Boolean
		{
			var error:String = xml.attribute("Error");
			return error.length > 0;
		}

		public static function hide(elements:Array):void
		{
			for each (var e:* in elements) e.visible = false;
		}

		public static function show(elements:Array):void
		{
			for each (var e:* in elements) e.visible = true;
		}

		public static function toggleVisibility(elements:Array):void
		{
			for each (var e:* in elements) e.visible = !e.visible;
		}

		public static function GreenButton(parent:*, text:String, x:int = 0, y:int = 0, onClick:Function = null):Button
		{
			var btn:Button = Make.button(parent, x, y, Skins.GREEN_PILL, null, null, text, Fonts.SYSTEM, 50, ColorMap.WHITE);

			var click:Function = function():void
			{
				Audio.play(AudioMap.BUTTON_PRESS);
				if (onClick) onClick();
			};
			if(onClick) Quick.click(btn, click, false);
			return btn;
		}
		public static function Try(func:Function):void{
			try { func(); }
			catch(e:*){}
		}

		public static function formatNumber(num:int = 0):String
		{
			var numberFormat:NumberFormatter = new NumberFormatter(flash.globalization.LocaleID.DEFAULT);
			numberFormat.trailingZeros = false;

			var result:String = numberFormat.formatNumber(num);
			numberFormat = null;

			return result;
		}

		// Creates a black box with 15% opacity to show the area used by a display object container.
		public static function showArea(object:*):void
		{
			Make.shapeImage(object, 0, 0, object.width, object.height, true).alpha = .15;
		}

		public static function updateTextField(field:TextField, text:String):void
		{
			if (field.text == text) return;

			TweenMax.to(field, 0.25, {alpha: 0, onComplete: function():void
			{
				field.text = text;
				TweenMax.to(field, 0.25, {alpha: 1});
			}});
		}
	}
}