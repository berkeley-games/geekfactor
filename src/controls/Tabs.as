/**
 * Created by wmaynard on 4/8/2016.
 */
package controls
{
	import architecture.AudioMap;
	import architecture.game.ColorMap;

	import starling.display.Button;
	import starling.display.DisplayObjectContainer;
	import starling.text.TextField;
	import starling.utils.VAlign;

	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.tools.Make;
	import ten90.tools.Quick;

	import tools.TriviaText;

	public class Tabs extends DisplayObjectContainer
	{
		private var btn1:Button;
		private var btn2:Button;
		private var btn3:Button;

		private var text1:TextField;
		private var text2:TextField;
		private var text3:TextField;

		private var action1:Function;
		private var action2:Function;
		private var action3:Function;

		public function setText(tabNumber:int, text:String):void
		{
			switch (tabNumber) {
				case 1:
					text1.text = text;
					break;
				case 2:
					text2.text = text;
					break;
				case 3:
					text3.text = text;
					break;
				default:
					setText(1, text);
					break;
			}
		}

		public function Tabs(parent:*, y:int, height:int, tab1props:Object = null, tab2props:Object = null, tab3props:Object = null)
		{
			super();

			btn1 = Make.emptyButton(this, 0, 0, Screen.width / 3, height);
			btn2 = Make.emptyButton(this, btn1.x + btn1.width, btn1.y, btn1.width, height);
			btn3 = Make.emptyButton(this, btn2.x + btn2.width, btn2.y, btn2.width, height);

			text1 = TriviaText.create(this, {
				x: btn1.x,
				y: btn1.y,
				w: btn1.width,
				h: btn1.height,
				text: tab1props.hasOwnProperty("text") ? tab1props.text : "",
				style: TriviaText.TURQ_MEDIUM,
				valign:"center"
			});

			text2 = TriviaText.create(this, {
				x: btn2.x,
				y: btn2.y,
				w: btn2.width,
				h: btn2.height,
				text: tab2props.hasOwnProperty("text") ? tab2props.text : "",
				style: TriviaText.GRAY_MEDIUM,
				valign:"center"
			});

			text3 = TriviaText.create(this, {
				x: btn3.x,
				y: btn3.y,
				w: btn3.width,
				h: btn3.height,
				text: tab3props.hasOwnProperty("text") ? tab3props.text : "",
				style: TriviaText.GRAY_MEDIUM,
				valign:"center"
			});

			Quick.index([text1, text2, text3], 0);

			action1 = tab1props.hasOwnProperty("onClick") ? tab1props.onClick : null;
			action2 = tab2props.hasOwnProperty("onClick") ? tab2props.onClick : null;
			action3 = tab3props.hasOwnProperty("onClick") ? tab3props.onClick : null;

			Quick.click(btn1, tabClicked(1), false);
			Quick.click(btn2, tabClicked(2), false);
			Quick.click(btn3, tabClicked(3), false);

			this.x = Screen.left;
			this.y = y;

			if (parent) parent.addChild(this);
		}

		public function enable(tabNumber:int, enabled:Boolean = true):void
		{
			var text:TextField = [text1, text2, text3][tabNumber - 1];
			var btn:Button = [btn1, btn2, btn3][tabNumber - 1];

			text.alpha = enabled ? 1 : .3;
			btn.touchable = enabled;
		}
		
		public function toggleTo(tabNumber:int):void
		{
			tabClicked(tabNumber)();
		}
		
		private function tabClicked(tab:int):Function
		{
			return function():void
			{
				Audio.play(AudioMap.BUTTON_PRESS);
				
				if (tab == 1)
				{
					if (text1.color == ColorMap.CISCO_BLUE) return;
					text1.color = ColorMap.CISCO_BLUE;
					text2.color = text3.color = ColorMap.GRAY;
					if (action1) action1();
				}
				else if (tab == 2)
				{
					if (text2.color == ColorMap.CISCO_BLUE) return;
					text2.color = ColorMap.CISCO_BLUE;
					text1.color = text3.color = ColorMap.GRAY;
					if (action2) action2();
				}
				else if (tab == 3)
				{
					if (text3.color == ColorMap.CISCO_BLUE) return;
					text3.color = ColorMap.CISCO_BLUE;
					text1.color = text2.color = ColorMap.GRAY;
					if (action3) action3();
				}
			}
		}
	}
}
