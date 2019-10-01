/**
 * Created by wmaynard on 3/4/2016.
 */
package scenes
{
	import architecture.Database;
	import architecture.ImageMap;
	import architecture.XMLHelper;
	import architecture.game.Achievement;
	import architecture.game.ColorMap;
	import architecture.game.User;

	import com.myflashlab.air.extensions.facebook.access.LogManager;
	import com.myflashlab.air.extensions.facebook.access.Permissions;

	import components.BackButton;

	import components.TriviaNetLogo;
	import components.LoginInfo;
	import components.CustomError;

	import controls.TriviaButton;
	import controls.TriviaInput;

	import starling.display.Image;
	import starling.text.TextField;

	import ten90.components.SpinnerRing;
	import ten90.device.Screen;
	import ten90.device.System;
	import ten90.scene.StarlingScene;
	import ten90.text.ProfanityFilter;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.utilities.Save;
	import ten90.utilities.ane.Facebook;

	import tools.TriviaText;

	public class Register extends StarlingScene
	{
		private var facebook:TriviaButton;

		private var error:CustomError;
		private var spinner:SpinnerRing;

		private var form:LoginInfo;

		private var warning:TextField;

	    public override function init():void
	    {
		    getComponent(BackButton).transitionTo = Login;

		    // Reference components
		    var title:TriviaNetLogo = getComponent(TriviaNetLogo);
		    error = getComponent(CustomError);

		    spinner = getComponent(SpinnerRing);

		    form = getComponent(LoginInfo);
		    form.y = title.y + title.height + 250;
		    form.email.addKeyboardListener(onRegisterChange);

		    // Create buttons
			form.addButton("Register", register_click, -88);
		    form.email.showValidState();

		    var button:TriviaButton = form.getButton("Register");
		    if(form.email.text.length < 5)
		    {
			    button.alpha = .625;
			    button.touchable = false;
		    }

		    facebook = TriviaButton.pill(this, Position.bottom(form) + 52, "   Sign up with Facebook", ColorMap.BLUE, facebook_click);
		    var fbLogo:Image = Make.image(facebook, ImageMap.ICON_FACEBOOK);
		    fbLogo.y = (facebook.height - fbLogo.height) / 2;
		    fbLogo.x = 100;

		    if(System.isDesktop)
		    {
			    facebook.touchable = false;
			    facebook.alpha = 0.3;
		    }

		    warning = TriviaText.create(this,
		    {
			    x:50,
			    y:int(Position.bottom(facebook) + 165),
			    text:"Please sign up with Facebook if you want to play on different devices, a custom profile photo, or other social features.",
			    style: TriviaText.GRAY_SMALL,
			    w:Screen.stageWidth-100
		    });
	    }

		public override function ready():void
		{

		}

		private function onRegisterChange():void
		{
			var button:TriviaButton = form.getButton("Register");

			if(form.email.text.length >= 5)
			{
				button.alpha = 1;
				button.touchable = true;
			}
			else
			{
				button.alpha = .625;
				button.touchable = false;
			}
		}

		public function register_click():void
		{
			if (!form.email.isValid(TriviaInput.EMAIL))
			{
				error.show("Your username appears to be invalid.");
				return;
			}

			error.show("Warning! Accounts created without Facebook are tied to the device you are using.");

			error.onDestroy = function():void
			{
				spinner.show([form, facebook, warning]);

				getComponent(BackButton).visible = false;

				Database.register(ProfanityFilter.cleanseText(form.email.text), function(data:XML):void
				{
					var msg:String = XMLHelper.getError(data);
					if (msg)
					{
						error.show(msg);
						spinner.hide();
					}
					else
					{
						Save.data("fromFacebook", false);

						new User(data, function():void
						{
							User.current.loadAchievements(Achievements.onData);
							Achievement.setID(User.current.id);
							transition(Menu);
						}, true);
					}
				});
			}
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

				var first:String = name.substring(0, name.indexOf(' '));
				var last:String = name.substring(name.indexOf(' ') + 1);

				spinner.show([form, facebook, warning]);

				Database.fbLogin(userString, id, first, last, url, Facebook.token, function(data:XML):void
				{
					Save.data("fromFacebook", true);

					new User(data, function():void
					{
						User.current.loadAchievements(Achievements.onData);
						Achievement.setID(User.current.id);
						if (User.current.email == userString) transition(Menu);
						Save.flush();
					}, true);
				});
			});
		}

		private function onFacebookFail():void
		{
			trace("Facebook failed.");
		}

		private function onFaceBookCancel():void
		{
			trace("Facebook canceled.");
		}
	}
}