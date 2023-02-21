package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.ui.Alphabet;

class OptionsMenu extends MusicBeatState {
    var swagBS:Array<String> = ['Prefences', 'Visuals', 'Misc'];
    var alphabet:FlxTypedGroup<Alphabet>;
    var curSel:Int = 0;

    override public function create() {
        var bg:FlxSprite = new FlxSprite().loadGraphic(FunkinPaths.image('UI/menus/menuBGBlue'));
        add(bg);

        alphabet = new FlxTypedGroup<Alphabet>();
        add(alphabet);

        for (i in 0...swagBS.length) {
            var cum:Alphabet = new Alphabet(0, 100 + (80 * i), swagBS[i], true);
            cum.ID = i;
            alphabet.add(cum);
        }
        
        super.create();
    }

    override public function update(elapsed:Float) {

        if (FlxG.keys.justPressed.UP) {
            curSel -= 1;
        }

        if (FlxG.keys.justPressed.DOWN) {
            curSel += 1;
        }
        if (FlxG.keys.justPressed.ENTER) {
            switch(curSel) {
                case 0:
                    FlxG.switchState(new MainMenuState());
                case 1:
                    FlxG.switchState(new MainMenuState());
                case 2:
                    FlxG.switchState(new MainMenuState());
            }
        }

        if (curSel < 0)
            curSel = swagBS.length - 1;
        if (curSel >= swagBS.length)
            curSel = 0;

        alphabet.forEach(function(alph:Alphabet) {
            if (alph.ID == curSel)
                alph.alpha = 1;
            else
                alph.alpha = 0.6;

            alph.screenCenter(X);
        });
        super.update(elapsed);
    }
}