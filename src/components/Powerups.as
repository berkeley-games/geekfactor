/**
 * Created by wmaynard on 3/11/2016.
 */
package components
{
	import architecture.ImageMap;
	import architecture.game.User;

	import controls.PowerupIcon;

	import ten90.components.Component;
	import ten90.tools.Help;

	import tools.Helper;

	public class Powerups extends Component
	{
		private var _5050:PowerupIcon;
		private var freeze:PowerupIcon;
		private var showStats:PowerupIcon;

		public static var current:Powerups;

		public override function init():void
		{
			_5050 = new PowerupIcon(this, 0, 0, ImageMap.ICON_POWERUP_1, User.current.fiftyfifties);
			freeze = new PowerupIcon(this, 0, 0, ImageMap.ICON_POWERUP_2, User.current.freezes);
			showStats = new PowerupIcon(this, 0, 0, ImageMap.ICON_POWERUP_3, User.current.audiences);

			setLayout(false);
			current = this;
		}

		public override function ready():void
		{
			switch (Help.getClassName(parentScene))
			{
				case "Menu":
					break;
				
				case "Pregame":
				case "Game":
					setLayout(true);
					Helper.center(this);
					break;
			}
		}

		public function update():void
		{
			_5050.count = User.current.fiftyfifties;
			freeze.count = User.current.freezes;
			showStats.count = User.current.audiences;
		}

		public function setLayout(horizontal:Boolean = true):void
		{
			if (horizontal)
			{
				freeze.x = _5050.width * 1.1;
				showStats.x = freeze.x + freeze.width * 1.1;
				freeze.y = 0;
			}
			else
			{
				freeze.x = 0;
				freeze.y = _5050.height * 1.1;
			}
		}

		public function set _5050_click(func:Function):void
		{
			_5050.onClick = func;
		}

		public function set freeze_click(func:Function):void
		{
			freeze.onClick = func;
		}
		
		public function set audiences_click(func:Function):void
		{
			showStats.onClick = func;
		}
	}
}