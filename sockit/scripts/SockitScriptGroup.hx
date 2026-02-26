package scripts;

import application.SockitApplication;
import assets.Cache;
import assets.FileSystem;
import assets.Paths;
import audio.SockitMusic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import meta.SockitState;
import objects.SockitSprite;
import text.SockitText;

using StringTools;

class SockitScriptGroup
{
	var scripts:Array<SockitScript> = [];

	public function new(dir:String)
	{
		for (i in FileSystem.readDir(dir))
		{
			if (i.endsWith('.hx'))
			{
				var script:SockitScript = new SockitScript(dir + '/${i.replace('.hx', '')}');
				scripts.push(script);
			}
		}
	}

	public function execute()
	{
		for (i in scripts)
		{
			i.execute();
		}
	}

	public function set(name:String, value:Dynamic)
	{
		for (i in scripts)
		{
			i.set(name, value);
		}
	}

	public function call(func:String, args:Array<Dynamic>)
	{
		for (i in scripts)
		{
			if (i.exists(func))
				i.call(func, args);
		}
	}
}
