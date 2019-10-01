/**
 * Created by gperry on 4/5/2016.
 */
package architecture
{
	import ten90.device.System;

	public class Fonts
	{
		// Roboto
		public static const ROBOTO:String = "Roboto";
		[Embed(source="../../res/fonts/Roboto-Regular.ttf", fontFamily=ROBOTO, fontWeight="normal", mimeType="application/x-font", embedAsCFF="false")]
		private static const RobotoRegular:Class;

		[Embed(source="../../res/fonts/Roboto-Bold.ttf", fontFamily=ROBOTO, fontWeight="bold", mimeType="application/x-font", embedAsCFF="false")]
		private static const RobotoBold:Class;

		[Embed(source="../../res/fonts/Roboto-BlackItalic.ttf", fontFamily=ROBOTO, fontWeight="bold", fontStyle="italic", mimeType="application/x-font", embedAsCFF="false")]
		private static const RobotoBlackItalic:Class;

		[Embed(source="../../res/fonts/Roboto-Light.ttf", fontFamily=ROBOTO, fontWeight="light", mimeType="application/x-font", embedAsCFF="false")]
		private static const RobotoLight:Class;


		// SF
		public static const SF:String = "SF Compact Text";
		[Embed(source="../../res/fonts/SF-Compact-Text-Regular.otf", fontFamily=SF, fontWeight="normal", mimeType="application/x-font", embedAsCFF="false")]
		private static const SFRegular:Class;

		[Embed(source="../../res/fonts/SF-Compact-Text-Bold.otf", fontFamily=SF, fontWeight="bold", mimeType="application/x-font", embedAsCFF="false")]
		private static const SFBold:Class;


		// Use the right font
		public static const SYSTEM:String = System.isIOS ? SF : ROBOTO;
	}
}
