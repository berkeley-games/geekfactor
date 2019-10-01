/**
 * Created by wmaynard on 3/7/2016.
 */
package architecture.game
{
	import starling.events.EventDispatcher;

	public class XMLClass extends EventDispatcher
	{
		protected var xml:XML;
		protected var usesRoot:Boolean;

	    public function XMLClass(xml:XML)
	    {
		    this.xml = xml;
	    }

		protected function att(name:String, index:int = 0):String
		{
			return getAttribute(xml, name, index);
		}

		protected static function getAttribute(xml:XML, name:String, index:int = 0):String
		{
			try
			{
				var output:String = xml.attribute(name);
				if (!output.length)
					return xml.children()[index].attribute(name);
				return output;
			}
			catch(e:TypeError)
			{
				return null;
			}
		}

		protected static function isError(xml:XML):Boolean
		{
			var error:String = (xml.row &&  xml.row[0] && xml.row[0].@Error) ? xml.row[0].@Error : "";
			return error.length > 0;
		}

		protected static function getError(xml:XML):String
		{
			var error:String = (xml.row &&  xml.row[0] && xml.row[0].@Error) ? xml.row[0].@Error : "";
			return error;
		}

	}
}