/**
 * Created by gperry on 3/31/2016.
 */
package scenes
{
	import architecture.Fonts;
	import architecture.Skins;
	import architecture.game.ColorMap;
	import architecture.game.GFEvent;
	import architecture.game.User;

	import com.greensock.TweenMax;

	import components.CustomError;

	import components.NumberDongle;

	import controls.BlueHeader;
	import controls.Tabs;
	import controls.TriviaButton;
	import controls.TriviaInput;

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;

	import starling.display.Quad;

	import starling.display.Sprite;
	import starling.text.TextField;

	import ten90.device.Screen;
	import ten90.scene.StarlingScene;
	import ten90.text.ProfanityFilter;
	import ten90.tools.Make;
	import ten90.tools.Position;
	import ten90.tools.Quick;
	import ten90.utilities.Save;

	import tools.TriviaText;

	public class Events extends StarlingScene
	{
		private var tabs:Tabs;
		private var input:TriviaInput;
		private var submit:TriviaButton;
		private var submit2:TriviaButton;
		private var leave:TextField;
		private var eventName:TextField;

		private var joinContainer:Sprite;
		private var createContainer:Sprite;
		private var historyContainer:Sprite;

		private var pastEvents:ScrollContainer;

		private var eventCode:TriviaInput;
		private var eventTitle:TriviaInput;
		private var welcomeMessage:TriviaInput;

		private var months:NumberDongle;
		private var days:NumberDongle;
		private var hours:NumberDongle;
		private var minutes:NumberDongle;

		private var error:CustomError;

		public override function init():void
		{
			error = getComponent(CustomError);

			var titleBG:BlueHeader = new BlueHeader(this, "Events");

			tabs = new Tabs(this, Position.bottom(titleBG), 150,
				{ text: "Join", onClick: joinClicked },
				{ text: "Create", onClick: createClicked },
				{ text: "History", onClick: historyClicked }
			);

			Make.quad(this, Screen.left+25, Position.bottom(tabs), Screen.width-50, Skins.dividerStroke, ColorMap.GRAY).alpha = .5;


			joinContainer = new Sprite();

			eventName = TriviaText.create(joinContainer, {
				y: Screen.stageHeight / 3,
				w: Screen.stageWidth,
				style: TriviaText.GRAY_XLARGE
			});

			input = new TriviaInput(joinContainer, Screen.stageHeight / 2, "Event Code");
			input.y -= input.height;

			submit = TriviaButton.pill(joinContainer, 0, "Submit", ColorMap.CISCO_BLUE, submit_clicked);
			Position.top(submit, Position.bottom(input) + 40);


			leave = TriviaText.create(joinContainer, {
				w: Screen.stageWidth,
				y: Screen.stageHeight - 100,
				text: "Log Out of Event",
				style: TriviaText.GRAY_SMALL
			});

			Quick.click(leave, leave_clicked, false);

			if (GFEvent.current)
			{
				leave.visible = true;
				eventName.text = GFEvent.current.name;
				submit.visible = false;
				input.visible = false;
			}
			else
			{
				leave.visible = false;
			}


			createContainer = new Sprite();
			eventCode = new TriviaInput(createContainer, Position.bottom(tabs) + 200, "Event Code");
			eventTitle = new TriviaInput(createContainer, Position.bottom(eventCode) + 200, "Display Name");
			welcomeMessage = new TriviaInput(createContainer, Position.bottom(eventTitle) + 200, "Welcome Message");

			var durationTitle:TextField = TriviaText.create(createContainer,
				{
					width:Screen.stageWidth,
					text:"Duration",
					style:TriviaText.BLACK_LARGE,
					y:Position.bottom(welcomeMessage) + 125
				});

			months = new NumberDongle("Months");
			months.y = Position.bottom(durationTitle) + 75;
			months.x = 56;
			createContainer.addChild(months);

			Make.quad(createContainer, Position.right(months), months.y, 2, months.height, ColorMap.GRAY);

			days = new NumberDongle("Days");
			days.y = months.y;
			days.x = Position.right(months) + 56;
			createContainer.addChild(days);

			Make.quad(createContainer, Position.right(days), months.y, 2, months.height, ColorMap.GRAY);

			hours = new NumberDongle("Hours");
			hours.y = months.y;
			hours.x = Position.right(days) + 56;
			createContainer.addChild(hours);

			Make.quad(createContainer, Position.right(hours), months.y, 2, months.height, ColorMap.GRAY);

			minutes = new NumberDongle("Minutes");
			minutes.y = months.y;
			minutes.x = Position.right(hours) + 56;
			createContainer.addChild(minutes);

			submit2 = TriviaButton.pill(createContainer, 0, "Create Event", ColorMap.CISCO_BLUE, createEvent);
			Position.bottom(submit2, Screen.bottom - 40);


			historyContainer = new Sprite();
			var scrollY:int = Position.bottom(tabs) + 1;
			var scrollHeight:int = Screen.height - Position.bottom(tabs) - 1;
			pastEvents = Make.scrollContainer(historyContainer, Screen.left, scrollY, Screen.width, scrollHeight, "vertical", 0);
			pastEvents.interactionMode = Scroller.INTERACTION_MODE_TOUCH;
			pastEvents.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;

			addChild(joinContainer);
			addChild(createContainer);
			addChild(historyContainer);

			showJoin();

			if(Save.data("eventTutorialWatched" + User.current.id) != true)
			{
				Quick.call(1, function():void {
					error.show("Type in your Event Code in order to join an event!");
				});
				Save.data("eventTutorialWatched" + User.current.id, true);
			}
		}



		// Join
		private function joinClicked():void
		{
			showJoin();
		}

		private function submit_clicked():void
		{
			this.touchable = false;
			GFEvent.join(input.text, onEvent);
		}

		private function leave_clicked():void
		{
			GFEvent.current.leave(populatePastEvents);

			TweenMax.to(leave, .5, {alpha: 0, visible: false});
			TweenMax.to(eventName, .5, {alpha: 0, onComplete: function():void{
				eventName.text = "";
			}});

			input.alpha = 0;
			input.visible = true;
			TweenMax.to(input, .5, {alpha: 1});

			submit.alpha = 0;
			submit.visible = true;
			TweenMax.to(submit, .5, {alpha: 1});
		}

		private function onEvent(event:GFEvent):void
		{
			this.touchable = true;
			if (!event) return;

			User.current.currentEventName = event.name;
			User.current.currentEventFriendlyName = event.friendlyName;

			TweenMax.fromTo(eventName, .5, {alpha: 0}, {alpha: 1});
			eventName.text = GFEvent.current.name;

			TweenMax.to(input, .5, {alpha: 0, visible: false, onComplete: function():void{
				input.text = "";
			}});

			TweenMax.to(submit, .5, {alpha: 0, visible: false});
			TweenMax.fromTo(leave, .5, {alpha: 0, visible: true}, {alpha: 1});
		}


		// Create
		private function createClicked():void
		{
			showCreate();
		}

		private function createEvent():void
		{
			var name:String = ProfanityFilter.cleanseText(eventCode.text);
			var friendlyName:String = ProfanityFilter.cleanseText(eventTitle.text);
			var welcome:String = ProfanityFilter.cleanseText(welcomeMessage.text);
			var month:Number = months.value;
			var day:Number = days.value;
			var hour:Number = hours.value;
			var minute:Number = minutes.value;

			if(name.length == 0 || friendlyName.length == 0 || welcome.length == 0 || (month == 0 && day == 0 && hour == 0 && minute == 0))
			{
				getComponent(CustomError).show("Please fill out all of the required fields.");
				return;
			}

			var now:Date = new Date();
			var then:Date = new Date
			(
				now.fullYear,
				now.month + month,
				now.date + day,
				now.hours + hour,
				now.minutes + minute,
				now.seconds,
				now.milliseconds
			);

			GFEvent.create(name, friendlyName, welcome, now, then, onCreate, onCreateError);
		}

		private function onCreate(data:GFEvent):void
		{
			tabs.toggleTo(1);
			onEvent(data);

			showJoin();

			eventCode.text = "";
			eventTitle.text = "";
			welcomeMessage.text = "";
			months.value = days.value = hours.value = minutes.value = 0;
		}

		private function onCreateError(error:String):void
		{
			getComponent(CustomError).show(error);
		}



		// History
		private function historyClicked():void
		{
			showHistory();

			populatePastEvents();
		}

		private function populatePastEvents():void
		{
			pastEvents.removeChildren(0, pastEvents.numChildren - 1, true);

			var thisref:Events = this;
			GFEvent.getPreviouslyEnteredEvents(function(events:*):void
			{
				TweenMax.to(pastEvents, .5, {alpha: 1});
				var callback:Function = function(event:GFEvent):void
				{
					TweenMax.to(pastEvents, 0.5, {alpha: 0});
					thisref.touchable = false;
					onEvent(event);
					tabs.toggleTo(1);
					showJoin();
				};

				for each (var event:GFEvent in events)
					event.createSprite(pastEvents, callback, events.indexOf(event) % 2);

				if(pastEvents.numChildren == 0)
					Make.text(pastEvents, 0, 0, pastEvents.width, 200, "No results!", Fonts.SYSTEM, 48, 0, false, "center");
			});
		}


		private function showJoin():void
		{
			historyContainer.visible = false;
			joinContainer.visible = true;
			createContainer.visible = false;
		}

		private function showCreate():void
		{
			historyContainer.visible = false;
			joinContainer.visible = false;
			createContainer.visible = true;
		}

		private function showHistory():void
		{
			historyContainer.visible = true;
			joinContainer.visible = false;
			createContainer.visible = false;
		}
	}
}
