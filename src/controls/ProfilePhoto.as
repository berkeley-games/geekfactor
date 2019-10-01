/**
 * Created by wmaynard on 3/3/2016.
 */
package controls
{
	import architecture.ImageMap;
	import architecture.game.Room;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quint;

	import scenes.Friends;
	import scenes.Leaderboards;
	import scenes.Menu;
	import scenes.Profile;

	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.deg2rad;

	import ten90.base.Assets;
	import ten90.scene.SceneController;
	import ten90.scene.Transitions;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	import tools.Helper;
	import tools.TriviaText;

	public class ProfilePhoto extends DisplayObjectContainer
	{
		private const ICON_SIZE:int = 402;

		public static const LARGE:Number = 1;
		public static const MEDIUM:Number = 0.65;
		public static const SMALL:Number = 0.35;
		public static const TINY:Number = 0.25;

		public var user:User;
		public var rankingIcon:RankingIcon;

		private var photoIconContainer:Sprite;
		private var photo:Image;
		private var icon:Image;
		private var shadow:Image;

		private var starburst:Image;
		private var actualScore:int;
		private var txtName:TextField;
		public var txtScore:TextField;

		private var defaultIcon:Image;
		private var defaultIconString:String;
		private var coin:Image;
		private var power:Image;

		public function ProfilePhoto(parent:*, user:User, x:int = 0, y:int = 0, size:Number = LARGE, noText:Boolean = false, largeName:Boolean = false, showCoin:Boolean = false, showPower:Boolean = false)
		{
			super();

			if (!user)
			{
				trace("An attempt was made to create a profile photo without a user object.");
				return;
			}

			this.user = user;

			photoIconContainer = new Sprite();

			shadow = Make.image(photoIconContainer, ImageMap.PROFILE_SHADOW_LARGE);
			shadow.width =  440;
			shadow.height = 440;

			if(user.photo && user.photo != "0") populatePhoto();
			else makeDefaultIcon();

			var scoreStyle:String = largeName ? TriviaText.GRAY_MEDIUM : TriviaText.GRAY_XLARGE;

			var displayScore:String;
			switch(SceneController.currentScene.className)
			{
				case "Game":
				case "Results":
				case "PregameSplash":
					if(Room.mode == Room.MODE_VERSUS || Room.mode == Room.MODE_VERSUS_REMATCH || Room.mode == Room.MODE_SINGLE) displayScore = Helper.formatNumber(user.lifetimeRankedScore);
					else if(Room.mode == Room.MODE_GROUP_PRIVATE || Room.mode == Room.MODE_GROUP_RANKED) displayScore = Helper.formatNumber(user.lifetimeGroupScore);
					else displayScore = Helper.formatNumber(user.lifetimeWins);
					break;

				default: displayScore = Helper.formatNumber(user.coins);
			}

			txtScore = TriviaText.create(this, {
				x: shadow.width / 2,
				text: displayScore,
				style: scoreStyle,
				valign:"center",
				height:125
			});

			var nameStyle:String = largeName ? TriviaText.GRAY_XLARGE : TriviaText.TURQ_LARGE;

			txtName = TriviaText.create(this, {
				x: shadow.width / 2,
				text: user.displayName,
				style: nameStyle,
				valign:"center"
			});

			Quick.pivot(txtScore, .5, 0);
			Quick.pivot(txtName, .5, 0);

			txtName.y = shadow.height;
			txtScore.y = txtName.y + txtName.height;

			if(showCoin) coin = Make.image(this, ImageMap.IMG_COIN, Position.right(txtScore) + 10);
			if(showPower) power = Make.image(this, ImageMap.SCORE, Position.right(txtScore) + 10);

			addChild(photoIconContainer);
			photoIconContainer.addChild(shadow);

			if(SceneController.currentScene is Menu
				|| SceneController.currentScene is Leaderboards
				|| SceneController.currentScene is Friends)
				Quick.click(photoIconContainer, photoClicked, false);

			setRankingIcon(user.bestCategory, user.level);

			actualScore = user.coins;

			if(coin) TweenMax.from(coin, .5, {alpha:0});
			if(power) TweenMax.from(power, .5, {alpha:0});
			TweenMax.from([txtName, txtScore], .5, {alpha:0});

			this.scale = size;
			this.x = x;
			this.y = y;

			if (noText)
			{
				removeChild(txtScore);
				removeChild(txtName);
			}

			parent.addChild(this);
		}

		private function makeDefaultIcon():void
		{
			icon = Make.image(photoIconContainer, ImageMap.ICON_PROFILE_LARGE, shadow.width / 2, shadow.height / 2);
			icon.scale = ICON_SIZE / icon.width * .95;
			icon.x -= icon.width / 2;
			icon.y -= icon.height / 2;
		}

		public function set textColor(color:int):void { txtName.color = txtScore.color = color; }

		public function fadeText(showText:Boolean = false):void
		{
			var alpha:int = showText ? 1 : 0;
			if(showText)
			{
				txtScore.text = Helper.formatNumber(user.coins);
				Quick.pivot(txtScore, .5, 0);
				txtScore.x = photoIconContainer.x + photoIconContainer.width / 2;
			}
			if(coin) TweenMax.to(coin, .5, {alpha:alpha});
			if(power) TweenMax.to(power, .5, {alpha:alpha});
			TweenMax.to([txtName, txtScore], .5, {alpha:alpha});
		}

		public function set fontColor(color:int):void
		{
			txtScore.color = txtName.color = color;
		}

		public function set displayName(value:String):void
		{
			txtName.text = value;
		}

		public function get score():int
		{
			return actualScore;
		}

		public function set score(value:int):void
		{
			if (actualScore != value)
			{
				actualScore = value;
				updateScore(Helper.formatNumber(value));
			}
		}

		public function add(value:int, delay:Number = 0):void
		{
			if (!value) return;

			actualScore += value;
			updateScore(Helper.formatNumber(actualScore), delay);
		}

		public function get centerX():Number
		{
			return photoIconContainer.width / 2;
		}

		public function get centerY():Number
		{
			return photoIconContainer.height / 2;
		}

		public function set defaultImage(string:String):void
		{
			if (defaultIconString == string) return;

			defaultIconString = string;

			if (defaultIcon)
			{
				TweenMax.to(defaultIcon, 0.25, {alpha: 0, onComplete: function():void{
					createDefaultIcon(string);
				}});
			}
			else createDefaultIcon(string);
		}

		public function get defaultImage():String
		{
			return defaultIconString;
		}

		private function createDefaultIcon(string:String, time:Number = 0.25):void
		{
			if(defaultIcon) defaultIcon.dispose();

			defaultIcon = Make.image(this, string, photoIconContainer.x, photoIconContainer.y);
			defaultIcon.scale = ICON_SIZE / defaultIcon.width;

			TweenMax.fromTo(defaultIcon, time, {alpha: 0}, {alpha: 1});
			Quick.index(defaultIcon, this.getChildIndex(icon) + 1);
		}

		public function get photoWidth():int
		{
			return shadow.width * this.scale;
		}

		private function populatePhoto():void
		{
			if(icon) icon.dispose();

			if(user.photoLoaded) createPhoto();
			else user.addEventListener("photoLoaded", createPhoto);
		}

		private function createPhoto(e:Event = null):void
		{
			if (e) user.removeEventListener("photoLoaded", createPhoto);

			if(Assets.getTexture(user.photoFileName) == null)
			{
				makeDefaultIcon();
				Quick.index(icon, 1);
				return;
			}

			// TODO: This causes a crash if a texture loads twice.
			// e.g. Will has two accounts, both set to the same profile photo url
			// When navigating to the friends list,
			// the first loads fine, the second one throws Invalid Bitmap Data.
			// try / catch prevents the crash, but the second instance will not render if the
			// texture does not already exist.
			try
			{
				photo = Make.image(photoIconContainer, user.photoFileName);
				photo.scale = ICON_SIZE / photo.width;
				photo.x = (shadow.width - photo.width) / 2;
				photo.y = (shadow.height - photo.height) / 2;

				var mask:Shape = new Shape();
				var radius:Number = photo.width * .475;
				mask.graphics.beginFill(0xFFFFFF);
				mask.graphics.drawCircle(radius, radius, radius);
				mask.graphics.endFill();
				mask.x = (shadow.width - mask.width) / 2;
				mask.y = (shadow.height - mask.height) / 2;
				photoIconContainer.addChild(mask);
				photo.mask = mask;

				photoIconContainer.addChild(shadow);

				if (rankingIcon) photoIconContainer.addChild(rankingIcon);
			}
			catch(e:*){}
		}

		public function setOptions(scoreFirst:Boolean = true, hideCoinIcon:Boolean = false, hideScore:Boolean = false, hideName:Boolean = false, hideRankingIcon:Boolean = false):void
		{
			if (txtScore) txtScore.visible = !hideScore;
			if (txtName) txtName.visible = !hideName;
			if (rankingIcon) rankingIcon.visible = !hideRankingIcon;

			if (scoreFirst && txtScore.y > txtName.y)
			{
				txtScore.y = txtName.y;
				txtName.y = txtScore.y + txtScore.height;
				if(coin) Position.centerY(coin, Position.centerY(txtScore));
				if(power) Position.centerY(power, Position.centerY(txtScore));
			}
			else if (!scoreFirst && txtScore.y < txtName.y)
			{
				txtName.y = txtScore.y - 15;
				txtScore.y = txtName.y + txtName.height;
				if(coin) Position.centerY(coin, Position.centerY(txtScore));
				if(power) Position.centerY(power, Position.centerY(txtScore));
			}
		}

		public function setRankingIcon(category:int, level:int):void
		{
			if (category == -1) return;

			var userScore:int = user.lifetimeGroupScore + user.lifetimeRankedScore;

			if(userScore > 1000)
			{

			}

			if (rankingIcon)
			{
				this.removeChild(rankingIcon);
				rankingIcon.dispose();
			}

			rankingIcon = new RankingIcon(photoIconContainer, category, level - 1);
			rankingIcon.x = shadow.x;
			rankingIcon.y = shadow.y;
		}

		public function updateScore(value:String, delay:Number = 0):void
		{
			TweenMax.killTweensOf(txtScore);

			if(value.length)
			{
				txtScore.alpha = 1;

				if(coin)
				{
					coin.alpha = 1;
					TweenMax.to(coin, .35, {alpha:0, ease:Quint.easeOut, repeat:1, repeatDelay:delay, yoyo:true});
				}

				if(power)
				{
					power.alpha = 1;
					TweenMax.to(power, .35, {alpha:0, ease:Quint.easeOut, repeat:1, repeatDelay:delay, yoyo:true});
				}

				TweenMax.to(txtScore, .35, {alpha:0, ease:Quint.easeOut, repeat:1, repeatDelay:delay, yoyo:true, onRepeat: function():void
				{
					txtScore.text = value;
					Quick.pivot(txtScore, .5, 0);
					txtScore.x = photoIconContainer.x + photoIconContainer.width / 2;

					if(coin) coin.x = Position.right(txtScore) + 10;
					if(power) power.x = Position.right(txtScore) + 10;
				}});
			}
			else txtScore.text = "0";
		}

		public function animate(isWinner:Boolean = true):void
		{
			if (isWinner)
			{
				starburst = Make.image(this, ImageMap.IMG_STARBURST);
				starburst.x = shadow.x + shadow.width / 2;
				starburst.y = shadow.y + shadow.height / 2;
				Helper.center(starburst);
				Quick.index(starburst, 0);
				starburst.scale = 0;

				TweenMax.to(starburst, 0.5, {scale:.85});
				TweenMax.to(starburst, 20, {rotation: deg2rad(360), repeat: -1, ease: Linear.easeNone});
			}
		}

		public function changeUser(user:User):void
		{
			TweenMax.to(this, 0.25, {alpha: 0, repeat:-1, yoyo:true, onRepeat: function():void
			{
				this.user = user;
				Helper.Try(populatePhoto);

				score = 0;
				displayName = user.displayName;
				setRankingIcon(user.bestCategory, user.level);
			}});
		}

		public function addPhotoClick(callback:Function):void
		{
			Quick.click(photoIconContainer, callback);
		}

		private function photoClicked():void
		{
			Profile.user = user;
			if(SceneController.currentScene is Menu) SceneController.currentScene.animateOut(gotoProfile);
			else if(SceneController.currentScene is Leaderboards || SceneController.currentScene is Friends) gotoProfile();
			else gotoProfile(true);
		}

		private function gotoProfile(removeScene:Boolean = false):void
		{
			SceneController.transition(Profile, Transitions.NONE, 1, removeScene);
		}
	}
}