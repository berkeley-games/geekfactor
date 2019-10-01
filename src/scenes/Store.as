/**
 * Created by gperry on 3/24/2016.
 */
package scenes
{
	import architecture.AudioMap;
	import architecture.Database;
	import architecture.Fonts;
	import architecture.ImageMap;
	import architecture.game.ColorMap;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;

	import components.BackButton;
	import components.Background;

	import controls.BlueHeader;
	import controls.PowerupIcon;
	import controls.ProfilePhoto;

	import org.gestouch.gestures.SwipeGestureDirection;

	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.StarlingScene;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	import tools.Helper;
	import tools.TriviaText;

	public class Store extends StarlingScene
	{
		private static var price5050:int;
		private static var priceFreeze:int;
		private static var priceAudience:int;

		private var container1:Sprite;
		private var container2:Sprite;
		private var container3:Sprite;
		private var fiftyButton:Button;
		private var freezeButton:Button;
		private var audienceButton:Button;

		private var profile:ProfilePhoto;

		private var _5050:PowerupIcon;
		private var freeze:PowerupIcon;
		private var audience:PowerupIcon;

		private var tapToPurchase:TextField;

		private var leftArrow:Image;
		private var rightArrow:Image;
		private var itemIndex:int = 1;

		private var line:Quad;

		private var containerX0:int;
		private var containerX1:int;
		private var containerX2:int;
		private var containerX3:int;
		private var containerX4:int;

		public override function init():void
		{
			new BlueHeader(this, "Store");

			BackButton.onClick = animateOut;

			profile = new ProfilePhoto(this, User.current, 0, Menu.PROFILE_Y, ProfilePhoto.LARGE, false, false, true);
			profile.setOptions(true, true, false, true);
			profile.x = (Screen.stageWidth - profile.photoWidth) / 2;

			_5050 = new PowerupIcon(this, 740, profile.y + 15, ImageMap.ICON_POWERUP_1, User.current.fiftyfifties);
			freeze = new PowerupIcon(this, 775, _5050.y + 155, ImageMap.ICON_POWERUP_2, User.current.freezes);
			audience = new PowerupIcon(this, 740, freeze.y + 155, ImageMap.ICON_POWERUP_3, User.current.audiences);

			Quick.index(_5050, 1);
			Quick.index(freeze, 1);
			Quick.index(audience, 1);

			container1 = new Sprite();
			container2 = new Sprite();
			container3 = new Sprite();

			line = Make.quad(this, Screen.left+50, Position.bottom(profile) + 100, Screen.width - 100, 2, ColorMap.GRAY);
			Quick.pivot(line, .5, 0, true);

			fiftyButton = Make.button(container1, 0, 0, ImageMap.ICON_POWERUP_1_LARGE);
			freezeButton = Make.button(container2, 0, 0, ImageMap.ICON_POWERUP_2_LARGE);
			audienceButton = Make.button(container3, 0, 0, ImageMap.ICON_POWERUP_3_LARGE);

			const TITLE_HEIGHT:int = 115;

			var fiftyTitle:TextField = Make.text
			(
				container1,
				fiftyButton.x, fiftyButton.y + fiftyButton.height + 15, Screen.width, TITLE_HEIGHT,
				"50/50", Fonts.SYSTEM, 75, ColorMap.BLACK, false, "center", "top"
			);

			var freezeTitle:TextField = Make.text
			(
				container2,
				freezeButton.x, freezeButton.y + freezeButton.height + 15, Screen.width, TITLE_HEIGHT,
				"Time Freeze", Fonts.SYSTEM, 75, ColorMap.BLACK, false, "center", "top"
			);

			var audienceTitle:TextField = Make.text
			(
				container3,
				audienceButton.x, audienceButton.y + audienceButton.height + 15, Screen.width, TITLE_HEIGHT,
				"Audience", Fonts.SYSTEM, 75, ColorMap.BLACK, false, "center", "top"
			);

			var fiftyText:String = "Can't decide?\nEliminate two incorrect\nanswers, leaving you\nwith a 50/50 chance.";
			var freezeText:String = "Need more time?\nFreeze the clock for 5\nseconds and hang on\nto a higher score.";
			var audienceText:String = "Stumped?\nSee the answers\nthat are picked\nthe most!";

			const DEXSCRIPTION_WIDTH:int = Screen.width;
			const DESCRIPTION_HEIGHT:int = 310;

			var fiftyDesc:TextField = Make.text
			(
				container1,
				fiftyButton.x, Position.bottom(fiftyTitle), DEXSCRIPTION_WIDTH, DESCRIPTION_HEIGHT,
				fiftyText, Fonts.SYSTEM, 47, ColorMap.BLACK, false, "center", "center"
			);

			var freezeDesc:TextField = Make.text
			(
				container2,
				freezeButton.x, Position.bottom(freezeTitle), DEXSCRIPTION_WIDTH, DESCRIPTION_HEIGHT,
				freezeText, Fonts.SYSTEM, 47, ColorMap.BLACK, false, "center", "center"
			);

			var audienceDesc:TextField = Make.text
			(
				container3,
				audienceButton.x, Position.bottom(audienceTitle), DEXSCRIPTION_WIDTH, DESCRIPTION_HEIGHT,
				audienceText, Fonts.SYSTEM, 47, ColorMap.BLACK, false, "center", "center"
			);

			fiftyDesc.x = fiftyButton.x + (fiftyButton.width - fiftyDesc.width) / 2;
			freezeDesc.x = freezeButton.x + (freezeButton.width - freezeDesc.width) / 2;
			audienceDesc.x = audienceButton.x + (audienceButton.width - audienceDesc.width) / 2;

			fiftyTitle.x = fiftyButton.x + (fiftyButton.width - fiftyTitle.width) / 2;
			freezeTitle.x = freezeButton.x + (freezeButton.width - freezeTitle.width) / 2;
			audienceTitle.x = audienceButton.x + (audienceButton.width - audienceTitle.width) / 2;

			var cost1:TextField = TriviaText.create(container1, {
				w: fiftyDesc.width,
				y:Position.bottom(fiftyDesc),
				x:fiftyDesc.x,
				text: "cost",
				style: TriviaText.BLACK_SMALL,
				size:35,
				halign:"center"
			});

			var cost2:TextField = TriviaText.create(container2, {
				w: freezeDesc.width,
				y:Position.bottom(freezeDesc),
				x:freezeDesc.x,
				text: "cost",
				style: TriviaText.BLACK_SMALL,
				size:35,
				halign:"center"
			});

			var cost3:TextField = TriviaText.create(container3, {
				w: freezeDesc.width,
				y:Position.bottom(audienceDesc),
				x:audienceDesc.x,
				text: "cost",
				style: TriviaText.BLACK_SMALL,
				size:35,
				halign:"center"
			});

			var price1:TextField = TriviaText.create(container1, {
				y: Position.bottom(cost1),
				text: Helper.formatNumber(price5050),
				style: TriviaText.GREEN_MEDIUM,
				halign:"center",
				size:65
			});

			var price2:TextField = TriviaText.create(container2, {
				y: Position.bottom(cost1),
				text: Helper.formatNumber(priceFreeze),
				style: TriviaText.GREEN_MEDIUM,
				halign:"center",
				size:65
			});

			var price3:TextField = TriviaText.create(container3, {
				y: Position.bottom(cost1),
				text: Helper.formatNumber(priceAudience),
				style: TriviaText.GREEN_MEDIUM,
				halign:"center",
				size:65
			});

			price1.x = Position.left(cost1) + (cost1.width - price1.width) / 2 - 10;
			price2.x = Position.left(cost2) + (cost2.width - price2.width) / 2 - 10;
			price3.x = Position.left(cost3) + (cost3.width - price3.width) / 2 - 10;

			var coin1:Image = Make.image(container1, ImageMap.IMG_COIN, Position.right(price1) + 10, price1.y + price1.height/2);
			Quick.pivot(coin1, 0, .5);

			var coin2:Image = Make.image(container2, ImageMap.IMG_COIN, Position.right(price2) + 10, price2.y + price2.height/2);
			Quick.pivot(coin2, 0, .5);

			var coin3:Image = Make.image(container3, ImageMap.IMG_COIN, Position.right(price3) + 10, price3.y + price3.height/2);
			Quick.pivot(coin3, 0, .5);

			coin1.scale = coin2.scale = coin3.scale = .65;

			containerX2 = (Screen.left + Screen.width  / 2) - fiftyButton.width / 2;
			containerX1 = Screen.left - containerX2;
			containerX0 = containerX1 - containerX2;
			containerX3 = Screen.right + containerX2;
			containerX4 = containerX3 + containerX2;

			container1.x = containerX2;
			Position.top(container1, Position.centerY(line) - fiftyButton.height / 2);

			Position.top(container2, Position.top(container1));
			Position.left(container2, Position.right(container1));

			Position.top(container3, Position.top(container2));
			Position.left(container3, Position.right(container2));

			addChild(container1);
			addChild(container2);
			addChild(container3);

			leftArrow = Make.image(this, ImageMap.STORE_LEFT);
			Position.left(leftArrow, Screen.left + 25);
			Position.centerY(leftArrow, container1.y + Position.centerY(fiftyDesc));
			leftArrow.alpha = .5; // it starts "disabled"

			rightArrow = Make.image(this, ImageMap.STORE_RIGHT);
			Position.right(rightArrow, Screen.right - 25);
			Position.top(rightArrow, Position.top(leftArrow));

			updateTotals();

			tapToPurchase = Make.text(this, 0, Screen.bottom - 125, Screen.stageWidth, 100, "Tap Icon to Purchase", Fonts.SYSTEM, 60, ColorMap.BLACK, false, "center");

			TweenMax.from(tapToPurchase, .5, {alpha:0, delay:.75});
			TweenMax.allFrom([_5050, freeze, audience], .65, {delay:.35, y:profile.y+profile.photoWidth/2, x:"-=350", ease:Back.easeOut}, .2);
			TweenMax.from(container1, .85, {delay:.2, y:Screen.bottom, ease:Back.easeOut.config(.75)});
			TweenMax.from([leftArrow, rightArrow], .5, {delay:.5, alpha:0});
			TweenMax.from(line, 1, {delay:.9, scaleX:0, ease:Back.easeOut});
		}

		public override function ready():void
		{
			Quick.click(fiftyButton, fiftyClicked, false);
			Quick.click(freezeButton, freezeClicked, false);
			Quick.click(audienceButton, audienceClicked, false);

			Quick.click(leftArrow, leftArrowClicked, false);
			Quick.click(rightArrow, rightArrowClicked, false);

			Quick.swipe(this, leftArrowClicked, 1, SwipeGestureDirection.RIGHT);
			Quick.swipe(this, rightArrowClicked, 1, SwipeGestureDirection.LEFT);
		}

		private function leftArrowClicked():void
		{
			adjustItemIndex(-1, 1, 3);
			animateContainers();
		}

		private function rightArrowClicked():void
		{
			adjustItemIndex(1, 1, 3);
			animateContainers();
		}

		private function adjustItemIndex(value:int, min:int, max:int):void
		{
			itemIndex += value;

			if(itemIndex > max) itemIndex = max;
			else if(itemIndex == max) rightArrow.alpha = .5;
			else if(itemIndex == min) leftArrow.alpha = .5;
			else if(itemIndex < min) itemIndex = min;

			if(itemIndex > min) leftArrow.alpha = 1;
			if(itemIndex < max) rightArrow.alpha = 1;
		}

		private function animateContainers():void
		{
			Audio.play(AudioMap.BUTTON_PRESS);

			var index1:int = 3 - itemIndex;
			var index2:int = 4 - itemIndex;
			var index3:int = 5 - itemIndex;

			TweenMax.to(container1, .75, {x:this["containerX" + index1], ease:Quart.easeOut});
			TweenMax.to(container2, .75, {x:this["containerX" + index2], ease:Quart.easeOut});
			TweenMax.to(container3, .75, {x:this["containerX" + index3], ease:Quart.easeOut});
		}

		private function fiftyClicked():void
		{
			if(price5050 <= User.current.coins)
			{
				setButtonsEnabled(false);
				Audio.play(AudioMap.ITEM_PURCHASED);
				Database.purchaseStoreItem(1, updateTotals);
			}
		}

		private function freezeClicked():void
		{
			if(priceFreeze <= User.current.coins)
			{
				setButtonsEnabled(false);
				Audio.play(AudioMap.ITEM_PURCHASED);
				Database.purchaseStoreItem(2, updateTotals);
			}
		}

		private function audienceClicked():void
		{
			if(priceAudience <= User.current.coins)
			{
				setButtonsEnabled(false);
				Audio.play(AudioMap.ITEM_PURCHASED);
				Database.purchaseStoreItem(3, updateTotals);
			}
		}

		private function updateTotals(userData:XML = null):void
		{
			profile.user.updateFromXML(userData, function():void
			{
				User.current = profile.user;
				profile.score = User.current.coins;
				_5050.count = User.current.fiftyfifties;
				freeze.count = User.current.freezes;
				audience.count = User.current.audiences;
				setButtonsEnabled();
			});
		}

		private function setButtonsEnabled(enabled:Boolean = true):void
		{
			for each (var o:* in [fiftyButton, freezeButton])
				o.touchable = enabled;
		}

		private function animateOut():void
		{
			touchable = false;
			getComponent(BackButton).touchable = false;
			profile.fadeText();
			TweenMax.to(tapToPurchase, .5, {alpha:0});
			TweenMax.allTo([_5050, freeze, audience], .65, {y:profile.y+profile.photoWidth/2, x:"-=350", ease:Back.easeIn}, .2);
			TweenMax.to(line, .65, {scaleX:0, ease:Back.easeIn});
			TweenMax.to([leftArrow, rightArrow], .5, {delay:.1, alpha:0});
			TweenMax.to([container1, container2, container3], .85, {delay:.5, y:Screen.bottom, ease:Back.easeIn.config(.75), onComplete:leave});
		}

		private function leave():void
		{
			container1.dispose();
			container1 = null;

			container2.dispose();
			container2 = null;

			container3.dispose();
			container3 = null;

			Quick.call(.2, function():void{
				transition(Menu);
			});
		}

		public static function set fiftyPrice(val:int):void {
			price5050 = val;
		}

		public static function set freezePrice(val:int):void {
			priceFreeze = val;
		}

		public static function set audiencePrice(val:int):void {
			priceAudience = val;
		}
	}
}
