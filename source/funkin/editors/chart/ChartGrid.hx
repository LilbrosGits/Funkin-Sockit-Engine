package funkin.editors.chart;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import funkin.data.Song.NoteData;
import funkin.obj.Note;
import assets.Paths;
import flixel.addons.display.FlxTiledSprite;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;

class ChartGrid extends FlxSpriteGroup {
    public var strum:FlxTiledSprite;
    public var curRenderedNotes:FlxTypedSpriteGroup<Note>;
    public var curRenderedSustains:FlxSpriteGroup;
    public var zoom:Int = 1;

    public function new() {
        super();
    }

    public function loadGrid(keys:Int, charName:String) {
        this.width = 40 * keys;
        this.height = (FlxG.sound.music != null) ? Math.floor(FlxG.sound.music.length * 40) / 40 : 40;
        strum = new FlxTiledSprite(Paths.getImage('UI/charter/grid'), 40 * keys, (FlxG.sound.music != null) ? Math.floor(FlxG.sound.music.length * 40) / 40 : 40, true, true);
        add(strum);

        curRenderedNotes = new FlxTypedSpriteGroup<Note>();
        curRenderedSustains = new FlxSpriteGroup();

        add(curRenderedSustains);
        add(curRenderedNotes);
    }

    public function updateGrid(notes:Array<NoteData>) {
        while (curRenderedNotes.members.length > 0)
        {
            curRenderedNotes.remove(curRenderedNotes.members[0], true);
        }

        while (curRenderedSustains.members.length > 0)
        {
            curRenderedSustains.remove(curRenderedSustains.members[0], true);
        }

        for (i in notes)
        {
            var note:Note = new Note(i.strumTime, i.noteID % 4);
            note.sustainLength = i.sustainLength;
            note.setGraphicSize(40, 40);
            note.updateHitbox();
            note.x = Math.floor((i.noteID % 4) * 40);
            note.y = Math.floor(getYfromStrum((i.strumTime)));

            curRenderedNotes.add(note);

            if (i.sustainLength > 0)
            {
                var sustainVis:FlxSprite = new FlxSprite(note.x + (40),
                    note.y + 40).makeGraphic(8, Math.floor(FlxMath.remapToRange(i.sustainLength, 0, (FlxG.sound.music != null) ? Math.floor(FlxG.sound.music.length / 40) * Conductor.stepCrochet : 0, 0, strum.height)));
                curRenderedSustains.add(sustainVis);
            }
        }
    }

    public function getStrumTime(yPos:Float):Float
    {
        return FlxMath.remapToRange(yPos, strum.y, strum.y + strum.height, 0, (FlxG.sound.music != null) ? Math.floor(FlxG.sound.music.length / 40) * Conductor.stepCrochet : 0);
    }

    public function getYfromStrum(strumTime:Float):Float
    {
        return FlxMath.remapToRange(strumTime, 0, (FlxG.sound.music != null) ? Math.floor(FlxG.sound.music.length / 40) * Conductor.stepCrochet : 0, strum.y, strum.y + strum.height);
    }
}