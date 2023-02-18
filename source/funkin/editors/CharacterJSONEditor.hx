package funkin.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyList;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.ui.Alphabet;
import sys.FileSystem;

using StringTools;

class CharacterJSONEditor extends MusicBeatState {
    var typedTxt:String = '';

    var alphabet:Alphabet;

    var cap = true; //no cap ong

    var daChar:String = 'bf';

    var charList:Array<String> = [];

    var ui_Colors:Array<FlxColor> = [0xFFFFFF, 0x000000, 0x858585];

    var textBG:FlxSprite;

    override public function create() {
        textBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        add(textBG);

        var swagChar = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(getCharacterFileFromPaths(), true), function(character:String)
        {
            daChar = getCharacterFileFromPaths()[Std.parseInt(character)];
        });

        swagChar.selectedLabel = 'bf';

        alphabet = new Alphabet(0, 0, typedTxt, false);
        add(alphabet);
        
        super.create();
    }

    function getCharacterFileFromPaths():Array<String> {
        for (file in FileSystem.readDirectory('assets/characters')){
            charList.push(file.replace('.json', ''));
        }

        return charList;
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(new CharacterEditor());
        }

        for (i in 0...typedTxt.length) {
            alphabet.text += i;
            alphabet.isBold = cap;
        }

        if (FlxG.keys.justPressed.CAPSLOCK && !cap)
            cap = true;
        else
            cap = false;

        typingInput();

        textBG.centerOrigin();
        
        super.update(elapsed);
    }

    function typingInput() {
        if (FlxG.keys.anyJustPressed([Q,W,E,R,T,Y,U,I,O,P,A,S,D,F,G,H,J,K,L,Z,X,C,V,B,N,M])) {
            if (cap)
                typedTxt += keyToLetter([Q,W,E,R,T,Y,U,I,O,P,A,S,D,F,G,H,J,K,L,Z,X,C,V,B,N,M]).toUpperCase();
            else
                typedTxt += keyToLetter([Q,W,E,R,T,Y,U,I,O,P,A,S,D,F,G,H,J,K,L,Z,X,C,V,B,N,M]).toLowerCase();
        }
    }

    function keyToLetter(key:Array<FlxKey>):String {
        return key.toString();
    }
}