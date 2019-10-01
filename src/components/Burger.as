/**
 * Created by George on 10/20/2015.
 */
package components
{
	import architecture.AudioMap;
	import architecture.Fonts;
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.game.Ad;
	import architecture.game.ColorMap;
	import architecture.game.Room;

	import com.greensock.TweenMax;

	import scenes.Achievements;

	import scenes.Credits;
	import scenes.Events;
	import scenes.Friends;
	import scenes.Game;
	import scenes.Leaderboards;
	import scenes.Login;
	import scenes.Menu;
	import scenes.PregameSplash;
	import scenes.Settings;
	import scenes.Store;
	import scenes.SubmitQuestion;

	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;

	import ten90.components.Component;
	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.SceneController;
	import ten90.tools.Help;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	public class Burger extends Component
	{
		private var overlay:Quad;

		public var icon:Image;
		private var menuContainer:Sprite;

		public override function ready():void
		{
			this.x = Screen.left;
			this.y = Screen.top;

			icon = Make.image(this, ImageMap.ICON_BURGER_MENU);

			var space:Quad = Make.quad(this, 0, 0, icon.width * 4, icon.width * 4, 0, 0);
			space.useHandCursor = true;
			Quick.pivot(space, .5, .5);

			icon.x = 75;

			//TODO: how in the hell did this become necessary?
			var iconY:int = (Screen.aspectRatioFloat <= .6) ? 225 : 262;
			icon.y = iconY;

			space.x = icon.x + icon.width / 2;
			space.y = icon.y + icon.height / 2;

//			function positionIcon():void
//			{
//				if(Ad.current && Ad.current.image)
//					icon.y = Position.bottom(Ad.current.sprite) + 75;
//				else
//				{
//					icon.y = 75;
//					Quick.call(.1, positionIcon);
//				}
//
//				space.x = icon.x + icon.width / 2;
//				space.y = icon.y + icon.height / 2;
//			}
//
//			Quick.call(.1, positionIcon);

			create();

			activateBurger();
		}

		private function activateBurger():void
		{
			Quick.click(this, showMenu);
		}

		private function create():void
		{
			menuContainer = new Sprite();

			var buttonHeight:int = 150;
			var buttonY:int = 225;

			var bg:Quad = Make.quad(menuContainer, 0, 0, 900, Screen.height, ColorMap.CISCO_BLUE);
			var homeButton:Button = Make.button(menuContainer, 0, buttonY, Skins.BURGER_DOWN, ImageMap.BURGER_MENU_DOWN, Skins.BURGER_DOWN);
			var storeButton:Button = Make.button(menuContainer, 0, buttonY+=buttonHeight, Skins.BURGER_DOWN, ImageMap.BURGER_MENU_DOWN, Skins.BURGER_DOWN);
			var friendButton:Button = Make.button(menuContainer, 0, buttonY+=buttonHeight, Skins.BURGER_DOWN, ImageMap.BURGER_MENU_DOWN, Skins.BURGER_DOWN);
			var eventButton:Button = Make.button(menuContainer, 0, buttonY+=buttonHeight, Skins.BURGER_DOWN, ImageMap.BURGER_MENU_DOWN, Skins.BURGER_DOWN);
			var achievementButton:Button = Make.button(menuContainer, 0, buttonY+=buttonHeight, Skins.BURGER_DOWN, ImageMap.BURGER_MENU_DOWN, Skins.BURGER_DOWN);
			var leaderButton:Button = Make.button(menuContainer, 0, buttonY+=buttonHeight, Skins.BURGER_DOWN, ImageMap.BURGER_MENU_DOWN, Skins.BURGER_DOWN);
			var questionButton:Button = Make.button(menuContainer, 0, buttonY+=buttonHeight, Skins.BURGER_DOWN, ImageMap.BURGER_MENU_DOWN, Skins.BURGER_DOWN);
			var settingsButton:Button = Make.button(menuContainer, 0, buttonY+=buttonHeight, Skins.BURGER_DOWN, ImageMap.BURGER_MENU_DOWN, Skins.BURGER_DOWN);
			var creditsButton:Button = Make.button(menuContainer, 0, buttonY+=buttonHeight, Skins.BURGER_DOWN, ImageMap.BURGER_MENU_DOWN, Skins.BURGER_DOWN);
			var logoutButton:Button = Make.button(menuContainer, 0, 0, Skins.BURGER_DOWN, ImageMap.BURGER_MENU_DOWN, Skins.BURGER_DOWN);
			Position.bottom(logoutButton, Screen.bottom);

			var padding:int = 60;
			function genText(target:Button, text:String, divider:Boolean = true):void
			{
				Make.text(menuContainer, target.x + padding, target.y, target.width - padding * 2, target.height, text, Fonts.SYSTEM, 44, 0xFFFFFF).touchable = false;
				if(divider) Make.quad(menuContainer, target.x, Position.bottom(target), target.width, Skins.dividerStroke, 0xFFFFFF).touchable = false;
			}

			genText(homeButton, "Home");
			genText(storeButton, "Store");
			genText(friendButton, "Friends");
			genText(eventButton, "Events");
			genText(leaderButton, "Leaderboards");
			genText(achievementButton, "Achievements");
			genText(questionButton, "Submit a Question");
			genText(settingsButton, "Settings");
			genText(creditsButton, "Credits");
			genText(logoutButton, "Log Out", false);

			Make.quad(menuContainer, homeButton.x, int(homeButton.y), homeButton.width, Skins.dividerStroke, 0xFFFFFF).touchable = false;

			Quick.click(homeButton, transition(Menu), false);
			Quick.click(storeButton, transition(Store), false);
			Quick.click(friendButton, transition(Friends), false);
			Quick.click(eventButton, transition(Events), false);
			Quick.click(leaderButton, transition(Leaderboards), false);
			Quick.click(achievementButton, transition(Achievements), false);
			Quick.click(questionButton, transition(SubmitQuestion), false);
			Quick.click(settingsButton, transition(Settings), false);
			Quick.click(creditsButton, transition(Credits), false);
			Quick.click(logoutButton, transition(Login), false);

			menuContainer.visible = false;
			addChild(menuContainer);
		}

		private function showMenu():void
		{
			Audio.play(AudioMap.BURGER);

			menuContainer.visible = true;

			overlay = Make.quad(this, 0, 0, Screen.width, Screen.height, 0, .65);
			Quick.index(overlay, 0);

			TweenMax.from(overlay, .4, {alpha:0});

			menuContainer.x = -menuContainer.width;
			TweenMax.to(menuContainer, .4, {x:0, onComplete:activateMenu});

			parent.setChildIndex(this, parent.numChildren-1);
		}

		private function activateMenu():void
		{
			var close:Button = Make.emptyButton(menuContainer, 0, 0, 200, 350);
			close.x = menuContainer.width - close.width;

			Quick.click(close, closeMenu);
			Quick.click(overlay, closeMenu);
		}

		private function closeMenu(playAudio:Boolean = true):void
		{
			if(playAudio) Audio.play(AudioMap.BURGER);

			Quick.removeClick(overlay);

			TweenMax.to(overlay, .4, {alpha:0});
			TweenMax.to(menuContainer, .4, {x:-menuContainer.width, onComplete:reset});
		}

		private function reset():void
		{
			menuContainer.visible = false;
			removeChild(overlay);

			activateBurger();
		}

		private function transition(scene:Class):Function
		{
			return function():void
			{
				Audio.play(AudioMap.BUTTON_PRESS);

				if(!(SceneController.currentScene is scene))
				{
					if (forfeitWarningNeeded(scene))
					{
						trace("User should forfeit the game before continuing.");
						Room.current.leave();
					}

					var removeOnComplete:Boolean = !(SceneController.currentScene is Menu);
					SceneController.transition(scene, 0, 1, removeOnComplete);

					if(!removeOnComplete) closeMenu(false);
				}
				else closeMenu();
			}
		}

		private function forfeitWarningNeeded(targetScene:Class):Boolean
		{
			var current:String = Help.getClassName(SceneController.currentScene);
			for each (var scene:* in [PregameSplash, Game])
				if (Help.getClassName(scene) == current)
					return true;
			return false;
		}
	}
}
