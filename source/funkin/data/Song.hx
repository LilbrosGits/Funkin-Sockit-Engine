package funkin.data;

import assets.Paths;
import audio.SockitMusic.Music;
import audio.SockitMusic.Audio;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SongData =
{
	var name:String;
	var authors:String;
	var playData:PlayData;
}

typedef PlayData =
{
	var difficulties:Array<String>;
	var variations:Array<String>;
	var inst:Music;
	var strumlines:Array<StrumlineData>;
	var stage:String;
}

typedef StrumlineData = {
	var variation:String;
	var keys:Int;
	var character:String;
	var charPos:Array<Float>;
	var scrollSpeed:Float;
	var strumPos:Array<Float>;
	var strumlineAudio:Audio;
	var syncAudio:Bool;
	var strumlineVisible:Bool;
	var cpu:Bool;
	var strumlineData:Array<Difficulty>;
	var events:Array<EventData>;
}
typedef Difficulty = {
	var difficulty:String;
	var notes:Array<NoteData>;
}

typedef NoteData = {
	var noteID:Int;
	var strumTime:Float;
	var type:String;
	var sustainLength:Float;
}

typedef EventData = {
	var name:String;
	var strumTime:Float;
	var values:Array<EventValue>;
}

typedef EventValue = {
	var name:String;
	var value:Dynamic;
}

class Song
{
	public var songData:SongData;

	public function new()
	{}

	public static function loadSong(song:String):SongData
	{
		return parseJSON(Paths.getScript('data/charts/$song/$song-chart', JSON));
	}

	public static function parseJSON(rawJson:String):SongData
	{
		var swagShit:SongData = Json.parse(rawJson);
		return swagShit;
	}
}
