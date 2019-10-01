/**
 * Created by gperry on 7/25/2016.
 */
package components
{
	import architecture.AudioMap;
	import architecture.ImageMap;
	import architecture.game.ColorMap;

	import com.greensock.TweenMax;

	import controls.ProfilePhoto;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import scenes.Menu;

	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.textures.Texture;

	import ten90.base.Assets;
	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	import tools.TriviaText;

	public class Tutorial extends Component
	{
		public var onComplete:Function;

		private var index:int = -1;
		private var bg:Image;
		private var container:Sprite;
		private var titleText:TextField;
		private var contentText:TextField;
		private var blocks:Image;
		private var arrow:Image;
		private var nextButton:TextField;
		private var skipButton:TextField;

		private var holePositions:Array = [];

		private const TEXT_CONTENT:Array =
		[
			{title:"Menu", content:"Here is where you will be able to access Events, Achievements, Friends, Leaderboards, and more."},
			{title:"Rank", content:"This indicates your rank level. Win ranked Versus or Group matches in order to level up!"},
			{title:"Currency", content:"This is how many coins you have accumulated throughout the game. You can spend these coins to purchase powerups in the store."},
			{title:"Events", content:"Battle a specific group of geeks with your own personalized leaderboards. Obtain a unique event code and type it in to join an event!"},
			{title:"Single", content:"Practice without the pressure of competing against other players, test your knowledge in each category!"},
			{title:"Versus", content:"A one on one battle against some of the best. Climb the ranks of the leaderboard and showcase your dominant intelligence. Win matches to gain ranked points and increase your level!"},
			{title:"Group", content:"See how you stack up against multiple brains at one time. Create a game and invite your friends or recent players, or view challenges sent to you by others."}
		];

		public function create():void
		{
			x = Screen.left;
			y = Screen.top;

			var parentScene:Menu = this.parentScene as Menu;
			var burger:Burger = parentScene.getComponent(Burger);
			var profile:ProfilePhoto = parentScene.profile;
			var modeSelector:ModeSelector = parentScene.modeSelector;

			holePositions.push(getHoleObject(burger.icon, null, 25));
			holePositions.push(getHoleObject(profile.rankingIcon));
			holePositions.push(getHoleObject(profile.txtScore, parentScene.shopButton, 25));
			holePositions.push(getHoleObject(parentScene.eventButton));
			holePositions.push(getHoleObject(modeSelector.singleMode));
			holePositions.push(getHoleObject(modeSelector.versusMode));
			holePositions.push(getHoleObject(modeSelector.multiMode));

			container = new Sprite();

			blocks = Make.image(container, ImageMap.TUTORIAL_BAR_1);

			titleText = TriviaText.create(container,
				{
					text:TEXT_CONTENT[0].title,
					style:TriviaText.WHITE_MEDIUM_LEFT,
					y:int(Position.bottom(blocks) + 25)
				});

			contentText = TriviaText.create(container,
				{
					text:TEXT_CONTENT[0].content,
					style:TriviaText.WHITE_SMALL_LEFT,
					width:950,
					y:int(Position.bottom(titleText) + 15)
				});

			nextButton = TriviaText.create(container,
				{
					text:"next",
					style:TriviaText.WHITE_MEDIUM_LEFT
				});

			Position.right(nextButton, int(Position.right(contentText) - 25));
			Position.top(nextButton, int(Position.bottom(contentText) + 125));

			skipButton = TriviaText.create(container,
				{
					text:"skip",
					style:TriviaText.WHITE_MEDIUM_LEFT
				});

			Position.right(skipButton, int(Position.left(nextButton) - 50));
			skipButton.y = nextButton.y;

			addChild(container);

			Quick.click(nextButton, next, false);
			Quick.click(skipButton, skip);

			next(false);
		}

		private function next(audio:Boolean = true):void
		{
			index++;

			if(audio) Audio.play(AudioMap.BUTTON_PRESS);

			if(index == TEXT_CONTENT.length)
			{
				done();
				return;
			}

			removeChild(bg);

			var holes:Object = holePositions[index];
			if(holes.hole2Y)  bg = makeBG(holes.hole1X, holes.hole1Y, holes.radius1, holes.hole2X, holes.hole2Y, holes.radius2);
			else bg = makeBG(holes.hole1X, holes.hole1Y, holes.radius1);
			addChildAt(bg, 0);

			TweenMax.to(container, .2, {alpha:0, repeat:1, yoyo:true, onRepeat:function():void
			{
				titleText.text = TEXT_CONTENT[index].title;
				contentText.text = TEXT_CONTENT[index].content;
				blocks.texture = Assets.getTexture(ImageMap["TUTORIAL_BAR_" + (index + 1)]);

				nextButton.y = contentText.y + contentText.textBounds.height + 25;
				skipButton.y = contentText.y + contentText.textBounds.height + 25;

				var containerX:int = (holes.hole1X + holes.radius1) - container.width / 2;
				if(containerX < Screen.left) containerX = 50;
				else if(containerX + container.width > Screen.right) containerX = Screen.right - container.width - 50;
				container.x = containerX;

				var containerY:int = holes.hole1Y + holes.radius1 + 100;
				if(containerY + container.height > Screen.bottom) containerY = holes.hole1Y - container.height - 160;
				container.y = containerY;
			}});
		}

		private function skip():void
		{
			Audio.play(AudioMap.BUTTON_PRESS);
			done();
		}

		private function done():void
		{
			onComplete();
		}

		private function makeBG(hole1X:Number, hole1Y:Number, hole1Radius:Number, hole2X:Number = 0, hole2Y:Number = 0, hole2Radius:Number = 0):Image
		{
			var texture:Texture;

			var shape:Shape = new Shape();

			shape.graphics.beginFill(ColorMap.CISCO_BLUE, .95);
			shape.graphics.drawRect(0, 0, Screen.width, Screen.height);

			shape.graphics.drawCircle(hole1X, hole1Y, hole1Radius);
			shape.graphics.drawCircle(hole2X, hole2Y, hole2Radius);

			shape.graphics.endFill();

			var bounds:Rectangle = shape.getBounds(shape);

			var bitmapData:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);
			bitmapData.draw(shape);

			shape = null;

			texture = Texture.fromBitmapData(bitmapData, false);

			return new Image(texture);
		}

		private function getHoleObject(target1:DisplayObject, target2:DisplayObject = null, target1ExtraRadius:int = 0, target2ExtraRadius:int = 0):Object
		{
			var point1:Point = target1.parent.localToGlobal(new Point(Position.left(target1), Position.top(target1)));
			var point2:Point;

			var object:Object =
		    {
			    radius1:target1.width / 2 + target1ExtraRadius,
			    hole1X:point1.x + target1.width / 2,
			    hole1Y:point1.y + target1.height / 2
		    };

			if(target2)
			{
				point2 = target2.parent.localToGlobal(new Point(Position.left(target2), Position.top(target2)));

				object.radius2 = target2.width / 2 + target2ExtraRadius;
				object.hole2X = point2.x + target2.width / 2;
				object.hole2Y = point2.y + target2.height / 2;
			}

			return object;
		}
	}
}
