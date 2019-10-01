/**
 * Created by George on 10/20/2015.
 */
package scenes
{
	import architecture.AudioMap;
	import architecture.Fonts;
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.game.Achievement;
	import architecture.game.Ad;
	import architecture.game.ColorMap;
	import architecture.game.Player;
	import architecture.game.Question;
	import architecture.game.Rematch;
	import architecture.game.Room;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;

	import components.RankDialog;

	import components.VersusProfiles;
	import components.Burger;

	import controls.CategoryPerformanceBar;
	import controls.ProfileBar;
	import controls.ProfilePhoto;
	import controls.TriviaButton;

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;

	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;

	import ten90.components.SpinnerRing;

	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.SceneController;
	import ten90.scene.StarlingScene;
	import ten90.scene.Transitions;
	import ten90.tools.Help;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;
	import ten90.utilities.Save;
	import ten90.utilities.ane.Facebook;

	import tools.Helper;
	import tools.TriviaText;

	public class Results extends StarlingScene
	{
		public static var willNotify:Boolean = false;

		private var replay:TriviaButton;
		private var home:TriviaButton;
		private var rematch:TriviaButton;
		private var waitingGraphic:Image;

		private var resultTitle:TextField;
		private var resultBG:Quad;

		private var playerScore:int = 0;
		private var txtRanking:TextField;
		private var lblRanking:TextField;

		private var lblMode:TextField;
		private var profile:ProfilePhoto;

		private var userRank:TextField;

		private var spinner:SpinnerRing;

		public static var declineRematchOnExit:Boolean = true;

		public override function terminate():void
		{
			Audio.fadeOut(AudioMap.lastSong, 1);

			Room.current.stopPing();
			if (declineRematchOnExit) Rematch.decline();
		}

		public override function init():void
		{
			Ad.preloadFullPage(function():void
			{
				Ad.preloadBanner(function():void
				{
					Audio.play(AudioMap.BUTTON_PRESS);
					transition(Menu);
				});
			});

			spinner = getComponent(SpinnerRing);

			home = TriviaButton.pill(this, 0, "Home", ColorMap.LIGHT_GREEN, home_click, false, true);
			Position.bottom(home, Screen.bottom - 25);

			resultBG = Make.quad(this, Screen.left, 0, Screen.width, Screen.stageHeight / 3, ColorMap.CISCO_BLUE);
			resultBG.y = Screen.stageHeight * .34;

			resultTitle = TriviaText.create(this, {
				y: 75,
				w: Screen.stageWidth,
				text: "RESULTS",
				font: Fonts.ROBOTO,
				bold: true,
				italic: true,
				style: TriviaText.GREEN_XLARGE
			});

			declineRematchOnExit = true;
		}

		public override function ready():void
		{
			Audio.crossFade(AudioMap.lastSong, AudioMap.VICTORY_MUSIC, 1, -1);

			// Save current user's level, as well as check for any changes in level.
			User.current.saveLevel();

			trace("ROOM MODE: " + Room.mode);

			switch (Room.mode)
			{
				case Room.MODE_SINGLE:
					singleMode();
					break;

				case Room.MODE_VERSUS:
				case Room.MODE_VERSUS_REMATCH:
					versusMode();
					break;

				case Room.MODE_INVITE:
				case Room.MODE_GROUP_PRIVATE:
					lblMode = TriviaText.create(this, {
						x: 0,
						w: Screen.stageWidth,
						y: resultTitle.y + resultTitle.height * 1.2,
						text: "MULTI\nPLAYER",
						bold: true,
						italic: true,
						font: Fonts.ROBOTO,
						style: TriviaText.BLUE_MEDIUM
					});
					resultTitle.text = "RANKINGS";
					groupMode();
					break;

				case Room.MODE_GROUP_RANKED:
					lblMode = TriviaText.create(this, {
						x: 0,
						w: Screen.stageWidth * 2 / 3,
						y: resultTitle.y + resultTitle.height * 1.2,
						text: "MULTI\nPLAYER",
						bold: true,
						italic: true,
						font: Fonts.ROBOTO,
						style: TriviaText.BLUE_MEDIUM
					});
					TriviaText.create(this, {
						x: 0,
						w: lblMode.width * 2,
						y: lblMode.y,
						text: "RANKED\nMATCH",
						bold: true,
						italic: true,
						font: Fonts.ROBOTO,
						style: TriviaText.ORANGE_MEDIUM
					});
					resultTitle.text = "RANKINGS";
					groupMode();
					break;
			}
		}

		private function singleMode():void
		{
			profile = new ProfilePhoto(this, User.current, 0, 0, ProfilePhoto.MEDIUM, true);
			Position.top(profile, Position.bottom(resultTitle) + 75);
			profile.x = (Screen.stageWidth - profile.width) / 2;
			profile.animate();

			replay = TriviaButton.pill(this, 0, "Play Again", ColorMap.LIGHT_GREEN, replay_click, false, true);
			Position.bottom(replay, Position.top(home) - 25);

//			for each (var button:Button in [home, replay])
//				Quick.pivot(button, .5, 1);

			var correct:int = 0;
			for each (var q:Question in Room.current.questions)
			{
				correct += q.answeredCorrectly ? 1 : 0;
				playerScore += q.score;
			}

			var large:int = 120;
			var small:int = large / 3;

			// TextField creation
			var x:int = Screen.right - 35;
			var y1:int = resultBG.y + 125;
			var y2:int = y1 + large;
			var y3:int = y2 + small + 50;
			var y4:int = y3 + large;
			var w:int = Screen.stageWidth / 2;

			var txtCorrect:TextField = TriviaText.create(this, {
				x: x,
				y: y1,
				w: w,
				text: "" + correct + "/" + Room.current.questions.length,
				style: TriviaText.WHITE_XLARGE_RIGHT
			});
			var lblCorrect:TextField = TriviaText.create(this, {
				x: x,
				y: y2,
				w: w,
				text: "Correct",
				style: TriviaText.WHITE_SMALL_RIGHT
			});
			var txtEarned:TextField = TriviaText.create(this, {
				x: x,
				y: y3,
				w: w,
				text: Helper.formatNumber(playerScore),
				style: TriviaText.WHITE_XLARGE_RIGHT
			});
			var lblEarned:TextField = TriviaText.create(this, {
				x: x,
				y: y4,
				w: w,
				text: "Earned",
				style: TriviaText.WHITE_SMALL_RIGHT
			});

			for each (var t:TextField in [txtCorrect, txtEarned, lblCorrect, lblEarned])
				Quick.pivot(t, 1, 0);

			var shareButton:TriviaButton = TriviaButton.pill(this, 0, "Share on Facebook", ColorMap.BLUE, share("single"), false, true);
			Position.bottom(shareButton, Position.top(replay) - 25);

			var fbLogo:Image = Make.image(shareButton, ImageMap.ICON_FACEBOOK);
			fbLogo.y = (shareButton.height - fbLogo.height) / 2;
			fbLogo.x = 100;

			if(Save.data("fromFacebook") == false)
			{
				shareButton.alpha = .3;
				shareButton.touchable = false;
			}

			var bars:Vector.<CategoryPerformanceBar> = Room.current.generatePerformanceBars(this);
			var barX:int = Screen.left;
			var barY:int = y1;
			for (var i:int = 0; i < bars.length; i++)
			{
				var b:CategoryPerformanceBar = bars[i];
				b.x = (barX += 100);
				b.y = barY;
				Helper.centerX(b);
				Quick.call(0.2 * (i + 1), b.animate);

				TweenMax.from(b, .5, {alpha:0, y:"+=15", delay:.5+i/10});
			}

			TweenMax.from(resultTitle, .5, {delay:.2, alpha:0});
			TweenMax.from(profile, .6, {delay:.35, alpha:0});
			TweenMax.allFrom([resultBG, txtCorrect, txtEarned, lblEarned, lblCorrect], .5, {delay:.5, alpha:0, y:"-=15"}, .1);
			TweenMax.allFrom([home, replay, shareButton], .5, {delay:.7, alpha:0, y:"+=15"}, .2);
		}

		private function versusMode():void
		{
			// Buttons below the results BG

			//replay = Helper.GreenButton(this, "Play Again", home.x, home.y - home.height - 15, replay_click);

			rematch = TriviaButton.pill(this, home.y - home.height - 15, "Rematch", ColorMap.LIGHT_GREEN, function():void
			{
				setRematchEnabled(false);
				Rematch.request(function():void
				{
					if (rematchMessage.text.length == 0) rematchMessage.text = "You challenged " + Room.current.topOpponent.displayName + " to a rematch!";
					else
					{
						rematchMessage.text = "Creating room...";
						keepPulsing = false;
					}
				});
			});

			var shareButton:TriviaButton = TriviaButton.pill(this, 0, "Share on Facebook", ColorMap.BLUE, share("versus"), false, true);
			Position.bottom(shareButton, Position.top(rematch) - 15);
			shareButton.alpha = .3;
			shareButton.touchable = false;

			var fbLogo:Image = Make.image(shareButton, ImageMap.ICON_FACEBOOK);
			fbLogo.y = (shareButton.height - fbLogo.height) / 2;
			fbLogo.x = 100;

			var setRematchEnabled:Function = function(enabled:Boolean = true):void
			{
				rematch.touchable = enabled;
				TweenMax.to(rematch, 0.5, {alpha: enabled ? 1 : .3});
			};
			rematch.touchable = false;

//			for each (var button:TriviaButton in [home, rematch])
//				Quick.pivot(button, .5, 1);

			var vs:VersusProfiles = getComponent(VersusProfiles);
			vs.y = Position.bottom(resultTitle)-50;

			var enemy:User = Room.current.topOpponent;
			if(!enemy) enemy = VersusProfiles.oppUser;

			Quick.index(vs, 1);

			var correct:int = 0;
			var enemyCorrect:int = 0;

			for each (var q:Question in Room.current.questions)
				correct += q.answeredCorrectly ? 1 : 0;

			if (!enemy.answers)
				enemy.answers = "";

			for each (var s:String in enemy.answers.split(','))
				enemyCorrect += s == "0" ? 1 : 0;

			var textSpacing:int = 160;

			var x1:int = 50;
			var w:int = Screen.stageWidth / 2;
			var x2:int = Screen.stageWidth - x1 - w;
			var y2:int = resultBG.y + resultBG.height - textSpacing;
			var y1:int = y2 - textSpacing;
			var y0:int = y1 - (y2 - y1);


			// Build it from the bottom up
			var txtPlayerEarned:TextField = TriviaText.create(this, {
				x: x1,
				y: y2,
				w: w,
				text: Helper.formatNumber(User.current.score),
				style: TriviaText.WHITE_LARGE_LEFT
			});

			var enemyEarned:TextField = TriviaText.create(this, {
				x: x2,
				y: txtPlayerEarned.y,
				w: w,
				text:Helper.formatNumber(enemy.score),
				style: TriviaText.WHITE_LARGE_RIGHT
			});

			var txtPlayerCorrect:TextField = TriviaText.create(this, {
				x: x1,
				y: y1,
				w: w,
				text: "" + correct + "/" + Room.current.questions.length,
				style: TriviaText.WHITE_XLARGE_LEFT
			});

			var txtEnemyCorrect:TextField = TriviaText.create(this, {
				x: x2,
				y: txtPlayerCorrect.y,
				w: w,
				text: (enemy.answers.length ? "" + enemyCorrect : '-') + "/" + Room.current.questions.length,
				style: TriviaText.WHITE_XLARGE_RIGHT
			});

			var lblCorrect:TextField = TriviaText.create(this, {
				y: y1,
				w: Screen.stageWidth,
				h: txtPlayerCorrect.height,
				text: "Correct",
				style: TriviaText.WHITE_MEDIUM
			});

			var lblEarned:TextField = TriviaText.create(this, {
				y: y2,
				w: Screen.stageWidth,
				h: txtPlayerEarned.height,
				text: "Earned",
				style: TriviaText.WHITE_MEDIUM
			});

			var barContainer:Sprite = new Sprite();
			var bars:Vector.<CategoryPerformanceBar> = Room.current.generatePerformanceBars(barContainer, .5, 0, resultBG.y + 40, 75, true);
			for each (var b:CategoryPerformanceBar in bars) Quick.call(.2 * bars.indexOf(b), b.animate);
			addChild(barContainer);
			barContainer.x = (Screen.stageWidth - barContainer.width) / 2;

			var rematchMessage:TextField = TriviaText.create(this, {
				x: Screen.stageWidth / 2,
				y: 0,
				w: Screen.stageWidth,
				text: "",
				style: TriviaText.BLUE_MEDIUM
			});

			Quick.pivot(rematchMessage, 0.5, 0.5);
			Position.top(rematchMessage, Position.bottom(resultBG) + 25);

			TweenMax.from(resultTitle, .5, {delay:.15, alpha:0});
			TweenMax.from(vs, .5, {delay:.25, alpha:0});
			TweenMax.from(resultBG, .5, {delay:.35, alpha:0});
			TweenMax.allFrom([barContainer, txtPlayerCorrect, txtPlayerEarned, enemyEarned, txtEnemyCorrect, lblEarned, lblCorrect], .35, {delay:.45, alpha:0, y:"+=15"}, .1);
			TweenMax.fromTo(rematch, .5, {alpha:0}, {delay:.5, alpha:.3});
			TweenMax.allFrom([home, shareButton], .5, {delay:.7, alpha:0, y:"+=15"}, .2);

			var keepPulsing:Boolean = true;
			var rematchTween:TweenMax = TweenMax.to(rematchMessage, .25, {scale: 1.1, onComplete: function():void
			{
				TweenMax.to(rematchMessage, .25, {scale: 1, onComplete: function():void {
					if (keepPulsing) Quick.call(3, rematchTween.restart);
				}});
			}});

			waitingGraphic = Make.image(this, Skins.GREEN_CIRCLE_SMALL, rematch.x + rematch.width / 2 + 125, rematch.y - rematch.height / 2);
			waitingGraphic.alpha = 0;

			var enemyAccepted:Image = Make.image(this, ImageMap.ICON_CHALLENGE_ACCEPT, waitingGraphic.x, waitingGraphic.y);
			var enemyRejected:Image = Make.image(this, ImageMap.ICON_CHALLENGE_DECLINE, waitingGraphic.x, waitingGraphic.y);
			var playerAccepted:Image = Make.image(this, ImageMap.ICON_CHALLENGE_ACCEPT, rematch.x - rematch.width / 2 - 125, waitingGraphic.y);

			Helper.center([enemyAccepted, enemyRejected, playerAccepted, waitingGraphic]);

			enemyAccepted.scale = enemyRejected.scale = playerAccepted.scale = 0;

			var onRoomComplete:Function = function():void
			{
				for each (var b2:CategoryPerformanceBar in bars)
					Quick.call(.2 * bars.indexOf(b2), b2.animateEnemy);

				setRematchEnabled(true);
				enemyCorrect = 0;

				if (!enemy.answers)
					enemy.answers = "";

				for each (var s:String in enemy.answers.split(','))
					enemyCorrect += s == "0" ? 1 : 0;

				try
				{
					getComponent(VersusProfiles).animateWin(enemy.score <= User.current.score);

					if(Room.mode == Room.MODE_INVITE && enemy.score <= User.current.score)
					{
						var challengesWon:int = Save.data(Achievement.SAVE_ACHIEVEMENT_WIN_A_CHALLENGE);
						Save.data(Achievement.SAVE_ACHIEVEMENT_WIN_A_CHALLENGE, challengesWon + 1);
					}

					if(Save.data("fromFacebook"))
					{
						TweenMax.to(shareButton, .5, {alpha:1});
						shareButton.touchable = true;
					}
				}
				catch(e:*){}

				Helper.updateTextField(txtEnemyCorrect, "" + enemyCorrect + "/" + Room.current.questions.length);
				Helper.updateTextField(enemyEarned, Helper.formatNumber(Room.current.topOpponent.score));

				if(!willNotify) getComponent(RankDialog).show();
			};

			var accept:Function = function(accepted:Boolean = true):void
			{
				if (accepted)
				{
					if (rematchMessage.text.length == 0) rematchMessage.text = Room.current.topOpponent.displayName + " wants a rematch!";
					else if (rematchMessage.text.indexOf(" wants a rematch") == -1) rematchMessage.text = Room.current.topOpponent.displayName + " accepted the rematch!";
				}
				else if (rematchMessage.text.length > 0)
				{
					rematchMessage.text = Room.current.topOpponent.displayName + " declined the rematch.";
					rematchMessage.color = ColorMap.ORANGE;
					keepPulsing = false;
				}
			};

			var decline:Function = function():void{
				setRematchEnabled(false);
			};

			Quick.call(1, waitForRoom, 0, [accept, decline, onRoomComplete]);
		}

		// onEnemyResponse accepts a Boolean - true if the enemy accepted.
		public function waitForRoom(onEnemyResponse:Function, onDecline:Function, onComplete:Function, firstRun:Boolean = true):void
		{
			var trueOnComplete:Function = function():void
			{
//				listenForRematch(onEnemyResponse, onDecline);
				TweenMax.to(waitingGraphic, 2, {scale: 0});
				if (onComplete)  onComplete();
			};

			var allDone:Boolean = true;
			for each (var p:Player in Room.current.players)
				if (!p.isComplete) allDone = false;

			if(Room.current.players.length == 1) allDone = false;

			if (allDone) trueOnComplete();
			else
			{
				if (firstRun)
				{
					TweenMax.to(waitingGraphic, .5, {alpha: 1});
					TweenMax.to(waitingGraphic, .5, {rotation: 360, ease: Linear.easeNone, repeat: -1});
				}

				Quick.call(2, function():void
				{
					Room.current.update(function():void
					{
						// If we've transitioned away from the Results scene, stop the callbacks from recurring.
						if (!(SceneController.currentScene is Results)) return;

						waitForRoom(onEnemyResponse, onDecline, onComplete, false);
					});
				});
			}
		}

		private function groupMode():void
		{
			if(Room.mode == Room.MODE_INVITE && CreateGroup.isHost)
			{
				var gamesCreated:int = Save.data(Achievement.SAVE_ACHIEVEMENT_CREATE_GAME);
				Save.data(Achievement.SAVE_ACHIEVEMENT_CREATE_GAME, gamesCreated + 1);
			}

			var finish:TriviaButton = TriviaButton.pill(this, Screen.stageHeight, "Finish", ColorMap.LIGHT_GREEN, home_click, false, true);
			Position.bottom(finish, Screen.bottom - 25);

			var shareButton:TriviaButton = TriviaButton.pill(this, 0, "Share on Facebook", ColorMap.BLUE, share("group"), false, true);
			Position.bottom(shareButton, Position.top(finish) - 25);
			shareButton.alpha = .3;
			shareButton.touchable = false;

			var fbLogo:Image = Make.image(shareButton, ImageMap.ICON_FACEBOOK);
			fbLogo.y = (shareButton.height - fbLogo.height) / 2;
			fbLogo.x = 100;

			var scrollY:int = Position.bottom(lblMode) + 15;
			var scrollHeight:int = Position.top(shareButton) - scrollY - 25;
			var scroller:ScrollContainer = Make.scrollContainer(this, Screen.left, scrollY, Screen.width, scrollHeight, "vertical", 50);
			scroller.interactionMode = Scroller.INTERACTION_MODE_TOUCH;
			scroller.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;

			TweenMax.from(scroller, 1, {alpha:0, delay:.5});

			var farquad:Quad = Make.quad(scroller, 0, 0, scroller.width, 1, 0xFFFFFF);
			farquad.touchable = false;

			Make.quad(this, Screen.left+25, scroller.y, Screen.width-50, Skins.dividerStroke, ColorMap.GRAY).alpha = .5;
			Make.quad(this, Screen.left+25, Position.bottom(scroller), Screen.width-50, Skins.dividerStroke, ColorMap.GRAY).alpha = .5;

			var userContainer:Sprite = new Sprite();
			resultBG.x = 0;
			resultBG.y = 0;
			userContainer.addChild(resultBG);

			var correct:TextField = TriviaText.create(userContainer, {
				y: resultBG.y + 30,
				w: 200,
				text: Room.current.correct,
				style: TriviaText.WHITE_LARGE_RIGHT
			});
			correct.x = Position.right(resultBG) - (correct.width + 50);

			var correctLabel:TextField = TriviaText.create(userContainer, {
				x: correct.x,
				y: correct.y + correct.height,
				w: correct.width,
				text: "Correct",
				style: TriviaText.WHITE_SMALL_RIGHT
			});

			userRank = TriviaText.create(userContainer, {
				y: correct.y,
				w: correct.width,
				text: "1st",
				style: TriviaText.WHITE_LARGE_RIGHT
			});
			userRank.x = correct.x - userRank.width - 50;

			var rankLabel:TextField = TriviaText.create(userContainer, {
				x: userRank.x,
				y: userRank.y + userRank.height,
				w: userRank.width,
				text: "Place",
				style: TriviaText.WHITE_SMALL_RIGHT
			});

			var profile:ProfilePhoto = new ProfilePhoto(userContainer, User.current, 50, 0, ProfilePhoto.LARGE);
			profile.setOptions(true, true, false, true);
			profile.fontColor = ColorMap.WHITE;
			profile.score = User.current.score;
			profile.y = 55;

			var barContainer:Sprite = new Sprite();
			userContainer.addChild(barContainer);

			var bars:Vector.<CategoryPerformanceBar> = Room.current.generatePerformanceBars(barContainer, .925, 0, Position.bottom(rankLabel) + 25, 150 * Screen.aspectRatioFloat);
			for (var i:int = 0; i < bars.length; i++)
				Quick.call(i * .2, bars[i].animate);

			Position.right(barContainer, Position.right(correctLabel) - 15);

			scroller.addChild(farquad);

			for each (var u:User in Room.current.users)
			{
				if(u.id == User.current.id)
				{
					var burr:ProfileBar = ProfileBar.create(scroller, 0, u, ProfileBar.TYPE_SCORE);

					for(var j:int=0; j < burr.numChildren; j++)
						burr.getChildAt(1).visible = false;

					burr.addChild(userContainer);

				}
				else ProfileBar.create(scroller, 0, u, ProfileBar.TYPE_SCORE);
			}

			var farquad2:Quad = Make.quad(scroller, 0, 0, scroller.width, 1, 0xFFFFFF);
			farquad2.touchable = false;
			scroller.addChild(farquad2);

			if(home) home.visible = false;
			if(replay) replay.visible = false;

			var incomplete:Boolean;

			function orderList():void
			{
				var scores:Array = [];
				for each (var a:Player in Room.current.players)
					scores.push(a.score);

				scores.sort(Array.NUMERIC);

				var place:int = scores.length - scores.indexOf(User.current.score);
				var suffix:String = place == 1 ? "st" : place == 2 ? "nd" : place == 3 ? "rd" : "th";
				Helper.updateTextField(userRank, "" + place + suffix);

				incomplete = false;
				for each (var p:Player in Room.current.players)
				{
					for each (var b:ProfileBar in ProfileBar.bars)
						if (b.user.id == p.id) b.updateScore(p.score);

					incomplete ||= !p.isComplete;
				}

				ProfileBar.sort();

				scroller.addChildAt(farquad, 0);
				scroller.addChildAt(farquad2, scroller.numChildren-1);

				scroller.validate();
				scroller.readjustLayout();

				if(Room.current.players.length == 1) incomplete = true;

				if (incomplete) return;

				profile.animate();

				if(Room.mode == Room.MODE_INVITE && scores[0] == User.current.score)
				{
					var challengesWon:int = Save.data(Achievement.SAVE_ACHIEVEMENT_WIN_A_CHALLENGE);
					Save.data(Achievement.SAVE_ACHIEVEMENT_WIN_A_CHALLENGE, challengesWon + 1);
				}

				Room.current.stopPing();

				profile.score = User.current.score;

				if(Save.data("fromFacebook"))
				{
					TweenMax.to(shareButton, .5, {alpha:1});
					shareButton.touchable = true;
				}

				if(!willNotify && Room.mode == Room.MODE_GROUP_RANKED) getComponent(RankDialog).show();
			}

			Quick.call(.1, function():void
			{
				orderList();
				if(incomplete) Room.current.pingDB(true, orderList);
			});
		}

		private function listenForRematch(onEnemyAccept:Function, onDecline:Function):void
		{
			var keepListening:Function = function():void{
				if (Help.getClassName(SceneController.currentScene) == Help.getClassName(Results))
					TweenMax.delayedCall(2, listenForRematch, [onEnemyAccept, onDecline]);
			};

			Rematch.getStatus(onEnemyAccept, onDecline, keepListening);
		}

		private function replay_click():void
		{
			Room.current.stopPing();
			switch(Room.mode)
			{
				case Room.MODE_SINGLE:
					transition(CategorySelection);
					break;

				case Room.MODE_VERSUS_REMATCH:
				case Room.MODE_VERSUS:
					Room.mode = Room.MODE_VERSUS;
					transition(PregameSplash);
					break;
			}
		}

		private function home_click():void
		{
			Audio.fadeOut(AudioMap.lastSong);

			Room.current.stopPing();

			var children:Array = [];
			for(var i:int = 1; i < numChildren-1; i++)
				children.push(getChildAt(i));

			children.push(getComponent(VersusProfiles));

			spinner.show(children);

			if(Math.random() <= .9) Ad.current.show(componentContainer);
			else transition(Menu);
		}

		private function checkComplete():Boolean
		{
			for each (var p:Player in Room.current.players)
				if (!p.isComplete)
				{
					TweenMax.delayedCall(4, Room.current.update, [checkComplete]);
					return false;
				}
			return true;
		}

		private function share(type:String):Function
		{
			return function():void
			{
				var titleString:String;
				var urlString:String = "http://facebook.com/ciscogeekfactor";
				var imageURL:String = "https://scontent.fsnc1-1.fna.fbcdn.net/t39.2081-0/p128x128/13331177_242185689493979_1576014384_n.png";
				var description:String = "Cisco Geek Factor is a networking trivia game.";

				switch(type)
				{
					case "single":
						titleString = User.current.displayName + " scored " + Helper.formatNumber(User.current.score) + " points in Cisco Geek Factor!";
						break;

					case "versus":
						var user:User = User.current;
						var opponent:User = Room.current.topOpponent;
						var isWinner:Boolean = opponent.score < user.score;
						var status:String = isWinner ? " defeated " : " was defeated by ";
						var winnerScore:String = isWinner ? Helper.formatNumber(user.score) : Helper.formatNumber(opponent.score);
						var loserScore:String = !isWinner ? Helper.formatNumber(user.score) : Helper.formatNumber(opponent.score);
						var score:String = " with a score of " + winnerScore + " to " + loserScore + " in Cisco Geek Factor!";
						titleString = user.displayName + status + opponent.displayName + score;
						break;

					case "group":
						titleString = User.current.displayName + " came in " + userRank.text + " place out of " + Room.current.users.length + " with " + + User.current.score + " points in Cisco Geek Factor!";
						break;
				}

				Facebook.share(titleString, urlString, imageURL, description, shareSuccess, shareCancel, shareError);
			};
		}

		private function shareSuccess():void
		{
//			trace("success!");
		}

		private function shareCancel():void
		{
//			trace("cancel!");
		}

		private function shareError(message:String):void
		{
//			trace("error: " + message);
		}

		private function traceUsers():void
		{
			trace("------ USERS ------");
			for each(var t:User in Room.current.users)
				trace(t, t.displayName, t.id);
		}
	}
}