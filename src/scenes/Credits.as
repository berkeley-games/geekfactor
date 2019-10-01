/**
 * Created by wmaynard on 5/12/2016.
 */
package scenes
{
	import controls.BlueHeader;

	import starling.display.Sprite;

	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.device.System;
	import ten90.network.Browser;

	import ten90.scene.StarlingScene;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	import tools.TriviaText;

	public class Credits extends StarlingScene
	{
		private var audio:Array = [];
		private var development:Array = [];
		private var management:Array = [];

		private var audioNames:Array = ["David Malloy", "", "", "Tim Carleton & Darrick Deel", "'Opus No. 1'"];
		private var developerNames:Array = ["Ryan Coquilla", "Will Maynard", "George Perry"];
		private var managerNames:Array = ["Dan Gill", "Joel Conover", "Christine Fisher", "D'Auria Henry", "Mark Hannah", "Mary Rose"];

		private var terms:TextField;
		private var privacy:TextField;

		public override function init():void
		{
			new BlueHeader(this, "Credits");

			var y:int = 290;
			var string:String;
			var field:TextField;

			management.push(TriviaText.create(this, {
				w: Screen.stageWidth,
				y: y,
				text: "Management",
				style: TriviaText.BLUE_MEDIUM,
				bold:true
			}));

			y += management[management.length - 1].height * 1.1;

			for each (string in managerNames)
			{
				field = createName(string, y);
				management.push(field);
				y += field.height * 1.1;
			}

			y += management[management.length - 1].height * 1.1;

			development.push(TriviaText.create(this, {
				w: Screen.stageWidth,
				y: y,
				text: "Development",
				style: TriviaText.BLUE_MEDIUM,
				bold:true
			}));

			y += development[development.length - 1].height * 1.1;

			for each (var s:String in developerNames)
			{
				var temp:TextField = createName(s, y);
				development.push(temp);
				y += temp.height * 1.1;
			}

			y += development[development.length - 1].height * 1.1;

			var destinationURL:String =
				System.isAndroid ? "https://play.google.com/store/music/album/Tim_Carleton_Darrick_Deel_Opus_No_1?id=Bexz3zvy6tghjt4bwdxhs33rywy"
					: "https://itunes.apple.com/us/album/opus-no.-1-single/id1118136394";

			audio.push(TriviaText.create(this, {
				w: Screen.stageWidth,
				y: y,
				text: "Audio",
				style: TriviaText.BLUE_MEDIUM,
				bold:true
			}));

			y += audio[audio.length - 1].height * 1.1;

			for each (string in audioNames)
			{
				field = createName(string, y);
				if(field.text.indexOf("Opus") > -1) Quick.click(field, navigate(destinationURL));
				audio.push(field);
				y += field.height * 1.1;
			}

			var linkContainer:Sprite = new Sprite();

			terms = TriviaText.create(linkContainer, {
				w: Screen.stageWidth,
				style: TriviaText.GREEN_MEDIUM,
				text: "Terms and Conditions"
			});

			privacy = TriviaText.create(linkContainer, {
				w: Screen.stageWidth,
				style: TriviaText.GREEN_MEDIUM,
				text: "Privacy Policy",
				y:Position.bottom(terms) + 15
			});

			addChild(linkContainer);

			var footer:TextField = TriviaText.create(this, {
				w: Screen.stageWidth,
				style: TriviaText.BLUE_TINY,
				size: 27,
				text: "All use of this software is subject to the terms and conditions and privacy policy.\nGeek Factor © 2016 Cisco Systems, Inc. and/or its affiliates. All Rights Reserved."
			});

			Position.bottom(footer, Screen.bottom - 15);

			Position.centerY(linkContainer, y + (footer.y - y) / 2);
		}

		public function createName(name:String, y:Number = NaN):TextField
		{
			return TriviaText.create(this, {
				w: Screen.stageWidth,
				y: y,
				text: name,
				style: TriviaText.BLUE_SMALL
			});
		}

		public override function ready():void
		{
			Quick.click(terms, navigate("http://www.cisco.com/web/siteassets/legal/terms_condition.html"));
			Quick.click(privacy, navigate("http://www.cisco.com/web/siteassets/legal/privacy_full.html"));
		}

		public override function terminate():void
		{

		}

		private function navigate(url:String):Function
		{
			return function():void
			{
				Browser.load(url);
			}
		}
	}
}
