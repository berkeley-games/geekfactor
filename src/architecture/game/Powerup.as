/**
 * Created by wmaynard on 5/10/2016.
 */
package architecture.game
{
	import architecture.Database;

	public class Powerup extends XMLClass
	{
		private static const ID:String = "ID";
		private static const INVENTORY_NAME:String = "InventoryName";
		private static const DISPLAY_NAME:String = "DisplayName";
		private static const PRICE:String = "Price";
		private static const DESCRIPTION:String = "Description";

		private var _id:int;
		private var _name:String;
		private var _price:int;
		private var _desc:String;

		public function get name():String { return _name; }
		public function get price():int { return _price; }
		public function get description():String { return _desc; }

		public function Powerup(child:XML)
		{
			super(child);

			_id = parseInt(att(ID));
			_name = att(DISPLAY_NAME);
			_price = parseInt(att(PRICE));
			_desc = att(DESCRIPTION);
		}

		public function purchase(onUserData:Function):void
		{
			Database.purchaseStoreItem(_id, onUserData);
		}

		public static function consumeFreeze(onComplete:Function):void
		{
			Database.consumeFreeze(onComplete);
		}

		public static function consume5050(onComplete:Function):void
		{
			Database.consume5050(onComplete);
		}

		public static function loadPowerups(onPowerupData:Function):void
		{
			Database.getStoreItems(function(data:XML):void{
				var powerups:Array = [];
				for each (var x:XML in data.children())
					powerups.push(new Powerup(x));
				onPowerupData(powerups);
			});
		}
	}
}