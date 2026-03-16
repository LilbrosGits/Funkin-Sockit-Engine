package funkin.backend.songs;

import assets.Paths;
import funkin.data.Song.NoteData;
import funkin.data.Song.SongData;
import haxe.Json;

typedef FunkinLegacyChart = {
    var song:String;
	var notes:Array<FunkinLegacySection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
}

typedef FunkinLegacySection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class SongConverter {
	public static function convertFromFunkinLegacy(rawJson:String):SongData
	{
		var swagShit:FunkinLegacyChart = cast Json.parse(rawJson).song;
		swagShit.validScore = false;
        var sockitSong:SongData = {
            name: swagShit.song,
            authors: 'N/A',
            playData: {
                difficulties: ['easy', 'normal', 'hard'],
                variations: ['Default'],
                inst: {
                    authors: 'N/A',
                    audio: {
                        name: '${swagShit.song}Inst',
                        assetPath:'data/songs/${swagShit.song.toLowerCase()}/Inst',
                        effects: []
                    },
                    bpm: swagShit.bpm,
                    loop: false,
                },
                strumlines:[{
                    variation: 'Default',
                    keys: 4,
                    character: swagShit.player1,
                    charPos: [770, 450],
                    scrollSpeed: swagShit.speed,
                    strumPos: [620, 50],
                    strumlineAudio: {
                    name: '${swagShit.player1}-vocals',
                    assetPath: 'data/songs/${swagShit.song.toLowerCase()}/Voices-${swagShit.player1}',
                    effects: []
                    },
                    syncAudio: true,
                    strumlineVisible: true,
                    cpu: false,
                    strumlineData: [{
                    difficulty: 'easy',
                    notes: convertFunkinLegacyNotes(swagShit.notes)
                    },{
                    difficulty: 'normal',
                    notes: convertFunkinLegacyNotes(swagShit.notes)
                    },{
                    difficulty: 'hard',
                    notes: convertFunkinLegacyNotes(swagShit.notes)
                    }],
                    events: [],
                }, {
                    variation: 'Default',
                    keys: 4,
                    character: swagShit.player2,
                    charPos: [0, 100],
                    scrollSpeed: swagShit.speed,
                    strumPos: [0, 50],
                    strumlineAudio: {
                    name: '${swagShit.player2}-vocals',
                    assetPath: 'data/songs/${swagShit.song.toLowerCase()}/Voices-${swagShit.player2}',
                    effects: []
                    },
                    syncAudio: true,
                    strumlineVisible: true,
                    cpu: true,
                    strumlineData: [{
                    difficulty: 'easy',
                    notes: convertFunkinLegacyNotes(swagShit.notes, false)
                    },{
                    difficulty: 'normal',
                    notes: convertFunkinLegacyNotes(swagShit.notes, false)
                    },{
                    difficulty: 'hard',
                    notes: convertFunkinLegacyNotes(swagShit.notes, false)
                    }],
                    events: [],
                }],
                stage: 'stage'
            }
        };
		return sockitSong;
	}

    public static function convertFunkinLegacyNotes(notes:Array<FunkinLegacySection>, player:Bool = true):Array<NoteData> {
        var songNotes:Array<NoteData> = [];
        for (section in notes) {
            for (note in section.sectionNotes) {
                if (player) {
                    if (section.mustHitSection == true) {
                        var newNote:NoteData = {
                            noteID: Std.int(note[1] % 4),
                            strumTime: note[0],
                            sustainLength: note[2],
                            type: 'default'
                        };
                        if (note[1] < 4)
                            songNotes.push(newNote);
                    }
                    else {
                        var newNote:NoteData = {
                            noteID: Std.int(note[1] % 4),
                            strumTime: note[0],
                            sustainLength: note[2],
                            type: 'default'
                        };
                        if (note[1] > 4)
                            songNotes.push(newNote);
                    }
                }
                else {
                    if (section.mustHitSection == false) {
                        var newNote:NoteData = {
                            noteID: Std.int(note[1] % 4),
                            strumTime: note[0],
                            sustainLength: note[2],
                            type: 'default'
                        };
                        if (note[1] < 4)
                            songNotes.push(newNote);
                    }
                    else {
                        var newNote:NoteData = {
                            noteID: Std.int(note[1] % 4),
                            strumTime: note[0],
                            sustainLength: note[2],
                            type: 'default'
                        };
                        if (note[1] > 4)
                            songNotes.push(newNote);
                    }
                }

            }
        }
        return songNotes;
    }
}