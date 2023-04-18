package funkin.states.menus.modding;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import funkin.system.FunkinPaths;
import funkin.util.FunkinUtil;
import sys.FileSystem;

using StringTools;

class ModsMenu extends FlxState {
    var modGrp:FlxTypedGroup<Mod>;
    var mods:Array<Array<String>> = [];
    var curModSel:Int = 0;
    var curPage:Int = 0;
    var lmao:FlxObject;

    override public function create() {
        var bg = new FlxSprite().loadGraphic(FunkinPaths.image('UI/menus/menuBGBlue'));
        bg.scrollFactor.set();
        add(bg);

        var but = new FlxButton(0, 0, 'Disable All', function() {
            FunkinPaths.currentModDir = '';
        });
        add(but);
        
        loadPage(curPage);

        select();
        
        super.create();
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.UP) {
            select(-1);
        }
        if (FlxG.keys.justPressed.DOWN) {
            select(1);
        }

        FlxG.mouse.useSystemCursor = true;

        super.update(elapsed);
    }

    public function select(change:Int = 0) {
        curModSel += change;

        if (curModSel >= mods[curPage].length)
            curModSel = 0;
        if (curModSel < 0)
            curModSel = mods[curPage].length - 1;

        modGrp.forEach(function(txt:Mod) {
            if (txt.ID == curModSel) {
                txt.alpha = 1;
                lmao.setPosition(FlxG.width / 2, txt.y);
            }
            else {
                txt.alpha = 0.6;
            }
        });
    }

    public function loadPage(page:Int = 0) {
        resetMods();
        lmao = new FlxObject(0, 0, 1, 1);
        
        FlxG.camera.follow(lmao, LOCKON, FunkinUtil.adjustedFrame(0.06));

        modGrp = new FlxTypedGroup<Mod>();
        add(modGrp);

        for (i in 0...mods[curPage].length) {
            var swag = new Mod(0, (100 * i), mods[curPage][i]);
            swag.ID = i;
            modGrp.add(swag);
        }
    }

    public function resetMods() {
        var modList:Array<Array<String>> = [];
        FunkinPaths.getAllMods(modList[0]);
    }
}