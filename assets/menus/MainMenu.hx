import flixel.FlxSprite;
import funkin.meta.states.PlayState;

var bg:SockitSprite;
var menuItems:Array<FlxSprite> = [];
var menuID:Array<String> = ['story mode', 'freeplay', 'options'];
var curSelected:Int = 0;
function onLoad() {
    bg = new SockitSprite(0, -20);
    bg.name = 'BG';
}

function onCreate() {
    bg.setImage('images/menuBG');
    bg.setGraphicSize(bg.width * 1.1);
    bg.scrollFactor.set(0, 0.2);
    add(bg);

    for (i in 0...menuID.length) {
        var item = new FlxSprite(0, 0 + (i * 180));
        item.frames = Paths.loadSparrow('images/FNF_main_menu_assets');
        item.animation.addByPrefix('idle', menuID[i] + ' basic', 24, true);
        item.animation.addByPrefix('selected', menuID[i] + ' white', 24, true);
        item.animation.play('idle');
        item.scrollFactor.set(1, 0.8);
        menuItems.push(item);
        trace(menuID[i]);
    }
    for (menuButton in menuItems) {
        add(menuButton);
    }
}
function onCreatePost() {    
    changeSelected(0);
}
function onUpdatePost() {
    if (FlxG.keys.justPressed.UP) {
        changeSelected(-1);
    }
    if (FlxG.keys.justPressed.DOWN) {
        changeSelected(1);
    }

    if (FlxG.keys.justPressed.ENTER) {
        switch(menuID[curSelected]) {
            case 'story mode':
                FlxG.switchState(new PlayState());
            case 'freeplay':
                switchState('menus/EditorMenu');

        }
    }
}

function onUpdate() {}

function changeSelected(sel:Int = 0) {
    curSelected += sel;

    if (curSelected > menuID.length - 1)
        curSelected = 0;
    if (curSelected < 0)
        curSelected = menuID.length - 1;

    for (i in 0...menuItems.length) {
        if (i == curSelected) {
            menuItems[i].alpha = 1;
            menuItems[i].animation.play('selected', true);
            FlxG.camera.follow(menuItems[i], null, 0.06);
            menuItems[i].centerOffsets();
        }
        if (i != curSelected) {
            menuItems[i].alpha = 0.6;
            menuItems[i].animation.play('idle');
            menuItems[i].centerOffsets();
        }
    }
}

