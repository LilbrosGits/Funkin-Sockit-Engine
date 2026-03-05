package funkin.editors.chart;

import funkin.backend.songs.SongConverter;
import haxe.ui.components.OptionStepper;
import flixel.addons.display.FlxTiledSprite;
import funkin.meta.states.PlayState;
import funkin.data.Song.Difficulty;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.data.Song.NoteData;
import application.SockitApplication;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import haxe.ui.containers.menus.Menu;
import audio.SockitMusic;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import openfl.net.FileReference;
import haxe.ui.components.NumberStepper;
import haxe.ui.components.CheckBox;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import sys.io.File;
import haxe.io.Path;
import funkin.data.Song.StrumlineData;
import objects.SockitSprite.SpriteFile;
import assets.Paths;
import haxe.ui.containers.Box;
import haxe.ui.containers.TabView;
import haxe.ui.components.TabBar;
import haxe.ui.containers.menus.MenuItem;
import flixel.FlxG;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.components.Button;
import assets.FileSystem;
import haxe.ui.components.DropDown;
import haxe.ui.components.TextArea;
import haxe.ui.containers.VBox;
import haxe.ui.containers.windows.Window;
import haxe.ui.containers.windows.WindowManager;
import funkin.data.Song.SongData;
import funkin.meta.states.GameState;

using StringTools;

class ChartEditor extends GameState {
    public static var instance:ChartEditor;

    public var song:SongData;

    public var winMan:WindowManager;

    public static var _file:FileReference;

    public var gridMap:Map<String, ChartGrid> = [];
    public var gridGrp:FlxTypedGroup<ChartGrid>;

    public var tabGrp:TabBar;
    public var tabView:TabView;
	public var chartBox:Box;
	public var songBox:Box;
	public var strumlineBox:Box;
    public var strumSpr:FlxSprite;

    public var curStrum:Int = 0;
    public var curDifficulty:Int = 0;
    public var curVariation:Int = 0;

    public var camUI:FlxCamera;
    public var camChart:FlxCamera;

    public var inst:SockitMusic;

    public var dummyArrow:FlxSprite;

    public var vocals:Map<String, SockitMusic> = [];

    public var hitSound:SockitMusic;

    public var camFollow:FlxObject;

    public var infoText:FlxText;

    public var bgGrid:FlxTiledSprite;

    public function new() {
        super('Chart Editor');
        instance = this;
    }

    override public function create() {
        super.create();

        camUI = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        camUI.bgColor = FlxColor.TRANSPARENT;

        camChart = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        camChart.bgColor = FlxColor.TRANSPARENT;

        FlxG.cameras.reset(camChart);
        FlxG.cameras.add(camUI);
        camChart.zoom = 1.5;

        winMan = new WindowManager();

        inst = new SockitMusic();

        var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.getImage('images/menuDesat'));
        bg.color = 0xD5FF75ED;
        bg.alpha = 0.6;
        bg.scrollFactor.set();
        add(bg);

        bgGrid = new FlxTiledSprite(Paths.getImage('UI/charter/grid'), 1280, 720, true, true);
        bgGrid.alpha = 0.3;
        bgGrid.scrollFactor.set();
        add(bgGrid);

        initUI();

        if (song == null) {
            createNewChart();
        } else {
            reloadStrumlineUI();
            reloadChartGrids();
            reloadInst();
        }

        strumSpr = new FlxSprite(0, 0).makeGraphic(40 * 4, 10);

        dummyArrow = new FlxSprite(0, 0).makeGraphic(40, 40);
        dummyArrow.alpha = 0;

