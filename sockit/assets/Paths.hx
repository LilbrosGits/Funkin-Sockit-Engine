package assets;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;
import haxe.Json;
import objects.SockitSprite;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;

using StringTools;

#if sys
import sys.io.File;
#end

enum abstract Script(String)
{
	var JSON = ".json";
	var SCRIPT = ".hx";
	var LUA = ".lua";
	var TXT = ".txt";
}

class Paths
{
	public static var curMod:String = '';

	public static function getPath(key:String)
	{
		// filtering maybe?
		if (sys.FileSystem.exists('mods/$curMod/$key'))
			return 'mods/$curMod/$key';
		else
			return 'assets/$key';
	}

	public static function getImage(key:String)
	{
		var path = getPath('$key.png');
		return path;
	}

	public static function getSnd(key:String)
	{
		// I hate this so god damn much
		var gottenPath:String = getPath('$key.ogg');
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if (!Cache.currentTrackedSounds.exists(gottenPath))
			Cache.currentTrackedSounds.set(gottenPath, Sound.fromFile(gottenPath));
		Cache.localTrackedAssets.push(key);
		return Cache.currentTrackedSounds.get(gottenPath);
	}

	public static function getJson(key:String):Dynamic
	{
		var json:String = key;
		json = getPath('$key.json');

		#if sys
		return Json.parse(File.getContent(json));
		#else
		return Json.parse(lime.utils.Assets.getText(json));
		#end
	}

	public static function getSprite(key:String):SpriteFile
	{
		var json:String = key;
		json = getPath('$key.json');

		#if sys
		return Json.parse(File.getContent(json));
		#else
		return Json.parse(lime.utils.Assets.getText(json));
		#end
	}

	public static function getData(key:String)
	{
		#if sys
		return File.getContent(getPath('$key'));
		#else
		return lime.utils.Assets.getText(getPath('$key'));
		#end
	}

	public static function getScript(key:String, script:Script = JSON)
	{
		var json:String;
		switch (script)
		{
			case JSON:
				json = getPath('$key$JSON');
				#if sys
				return File.getContent(json);
				#else
				return lime.utils.Assets.getText(json);
				#end
			case SCRIPT:
				json = getPath('$key$SCRIPT');
				#if sys
				return File.getContent(json);
				#else
				return lime.utils.Assets.getText(json);
				#end
			case LUA:
				json = getPath('$key$LUA');
				#if sys
				return File.getContent(json);
				#else
				return lime.utils.Assets.getText(json);
				#end
			default:
				json = getPath('$key$SCRIPT');
				#if sys
				return File.getContent(json);
				#else
				return lime.utils.Assets.getText(json);
				#end
		}
	}

	public static function getXml(key:String)
	{
		var xml:String = getPath('$key.xml');

		#if sys
		return File.getContent(xml);
		#else
		return lime.utils.Assets.getText(xml);
		#end
	}

	public static function getFont(key:String)
	{
		var font = getPath('$key.ttf');

		return font;
	}

	public static function getOTFFont(key:String)
	{
		var font = getPath('$key.otf');

		return font;
	}

	public static function getAppData(key:String):Dynamic
	{
		var json:String = key;
		json = '$key.data';

		#if sys
		return Json.parse(File.getContent(json));
		#else
		return Json.parse(lime.utils.Assets.getText(json));
		#end
	}

	public static function loadSparrow(key:String)
	{
		return FlxAtlasFrames.fromSparrow(getImage(key), getPath(key + '.xml'));
	}

	public static function getCharacter(path:String)
	{
		return haxe.Json.parse(sys.io.File.getContent(getPath('data/characters/$path/data.json')));
	}

	public static function getLevel(path:String):String
	{
		return getPath('data/levels/$path/level.json');
	}

	public static function getMoveset(path:String):String
	{
		return getPath('data/scripts/movesets/$path.hx');
	}
}
