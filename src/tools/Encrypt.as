/**
 * Created by wmaynard on 3/4/2016.
 */
package tools
{
	import ten90.utilities.Encryption;

	public class Encrypt
	{
	    public static function password(password:String):String
	    {
			return password;

			var encrypted:String = Encryption.sha256(password);
			//trace(encrypted);
			encrypted = encrypted.replace('\'', '');
			//trace(encrypted);

			// Not sure why this is necessary.  The output below looks identical.
			// However, without replacing single quotes, the call to the DB will fail,
			// and the user will be stuck on the Registration page.
			// For reference, this is an issue with the following situation at registration:
			// Email: mhannah@ten90studios.com
			// Pass : 4testing

			// �$�?Q?�|P�H�?�R��q�m�����
			// �$�?Q?�|P�H�?�R��q�m�����

			return encrypted;
	    }
	}
}