        infoText = new FlxText(FlxG.width - 450, 200, 0, '', 32);
        infoText.setFormat(Paths.getFont('fonts/vcr'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, false);
        add(infoText);

        dummyArrow.cameras = [camChart];
        strumSpr.cameras = [camChart];
        bg.cameras = [camChart];
        bgGrid.cameras = [camChart];
        infoText.cameras = [camUI];

        gridGrp = new FlxTypedGroup<ChartGrid>();
        add(gridGrp);

        add(strumSpr);

        hitSound = new SockitMusic();
        hitSound.parseAudio({
            name: 'hitNote',
            assetPath: 'sounds/clickText',
            effects: []
        });

        camFollow = new FlxObject(0, 0, 1, 1);

        add(dummyArrow);

        camChart.follow(camFollow, null, 1);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        bgGrid.scrollX = elapsed * 70;
        
        bgGrid.scrollY = elapsed * 70;

        if (FlxG.sound.music != null) {
            Conductor.songPosition = FlxG.sound.music.time;

            if (FlxG.keys.justPressed.SPACE) {
                if (!FlxG.sound.music.playing) {
                    FlxG.sound.music.play();
                    playVocals();
                }
                else  {
                    FlxG.sound.music.pause();
                    pauseVocals();
                }
            }

            if (FlxG.mouse.wheel != 0) {
                FlxG.sound.music.time -= FlxG.mouse.wheel * Conductor.stepCrochet;
            }
        }

        if (song != null) {
            updateGrids();

            if (FlxG.keys.justPressed.ENTER) {
                PlayState.song = song;
                PlayState.difficulty = curDifficulty;
                FlxG.switchState(new PlayState());
            }
        }
        else {
            //SockitApplication.setWarning('Error!', 'The Current Grid Can\'t Be Updated');
        }

        //gridMap.get(song.playData.strumlines[curStrum].character).updateGrid(song.playData.strumlines[curStrum].strumlineData[curDifficulty].strumlineData[curDifficulty].notes);
    }

    public function initUI() {
        var menuBar:MenuBar = new MenuBar();
        menuBar.width = FlxG.width;
        menuBar.text = 'Idk Yo';
        add(menuBar);

        var fileMenu:Menu = new Menu();
        fileMenu.text = 'File';
        
        var newChart:MenuItem = new MenuItem();
        newChart.text = 'New Chart';
        newChart.onClick = function(_) {
            createNewChart();
        };
        fileMenu.addComponent(newChart);

        var save:MenuItem = new MenuItem();
        save.text = 'Save Chart';
        save.onClick = function(_) {
            saveChart(song);
        };
        fileMenu.addComponent(save);

        var openChart:MenuItem = new MenuItem();
        openChart.text = 'Open Chart';
        openChart.onClick = function(_) {
            loadChart();
        };
        fileMenu.addComponent(openChart);

        var loadLegacy:MenuItem = new MenuItem();
        loadLegacy.text = 'Open Funkin Legacy Chart';
        loadLegacy.onClick = function(_) {
            loadLegacyChart();
        };
        fileMenu.addComponent(loadLegacy);

        var viewMenu:Menu = new Menu();
        viewMenu.text = 'View';
        var editMenu:Menu = new Menu();
        editMenu.text = 'Edit';

        menuBar.addComponent(fileMenu);
        menuBar.addComponent(editMenu);
        menuBar.addComponent(viewMenu);

        tabGrp = new TabBar();
        tabView = new TabView();
		tabView.width = 320;
		tabView.height = 400;
		tabView.x = 0;
		tabView.y = FlxG.height - 400;
		tabGrp.addComponent(tabView);
		add(tabView);

        menuBar.cameras = [camUI];
        tabView.cameras = [camUI];

        songBox = new Box();
		songBox.width = 320;
		songBox.height = 400;
		songBox.x = 0;
		songBox.y = FlxG.height - 400;
		songBox.text = 'Song';
		tabView.addComponent(songBox);

        strumlineBox = new Box();
		strumlineBox.width = 320;
		strumlineBox.height = 400;
		strumlineBox.x = 0;
		strumlineBox.y = FlxG.height - 400;
		strumlineBox.text = 'Strumline';
		tabView.addComponent(strumlineBox);
    }

