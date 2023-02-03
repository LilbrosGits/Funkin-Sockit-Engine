package funkin.obj;

import flixel.FlxSprite;
import funkin.system.*;

class Note extends FlxSprite {
    public static var noteWidth = 160 * 0.7;

    public static var notes:Array<String> = ['purple', 'blue', 'green', 'red'];

    public var noteData:Int = 0;

    public var susNote:Bool = false; //GET OUT OF MY HEAD GET OUYT GET OPUT GET OUTFDRSHSZ

    public var prevNote:Note;

    public var mustHit:Bool = false;

    public var susLength:Float;

    public var strumTime:Float;

    public function new(strumTime:Float, noteData:Int, ?previousNote:Note, ?isSus:Bool) {
        super();

        if (previousNote == null)
            previousNote = this;
        this.noteData = noteData;
        susNote = isSus;
        prevNote = previousNote;
        this.strumTime = strumTime;
        
        x += 50;
        x += noteWidth * noteData;

        y -= 2000;
        //just in case???

        loadNotes();
    }

    function loadNotes(skin:String = 'UI/HUD/NOTE_assets') {
        frames = FunkinPaths.sparrowAtlas(skin);
        animation.addByPrefix('purple', 'purple0', 24, false);
        animation.addByPrefix('blue', 'blue0', 24, false);
        animation.addByPrefix('green', 'green0', 24, false);
        animation.addByPrefix('red', 'red0', 24, false);
        animation.addByPrefix('purplehold', 'purple hold piece', 24, false);
        animation.addByPrefix('bluehold', 'blue hold piece', 24, false);
        animation.addByPrefix('greenhold', 'green hold piece', 24, false);
        animation.addByPrefix('redhold', 'red hold piece', 24, false);
        animation.addByPrefix('purpleholdend', 'pruple end hold', 24, false);
        animation.addByPrefix('blueholdend', 'blue hold end', 24, false);
        animation.addByPrefix('greenholdend', 'green hold end', 24, false);
        animation.addByPrefix('redholdend', 'red hold end', 24, false);

        setGraphicSize(Std.int(width * 0.7));

        animation.play(notes[noteData]);

        if (prevNote != null && susNote) {
            alpha = 0.6;

            x += width / 2;

            animation.play('${notes[noteData]}holdend');

            updateHitbox();

            if (prevNote.susNote) {
                prevNote.animation.play('${notes[prevNote.noteData]}hold');
                prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * funkin.states.PlayState.song.speed;
                prevNote.updateHitbox();
            }
        }
    }
}