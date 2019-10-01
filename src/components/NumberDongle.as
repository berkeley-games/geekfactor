/**
 * Created by George on 8/12/2016.
 */
package components
{
	import architecture.Fonts;
	import architecture.game.ColorMap;

	import controls.TriviaInput;

	import feathers.controls.TextInput;

	import starling.text.TextField;

	import ten90.components.Component;
	import ten90.tools.Make;
	import ten90.tools.Position;

	public class NumberDongle extends Component
	{
		private var numberField:TextInput;

		public function NumberDongle(label:String):void
		{
			numberField = Make.textInput(this, 0, 0, 150, 75, TriviaInput.editFactory2, "0", TriviaInput.promFactory2);
			numberField.restrict = "0-9";
			numberField.maxChars = 2;

			var field:TextField = Make.text(this, 0, Position.bottom(numberField), 200, 100, label, Fonts.SYSTEM, 50, ColorMap.BLACK, false, "center");
			Position.centerX(field, Position.centerX(numberField));
		}

		public function get value():int
		{
			return int(numberField.text);
		}

		public function set value(val:int):void
		{
			numberField.text = val == 0 ? "" : String(val);
		}
	}
}