    public function createNewChart(mustDo:Bool = true) {
        var window:Window = new Window();
        window.title = 'Create New Chart';
        window.width = 256;
        window.height = 420;
        window.closable = mustDo;
        window.collapsable = false;
        window.minimizable = false;
        window.cameras = [camUI];

        var windowbox1:VBox = new VBox();
        var newSSong:SongData = {
            name: 'Song',
            authors: 'Name',
            playData: {
                difficulties: ['easy', 'normal', 'hard'],
                variations: ['Default'],
                inst: {
                    authors: 'Name',
                    audio: {
                        name:'SongInst',
                        assetPath: 'data/songs/test/Inst',
                        effects: []
                    },
                    bpm:185,
                    loop:false,
                },
                strumlines: [],
                stage: 'stage'
            }
        }

        var songName:TextArea = new TextArea();
        songName.text = newSSong.name;
        songName.onChange = function(e) {
            newSSong.name = songName.text;
            newSSong.playData.inst.audio.name = '${songName.text}Inst';
        };
        windowbox1.addComponent(songName);

        var songID:TextArea = new TextArea();
        songID.text = newSSong.name.toLowerCase();
        songID.onChange = function(e) {
            newSSong.playData.inst.audio.assetPath = 'data/songs/${songID.text}/Inst';
        };
        windowbox1.addComponent(songID);

        var songAuthors:TextArea = new TextArea();
        songAuthors.text = 'N/A';
        songAuthors.onChange = function(e) {
            newSSong.authors = songAuthors.text;
            newSSong.playData.inst.authors = songAuthors.text;
        };
        windowbox1.addComponent(songAuthors);

        var stageDD:DropDown = new DropDown();
        for (stage in FileSystem.readDir('stages/')) {
            if (FileSystem.isDir('stages/$stage')) {
                stageDD.dataSource.add({id: stage, text: stage});
            }
        }
        stageDD.selectedIndex = 0;
        stageDD.onChange = function(e) {
            newSSong.playData.stage = stageDD.text;
        };
        windowbox1.addComponent(stageDD);
        
        var createButton:Button = new Button();
        createButton.text = 'Create';
        createButton.onClick = function(e) {
            song = newSSong;
            reloadChartGrids();
            reloadStrumlineUI();
            reloadInst();
            Conductor.changeBPM(song.playData.inst.bpm);
            winMan.closeWindow(window);
        };
        windowbox1.addComponent(createButton);
        window.addComponent(windowbox1);
        winMan.addWindow(window);
    }

    public function reloadSongUI() {
        songBox.removeAllComponents(true);

        var songVBox:VBox = new VBox();
        songBox.addComponent(songVBox);

        var songName:TextArea = new TextArea();
        songName.text = song.name;
        songName.onChange = function(e) {
            song.name = songName.text;
        };
        songVBox.addComponent(songName);

        var songDifficulty:DropDown = new DropDown();
        for (i in song.playData.difficulties) {
            songDifficulty.dataSource.add({id: i, text: i});
        }
        songDifficulty.selectedIndex = curDifficulty;
        songDifficulty.onChange = function(e) {
            curDifficulty = songDifficulty.selectedIndex;
        };
        songVBox.addComponent(songDifficulty);

    }

