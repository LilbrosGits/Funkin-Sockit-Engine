package funkin.system;

import funkin.system.Sec.SecData;
import haxe.Json;

using StringTools;

typedef SongData = {
    var song:String;
    var bpm:Float;
    var sections:Array<SecData>;
    var needsVoices:Bool;
    var speed:Float;
    var characters:Array<String>;
    var validScore:Bool;
}

class Song {
    public var song:String;
	public var sections:Array<SecData>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

    public var characters:Array<String> = ['dad', 'bf'];
    public var player1:String;

	//public var characters:Array<String> = ['dad', 'bf'];

	public function new(song, sections, bpm)
	{
		this.song = song;
		this.sections = sections;
		this.bpm = bpm;
	}

    public static function loadSong(song:String, difficulty:String = 'normal'){
        var daJson = FunkinPaths.songJson(song, difficulty);

        while (!daJson.endsWith("}")) {
            daJson = daJson.substr(0, daJson.length - 1);
        }//i think thats what cam did idfk

        return songParse(daJson);
    }

    public static function songParse(daFile:String):SongData {
        var parsedSong:SongData = cast Json.parse(daFile).song;
        parsedSong.validScore = true;
        return parsedSong;
    }
}