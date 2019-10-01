/**
 * Created by wmaynard on 3/3/2016.
 */
package architecture
{
	import ten90.utilities.Save;

	public class AudioMap
	{
		public static var lastSong:String;

		// sfx
		public static const BURGER:String = "burger";
	    public static const BUTTON_PRESS:String = "analogue_click";
		public static const NEW_QUESTION:String = "question_presented";
		public static const CORRECT:String = "answer_correct";
		public static const INCORRECT:String = "answer_incorrect";
		public static const ITEM_PURCHASED:String = "item_purchased";
		public static const POWERUP_FREEZE:String = "powerup_freeze";
		public static const POWERUP_5050:String = "powerup_5050";

		public static const POINTS:String = "points";
		public static const NOTIFY_UP:String = "notifyUp";
		public static const NOTIFY_DOWN:String = "notifyDown";

		// music
		public static const LOADING:String = "loading";
		public static const MENU:String = "menu";
		public static const GAME1:String = "game1";
		public static const GAME2:String = "game2";
		public static const SEARCH1:String = "search1";
		public static const SEARCH2:String = "search2";
		public static const VICTORY1:String = "victory1";
		public static const VICTORY2:String = "victory2";

		// so we never get the same song twice in a row

		public static function get LOADING_MUSIC():String
		{
			return lastSong = LOADING;
		}

		public static function get MENU_MUSIC():String
		{
			return lastSong = MENU;
		}

		public static function get SEARCH_MUSIC():String
		{
			if(Save.data("lastSearchSong") != SEARCH1) return lastSong = Save.data("lastSearchSong", SEARCH1);
			else return lastSong = Save.data("lastSearchSong", SEARCH2);
		}

		public static function get GAME_MUSIC():String
		{
			if(Save.data("lastGameSong") != GAME1) return lastSong = Save.data("lastGameSong", GAME1);
			else return lastSong = Save.data("lastGameSong", GAME2);
		}

		public static function get VICTORY_MUSIC():String
		{
			if(Save.data("lastVictorySong") != VICTORY1) return lastSong = Save.data("lastVictorySong", VICTORY1);
			else return lastSong = Save.data("lastVictorySong", VICTORY2);
		}
	}
}