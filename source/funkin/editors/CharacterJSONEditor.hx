package funkin.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import sys.FileSystem;

using StringTools;

class CharacterJSONEditor extends MusicBeatState {
    var stupidStuff:FlxInputText;

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

        stupidStuff = new FlxInputText(0, 0, FlxG.width * 2, FunkinPaths.characterJson(daChar), 16, ui_Colors[1], FlxColor.TRANSPARENT);
        stupidStuff.font = FunkinPaths.font('vcr.ttf');
        add(stupidStuff);
        
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

        textBG.width = stupidStuff.width;
        textBG.height = stupidStuff.height;

        textBG.centerOrigin();
        
        super.update(elapsed);
    }
}