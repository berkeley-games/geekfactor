/**
 * Created by wmaynard on 3/4/2016.
 */
package components {

	import architecture.game.ColorMap;

	import controls.TriviaButton;
	import controls.TriviaInput;

	import ten90.components.Component;

	public class LoginInfo extends Component
	{
		public var fields:Array;
	    public var email:TriviaInput;
		public var password:TriviaInput;

		private var buttons:Object = {};
		private var objects:Array;
		private var offset:int;

		public override function init():void
		{
			email = new TriviaInput(this, 0, "username");
			email.regex = TriviaInput.EMAIL;
			email.disallow(" \t\n");

			offset = 75;

			password = new TriviaInput(this, email.y + email.height + offset, "password");
			password.displayAsPassword = true;
			password.regex = TriviaInput.PASSWORD;
			password.visible = false;

			fields = [email, password];
			objects = [email, password];
		}

		public override function ready():void
		{

		}

		public function addField(field:TriviaInput, regex:RegExp = null):void
		{
			var last:* = objects[objects.length - 1];
			field.y = last.y + last.height + offset;
			if (regex) field.regex = regex;
			fields.push(field);
			objects.push(field);
			addChild(field);
		}

		public function addButton(text:String, onClick:Function, yPadding:Number = 0):void
		{
			var last:* = objects[objects.length - 1];

			var realY:Number = (last.y + last.height * 1.75) + yPadding;

			buttons[text] = TriviaButton.pill(this, realY, text, ColorMap.CISCO_BLUE, onClick);
		}

		public function isValid():Boolean
		{
			for each (var f:* in fields)
				if (!f.isValid()) return false;

			return true;
		}

		public function getButton(text:String):TriviaButton
		{
			return buttons[text];
		}
	}
}