package scripts;

import flixel.FlxObject;
import application.SockitApplication;
import assets.Cache;
import assets.FileSystem;
import assets.Paths;
import audio.SockitMusic;
import crowplexus.iris.Iris;
import flixel.addons.display.FlxRuntimeShader;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxGradient;
import haxe.ui.components.Button;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.containers.ButtonBar;
import haxe.ui.containers.HorizontalButtonBar;
import haxe.ui.containers.VerticalButtonBar;
import haxe.ui.containers.windows.Window;
import haxe.ui.containers.windows.WindowManager;
import meta.SockitState;
import objects.SockitSprite;
import text.SockitText.SockitFont;
import text.SockitText;
import flixel.group.FlxGroup;

class SockitScript extends Iris
{
	override public function preset()
	{
		set('SockitSprite', SockitSprite);
		set('Object', FlxObject);
		set('FlxGroup', FlxGroup);
		set('SockitState', SockitState);
		set('SockitText', SockitText);
		set('SockitFont', SockitFont);
		set('SockitMusic', SockitMusic);
		set('Gradient', FlxGradient);
		set('TextArea', TextArea);
		set('TextField', TextField);
		set('Window', Window);
		set('WindowManager', WindowManager);
		set('Button', Button);
		set('ButtonBar', ButtonBar);
		set('HButtonBar', HorizontalButtonBar);
		set('VButtonBar', VerticalButtonBar);
		set('FlxG', flixel.FlxG);
		set('Paths', Paths);
		set('FileSystem', FileSystem);
		set('Cache', Cache);
		set('SockitApplication', SockitApplication);
		set('Bar', FlxBar);
		set('Std', Std);
		set('Math', Math);
	}

	public function new(script:String)
	{
		super(Paths.getScript(script, SCRIPT));
		parse(true);
	}
}
