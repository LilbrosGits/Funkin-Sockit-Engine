package;

import funkin.meta.states.IntroState;
import haxe.ui.Toolkit;
import assets.Paths;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;
import application.SockitApplication;
import meta.SockitState;

class Main extends Sprite
{
	public function new()
	{
		super();
		Toolkit.init();
		Toolkit.theme = "DARK";
		SockitApplication.parseApplicationFile(Paths.getAppData('engine/app'));
		addChild(new FlxGame(0, 0, IntroState));

		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
	}
}
