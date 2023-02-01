package funkin.obj;

import flixel.FlxSprite;
import funkin.system.*;

class Note extends FlxSprite {
    public static var noteWidth = 160 * 0.7;

    public static var notes:Array<String> = ['purple', 'blue', 'green', 'red'];

    public function new(strumTime:Float, noteData:Int, previousNote:Note) {
        super();

        if (previousNote == null)
            previousNote = this;
        
        x += 50;
        x += noteWidth * noteData;
        
        frames = FunkinPaths.sparrowAtlas('UI/HUD/NOTE_assets');
        animation.addByPrefix('purple', 'purple0', 24, false);
        animation.addByPrefix('blue', 'blue0', 24, false);
        animation.addByPrefix('green', 'green0', 24, false);
        animation.addByPrefix('red', 'red0', 24, false);

		setGraphicSize(Std.int(width * 0.7));

        animation.play(notes[noteData]);
    }
}