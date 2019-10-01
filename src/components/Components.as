/**
 * Created by georgeperry on 10/3/16.
 */
package components
{
	import scenes.ForgotPassword;
	import scenes.Game;
	import scenes.Loading;
	import scenes.Login;
	import scenes.Menu;
	import scenes.PregameSplash;
	import scenes.Register;
	import scenes.Results;
	import scenes.Settings;
	import scenes.StandaloneLeaderboard;

	import ten90.base.Application;
	import ten90.components.SpinnerRing;

	public class Components
	{
		public static function init():void
		{
			Application.addComponent(Background,        [], [PregameSplash]);
			Application.addComponent(CustomError,       [], [Loading]);
			Application.addComponent(TransferDialog,    [Login]);
			Application.addComponent(SpinnerRing,       []);
			Application.addComponent(TriviaNetLogo,     [Loading, Login, Register, ForgotPassword]);
			Application.addComponent(CiscoLogo,         [Loading, Login, ForgotPassword, Register]);
			Application.addComponent(LoginInfo,         [Login, Register, ForgotPassword]);
			Application.addComponent(Quiz,              [Game]);
			Application.addComponent(Timer,             [Game]);
			Application.addComponent(ModeSelector,      [Menu]);
			Application.addComponent(Shadow,            [Login]);
			Application.addComponent(Banner,            [Menu]);
			Application.addComponent(Categories,        [Game]);
			Application.addComponent(VersusProfiles,    [Game, Results]);
			Application.addComponent(Powerups,          [Game]);
			Application.addComponent(ProfileSelector,   [Settings]);
			Application.addComponent(Burger,            [Menu]);
			Application.addComponent(PlayerList,        [PregameSplash]);
			Application.addComponent(BackButton,        [], [Menu, Loading, Login, Game, Results, StandaloneLeaderboard]);
			Application.addComponent(Tutorial,          [Menu]);
			Application.addComponent(RankDialog,        [Results, Menu]);

//			Application.customizeComponent
//			(
//				SpinnerRing,
//				{x:Screen.centerX, y:Screen.centerY, color:ColorMap.CISCO_BLUE, thickness:25, radius:100},
//				[Loading, Login, Leaderboards, CreateGroup, Friends, SubmitQuestionFields, Register, Game, StandaloneLeaderboard, Results]
//			);
//
//			Application.customizeComponent(SpinnerRing,  {thickness:25, radius:100}, [PregameSplash]);
//			Application.customizeComponent(BackButton,   {buttonImage:ImageMap.BUTTON_BACK_DARK}, [ForgotPassword, Register, PregameSplash, MultiplayerMenu]);
		}
	}
}
