/**
 * Created by gperry on 4/5/2016.
 */
package scenes
{
	import architecture.ImageMap;
	import architecture.game.Achievement;
	import architecture.game.ColorMap;

	import components.BackButton;

	import controls.BlueHeader;
	import controls.TriviaButton;

	import starling.display.Image;
	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.scene.SceneController;
	import ten90.scene.StarlingScene;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	import tools.TriviaText;

	public class SubmitQuestion extends StarlingScene
	{
		public static var submitted:Boolean = false;

		private var header:BlueHeader;
		private var submit:TriviaButton;

		public override function init():void
		{
			header = new BlueHeader(this, "Submit a Question");

			getComponent(BackButton).transitionTo = Menu;

			var startY:int = 400;
			var fieldWidth:int = Screen.stageWidth * .75;
			var fieldHeight:int = 200;

			var textString:String = submitted
				? "Thank you for your submission!"
				: "Think of a good question that might stump others?";

			var textfield1:TextField = TriviaText.create(this, {style:TriviaText.BLACK_SMALL, width:fieldWidth, height:fieldHeight, y:startY, text:textString});

			textString = "If your question is chosen, your name will show up here!";
			var textfield2:TextField = TriviaText.create(this, {style:TriviaText.BLACK_SMALL, width:fieldWidth, height:fieldHeight, y:startY + 500, text:textString});

			textfield1.x = textfield2.x = (Screen.stageWidth - fieldWidth) / 2;

			var pillText:String = submitted ? "Return to Game" : "Submit it Here";
			var pillCallback:Function = submitted ? goHome : submitQuestion;

			var pillY:int = Position.bottom(textfield1) + (textfield2.y - Position.bottom(textfield1)) / 2;
			submit = TriviaButton.pill(this, pillY, pillText, ColorMap.CISCO_BLUE, pillCallback);

			var bottomImage:Image = Make.image(this, ImageMap.SUBMIT_QUESTION);
			bottomImage.scale = Screen.width / bottomImage.width;
			Position.left(bottomImage, Screen.left);
			Position.top(bottomImage, Position.bottom(textfield2));
			if(Position.bottom(bottomImage) < Screen.height)
				Position.bottom(bottomImage, Screen.height);
		}

		private function submitQuestion():void
		{
			transition(SubmitQuestionFields);
		}

		private function goHome():void
		{
			transition(Menu);
		}

		public override function terminate():void
		{
			submitted = false;
		}
	}
}