    public function reloadStrumlineUI() {
        reloadSongUI();
        strumlineBox.removeAllComponents(true);

        if (song.playData.strumlines[curStrum] == null) {
            var vbox:VBox = new VBox();
            strumlineBox.addComponent(vbox);
            var createStrumButton:Button = new Button();
            createStrumButton.text = 'Add Character';
            createStrumButton.onClick = function(_) {
                createNewStrumline(true);
            };
            vbox.addComponent(createStrumButton);
        }
        else {
            var vbox:VBox = new VBox();
            strumlineBox.addComponent(vbox);
        
            var keyStepper:NumberStepper = new NumberStepper();
            keyStepper.pos = 4;
            keyStepper.step = 1;
            keyStepper.onChange = function(e) {
                song.playData.strumlines[curStrum].keys = Std.int(keyStepper.pos);
            };

            var scrollStepper:NumberStepper = new NumberStepper();
            scrollStepper.pos = 1.0;
            scrollStepper.step = 0.1;
            scrollStepper.onChange = function(e) {
                song.playData.strumlines[curStrum].scrollSpeed = scrollStepper.pos;
            };

            var isVisible:CheckBox = new CheckBox();
            isVisible.text = 'Hide Strumline?';
            isVisible.selected = song.playData.strumlines[curStrum].strumlineVisible;
            isVisible.onChange = function(e) {
                song.playData.strumlines[curStrum].strumlineVisible = isVisible.selected;
            };

            var syncAudioButton:CheckBox = new CheckBox();
            syncAudioButton.text = 'Sync Audio?';
            syncAudioButton.selected = song.playData.strumlines[curStrum].syncAudio;
            syncAudioButton.onChange = function(e) {
                song.playData.strumlines[curStrum].syncAudio = syncAudioButton.selected;
            };

            var isCPU:CheckBox = new CheckBox();
            isCPU.text = 'Is CPU?';
            isCPU.selected = song.playData.strumlines[curStrum].cpu;
            isCPU.onChange = function(e) {
                song.playData.strumlines[curStrum].cpu = isCPU.selected;
            };

            var createStrumButton:Button = new Button();
            createStrumButton.text = 'Add Character';
            createStrumButton.onClick = function(_) {
                createNewStrumline(false);
            };

            var charDD:DropDown = new DropDown();
            for (i in 0...FileSystem.readDir('data/characters').length) {
                if (FileSystem.isDir('data/characters/${FileSystem.readDir('data/characters')[i]}')) {
                    var chr:SpriteFile = haxe.Json.parse(Paths.getScript('data/characters/${FileSystem.readDir('data/characters')[i]}/char', JSON));
                    charDD.dataSource.add({id: i, text: '${FileSystem.readDir('data/characters')[i]} (${chr.name})'});
                }
            }
            charDD.selectedIndex = curStrum;
            charDD.onChange = function(_) {
                for (i in 0...song.playData.strumlines.length) {
                    if (song.playData.strumlines[i].character == song.playData.strumlines[charDD.selectedIndex].character)
                        curStrum = i;
                }

                keyStepper.pos = song.playData.strumlines[curStrum].keys;
                scrollStepper.pos = song.playData.strumlines[curStrum].scrollSpeed;
                isVisible.selected = !song.playData.strumlines[curStrum].strumlineVisible;
                syncAudioButton.selected = song.playData.strumlines[curStrum].syncAudio;
                isCPU.selected = song.playData.strumlines[curStrum].cpu;
            };
            vbox.addComponent(charDD);
            vbox.addComponent(keyStepper);
            vbox.addComponent(scrollStepper);   
            vbox.addComponent(isVisible);
            vbox.addComponent(syncAudioButton);
            vbox.addComponent(isCPU);
            vbox.addComponent(createStrumButton);
        }
    }

    public function reloadChartGrids() {
        for (i in 0...song.playData.strumlines.length) {
            if (gridMap.exists(song.playData.strumlines[i].character)) {
                gridMap.get(song.playData.strumlines[i].character).x = i * (song.playData.strumlines[i].keys + gridMap.get(song.playData.strumlines[i].character).width);
            }
            else {
                var grid:ChartGrid = new ChartGrid();
                grid.loadGrid(song.playData.strumlines[i].keys, song.playData.strumlines[i].character);
                grid.cameras = [camChart];
                gridMap.set(song.playData.strumlines[i].character, grid);
                gridMap.get(song.playData.strumlines[i].character).x = i * (song.playData.strumlines[i].keys + gridMap.get(song.playData.strumlines[i].character).width);
                gridGrp.add(gridMap.get(song.playData.strumlines[i].character));
            }
        }
    }

