/**
 * Created by gperry on 3/31/2016.
 */
package scenes
{
	import architecture.AudioMap;
	import architecture.game.ColorMap;
	import architecture.game.ProfileTransfer;
	import architecture.game.User;

	import com.greensock.TweenMax;

	import components.BackButton;
	import components.ProfileSelector;
	import components.CustomError;

	import controls.BlueHeader;
	import controls.ProfilePhoto;
	import controls.Setting;
	import controls.TriviaButton;
	import controls.TriviaInput;

	import feathers.controls.ScrollContainer;

	import starling.display.Button;
	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.media.Audio;
	import ten90.scene.SceneController;
	import ten90.scene.StarlingScene;
	import ten90.scene.Transitions;
	import ten90.text.ProfanityFilter;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	import tools.TriviaText;

	public class Settings extends StarlingScene
	{
		private var header:BlueHeader;
		private var txtChangeName:TriviaInput;
		private var btnUpdate:TriviaButton;
		private var txtFullName:TextField;
		private var btnEdit:Button;
		private var transferProfile:TriviaButton;

		private var settingsScroller:ScrollContainer;

		public override function init():void
		{
			header = new BlueHeader(this, "Settings");

			getComponent(BackButton).transitionTo = Menu;

			var photo:ProfilePhoto = new ProfilePhoto(this, User.current, 0, 0, ProfilePhoto.LARGE, true);
			photo.x = (Screen.stageWidth - photo.width) / 2;
			photo.y = 275;

			txtFullName = TriviaText.create(this, {
				y: photo.y + photo.height * 1.05,
				w: Screen.stageWidth,
				text: User.current.displayName,
				style: TriviaText.GRAY_LARGE
			});

			transferProfile = TriviaButton.pill(this, 0, "Transfer Profile", ColorMap.CISCO_BLUE, transfer);
			Position.bottom(transferProfile, Screen.bottom - 50);
			if(Save.data("fromFacebook"))
			{
				transferProfile.alpha = .3;
				transferProfile.touchable = false;
			}

			createSettingSliders();

			btnEdit = Make.emptyButton(this, 0, photo.y, Screen.stageWidth, Position.bottom(txtFullName) - photo.y);

			txtChangeName = new TriviaInput(this, photo.y + photo.height * 1.2, "Display Name", User.current.displayName, Screen.width - 50);

			btnUpdate = TriviaButton.pill(this, 0, "Update", ColorMap.CISCO_BLUE, update);
			Position.bottom(btnUpdate, Screen.bottom - 50);

			txtChangeName.visible = btnUpdate.visible = false;
		}

		private function createSettingSliders():void
		{
			var y:int = Position.bottom(txtFullName) + 150;
			var h:int = (Screen.stageHeight - 200) - y;
			settingsScroller = Make.scrollContainer(this, 0, y, Screen.stageWidth, h, "vertical", 80);

			Setting.loadAll(settingsScroller);
		}

		public override function ready():void
		{
			Quick.click(btnEdit, showEditControls, false);
		}

		private function showEditControls(visible:Boolean = true):void
		{
			BackButton.onClick = visible ? function():void{
				showEditControls(false);
			} : null;

			this.touchable = false;
			var thisref:Settings = this;
			var standardControls:Array = [txtFullName, settingsScroller];
			var editControls:Array = [txtChangeName, btnUpdate];
			var start:Array = visible ? standardControls : editControls;
			var end:Array = visible ? editControls : standardControls;

			var time:Number = 0.25;

			for each (var s:* in start)
				TweenMax.to(s, time, {alpha: 0, visible: false});

			for each (var e:* in end)
			{
				e.alpha = 0;
				e.visible = true;
				TweenMax.to(e, time, {delay: time, alpha: 1});
			}

			TweenMax.delayedCall(time * 2, function():void{
				thisref.touchable = true;
			});
		}

		private function update():void
		{
			var thisref:Settings = this;
			this.touchable = false;

			User.current.updateDisplayName(ProfanityFilter.cleanseText(txtChangeName.text), function():void
			{
				thisref.touchable = true;
				showEditControls(false);
				txtFullName.text = txtChangeName.text;
			});
		}

		private function selectIcon():void
		{
			Audio.play(AudioMap.BUTTON_PRESS);
			if (!User.current.photo) getComponent(ProfileSelector).fadeIn();
		}

		private function transfer():void
		{
			ProfileTransfer.start(transferSuccess, transferStart);
		}

		private function transferSuccess():void
		{
			SceneController.currentScene.transition(Login, Transitions.FADE);
		}

		private function transferStart(code:String):void
		{
			var popup:CustomError = getComponent(CustomError);
			popup.show("Your code is:\n" + code);
			popup.onDestroy = ProfileTransfer.current.cancel;
		}
	}
}
