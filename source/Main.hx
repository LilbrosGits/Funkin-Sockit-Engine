package;

import flixel.FlxGame;
import flixel.FlxState;
import funkin.ui.FunkinOverlay;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
//Crash Handler
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = funkin.states.TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var overlay:FunkinOverlay;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));

		funkin.system.Preferences.loadOptions();

		#if !mobile
		overlay = new FunkinOverlay(0, 0);
		addChild(overlay);
		#end
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	function onCrash(event:UncaughtErrorEvent) {
		var msg:String = '';
		var path:String = '';
		var eStack:Array<StackItem> = CallStack.exceptionStack(true);
		var time:String = Date.now().toString();
		time.replace(" ", "_");
		time.replace(":", "-");
		path = "./logs/crashes/" + "Sockit_" + time + ".txt";
		for (stackItem in eStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					msg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}
		msg += "\nUnexpected Error: " + event.error + "\nPlease report bug to the Github page: https://github.com/LilbrosGits/Funkin-Sockit-Engine";
		if (!FileSystem.exists("./logs/crashes/"))
			FileSystem.createDirectory("./logs/crashes/");
		File.saveContent(path, msg + "\n");
		Application.current.window.alert(msg, "Sockit Error!");
		Sys.exit(1);
	}
}