    public function updateGrids() {
        if (song != null) {
            for (i in 0...song.playData.strumlines.length) {
                if (gridMap.get(song.playData.strumlines[i].character) != null) {
                    for (note in gridMap.get(song.playData.strumlines[i].character).curRenderedNotes) {
                        if (note.y < FlxG.height) {
                            note.visible = true;
                            note.active = true;
                        }
                        else {
                            note.visible = false;
                            note.active = false;
                        }
                    }
                    for (sus in gridMap.get(song.playData.strumlines[i].character).curRenderedSustains) {
                        if (sus.y > FlxG.height && sus.y > 0) {
                            sus.visible = true;
                            sus.active = true;
                        }
                        else {
                            sus.visible = false;
                            sus.active = false;
                        }
                    }
                    if (FlxG.mouse.overlaps(gridMap.get(song.playData.strumlines[i].character).strum)) {
                        dummyArrow.alpha = 0.6;
                        dummyArrow.x = gridMap.get(song.playData.strumlines[i].character).strum.x + Math.floor(FlxG.mouse.x / 40) * 40;
                        dummyArrow.y = Math.floor(FlxG.mouse.y / 40) * 40;
                        if (i == curStrum) {
                            if (FlxG.mouse.justPressed) {
                                if (!FlxG.mouse.overlaps(gridMap.get(song.playData.strumlines[i].character).curRenderedNotes)) {
                                    var newNote:NoteData = {
                                    noteID: Math.floor(FlxG.mouse.x / 40),
                                    strumTime: gridMap.get(song.playData.strumlines[curStrum].character).getStrumTime(dummyArrow.y),
                                    type: 'default',
                                    sustainLength: 0
                                    }
                                    addNote(newNote);
                                }
                            }
                            if (FlxG.mouse.pressed) {
                                    if (FlxG.mouse.overlaps(gridMap.get(song.playData.strumlines[i].character).curRenderedNotes)) {
                                        for (note in song.playData.strumlines[curStrum].strumlineData[curDifficulty].notes) {
                                            if (note.strumTime == gridMap.get(song.playData.strumlines[curStrum].character).getStrumTime(dummyArrow.y))
                                            {
                                                note.noteID = Math.floor(FlxG.mouse.x / 40);
                                                note.strumTime = gridMap.get(song.playData.strumlines[curStrum].character).getStrumTime(dummyArrow.y);
                                                note.sustainLength = 0 + gridMap.get(song.playData.strumlines[curStrum].character).getStrumTime(Math.floor(FlxG.mouse.deltaY / 40) * 40);
                                            }
                                        }
                                    }
                                }

                            if (FlxG.mouse.justPressedRight) {
                                for (note in song.playData.strumlines[curStrum].strumlineData[curDifficulty].notes) {
                                    if (note.strumTime == gridMap.get(song.playData.strumlines[curStrum].character).getStrumTime(dummyArrow.y) && (note.noteID == Math.floor(FlxG.mouse.x / 40)))
                                    {
                                        trace('kill');
                                        deleteNote(note);
                                    }
                                }
                            }
                        }
                        else {
                            if (FlxG.mouse.justPressed) {
                                curStrum = i;
                                reloadStrumlineUI();
                            }
                        }
                    }
                    else {
                        dummyArrow.alpha = 0;
                    }
                }
                    if (i == curStrum) {
                    infoText.text = 'Song: ${song.name}\n${Std.int(Conductor.songPosition / 1000)} : ${Std.int(FlxG.sound.music.length / 60000)}.${FlxMath.roundDecimal(Conductor.songPosition, 0)}\n Character: ${song.playData.strumlines[curStrum].character}';
                    if (gridMap.get(song.playData.strumlines[curStrum].character) != null) {
                        gridMap.get(song.playData.strumlines[curStrum].character).updateGrid(song.playData.strumlines[curStrum].strumlineData[curDifficulty].notes);
                        gridMap.get(song.playData.strumlines[i].character).alpha = 1;
                        strumSpr.y = gridMap.get(song.playData.strumlines[curStrum].character).getYfromStrum(Conductor.songPosition);
                        strumSpr.x = gridMap.get(song.playData.strumlines[curStrum].character).x;
                        camFollow.x = 0 + gridGrp.members.length * 40;
                        camFollow.y = strumSpr.y;

                        for (note in gridMap.get(song.playData.strumlines[curStrum].character).curRenderedNotes.members) {
                            if (note.strumTime <= gridMap.get(song.playData.strumlines[curStrum].character).getStrumTime(strumSpr.y)) {
                                note.alpha = 0.6;
                            }
                            else {
                                note.alpha = 1;
                            }
                        }
                    }
                }
                else {
                        if (gridMap.get(song.playData.strumlines[i].character) != null) {
                            gridMap.get(song.playData.strumlines[i].character).alpha = 0.6;
                        }
                    }
            }
        }
    }

    function addNote(data:NoteData) {
        trace(data.noteID);
        if (!song.playData.strumlines[curStrum].strumlineData[curDifficulty].notes.contains(data))
            song.playData.strumlines[curStrum].strumlineData[curDifficulty].notes.push(data);
    }

