/**
 * Created by wmaynard on 4/4/2016.
 */
package tools
{
	import architecture.Fonts;
	import architecture.game.ColorMap;

	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import ten90.tools.Make;

	public class TriviaText
	{
		public static const BLACK_LARGE_LEFT:String = "black_large_left";
		public static const WHITE_LARGE_LEFT:String = "white_large_left";		// Results
		public static const GREEN_LARGE_LEFT:String = "green_large_left";
		public static const GRAY_LARGE_LEFT:String = "gray_large_left";

		public static const WHITE_MEDIUM_LEFT:String = "white_medium_left";	// Button text,
		public static const GREEN_MEDIUM_LEFT:String = "green_medium_left";	// Results, Timer
		public static const GRAY_MEDIUM_LEFT:String = "gray_medium_left";		// Events "Cisco Live"
		public static const BLUE_MEDIUM_LEFT:String = "blue_medium_left";		// Create Group Match
		public static const RED_MEDIUM_LEFT:String = "red_medium_left";
		public static const BLACK_MEDIUM_LEFT:String = "black_medium_left";

		public static const WHITE_SMALL_LEFT:String = "white_small_left";		// Category Select, Game
		public static const GREEN_SMALL_LEFT:String = "green_small_left";		// Profile Photo Coins
		public static const BLUE_SMALL_LEFT:String = "blue_small_left";		// ProfileBar name
		public static const TURQ_SMALL_LEFT:String = "turq_small_left";
		public static const GRAY_SMALL_LEFT:String = "gray_small_left";		// Category Select
		public static const BLACK_SMALL_LEFT:String = "black_small_left";

		// Right align
		public static const BLACK_LARGE_RIGHT:String = "black_large_right";
		public static const WHITE_LARGE_RIGHT:String = "white_large_right";		// Results
		public static const GREEN_LARGE_RIGHT:String = "green_large_right";
		public static const GRAY_LARGE_RIGHT:String = "gray_large_right";

		public static const WHITE_MEDIUM_RIGHT:String = "white_medium_right";	// Button text,
		public static const GREEN_MEDIUM_RIGHT:String = "green_medium_right";	// Results, Timer
		public static const GRAY_MEDIUM_RIGHT:String = "gray_medium_right";		// Events "Cisco Live"
		public static const BLUE_MEDIUM_RIGHT:String = "blue_medium_right";		// Create Group Match
		public static const RED_MEDIUM_RIGHT:String = "red_medium_right";
		public static const BLACK_MEDIUM_RIGHT:String = "black_medium_right";

		public static const WHITE_SMALL_RIGHT:String = "white_small_right";		// Category Select, Game
		public static const GREEN_SMALL_RIGHT:String = "green_small_right";		// Profile Photo Coins
		public static const BLUE_SMALL_RIGHT:String = "blue_small_right";		// ProfileBar name
		public static const GRAY_SMALL_RIGHT:String = "gray_small_right";		// Category Select
		public static const BLACK_SMALL_RIGHT:String = "black_small_right";

		public static const BLACK_RIGHT:String = "black_right";
		public static const GRAY_RIGHT:String = "gray_right";
		public static const WHITE_RIGHT:String = "white_right";

		// Center align
		public static const BLACK_LARGE:String = "black_large";
		public static const WHITE_LARGE:String = "white_large";		// Results
		public static const GREEN_LARGE:String = "green_large";
		public static const GRAY_LARGE:String = "gray_large";
		public static const TURQ_LARGE:String = "turq_large";

		public static const WHITE_MEDIUM:String = "white_medium";	// Button text,
		public static const GREEN_MEDIUM:String = "green_medium";	// Results, Timer
		public static const GRAY_MEDIUM:String = "gray_medium";		// Events "Cisco Live"
		public static const BLUE_MEDIUM:String = "blue_medium";		// Create Group Match
		public static const RED_MEDIUM:String = "red_medium";
		public static const BLACK_MEDIUM:String = "black_medium";
		public static const ORANGE_MEDIUM:String = "orange_medium";
		public static const TURQ_MEDIUM:String = "turq_medium";

		public static const WHITE_SMALL:String = "white_small";		// Category Select, Game
		public static const GREEN_SMALL:String = "green_small";		// Profile Photo Coins
		public static const BLUE_SMALL:String = "blue_small";		// ProfileBar name
		public static const GRAY_SMALL:String = "gray_small";		// Category Select
		public static const BLACK_SMALL:String = "black_small";

		// Tiny Fonts
		public static const WHITE_TINY:String = "white_tiny";
		public static const BLACK_TINY_RIGHT:String = "black_tiny_right";
		public static const GRAY_TINY_RIGHT:String = "gray_tiny_right";
		public static const BLUE_TINY:String = "blue_tiny";

		// XL Fonts
		public static const WHITE_XLARGE_RIGHT:String = "white_xlarge_right";
		public static const WHITE_XLARGE_LEFT:String = "white_xlarge_left";
		public static const WHITE_XLARGE:String = "white_xlarge";
		public static const BLACK_XLARGE:String = "black_xlarge";
		public static const GRAY_XLARGE:String = "gray_xlarge";
		public static const GREEN_XLARGE:String = "green_xlarge";

		private static function getFontSize(style:String):int
		{
			if (style.indexOf("xlarge") > -1)
				return 100;
			else if (style.indexOf("large") > -1)
				return 70;
			else if (style.indexOf("medium") > -1)
				return 60;
			else if (style.indexOf("small") > -1)
				return 45;
			return 25;
		}

		private static function getAlignment(style:String):String
		{
			if (style.indexOf("left") > -1)
				return HAlign.LEFT;
			else if (style.indexOf("right") > -1)
				return HAlign.RIGHT;
			return HAlign.CENTER;
		}

		private static function getColor(style:String):int
		{
			if (style.indexOf("white") > -1)
				return ColorMap.WHITE;
			else if (style.indexOf("green") > -1)
				return ColorMap.GREEN;
			else if (style.indexOf("gray") > -1)
				return ColorMap.GRAY;
			else if (style.indexOf("blue") > -1)
				return ColorMap.BLUE;
			else if (style.indexOf("turq") > -1)
				return ColorMap.CISCO_BLUE;
			else if (style.indexOf("orange") > -1)
				return ColorMap.ORANGE;
			return ColorMap.BLACK;
		}

		public static function create(parent:*, props:Object = null):TextField
		{
			props = props ? props : {};

			var style:String 	= props.hasOwnProperty("style") ? props.style : BLACK_MEDIUM;
			var size:int 		= props.hasOwnProperty("size") ? props.size : props.hasOwnProperty("fontSize") ? props.fontSize : getFontSize(style);
			var color:int 		= props.hasOwnProperty("color") ? props.color : getColor(style);
			var halign:String 	= props.hasOwnProperty("halign") ? props.halign : getAlignment(style);
			var valign:String 	= props.hasOwnProperty("valign") ? props.valign : VAlign.CENTER;
			var bold:Boolean 	= props.hasOwnProperty("bold") && props.bold;
			var italic:Boolean  = props.hasOwnProperty("italic") && props.italic;
			var x:int 			= props.hasOwnProperty("x") ? props.x : 0;
			var y:int 			= props.hasOwnProperty("y") ? props.y : 0;
			var width:int 		= props.hasOwnProperty("w") && props.w ? props.w : props.hasOwnProperty("width") && props.width ? props.width : -1;
			var height:int 		= props.hasOwnProperty("h") && props.h ? props.h : props.hasOwnProperty("height") && props.height ? props.height : -1;
			var text:String 	= props.hasOwnProperty("text") ? props.text : "";
			var font:String		= props.hasOwnProperty("font") ? props.font : props.hasOwnProperty("fontName") ? props.fontName : Fonts.SYSTEM;
			var autoSize:String = props.hasOwnProperty("autoSize") ? props.autoSize : null;

			var output:TextField = Make.text(null, x, y, width, height, text, font, size, color, bold, halign, valign);
			output.italic = italic;

			if(autoSize == null)
			{
				if (width == height && width == -1) output.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				else if (width == -1) output.autoSize = TextFieldAutoSize.HORIZONTAL;
				else if (height == -1) output.autoSize = TextFieldAutoSize.VERTICAL;
				else output.autoSize = TextFieldAutoSize.NONE;
			}

			try
			{
				if(parent) parent.addChild(output);
			}
			catch(e:*)
			{
				if (parent && parent.parent) parent.parent.addChild(output);
				output.x += parent.x;
				output.y += parent.y;
			}

			x = Math.round(x);
			y = Math.round(y);

			return output;
		}
	}
}