/**
 * Created by georgeperry on 10/25/15.
 */
package scenes
{
	import architecture.AudioMap;
	import architecture.Database;
	import architecture.ImageMap;
	import architecture.Skins;
	import architecture.XMLHelper;
	import architecture.game.Achievement;
	import architecture.game.Ad;
	import architecture.game.ColorMap;
	import architecture.game.GFEvent;
	import architecture.game.PlayerLevelThreshold;
	import architecture.game.Powerup;
	import architecture.game.ProfileTransfer;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.myflashlab.air.extensions.facebook.access.LogManager;
	import com.myflashlab.air.extensions.facebook.access.Permissions;

	import components.Background;

	import components.TriviaNetLogo;
	import components.LoginInfo;
	import components.TransferDialog;
	import components.CustomError;

	import controls.TriviaButton;

	import flash.net.NetworkInfo;
	import flash.utils.describeType;

	import starling.display.Image;

	import starling.text.TextField;

	import ten90.components.SpinnerRing;
	import ten90.device.Screen;
	import ten90.device.System;
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
	import ten90.utilities.ane.PushNotification;

	import tools.Encrypt;
	import tools.TriviaText;

	public class Login extends StarlingScene
	{
		private var login:TriviaButton;
		private var facebook:TriviaButton;
		private var registerAccount:TextField;
		private var spinner:SpinnerRing;
		private var form:LoginInfo;
		private var errorComponent:CustomError;
		private var transfer:TextField;
		private var transferDialog:TransferDialog;

		public override function init():void
		{
			if (!PlayerLevelThreshold.list.length)
				PlayerLevelThreshold.load();

			if(!Audio.isPlaying(AudioMap.LOADING))
				Audio.crossFade(AudioMap.lastSong, AudioMap.LOADING_MUSIC, .5, -1);

			Powerup.loadPowerups(function(powerups:Array):void
			{
				for each (var p:Powerup in powerups)
				{
					trace(p.name, p.price);

					if (p.name == "50/50")
						Store.fiftyPrice = p.price;

					else if (p.name == "Freeze")
						Store.freezePrice = p.price;

					else if (p.name == "ShowStats")
						Store.audiencePrice = p.price;
				}
			});

			transferDialog = getComponent(TransferDialog);

			var title:TriviaNetLogo = getComponent(TriviaNetLogo);
			errorComponent = getComponent(CustomError);

			form = getComponent(LoginInfo);
			form.y = title.y + title.height + 250;
			form.email.text = (Save.data("fromFacebook") == false) ? Save.data("username") : "";
			form.email.addKeyboardListener(onLoginChange);

			var ySpacing:int = 35;

			login = TriviaButton.pill(this, form.y + Position.bottom(form.email) + ySpacing + 110, "Log In", ColorMap.CISCO_BLUE, login_click, false, true);
			login.y += login.height / 2;

			if(form.email.text.length < 5)
			{
				login.alpha = .625;
				login.touchable = false;
			}

			facebook = TriviaButton.pill(this, login.y + login.height + ySpacing, "   Log In with Facebook", ColorMap.BLUE, facebook_click, false, true);
			var fbLogo:Image = Make.image(facebook, ImageMap.ICON_FACEBOOK);
			fbLogo.y = (facebook.height - fbLogo.height) / 2;
			fbLogo.x = 100;

			registerAccount = TriviaText.create(this, {
				y: facebook.y + facebook.height + ySpacing + 40,
				w: Screen.stageWidth,
				text: "Register",
				style: TriviaText.GRAY_SMALL
			});

			transfer = TriviaText.create(this, {
				y: Position.bottom(registerAccount) + ySpacing,
				w: Screen.stageWidth,
				text: "Transfer Profile",
				style: TriviaText.GRAY_SMALL
			});

			if(System.isDesktop)
			{
				facebook.alpha = 0.3;
				facebook.touchable = false;
			}

			spinner = getComponent(SpinnerRing);

			Ad.preloadBanner();
		}

		private function onLoginChange():void
		{
			if(form.email.text.length >= 5)
			{
				login.alpha = 1;
				login.touchable = true;
			}
			else
			{
				login.alpha = .625;
				login.touchable = false;
			}
		}

		public override function ready():void
		{
			SceneController.disposeScene(Menu);

			Quick.click(registerAccount, register_click);
			Quick.click(transfer, transfer_click, false);
		}

		private function login_click():void
		{
			spinner.show([form, registerAccount, transfer, facebook, login ]);

			Database.login(form.email.text, Save.data("password" + form.email.text), onLoginSuccess, onLoginFail);
		}

		private function transfer_click():void
		{
			Audio.play(AudioMap.BUTTON_PRESS);
			transferDialog.show(attemptTransfer);
		}

		private function attemptTransfer():void
		{
			ProfileTransfer.complete(transferDialog.username, transferDialog.code, function():void {
				form.email.text = transferDialog.username;
				getComponent(CustomError).show("Transfer Successful!\nYou may now log-in with this device.");
			});
		}

		private function register_click():void
		{
			Audio.play(AudioMap.BUTTON_PRESS);
			transition(Register);
		}

		private function onLoginSuccess(data:XML):void
		{
			var error:String = XMLHelper.getError(data);
			if (error)
			{
				errorComponent.show(error);
				spinner.hide();
				login.listen();
			}
			else
			{
				Save.data("fromFacebook", false);

				new User(data, function():void
				{
					Save.data("username", form.email.text);
					User.current.loadAchievements(Achievements.onData);
					Achievement.setID(User.current.id);
					TweenMax.delayedCall(1, transition, [Menu, Transitions.NONE]);
					GFEvent.load();
				}, true);
			}
		}

		private function onLoginFail():void
		{
			errorComponent.show("Could not connect to the server.");
			spinner.hide();

			login.listen();
		}

		private function facebook_click():void
		{
			var permissions:Array =
			[
				LogManager.WITH_READ_PERMISSIONS,
				Permissions.public_profile,
				Permissions.user_friends
			];

			Facebook.login(permissions, onFacebookSuccess, onFacebookFail, onFaceBookCancel);
		}

		private function onFacebookSuccess():void
		{
			Facebook.request("/me?fields=third_party_id,name,picture.type(square).height(400).width(400)", function(json:Object):void
			{
				var id:String = json.third_party_id;
				var name:String = json.name;
				var userString:String = "user" + id;
				var url:String = json.picture.data.url;

				var pw:String = id;
				var first:String = name.substring(0, name.indexOf(' '));
				var last:String = name.substring(name.indexOf(' ') + 1);

				spinner.show([form, registerAccount, transfer, facebook, login]);

				Database.fbLogin(userString, pw, first, last, url, Facebook.token, function(data:XML):void
				{
					Save.data("fromFacebook", true);

					new User(data, function():void
					{
						TweenMax.delayedCall(1, transition, [Menu, Transitions.NONE]);
						User.current.loadAchievements(Achievements.onData);
						Achievement.setID(User.current.id);
						Save.flush();
						GFEvent.load();
					}, true);
				});
			});
		}

		private function onFacebookFail(event:*):void
		{
			errorComponent.show(event.message);
			facebook.listen();

		}

		private function onFaceBookCancel():void
		{
			facebook.listen();
		}
	}
}