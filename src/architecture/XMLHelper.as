/**
 * Created by wmaynard on 3/3/2016.
 */
package architecture
{
	public class XMLHelper
	{
		// Extracts an error message from the returned XML.
		public static function getError(xml:XML):String
		{
			for each (var x:XML in xml.children())
			{
				var error:String = x.attribute("Error");
				if (error) return error;
			}
			return null;
		}
	}
}