/**
 * Created by wmaynard on 5/17/2016.
 */
package architecture.game
{
	import architecture.Database;
	import architecture.Skins;

	import com.greensock.TweenMax;

	import scenes.Menu;

	import starling.display.Button;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;

	import ten90.device.Screen;
	import ten90.network.Browser;
	import ten90.scene.SceneController;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	public class Ad extends XMLClass
	{
		private static const ID:String = "ID";
		private static const DESCRIPTION:String = "Description";
		private static const IMAGE_URL:String = "ImageURL";
		private static const NAVIGATION_URL:String = "NavigationURL";
		private static const IS_BANNER:String = "isBanner";
		private static const CLOSE_BUTTON_X:String = "closeX";
		private static const CLOSE_BUTTON_Y:String = "closeY";
		private static const CLOSE_BUTTON_WIDTH:String = "closeW";
		private static const CLOSE_BUTTON_HEIGHT:String = "closeH";
		private static const CATEGORY_ID:String = "CategoryID";
		private static const IS_PRIORITY:String = "IsPriority";

		private var id:int;
		public var description:String;
		public var imageURL:String;
		public var navigationURL:String;
		public var isBanner:Boolean;
		public var categoryID:int;
		public var isPriority:Boolean;

		public var image:Image;
		private var close:Button;
		private var _sprite:Sprite;

		private var onClose:Function;
		private var onImageLoad:Function;
		private var assetName:String;

		public function get sprite():Sprite { return _sprite; }

		public static var current:Ad;

		private var instantiated:Boolean = false;

		// TODO: Upload functionality for ad?
		public function Ad(root:XML, onImageLoad:Function, onClose:Function = null)
		{
			super(root);

			current = this;

			id = parseInt(att(ID));
			description = att(DESCRIPTION);
			imageURL = att(IMAGE_URL);
			navigationURL = att(NAVIGATION_URL);
			isBanner = parseInt(att(IS_BANNER));
			categoryID = parseInt(att(CATEGORY_ID));
			isPriority = parseInt(att(IS_PRIORITY));

			this.onClose = onClose;
			this.onImageLoad = onImageLoad;

			assetName = Skins.createFromURL(null, imageURL, createSprite);
			instantiated = true;
		}

		private function createSprite(assetName = null):void
		{
			assetName = assetName ? assetName : this.assetName;

			_sprite = new Sprite();
			_sprite.x = Screen.left;
			_sprite.y = Screen.top;

			image = Make.image(_sprite, assetName);

			Quick.click(image, navigate, false);

			if (!isBanner)
			{
				var buttonLength:int = 360;
				close = Make.emptyButton(_sprite,
					Position.right(image) - buttonLength, image.y,
					buttonLength, buttonLength);

				Quick.click(close, onClose);
			}

			Quick.index(Make.shapeImage(_sprite, 0, 0, Screen.width, _sprite.height, true), 0);

			// TODO: Fix this kluge.
			// Since the Ad finishes instantiation when Skins.createFromURL returns,
			// the ad object in load() will be null when the image is cached, since there's no callback when
			// a cached version exists.
			if (instantiated) onImageLoad();
			else Quick.call(.1, onImageLoad);
		}

		private function navigate():void
		{
			Browser.load(navigationURL);
		}

		private static function load(onClose:Function = null, categoryID:int = -1):void
		{
			var isBanner:Boolean = (onClose == null);
			var isTablet:Boolean = (Screen.aspectRatioFloat > .6);

			var isPriority:Boolean = !checkIfPrimaryAdHasBeenViewed(categoryID);

			Database.getTargetedAd(User.current.id, isBanner, isTablet, categoryID > 0 ? categoryID : null, isPriority, function(data:XML):void
			{
				if (isPriority)
					Save.data(getPriorityString(categoryID), true);

				var ad:Ad;

				var onLoad:Function = function():void
				{
					if(isTablet)
					{
						if(ad.sprite.width > Screen.stageWidth) ad.sprite.x = Screen.left;
						ad.sprite.y = Screen.top;
					}

					SceneController.currentScene.addChildAt(ad.sprite, 1);
				};

				onClose = onClose ? onClose : function():void{
					TweenMax.to(ad.sprite, .5, {alpha: 0, visible: false});
				};

				ad = new Ad(data, onLoad, onClose);
			});
		}

		private static function checkIfPrimaryAdHasBeenViewed(categoryID:int):Boolean
		{
			return categoryID > 0 ? Save.data(getPriorityString(categoryID)) : true;
		}

		private static function getPriorityString(categoryID):String
		{
			return "User" + User.current.id + "|Category" + categoryID + "|PriorityAdViewed";
		}

		private static function preload(onClose:Function = null, onComplete:Function = null, categoryID:int = -1):void
		{
			var isBanner:Boolean = (onClose == null);
			var isTablet:Boolean = (Screen.aspectRatioFloat > .6);

			var isPriority:Boolean = !checkIfPrimaryAdHasBeenViewed(categoryID);

			Database.getTargetedAd(User.current ? User.current.id : 1, isBanner, isTablet, categoryID > 0 ? categoryID : null, isPriority, function(data:XML):void
			{
				if (isPriority)
					Save.data(getPriorityString(categoryID), true);

				var ad:Ad;

				var onLoad:Function = function():void
				{
					if(isTablet)
					{
						if(ad.sprite.width > Screen.stageWidth) ad.sprite.x = Screen.left;
						ad.sprite.y = Screen.top;
					}

//					ad.sprite.visible = false;
					ad.sprite.touchable = false;
					if (onComplete) onComplete();
				};

				onClose = onClose ? onClose : function():void {
					TweenMax.to(ad.sprite, .5, {alpha: 0, visible: false});
				};

				ad = new Ad(data, onLoad, onClose);
			});
		}

		private var attemptsToLoad:int = 0;
		public function show(parent:DisplayObjectContainer = null):*
		{
			if(sprite) onAdded();
			else
			{
				//TODO
				if(attemptsToLoad >= 20) SceneController.transition(Menu);
				else return Quick.call(.1, show, 0, [parent]);
			}

			attemptsToLoad = 0;
			Position.centerX(image, Screen.width/2);
			sprite.addEventListener(Event.ADDED_TO_STAGE, onAdded);

			if(!parent) parent = SceneController.currentScene;
			return parent.addChild(sprite);
		}

		private function onAdded(e:Event = null):void
		{
			if(e) sprite.removeEventListener(Event.ADDED_TO_STAGE, onAdded);

			TweenMax.fromTo(sprite, .5, {alpha:0}, {alpha:1});

			Quick.call(.5, function():void {
				sprite.touchable = true;
			});
		}

		public static function loadFullPage(onClose:Function, categoryID:int = -1):void
		{
			load(onClose, categoryID);
		}

		public static function preloadFullPage(onClose:Function, categoryID:int = -1):void
		{
			preload(onClose, null, categoryID);
		}

		public static function loadBanner():void
		{
			load();
		}

		public static function preloadBanner(onComplete:Function = null, categoryID:int = -1):void
		{
			preload(null, onComplete, categoryID);
		}
	}
}