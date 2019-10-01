/**
 * Created by gperry on 4/18/2016.
 */
package scenes
{
	import architecture.Fonts;
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.game.Achievement;
	import architecture.game.ColorMap;
	import architecture.game.Question;

	import components.BackButton;
	import components.CustomError;

	import controls.BlueHeader;
	import controls.TriviaButton;
	import controls.TriviaInput;

	import feathers.controls.Check;

	import ten90.components.SpinnerRing;
	import ten90.device.Screen;
	import ten90.scene.StarlingScene;
	import ten90.tools.Make;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	public class SubmitQuestionFields extends StarlingScene
	{
		private var spinner:SpinnerRing;

		private var submit:TriviaButton;

		private var question:TriviaInput;
		private var answer:TriviaInput;
		private var incorrect1:TriviaInput;
		private var incorrect2:TriviaInput;
		private var incorrect3:TriviaInput;

		private var categoryID:int;
		private var difficulty:int;

		private var categories:Array = [];
		private var difficulties:Array = [];

		public override function init():void
		{
			BackButton.onClick = function():void{
				transition(SubmitQuestion);
			};
			var header:BlueHeader = new BlueHeader(this, "Submit a Question");

			getComponent(BackButton).transitionTo = Menu;

			var inputY:int = header.height + 150;
			var verticalSpacing:int = 200;

			question = input(inputY, "Question", TriviaInput.QUESTION);
			answer = input(inputY += verticalSpacing, "Correct Answer");
			incorrect1 = input(inputY += verticalSpacing, "Incorrect Answer #1");
			incorrect2 = input(inputY += verticalSpacing, "Incorrect Answer #2");
			incorrect3 = input(inputY += verticalSpacing, "Incorrect Answer #3");

			var x1:int = Screen.stageLeft + 25;
			var x2:int = x1 + 375;
			var x3:int = x2 + 450;
			var y1:int = 1325;
			var y2:int = y1 + 75;
			var y3:int = y2 + 75;

			categories.push(checkbox(x1, y1, ImageMap.getCategoryName(1, true)));
			categories.push(checkbox(x1, y2, ImageMap.getCategoryName(2, true)));
			categories.push(checkbox(x1, y3, ImageMap.getCategoryName(3, true)));
			categories.push(checkbox(x2, y1, ImageMap.getCategoryName(4, true)));
			categories.push(checkbox(x2, y2, ImageMap.getCategoryName(5, true)));
			categories.push(checkbox(x2, y3, ImageMap.getCategoryName(6, true)));
			Quick.checkToggle(categories);

			difficulties.push(checkbox(x3, y1, "Easy"));
			difficulties.push(checkbox(x3, y2, "Medium"));
			difficulties.push(checkbox(x3, y3, "Hard"));
			Quick.checkToggle(difficulties);

			submit = TriviaButton.pill(this, 1800, "Submit", ColorMap.CISCO_BLUE, validate);

			spinner = getComponent(SpinnerRing);
		}

		private function input(y:int, prompt:String, regex:RegExp = null):TriviaInput
		{
			regex = regex ? regex : TriviaInput.ANSWER;
			var w:int = Screen.width - 30;
			var field:TriviaInput = new TriviaInput(this, y, prompt, "", w);
			field.disallow("\t\n");
			field.maxChars = regex == TriviaInput.QUESTION ? 140 : 60;
			field.regex = regex;
			return field;
		}

		private function checkbox(x:int, y:int, text:String):Check
		{
			var w:int = 50;
			var fontSize:int = 30;
			return Make.checkBox(this, w, x, y, Skins.CHECK_BOX_BACKGROUND, Skins.CHECK_BOX_FOREGROUND, false, text, Fonts.SYSTEM, fontSize);
		}

		public override function ready():void
		{
		}

		private function validate():void
		{
			this.touchable = false;
			var error:String = "";

			var i:int;

			for(i = 0; i < categories.length; i++)
				if(categories[i].isSelected)
					categoryID = i + 1;

			for(i = 0; i < difficulties.length; i++)
				if(difficulties[i].isSelected)
					difficulty = i + 1;

			// Look for errors.
			for each (var t:TriviaInput in [question, answer, incorrect1, incorrect2, incorrect3])
				if (!t.isValid())
					error += "\nA field is invalid! (" + t.text + ")";
			if (!(categoryID && difficulty))
				error += "\nYou must select a category and a difficulty level.";

			if (!error)
			{
				spinner.show();
				Question.upload(question.text, answer.text, incorrect1.text, incorrect2.text, incorrect3.text, categoryID, difficulty, "", complete);
			}
			else
			{
				this.touchable = true;
				getComponent(CustomError).show(error);
			}
		}

		private function complete():void
		{
			SubmitQuestion.submitted = true;

			var questionsSubmitted:int = Save.data(Achievement.SAVE_ACHIEVEMENT_SUBMIT_A_QUESTION);
			Save.data(Achievement.SAVE_ACHIEVEMENT_SUBMIT_A_QUESTION, questionsSubmitted + 1);

			transition(SubmitQuestion);
		}
	}
}
