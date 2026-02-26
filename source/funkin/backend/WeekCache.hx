package funkin.backend;

import funkin.data.Week.WeekData;
import flixel.FlxG;
import funkin.data.Song;
import funkin.data.Song.SongData;
import assets.FileSystem;

using StringTools;

class SongCache {
    public static var songs:Map<String, WeekData> = [];
    
    public static function reloadSongCache() {
        for (i in FileSystem.readDir('weeks/')) {
            trace(i);
            if (FileSystem.isDir('weeks/$i')) {
                trace(i);
                var songfiles = FileSystem.readDir('weeks/$i');
                for (song in songfiles) {
                    trace(song);
                    if (song.endsWith('week.json')) {
                        var weekDat = WeekData;
                        weekDat = Paths.getJson(song);
                        songs.set(weekDat.weekName, weekDat);
                    }
                }
            }
        }
        FlxG.save.data.weeks = songs;
    }
}