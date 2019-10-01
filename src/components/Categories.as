/**
 * Created by gperry on 10/21/2015.
 */
package components
{
	import architecture.game.Question;
	import architecture.game.Room;

	import components.*;

	import controls.CategoryIcon;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.tools.Help;

	public class Categories extends Component
	{
		private var currentCircle:int = 0;
		public var icons:Array = [];

		public override function init():void
		{
			this.touchable = false;

			var hideDetails:Boolean = (parentScene.className == "Pregame");

			var totalQuestions:int = Room.current.questions.length;

			var xGap:Number = Screen.width / totalQuestions;

			for (var i:int = 0; i < totalQuestions; i++)
			{
				var q:Question = Room.current.questions[i];
				var icon:CategoryIcon = new CategoryIcon(this, 0, 0, q.categoryID, q.multiplier, CategoryIcon.CATEGORY_CIRCLE, hideDetails);
				icon.x = (Screen.width * (i + 1)) / (totalQuestions + 1) - icon.width / 2;
				icons.push(icon);
			}
		}

		public override function ready():void
		{
			this.x = Screen.left;

			switch(Help.getClassName(parentScene))
			{
				case "Pregame":
					this.y = (Screen.height - this.height) / 2;
					break;
				case "Game":
					this.y = parentScene.getComponent(Quiz).y - this.height - 25;
					break;
			}
		}

		public function show(populateIcons:Boolean = false, animate:Boolean = true):void
		{
			var icon:CategoryIcon;
			for each (icon in icons)
			{
				var delay:Number = animate ? 0.3 + icons.indexOf(icon) / 20 : 0;
				icon.animateIn(delay);
				if (populateIcons) icon.popIn(delay);
			}
		}

		public function showNextCircle():void
		{
			icons[currentCircle++].popIn();
		}

		public function setStatus(questionNum:int, correct:Boolean):void
		{
			icons[questionNum - 1].onQuestionAnswer(correct);
		}
	}
}