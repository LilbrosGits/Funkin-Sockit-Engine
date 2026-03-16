package funkin.data;

import assets.Paths;

typedef WeekData = {
    weekName:String,
    songs:Array<String>,
    characters:Array<String>,
    difficulties:Array<String>,
    hideFreeplay:Bool,
    startLocked: Bool,
    hideStoryMode: Bool,
    pos:Int
}

class Week {
    public var data:WeekData;
    public function new(weekName, songs, characters, difficulties, startLocked, hideFreeplay, hideStoryMode, pos) {
        data = {
            weekName: weekName,
            songs: songs,
            characters: characters,
            difficulties: difficulties,
            hideFreeplay: hideFreeplay,
            startLocked: startLocked,
            hideStoryMode: hideStoryMode,
            pos: pos
        };
    }

    public static function parseFile(file:String):WeekData {
        var data = Paths.getJson('data/weeks/$file');

        return data;
    }
}