/**
 * Created by wmaynard on 3/31/2016.
 */
package components
{
	import architecture.game.ColorMap;
	import architecture.game.Room;
	import architecture.game.User;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Quad;

	import controls.ProfilePhoto;

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;

	import starling.animation.Transitions;
	import starling.display.DisplayObject;
	import starling.display.Sprite;

	import ten90.components.Component;
	import ten90.components.SpinnerRing;
	import ten90.device.Screen;
	import ten90.graphics.Spinner;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;

	public class PlayerList extends Component
	{
		private var scroller:ScrollContainer;
		private var queuedProfiles:Vector.<User>;
		private var animating:Boolean = false;
		private var spinnerContainer:Sprite;

		public override function init():void
		{
			this.x = Screen.left;
			this.y = Screen.top;

			queuedProfiles = new Vector.<User>();
		}

		public override function ready():void
		{
			switch(parentScene.className)
			{
				case "PregameSplash":
					if(!isNeeded) return;

					scroller = Make.scrollContainer(this, 0, Screen.bottom - 750, Screen.width, 550, "horizontal", 20);
					scroller.interactionMode = Scroller.INTERACTION_MODE_TOUCH;
					scroller.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
					Make.quad(scroller, 0, 0, Screen.width - 550, 200, 0xFFFFFF).visible = false;

					spinnerContainer = new Sprite();
					var box:* = Make.quad(spinnerContainer, 0, 0, 500, 500, 0, 0);

					var spinner:SpinnerRing = parentScene.getComponent(SpinnerRing);
					spinnerContainer.addChild(spinner);
					Position.centerX(spinner, Position.centerX(box));
					Position.centerY(spinner, Position.centerY(box));
					spinner.show();

					scroller.addChild(spinnerContainer);

					TweenMax.from(spinnerContainer, .5, {alpha:0, delay:2});
					break;
			}
		}

		public function add(user:User):void
		{
			if(!isNeeded) return;

			if(user.id == User.current.id) return;

			if(animating)
			{
				queuedProfiles.push(user);
				return
			}

			animating = true;

			var profile:ProfilePhoto = new ProfilePhoto(scroller, user);
			profile.setOptions(false, true, true, false, false);
			profile.textColor = ColorMap.WHITE;

			scroller.addChild(spinnerContainer);

			scroller.validate();
			TweenMax.to(scroller, .8, {delay:1, horizontalScrollPosition:scroller.maxHorizontalScrollPosition, ease:Quad.easeInOut});

			Quick.pivot(profile, .5, .5, true);
			TweenMax.from(profile, .65, {alpha:0, scale:0, ease:Back.easeOut.config(.75), delay:.45, onComplete:doneAnimating});
		}

		public function animateOut():void
		{
			if(!isNeeded) return;

			for(var i:int = 0; i < scroller.numChildren; i++)
			{
				var object:DisplayObject = scroller.getChildAt(i);
				TweenMax.to(object, .65, {alpha:0, scale:0, delay:i/20, ease:Back.easeIn.config(.75)});
			}
		}

		private function doneAnimating():void
		{
			animating = false;

			if(queuedProfiles.length > 0) add(queuedProfiles.shift());
		}

		private function get isNeeded():Boolean
		{
//			trace(Room.mode);
			return (Room.mode == Room.MODE_GROUP_PRIVATE || Room.mode == Room.MODE_GROUP_RANKED || Room.mode == Room.MODE_INVITE);
		}
	}
}



















