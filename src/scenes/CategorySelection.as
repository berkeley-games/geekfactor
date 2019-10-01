/**
 * Created by wmaynard on 3/7/2016.
 */
package scenes
{
	import architecture.AudioMap;
	import architecture.ImageMap;
	import architecture.game.Room;

	import com.greensock.TweenMax;

	import controls.BlueHeader;

	import starling.display.Button;
	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.StarlingScene;
	import ten90.scene.Transitions;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	import tools.Helper;
	import tools.TriviaText;

	public class CategorySelection extends StarlingScene
	{
		private var back:Button;
		private var catAll:Button;
		private var cat1:Button;
		private var cat2:Button;
		private var cat3:Button;
		private var cat4:Button;
		private var cat5:Button;
		private var cat6:Button;

		private var catAll_label:TextField;
		private var cat1_label:TextField;
		private var cat2_label:TextField;
		private var cat3_label:TextField;
		private var cat4_label:TextField;
		private var cat5_label:TextField;
		private var cat6_label:TextField;

		public override function init():void
		{
			back = Make.button(this,Screen.left + 25, Screen.top + 25, "back_button");
			var bg:BlueHeader = new BlueHeader(this, "Select a Category");

			var x1:int = Screen.left + Screen.width * .25;
			var x2:int = Screen.left + Screen.width * .75;

			catAll = Make.button(this, Screen.stageWidth / 2, Position.bottom(bg) + 250, ImageMap.BUTTON_CATEGORY_ALL);
//			catAll_label =  Make.text(this, Screen.stageWidth / 2, Position.bottom(catAll)-25, 300, 75, ImageMap.getCategoryName(0), Fonts.SYSTEM, 42, 0x2B5592, false, "center");

			var spacer:Number = catAll.height * 2;
			var y1:int = catAll.y + spacer;
			var y2:int = y1 + spacer;
			var y3:int = y2 + spacer;

			cat1 = Make.button(this, x1, y1, ImageMap.BUTTON_CATEGORY_1);
			cat2 = Make.button(this, x1, y2, ImageMap.BUTTON_CATEGORY_2);
			cat3 = Make.button(this, x1, y3, ImageMap.BUTTON_CATEGORY_3);
			cat4 = Make.button(this, x2, y1, ImageMap.BUTTON_CATEGORY_4);
			cat5 = Make.button(this, x2, y2, ImageMap.BUTTON_CATEGORY_5);
			cat6 = Make.button(this, x2, y3, ImageMap.BUTTON_CATEGORY_6);

			catAll_label = TriviaText.create(this, {
				x: Screen.stageWidth / 2,
				y: Position.bottom(catAll) - 25,
				text: ImageMap.getCategoryName(0, true),
				style: TriviaText.BLUE_SMALL
			});
			cat1_label = TriviaText.create(this, {
				x: x1,
				y: Position.bottom(cat1) - 25,
				text: ImageMap.getCategoryName(1, true),
				style: TriviaText.BLUE_SMALL
			});
			cat2_label = TriviaText.create(this, {
				x: x1,
				y: Position.bottom(cat2) - 25,
				text: ImageMap.getCategoryName(2, true),
				style: TriviaText.BLUE_SMALL
			});
			cat3_label = TriviaText.create(this, {
				x: x1,
				y: Position.bottom(cat3) - 25,
				text: ImageMap.getCategoryName(3, true),
				style: TriviaText.BLUE_SMALL
			});
			cat4_label = TriviaText.create(this, {
				x: x2,
				y: Position.bottom(cat4) - 25,
				text: ImageMap.getCategoryName(4, true),
				style: TriviaText.BLUE_SMALL
			});
			cat5_label = TriviaText.create(this, {
				x: x2,
				y: Position.bottom(cat5) - 25,
				text: ImageMap.getCategoryName(5, true),
				style: TriviaText.BLUE_SMALL
			});
			cat6_label = TriviaText.create(this, {
				x: x2,
				y: Position.bottom(cat6) - 25,
				text: ImageMap.getCategoryName(6, true),
				style: TriviaText.BLUE_SMALL
			});

			Helper.center([catAll_label, cat1_label, cat2_label, cat3_label, cat4_label, cat5_label, cat6_label]);
			Helper.center([catAll, cat1, cat2, cat3, cat4, cat5, cat6]);

			TweenMax.from([catAll, catAll_label], .5, {alpha:0, y:"+=15"});
			TweenMax.from([cat1, cat1_label], .5, {alpha:0, y:"+=15", delay:.1});
			TweenMax.from([cat4, cat4_label], .5, {alpha:0, y:"+=15", delay:.15});
			TweenMax.from([cat2, cat2_label], .5, {alpha:0, y:"+=15", delay:.2});
			TweenMax.from([cat5, cat5_label], .5, {alpha:0, y:"+=15", delay:.25});
			TweenMax.from([cat3, cat3_label], .5, {alpha:0, y:"+=15", delay:.3});
			TweenMax.from([cat6, cat6_label], .5, {alpha:0, y:"+=15", delay:.35});
		}

		public override function ready():void
		{
			Quick.click(back, close, false) ;

			Quick.click(catAll, categorySelected(0));
			Quick.click(cat1, categorySelected(1));
			Quick.click(cat2, categorySelected(2));
			Quick.click(cat3, categorySelected(3));
			Quick.click(cat4, categorySelected(4));
			Quick.click(cat5, categorySelected(5));
			Quick.click(cat6, categorySelected(6));
		}

		public function show():void
		{
			this.visible = true;
			TweenMax.fromTo(this, .5, {alpha: 0}, {alpha: 1});
		}

		private function categorySelected(category:int):Function
		{
			return function():void
			{
				Audio.play(AudioMap.BUTTON_PRESS);
				Room.selectedCategory = category;
				if (Room.mode == Room.MODE_SINGLE)
					transition(PregameSplash, Transitions.MANUAL);
				else
					CreateGroup.host();
			}
		}

		private function close():void
		{
			transition(Menu, Transitions.NONE);
		}
	}
}