    function deleteNote(data:NoteData) {
        for (i in 0...song.playData.strumlines[curStrum].strumlineData[curDifficulty].notes.length) {
            if (song.playData.strumlines[curStrum].strumlineData[curDifficulty].notes[i] == data)
                song.playData.strumlines[curStrum].strumlineData[curDifficulty].notes.remove(song.playData.strumlines[curStrum].strumlineData[curDifficulty].notes[i]);
        }
    }

    public function reloadInst() {
        inst.parseMusic(song.playData.inst);
        inst.playMusic();
        FlxG.sound.music.pause();
    }

    public function playVocals() {
        for (char in gridMap.keys()) {
            vocals.get(char + '-vocals').playAudio();
        }
        resyncVocals();
    }

    public function pauseVocals() {
        for (char in gridMap.keys()) {
            vocals.get(char + '-vocals').pauseAudio();
        }
    }

    public function resyncVocals() {
        for (char in gridMap.keys()) {
            vocals.get(char + '-vocals').audio.time = FlxG.sound.music.time;
        }
    }

    public function createNewStrumline(mustDo:Bool = true) {
        var window:Window = new Window();
        window.title = 'Create New Strumline';
        window.width = 256;
        window.height = 420;
        window.closable = mustDo;
        window.collapsable = false;
        window.minimizable = false;
        window.cameras = [camUI];

        var windowbox1:VBox = new VBox();
        var newStrum:StrumlineData = {
            character: 'Char',
            strumlineData: [],
            variation: song.playData.variations[curVariation],
            keys: 4,
            charPos: [0, 0],
            scrollSpeed: 1.0,
            strumPos: [0, 50],
            strumlineAudio: {
                name: 'Char-vocals',
                assetPath: '',
                effects: []
            },
            syncAudio: true,
            strumlineVisible: true,
            cpu: false
        };

        var chr:Array<SpriteFile> = [];

        var vocal:SockitMusic = new SockitMusic();
        
        var keyStepper:NumberStepper = new NumberStepper();
        keyStepper.pos = 4;
        keyStepper.step = 1;
        keyStepper.onChange = function(e) {
            newStrum.keys = Std.int(keyStepper.pos);
        };

        var scrollStepper:NumberStepper = new NumberStepper();
        scrollStepper.pos = 1.0;
        scrollStepper.step = 0.1;
        scrollStepper.onChange = function(e) {
            newStrum.scrollSpeed = scrollStepper.pos;
        };

        var isVisible:CheckBox = new CheckBox();
        isVisible.text = 'Hide Strumline?';
        isVisible.selected = false;
        isVisible.onChange = function(e) {
            newStrum.strumlineVisible = isVisible.selected;
        };

        var syncAudioButton:CheckBox = new CheckBox();
        syncAudioButton.text = 'Sync Audio?';
        syncAudioButton.selected = newStrum.syncAudio;
        syncAudioButton.onChange = function(e) {
            newStrum.syncAudio = syncAudioButton.selected;
        };

        var isCPU:CheckBox = new CheckBox();
        isCPU.text = 'Is CPU?';
        isCPU.selected = newStrum.cpu;
        isCPU.onChange = function(e) {
            newStrum.cpu = isCPU.selected;
        };

        var charDD:DropDown = new DropDown();
        for (i in 0...FileSystem.readDir('data/characters').length) {
            if (FileSystem.isDir('data/characters/${FileSystem.readDir('data/characters')[i]}')) {
                chr.push(haxe.Json.parse(Paths.getScript('data/characters/${FileSystem.readDir('data/characters')[i]}/char', JSON)));
                charDD.dataSource.add({id: '${FileSystem.readDir('data/characters')[i]}', text: '${FileSystem.readDir('data/characters')[i]} (${chr[i].name})'});
            }
        }
        charDD.selectedIndex = 0;
        charDD.onChange = function(_) {
            //charDD.text = '${FileSystem.readDir('data/characters')[charDD.selectedIndex]} (${chr[charDD.selectedIndex].name})';
            newStrum.character = '${FileSystem.readDir('data/characters')[charDD.selectedIndex]}';
            newStrum.strumlineAudio.name = '${FileSystem.readDir('data/characters')[charDD.selectedIndex]}-vocals';
            newStrum.strumlineAudio.assetPath = '${song.playData.inst.audio.assetPath.replace('Inst', 'Voices-${FileSystem.readDir('data/characters')[charDD.selectedIndex]}')}';
            vocal.parseAudio(newStrum.strumlineAudio);
            trace(newStrum);
        };

        var createButton:Button = new Button();
        createButton.text = 'Create Strumline';
        createButton.onClick = function(e) {
            var strumDiffs:Array<StrumlineData> = [];
            for (i in song.playData.difficulties) {
                var strum:Difficulty = {
                    difficulty: i, 
                    notes: [],
                };
                strum.difficulty = i;
                if (!newStrum.strumlineData.contains(strum))
                    newStrum.strumlineData.push(strum);
            }
            song.playData.strumlines.push(newStrum);
            for (i in 0...song.playData.strumlines.length)
                if (song.playData.strumlines[i].character == newStrum.character) curStrum = i;

            vocals.set('${FileSystem.readDir('data/characters')[charDD.selectedIndex]}-vocals', vocal);

            reloadStrumlineUI();
            reloadChartGrids();

            winMan.closeWindow(window);
        };

        windowbox1.addComponent(charDD);
        windowbox1.addComponent(keyStepper);
        windowbox1.addComponent(scrollStepper);
        windowbox1.addComponent(isVisible);
        windowbox1.addComponent(isCPU);
        windowbox1.addComponent(syncAudioButton);
        windowbox1.addComponent(createButton);
        window.addComponent(windowbox1);
        winMan.addWindow(window);
    }

