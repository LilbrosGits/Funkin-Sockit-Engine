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
    var txtGrp:FlxTypedGroup<FlxText>;
    var ew:FlxTypedGroup<FlxText>;
    var mods:Array<Array<String>> = [];
    var curModSel:Int = 0;
    var curPage:Int = 0;
    var lmao:FlxObject;
    var cum:Array<String> = ['Enabled', 'Disabled'];
    var curON:Int = 0;

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

        if (FlxG.keys.justPressed.LEFT) {
            curON -= 1;
        }
        if (FlxG.keys.justPressed.RIGHT) {
            curON += 1;
        }

        ew.forEach(function(gay:FlxText) {
            gay.text = cum[curON];

            if (gay.text == 'Enabled')
                FunkinPaths.currentModDir = mods[curPage][curModSel];
            if (gay.text == 'Disabled')
                FunkinPaths.currentModDir != gay.text;
        });

        if (curON >= cum.length)
            curON = 0;
        if (curON < 0)
            curON = cum.length - 1;

        FlxG.mouse.useSystemCursor = true;

        super.update(elapsed);
    }

    public function select(change:Int = 0) {
        curModSel += change;

        if (curModSel >= mods[curPage].length)
            curModSel = 0;
        if (curModSel < 0)
            curModSel = mods[curPage].length - 1;

        txtGrp.forEach(function(txt:FlxText) {
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

        txtGrp = new FlxTypedGroup<FlxText>();
        add(txtGrp);

        ew = new FlxTypedGroup<FlxText>();
        add(ew);

        for (i in 0...mods[curPage].length) {
            var swag = new FlxText(0, 0 + (i * 100), 0, mods[curPage][i], 32);
            swag.setFormat(FunkinPaths.font('vcr.ttf'), 64, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            swag.ID = i;
            txtGrp.add(swag);

            var kys = new FlxText(swag.width + 20, 0 + (i * 100), 0, 'Disabled', 32);
            kys.setFormat(FunkinPaths.font('vcr.ttf'), 64, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            kys.ID = i;
            ew.add(kys);
        }
    }

    public function resetMods() {
        var modList:Array<String> = [];
        for (file in FileSystem.readDirectory('mods/')) {
            modList.push(file);
        }
        mods.push(modList);
    }
}