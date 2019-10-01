/**
 * Created by wmaynard on 3/4/2016.
 */
package scenes {
	import architecture.Database;

	import components.TriviaNetLogo;
	import components.LoginInfo;
	import components.CustomError;

	import starling.text.TextField;

	import ten90.components.SpinnerRing;
	import ten90.device.Screen;
	import ten90.scene.StarlingScene;

	import tools.TriviaText;

	public class ForgotPassword extends StarlingScene
	{
		private var error:CustomError;
		private var spinner:SpinnerRing;
		private var form:LoginInfo;
		private var title:TriviaNetLogo;

	    public override function init():void
	    {
		    title = getComponent(TriviaNetLogo);
		    error = getComponent(CustomError);
		    spinner = getComponent(SpinnerRing);
		    form = getComponent(LoginInfo);

//		    var instructions:TextField = Make.text(this, Screen.stageWidth / 2, title.y + title.height * 3, 500, 200, "Forgot Password?", Fonts.SYSTEM, 38, 0xCCCCCC, false, "center");

			var instructions:TextField = TriviaText.create(this, {
				y: title.y + title.height + 200,
				w: Screen.stageWidth,
				text: "Forgot your password?",
				style: TriviaText.GRAY_LARGE,
				size:65
			});
			var subinstructions:TextField = TriviaText.create(this, {
				y: instructions.y + instructions.height * 1.1,
				w: Screen.stageWidth-150,
				text: "Enter your email address below and we'll send you a new one.",
				style: TriviaText.GRAY_SMALL,
				x:75,
				size:30
			});

		    form.y = subinstructions.y + subinstructions.height + 150;
		    form.password.prompt = "New Password";

		    form.email.showValidState();
		    form.password.showValidState();

//		    form.addButton(Skins.GREEN_CIRCLE, Skins.GREEN_CIRCLE, recover_click);
			form.addButton("Submit", recover_click, 110);
	    }

		public override function ready():void
		{

		}

		public function recover_click():void
		{
			if (!form.email.isValid()) {
				error.show("Your email address appears to be invalid.");
				return;
			}
			else if (!form.password.isValid()) {
				error.show("Your password must be between 5-14 characters and not contain any spaces.");
				return;
			}

			spinner.show([form]);

			Database.beginPasswordReset(form.email.text, form.password.text, function(e:* = null):void{
				transition(Login);
			});
		}
	}
}