    public function loadAudio()
	{
		var oggFilter:FileFilter = new FileFilter('.OGG', 'ogg');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([oggFilter]);
	}

    public function loadChart()
	{
		var jsonFilter:FileFilter = new FileFilter('.JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onChartLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

    public function loadLegacyChart()
	{
		var jsonFilter:FileFilter = new FileFilter('.JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLegacyLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

    public function saveChart(songData:SongData)
	{
		var data:String = haxe.Json.stringify(songData, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), songData.name + ".json");
		}
	}

	public function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	public function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	public function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	public static var loadError:Bool = false;

	private function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		var fullPath:String = null;
		@:privateAccess
		if (_file.__path != null)
			fullPath = _file.__path;

		if (fullPath != null)
		{
			var rawOGG:String = File.getContent(fullPath);
			if (rawOGG != null)
			{
                trace(rawOGG);
                if (FileSystem.exists(Path.normalize(fullPath))) {
                    song.playData.strumlines[curStrum].strumlineAudio.assetPath = 'data/songs/${song.name.toLowerCase()}/${_file.name}';
                }
                else {
                    if (FileSystem.isDir('data/songs/${song.name.toLowerCase()}')) {
                        File.saveContent(Paths.getPath('data/songs/${song.name.toLowerCase()}/Voices-${song.playData.strumlines[curStrum].character.toLowerCase()}.ogg'), rawOGG);
                    }
                }
			}
		}
		loadError = true;
		_file = null;
	}

	private function onChartLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		var fullPath:String = null;
		@:privateAccess
		if (_file.__path != null)
			fullPath = _file.__path;

		if (fullPath != null)
		{
			song = haxe.Json.parse(sys.io.File.getContent(fullPath));
            reloadStrumlineUI();
            reloadInst();
            reloadChartGrids();
            Conductor.changeBPM(song.playData.inst.bpm);
            for (i in song.playData.strumlines) {
                var vocal:SockitMusic = new SockitMusic();
                vocal.parseAudio(i.strumlineAudio);
                vocals.set('${i.character}-vocals', vocal);
            }
		}
		loadError = true;
		_file = null;
	}

    	private function onLegacyLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		var fullPath:String = null;
		@:privateAccess
		if (_file.__path != null)
			fullPath = _file.__path;

		if (fullPath != null)
		{
			song = SongConverter.convertFromFunkinLegacy(sys.io.File.getContent(fullPath));
            reloadStrumlineUI();
            reloadInst();
            reloadChartGrids();
            Conductor.changeBPM(song.playData.inst.bpm);
            for (i in song.playData.strumlines) {
                var vocal:SockitMusic = new SockitMusic();
                vocal.parseAudio(i.strumlineAudio);
                vocals.set('${i.character}-vocals', vocal);
            }
		}
		loadError = true;
		_file = null;
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	private function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	private function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}

}