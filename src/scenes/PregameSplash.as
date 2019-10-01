/**
 * Created by wmaynard on 3/7/2016.
 */
package scenes
{
	import architecture.AudioMap;
	import architecture.Database;
	import architecture.Fonts;
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.game.ColorMap;
	import architecture.game.GFEvent;
	import architecture.game.Room;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Quint;

	import components.BackButton;
	import components.CustomError;
	import components.PlayerList;
	import components.VersusProfiles;

	import controls.CategoryIcon;
	import controls.ProfilePhoto;

	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.text.TextField;

	import ten90.components.SpinnerRing;
	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.SceneController;
	import ten90.scene.StarlingScene;
	import ten90.scene.Transitions;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	import tools.Helper;
	import tools.TriviaText;

	public class PregameSplash extends StarlingScene
	{
		private const WAIT_TIME:int = 15;
		private const GROUP_MIN_USERS:int = 2;

		public static var showDetails:Boolean = true;

		private var profile:ProfilePhoto;
		private var black:Quad;
		private var blueShape:Shape;
		private var whiteShape:Shape;
		private var play:Button;
		private var categoryName:String;
		private var iconString:String;
		private var onRoomJoin:Function;
		private var onStart:Function;
		private var spinner:SpinnerRing;
		private var backButton:BackButton;

		private var category:Image;
		private var label:TextField;
		private var _categoryLabel:TextField;
		private var bgCategory:Image;
		private var invitePlayers:TextField;
		private var playerList:PlayerList;

		private var eventLabel:TextField;

		private var opponentProfile:ProfilePhoto;
		private var categoryIcon:CategoryIcon;
		private var logoContainer:Sprite;
		private var dropShadow:Image;
		private var extraLeft:Number;
		private var blueXPos:Number;

		public override function init():void
		{
			trace("ROOM MODE: " + Room.mode);

			VersusProfiles.oppUser = null;
			Results.willNotify = false;

			// TODO: Not sure where this belongs, but we need to store the previous ranked score to get the difference for RankDialog.
			User.current.storeXP();

			spinner = getComponent(SpinnerRing);
			backButton = getComponent(BackButton);

			black = Make.quad(this, Screen.left, Screen.top, Screen.width, Screen.height);

			var bottomPadding:int = 200;
			extraLeft = 110 * (Screen.aspectRatioFloat / (9 / 16));
			blueXPos = Screen.right + Math.abs(Screen.left) + extraLeft;

			// Images
			blueShape = new Shape();
			blueShape.graphics.beginFill(0x049FD8);
			blueShape.graphics.moveTo(Screen.right, Screen.top);
			blueShape.graphics.lineTo(Screen.right, Screen.bottom);
			blueShape.graphics.lineTo(Screen.left-extraLeft, Screen.bottom);
			blueShape.graphics.lineTo(Screen.left, Screen.bottom-bottomPadding);
			blueShape.graphics.lineTo(Screen.right, Screen.top);
			blueShape.graphics.endFill();
			blueShape.touchable = false;
			addChild(blueShape);

			whiteShape = new Shape();
			whiteShape.graphics.beginFill(0xFFFFFF);
			whiteShape.graphics.moveTo(Screen.left, Screen.top);
			whiteShape.graphics.lineTo(Screen.right, Screen.top);
			whiteShape.graphics.lineTo(Screen.left, Screen.bottom-bottomPadding);
			whiteShape.graphics.lineTo(Screen.left, Screen.top);
			whiteShape.graphics.endFill();
			whiteShape.touchable = false;

			addChild(getComponent(PlayerList));

			dropShadow = Make.image(this, ImageMap.PREGAME_DROP_SHADOW);
			dropShadow.x = Screen.left;
			dropShadow.y = Screen.bottom - bottomPadding;
			var yDistance:Number = Screen.top - dropShadow.y;
			var xDistance:Number = Screen.right - dropShadow.x;
			var radian:Number = Math.atan2(yDistance, xDistance); // trigonometry!!!
			dropShadow.rotation = radian;
			dropShadow.width = Screen.width * 1.1;
			dropShadow.touchable = false;
			addChild(whiteShape);

			playerList = getComponent(PlayerList);

			if(GFEvent.current && Room.mode != Room.MODE_SINGLE)
			{
				eventLabel = TriviaText.create(this, {
					h: 100,
					x:Screen.left,
					w:Screen.width,
					text: GFEvent.current ? "Event: " + GFEvent.current.name : null,
					style: TriviaText.WHITE_MEDIUM
				});

				eventLabel.alpha = 0;
				eventLabel.y = Screen.bottom - eventLabel.height - 15;
			}

			// Buttons
			play = Helper.GreenButton(this, "Play", Screen.stageWidth / 2, Screen.bottom + 25, function():void {
				if (onStart) onStart();
			});
			play.y -= play.height;
			Helper.center(play);

			if(Room.mode != Room.MODE_SINGLE)
			{
				play.visible = false;
				play.alpha = 0;
			}
			else TweenMax.from(play, .5, {delay:2, scale:0, alpha:0, ease:Back.easeOut});

			TweenMax.from(black, 2, {delay:.15, alpha:0});
			TweenMax.from(blueShape, 1, {x:blueXPos, ease:Quint.easeInOut});
			TweenMax.allFrom([whiteShape, dropShadow], 1, {x:Screen.left-whiteShape.width-200, ease:Quint.easeInOut});
			if(eventLabel) TweenMax.to(eventLabel, 0.5, {delay:1.5, alpha: 1});

			Quick.call(2, SceneController.transitionComplete);
		}

		public override function terminate():void {}

		public override function ready():void
		{
			if(!showDetails)
			{
				spinner.visible = false;
				play.visible = false;
				showDetails = true;
				start();
				return;
			}

			Audio.crossFade(AudioMap.lastSong, AudioMap.SEARCH_MUSIC, .5, -1);

			profile = new ProfilePhoto(this, User.current, Screen.left + 100, Screen.top + 175);
			profile.setOptions(false, true, true, false);
			TweenMax.from(profile, .25, {alpha: 0});
			createLogo();

			Quick.pivot(profile, .5, .5, true);

			var alreadyInRoom:Boolean = false;
			switch(Room.mode)
			{
				case Room.MODE_SINGLE:
					singleMode();
					break;

				case Room.MODE_VERSUS:
				case Room.MODE_VERSUS_REMATCH:
					versusMode();
					break;

				case Room.MODE_INVITE:
					if(eventLabel) eventLabel.visible = false;
					CreateGroup.clearSavedInvites();
					invitePlayers = TriviaText.create(this, {x:Screen.left, w:Screen.width, h: 100, text:"Waiting for the host...", size:60, color:ColorMap.WHITE});
				case Room.MODE_GROUP_PRIVATE:
					if(eventLabel) eventLabel.visible = false;
//					alreadyInRoom = true;
				case Room.MODE_GROUP_RANKED:
					groupMode(alreadyInRoom);
					break;
			}

			Quick.click(backButton, backClicked);
		}

		private function createLogo():void
		{
			logoContainer = new Sprite();

			var logo:Image = Make.image(this, Room.mode == Room.MODE_SINGLE ? Skins.ORANGE_SPLASH_CIRCLE : Skins.BLUE_SPLASH_CIRCLE);

			var text:String;
			switch (Room.mode)
			{
				case Room.MODE_SINGLE:
					text = "SINGLE\nPLAYER";
					break;

				case Room.MODE_VERSUS:
				case Room.MODE_VERSUS_REMATCH:
					text = "VERSUS";
					break;

				default:
					text = "MULTI\nPLAYER";
					break;
			}

			var title:TextField = TriviaText.create(null, {
				w: logo.width,
				h: logo.height,
				text: text,
				font: Fonts.ROBOTO,
				bold: true,
				italic: true,
				style: TriviaText.WHITE_MEDIUM
			});

			logoContainer.addChild(logo);
			logoContainer.addChild(title);

			logoContainer.x = (Screen.stageWidth - logoContainer.width) / 2;
			logoContainer.y = (Screen.stageHeight - logoContainer.height) / 2 - 50;
			Quick.pivot(logoContainer, .5, .5, true);
			addChild(logoContainer);

			Quick.click(logoContainer, function():void {
				if (onStart) onStart();
			}, false);

			TweenMax.from(logoContainer, .5, {alpha:0, scale: 0, ease:Back.easeOut});
		}

		private function backClicked(playAudio:Boolean = true):void
		{
			if(playAudio) Audio.play(AudioMap.BUTTON_PRESS);
			transition(Menu, Transitions.MANUAL);
			Quick.index(SceneController.currentScene, 0);
			if (Room.current) Room.current.leave();
			animateOut();
		}

		private function animateOut(delay:Number = 0):void
		{
			Quick.call(.75, function():void
			{
				playerList.animateOut();

				if(label) TweenMax.to(label, .5, {alpha:0});
				if(category) TweenMax.to(category, .5, {alpha:0});
				if(bgCategory) TweenMax.to(bgCategory, .5, {alpha:0});
				if(_categoryLabel) TweenMax.to(_categoryLabel, .5, {alpha:0});
				if(categoryIcon) TweenMax.to(categoryIcon, .5, {alpha:0, scale:.5, ease:Back.easeIn});
				if(logoContainer) TweenMax.to(logoContainer, .5, {alpha:0, scale:.5, delay:.15, ease:Back.easeIn});
				if(opponentProfile) TweenMax.to(opponentProfile, .5, {alpha:0, scale:.5, delay:.1, ease:Back.easeIn});
				if(invitePlayers) TweenMax.to(invitePlayers, .5, {alpha: 0, delay:.3});

				if(eventLabel) TweenMax.to(eventLabel,.5, {alpha: 0});
				TweenMax.to(backButton, .5, {alpha:0});
				TweenMax.to(spinner, .5, {alpha:0});
				if(profile) TweenMax.to(profile, .4, {alpha:0, scale:.5, ease:Back.easeIn, delay:.15});
				TweenMax.to(play, .5, {alpha:0, scale:.5, ease:Back.easeIn});

				TweenMax.to(blueShape, .5, {x:blueXPos, delay:1, ease:Quint.easeIn});
				TweenMax.to([whiteShape, dropShadow], .5, {x:Screen.left-whiteShape.width-200, delay:1, ease:Quint.easeIn});
				TweenMax.to(black, .7, {delay:1.15, alpha:0, onComplete:function():void {
					SceneController.transitionComplete();
					if(!(SceneController.currentScene is Game) && Room.current) Room.current.stopPing();
				}});
			});
		}

		public function start():void
		{
			play.alpha = .5;

			Quick.call(.1, function():void
			{
				transition(Game, Transitions.MANUAL);
				Quick.index(SceneController.currentScene, 0);
				animateOut();
			});
		}

		public function singleMode():void
		{
			setIconString();

			categoryIcon = new CategoryIcon(this, Screen.right - 305, Screen.bottom - 600, Room.selectedCategory, 0, CategoryIcon.SPLASH);
			Quick.pivot(categoryIcon, .5, .5, true);

			label = TriviaText.create(this, {
				y: Position.top(categoryIcon) + 50,
				w: Screen.width / 2,
				h: 75,
				text: "Category",
				color:ColorMap.WHITE,
				halign:"right",
				size:37
			});

			Position.right(label, Position.left(categoryIcon) + 20);

			_categoryLabel = TriviaText.create(this, {
				x: label.x,
				y: Position.bottom(label) - 15,
				w: Screen.width / 2,
				h: 125,
				text: categoryName,
				color:ColorMap.WHITE,
				halign:"right",
				valign:"top",
				size:60
			});

			TweenMax.allFrom([label, _categoryLabel], .5, {x:"+=15", alpha:0, delay:.1});
			TweenMax.from(categoryIcon, .5, {x:"-=15", alpha:0, delay:.1});

			onRoomJoin = start;

			onStart = function():void
			{
				play.touchable = false;
				Room.practice(onRoomJoin, Room.selectedCategory);
			};
		}

		public function versusMode():void
		{
			var thisref:PregameSplash = this;
			var checksMade:int = 0;

			onRoomJoin = function():void
			{
				var waitForOpponent:Function = function():void
				{
					// Stop callback if not in PregameSplash scene.
					if (!(SceneController.currentScene is PregameSplash)) return;

					// Room does not have enough players.
					if (!Room.current.isFull())
					{
						checksMade++;
						if(checksMade > 3)
						{
							Results.willNotify = true;

							var error:CustomError = getComponent(CustomError);
							error.show("You will be matched with the next available player.");

							function callbackClicked():void
							{
								Database.notifyOnGameComplete(User.current.id, User.localStoredPassword, Room.current.id);
								start();
							}

							error.onDestroy = callbackClicked;

							spinner.pause();
						}
						else
						{
							Quick.call(5, function():void {
								if(!Room.current) return;
								Room.current.update(waitForOpponent);
							});
						}
					}

					// Room is ready.
					else
					{
						spinner.hide();

						play.visible = true;
						TweenMax.to(play, 1, {delay:.5, alpha:1});
						TweenMax.from(play, .75, {delay:.5, y:Screen.bottom+play.height/2, ease:Quint.easeOut});
						if(eventLabel) TweenMax.to(eventLabel,.5, {alpha:0});

						opponentProfile = new ProfilePhoto(thisref, Room.current.topOpponent);
						opponentProfile.x = Screen.right - opponentProfile.width - 100;
						opponentProfile.y = Screen.bottom - 760;
						opponentProfile.setOptions(false, true, true, false);
						opponentProfile.textColor = ColorMap.WHITE;
						Quick.pivot(opponentProfile, .5, .5, true);

						TweenMax.fromTo(opponentProfile, 0.5, {scale: 0}, {scale: 1, ease:Back.easeOut, onComplete: function():void{
							onStart = start;
						}});
					}
				};
				waitForOpponent();
			};

			spinner.x = Screen.right - 330;
			spinner.y = 1430;
			spinner.show();

			if (Room.mode == Room.MODE_VERSUS) Room.joinRanked(onRoomJoin);
			else
			{
				trace("-------------------------------------------------------------------------JOINING RANKED REMATCH");
				Room.joinRankedRematch(onRoomJoin);
			}
		}

		public function groupMode(alreadyInRoom:Boolean = false):void
		{
			profile.setOptions(false, true, true, false);

			if (invitePlayers) invitePlayers.y = Screen.bottom - invitePlayers.height - 15;

			setIconString();

			var count:int = 0;
			var checksMade:int = 0;

			var waitForOpponent:Function = function():void
			{
				//TODO: this is a hack
				if(count > 2 && SceneController.currentScene.className != "PregameSplash") return;
				count++;

				// Room does not have enough players to start.
				if (!Room.current.isFull())
				{
					checksMade++;

					if(checksMade > 3 && Room.current.players.length == 1)
					{
						Results.willNotify = true;

						var error:CustomError = getComponent(CustomError);
						error.show("You will be matched with the next available players.");

						function callbackClicked():void
						{
							Database.notifyOnGameComplete(User.current.id, User.localStoredPassword, Room.current.id);
							start();
						}

						error.onDestroy = callbackClicked;

						spinner.pause();
					}
					else TweenMax.delayedCall(4, Room.current.update, [waitForOpponent]);
				}

				// Room has not yet populated player details
				else if (Room.current.users.length < Room.current.seats)
					TweenMax.delayedCall(4, waitForOpponent);

				if (Room.mode == Room.MODE_INVITE) Room.current.isFull(start);
				else if (Room.current.seats > GROUP_MIN_USERS && Room.current.users.length >= GROUP_MIN_USERS)
				{
					play.visible = true;
					TweenMax.to(play, .5, {alpha:1});
					if(eventLabel) TweenMax.to(eventLabel,.5, {alpha:0});
				}

				onStart = function ():void
				{
					if(Room.current.users.length > GROUP_MIN_USERS) Room.current.close();
					start();
				};
			};

			if (alreadyInRoom) waitForOpponent();
			else Room.joinRankedGroupMatch(waitForOpponent);
		}

		private function setIconString():void
		{
			categoryName = ImageMap.getCategoryName(Room.selectedCategory, true);
			iconString = ImageMap["ICON_CATEGORY_" + Room.selectedCategory + "_LARGE"];
		}
	}
}