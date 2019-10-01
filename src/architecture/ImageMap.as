/**
 * Created by wmaynard on 3/3/2016.
 */
package architecture
{
	import architecture.game.Achievement;

	public class ImageMap
	{
		public static const ACH_STAR_OFF:String = "ach_star_off";
		public static const ACH_STAR_ON:String = "ach_star_on";

		private static const ACH_IMAGE_LIST:Array =
		[
			"ach_games_won_",
			"ach_quest_row_",
			"ach_play_lvl_",
			"ach_quest_cat_",
			"ach_friends_",
			"ach_create_gme_",
			"ach_challenge_",
			"ach_submit_quest_"
		];

		public static const CATEGORY_0:String = "all categories";
		public static const CATEGORY_1:String = "general";
		public static const CATEGORY_2:String = "collaboration";
		public static const CATEGORY_3:String = "datacenter";
		public static const CATEGORY_4:String = "routing/switching";
		public static const CATEGORY_5:String = "security";
		public static const CATEGORY_6:String = "wireless";

		private static const CATEGORY_0_PRETTY:String = "All Categories";
		private static const CATEGORY_1_PRETTY:String = "General";
		private static const CATEGORY_2_PRETTY:String = "Collaboration";
		private static const CATEGORY_3_PRETTY:String = "Data Center";
		private static const CATEGORY_4_PRETTY:String = "Routing/Switching";
		private static const CATEGORY_5_PRETTY:String = "Security";
		private static const CATEGORY_6_PRETTY:String = "Wireless";

		public static const ICON_CHALLENGE_ACCEPT:String = "accept";
		public static const ICON_CHALLENGE_DECLINE:String = "decline";
		public static const ICON_ADD_FRIEND:String = "add";
		public static const BUTTON_BACK:String = "back_button";
		public static const BUTTON_BACK_DARK:String = "back_button_drk";
		public static const ICON_BURGER_MENU:String = "burger_icon";

		public static const BUTTON_CATEGORY_ALL:String = "category_all";
		public static const BUTTON_CATEGORY_1:String = "category_general";
		public static const BUTTON_CATEGORY_2:String = "category_datacenter";
		public static const BUTTON_CATEGORY_3:String = "category_collaboration";
		public static const BUTTON_CATEGORY_4:String = "category_routing-switching";
		public static const BUTTON_CATEGORY_5:String = "category_security";
		public static const BUTTON_CATEGORY_6:String = "category_wireless";

		public static const ICON_CATEGORY_0_LARGE:String = "icon_all_lrg";
		public static const ICON_CATEGORY_1_LARGE:String = "icon_general_lrg";
		public static const ICON_CATEGORY_2_LARGE:String = "icon_datacenter_lrg";
		public static const ICON_CATEGORY_3_LARGE:String = "icon_collaboration_lrg";
		public static const ICON_CATEGORY_4_LARGE:String = "icon_switching-routing_lrg";
		public static const ICON_CATEGORY_5_LARGE:String = "icon_security_lrg";
		public static const ICON_CATEGORY_6_LARGE:String = "icon_WiFi_lrg";

		public static const ICON_CATEGORY_1_SMALL:String = "icon_general_sm";
		public static const ICON_CATEGORY_2_SMALL:String = "icon_datacenter_sm";
		public static const ICON_CATEGORY_3_SMALL:String = "icon_collaboration_sm";
		public static const ICON_CATEGORY_4_SMALL:String = "icon_switching-routing_sm";
		public static const ICON_CATEGORY_5_SMALL:String = "icon_security_sm";
		public static const ICON_CATEGORY_6_SMALL:String = "icon_WiFi_sm";

		public static const ICON_CATEGORY_1_SMALL_GREY:String = "icon_general_sm_grey";
		public static const ICON_CATEGORY_2_SMALL_GREY:String = "icon_datacenter_sm_grey";
		public static const ICON_CATEGORY_3_SMALL_GREY:String = "icon_collaboration_sm_grey";
		public static const ICON_CATEGORY_4_SMALL_GREY:String = "icon_switching-routing_sm_grey";
		public static const ICON_CATEGORY_5_SMALL_GREY:String = "icon_security_sm_grey";
		public static const ICON_CATEGORY_6_SMALL_GREY:String = "icon_WiFi_sm_grey";

		public static const ICON_CISCO:String = "cisco_logo";
		public static const IMG_COIN:String = "coin";

		public static const ICON_FACEBOOK:String = "facebook_icon";

		public static const ICON_POWERUP_1:String = "powerup_5050";
		public static const ICON_POWERUP_2:String = "powerup_tme_frz";
		public static const ICON_POWERUP_3:String = "powerup_ask_audience";

		public static const ICON_POWERUP_1_LARGE:String = "powerup_5050_lrg";
		public static const ICON_POWERUP_2_LARGE:String = "powerup_tme_frz_lrg";
		public static const ICON_POWERUP_3_LARGE:String = "powerup_ask_audience_lrg";

		public static const ICON_SEARCH:String = "search_icon";

		public static const PROFILE_SHADOW_LARGE:String = "shadow_lrg";

		public static const BUTTON_STORE:String = "store_icon_sm";
		public static const BUTTON_EVENT:String = "event_icon";
		public static const ICON_STORE:String = "store_icon_lrg";
		public static const IMG_STARBURST:String = "win_animation";

		public static var ICON_MULTIPLAYER:String = "multiplayer_bttn_txt";
		public static var ICON_SINGLE_PLAYER:String = "single_player_bttn_txt";
		public static var ICON_VERSUS:String = "versus_bttn_txt";

		public static const SUBMIT_QUESTION:String = "submit_question";

		public static const ICON_PROFILE_LARGE:String = "profile_large";
		public static const ICON_PROFILE_DEFAULT_1:String = "profile_large";
		public static const ICON_PROFILE_DEFAULT_2:String = "profile_large";
		public static const ICON_PROFILE_DEFAULT_3:String = "profile_large";

		public static const ICON_FIRST_PLACE:String = "placeholder";
		public static const ICON_SECOND_PLACE:String = "placeholder";
		public static const ICON_THIRD_PLACE:String = "placeholder";

		public static const BURGER_MENU_DOWN:String = "nav_menu_dwnstate";

		public static const PREGAME_DROP_SHADOW:String = "menu_shadow";

		public static const LEADERBOARD_ALL_TIME:String = "all_time";
		public static const LEADERBOARD_WEEKLY:String = "weekly";
		public static const SCORE:String = "score";

		public static const TUTORIAL_ARROW:String = "tutorial_arrow";
		public static const TUTORIAL_BAR_1:String = "tutorial_bar_1";
		public static const TUTORIAL_BAR_2:String = "tutorial_bar_2";
		public static const TUTORIAL_BAR_3:String = "tutorial_bar_3";
		public static const TUTORIAL_BAR_4:String = "tutorial_bar_4";
		public static const TUTORIAL_BAR_5:String = "tutorial_bar_5";
		public static const TUTORIAL_BAR_6:String = "tutorial_bar_6";
		public static const TUTORIAL_BAR_7:String = "tutorial_bar_7";

		public static const STORE_LEFT:String = "store_left";
		public static const STORE_RIGHT:String = "store_right";

		private static var achievementMap:Object;

		public static function achievementFromName(name:String):String
		{
			var i:int;
			var achNames:Array = Achievement.ACHIEVEMENT_NAMES;
			var length:int = achNames.length;

			if(!achievementMap)
			{
				achievementMap = {};
				for(i = 0; i < length; i++)
					achievementMap[achNames[i]] = ACH_IMAGE_LIST[i];
			}

			for(i = 0; i < length; i++)
				if(name == achNames[i])
					return achievementMap[name];

			return null;
		}

		public static function getCategoryName(id:int, forUI:Boolean = false):String
		{
			if (!forUI)
			{
				switch(id)
				{
					case 1: return ImageMap.CATEGORY_1;
					case 2: return ImageMap.CATEGORY_2;
					case 3: return ImageMap.CATEGORY_3;
					case 4: return ImageMap.CATEGORY_4;
					case 5: return ImageMap.CATEGORY_5;
					case 6: return ImageMap.CATEGORY_6;
					default: return ImageMap.CATEGORY_0;
				}
			}
			else
			{
				switch(id)
				{
					case 1: return ImageMap.CATEGORY_1_PRETTY;
					case 2: return ImageMap.CATEGORY_2_PRETTY;
					case 3: return ImageMap.CATEGORY_3_PRETTY;
					case 4: return ImageMap.CATEGORY_4_PRETTY;
					case 5: return ImageMap.CATEGORY_5_PRETTY;
					case 6: return ImageMap.CATEGORY_6_PRETTY;
					default: return ImageMap.CATEGORY_0_PRETTY;
				}
			}
		}

		public static function getCategoryID(name:String):int
		{
			switch (name)
			{
				case ImageMap.CATEGORY_0: return 0;
				case ImageMap.CATEGORY_1: return 1;
				case ImageMap.CATEGORY_2: return 2;
				case ImageMap.CATEGORY_3: return 3;
				case ImageMap.CATEGORY_4: return 4;
				case ImageMap.CATEGORY_5: return 5;
				case ImageMap.CATEGORY_6: return 6;
			}
			return -1;
		}

		public static function getCategoryIcon(id:int, small:Boolean = true, grey:Boolean = false):String
		{
			var sizeString:String = small ? "SMALL" : "LARGE";
			var greyString:String = grey ? "_GREY" : "";
			var image:String = ImageMap['ICON_CATEGORY_' + String(id) + "_" + sizeString + greyString];

			if(image) return image;
			else return ICON_CATEGORY_0_LARGE;
		}

		public static function getRankIcon(rank:int):String
		{
			switch(rank)
			{
				case 1: return ImageMap.ICON_FIRST_PLACE;    break;
				case 2: return ImageMap.ICON_SECOND_PLACE;   break;
				case 3: return ImageMap.ICON_THIRD_PLACE;    break;
				default: return "";
			}
		}
	}
}
