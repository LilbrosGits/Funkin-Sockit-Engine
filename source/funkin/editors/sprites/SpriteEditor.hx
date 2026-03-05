package funkin.editors.sprites;

import haxe.Json;
import assets.FileSystem;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.ui.components.Button;
import haxe.ui.components.CheckBox;
import haxe.ui.components.DropDown;
import haxe.ui.components.NumberStepper;
import haxe.ui.components.TabBar;
import haxe.ui.components.TextArea;
import haxe.ui.containers.Box;
import haxe.ui.containers.HBox;
import haxe.ui.containers.TabView;
import haxe.ui.containers.VBox;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.windows.Window;
import haxe.ui.containers.windows.WindowManager;
import haxe.ui.core.TextInput;
import objects.SockitSprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import sys.io.File;
import text.SockitText;

using StringTools;

class SpriteEditor extends FlxState
{
	public static var instance:SpriteEditor;
	public var mainSprite:SockitSprite;
	public static var _file:FileReference;

	public var uiGroup1:FlxGroup; // group for the upper menu

	public var tabGrp:TabBar;
	public var tabView:TabView;
	public var animationBox:Box;
	public var transformBox:Box;
	public var dataBox:Box;
	public var camUI:FlxCamera;
	public var camSprite:FlxCamera;

	public var animList:FlxTypedGroup<FlxText>;
	public var animInfo:FlxText;
	public var curAnim:Int = 0;
	public var playButton:Button;
	public var followPoint:FlxPoint;

	public var windows:WindowManager;

	public function new()
	{
		super();
		FlxG.sound.muteKeys = null;
		instance = this;
	}

	public function resetSprite()
	{
		if (mainSprite.spriteFile == null) {
			mainSprite.spriteFile = {
				name: 'untitled',
				transform: {
					pos: [0, 0],
					scale: [1, 1],
					angle: 0
				},
				version: '0.0.0',
				renderType: 'sparrow',
				assetPath: 'images/logoBumpin',
				anims: [
					{
						name: 'idle',
						xmlName: 'logo bumpin',
						frameRate: 24,
						offsets: [0, 0],
						loop: true,
						postFix: ''
					}
				]
			};
		}
		mainSprite.updateAssetPath();
	}

	override public function create()
	{
		super.create();

		mainSprite = new SockitSprite(0, 0);
		resetSprite();
		add(mainSprite);

		followPoint = new FlxPoint(0, 0);

		animList = new FlxTypedGroup<FlxText>();
		add(animList);

		uiGroup1 = new FlxGroup();
		add(uiGroup1);
		uiGroup1.add(animList);

		camSprite = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		camSprite.bgColor = FlxColor.TRANSPARENT;
		add(camSprite);

		camUI = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		camUI.bgColor = FlxColor.TRANSPARENT;
		add(camUI);

		FlxG.cameras.add(camSprite, true);
		FlxG.cameras.add(camUI, false);

		mainSprite.cameras = [camSprite];
		uiGroup1.cameras = [camUI];

		camSprite.focusOn(followPoint);

		animInfo = new FlxText(0, 50, 0, 'AnimInfo', 32);
		animInfo.cameras = [camUI];
		add(animInfo);
		animInfo.screenCenter(X);

		var menuBar:MenuBar = new MenuBar();
		menuBar.percentWidth = 100;
		uiGroup1.add(menuBar);

		var fileMenu:Menu = new Menu();
		fileMenu.text = 'File';
		menuBar.addComponent(fileMenu);

		var newSprite:MenuItem = new MenuItem();
		newSprite.text = 'New File';
		newSprite.onClick = function(e)
		{
			makeSpriteWindow();
		};
		fileMenu.addComponent(newSprite);

		var saveSprite:MenuItem = new MenuItem();
		saveSprite.text = 'Save File';
		saveSprite.onClick = function(e)
		{
			this.saveSprite(mainSprite.spriteFile);
		};
		fileMenu.addComponent(saveSprite);

		var loadaSprite:MenuItem = new MenuItem();
		loadaSprite.text = 'Open File';
		loadaSprite.onClick = function(e)
		{
			loadSprite();
		};
		fileMenu.addComponent(loadaSprite);

		var editMenu:Menu = new Menu();
		editMenu.text = 'Edit';
		menuBar.addComponent(editMenu);

		var addNewAnimation:MenuItem = new MenuItem();
		addNewAnimation.text = 'Add Animation';
		addNewAnimation.onClick = function(e)
		{
			makeAnimWindow();
		};
		editMenu.addComponent(addNewAnimation);

		tabGrp = new TabBar();
		tabView = new TabView();
		tabView.width = 320;
		tabView.height = 400;
		tabView.x = 0;
		tabView.y = FlxG.height - 400;
		tabGrp.addComponent(tabView);
		uiGroup1.add(tabView);

		dataBox = new Box();
		dataBox.width = 320;
		dataBox.height = 400;
		dataBox.x = 0;
		dataBox.y = FlxG.height - 400;
		dataBox.text = 'Sprite';
		tabView.addComponent(dataBox);

		animationBox = new Box();
		animationBox.width = 320;
		animationBox.height = 400;
		animationBox.x = 0;
		animationBox.y = FlxG.height - 400;
		animationBox.text = 'Animation';

		transformBox = new Box();
		transformBox.width = 320;
		transformBox.height = 400;
		transformBox.x = 0;
		transformBox.y = FlxG.height - 400;
		transformBox.text = 'Transform';

		tabView.addComponent(transformBox);

		tabView.addComponent(animationBox);

		windows = new WindowManager();

		reloadAnimUI();

		reloadTransData();

		reloadSpriteData();

		updateAnimList();
	}

	public function reloadTransData()
	{
		transformBox.removeAllComponents(true);

		var transContents:VBox = new VBox();

		transformBox.addComponent(transContents);

		var posBox:HBox = new HBox();

		var posXStepper:NumberStepper = new NumberStepper();
		posXStepper.pos = 0;
		posXStepper.step = 1;
		posXStepper.onChange = function(e)
		{
			mainSprite.spriteFile.transform.pos[0] = posXStepper.value;
		}
		posBox.addComponent(posXStepper);

		var posYStepper:NumberStepper = new NumberStepper();
		posYStepper.pos = 0;
		posYStepper.step = 1;
		posYStepper.onChange = function(e)
		{
			mainSprite.spriteFile.transform.pos[1] = posYStepper.value;
		}
		posBox.addComponent(posYStepper);

		transContents.addComponent(posBox);

		var scaleBox:HBox = new HBox();

		var scaleXStepper:NumberStepper = new NumberStepper();
		scaleXStepper.pos = 1;
		scaleXStepper.step = 0.1;
		scaleXStepper.onChange = function(e)
		{
			mainSprite.spriteFile.transform.scale[0] = scaleXStepper.value;
			camSprite.focusOn(followPoint);
		}
		scaleBox.addComponent(scaleXStepper);

		var scaleYStepper:NumberStepper = new NumberStepper();
		scaleYStepper.pos = 1;
		scaleYStepper.step = 0.1;
		scaleYStepper.onChange = function(e)
		{
			mainSprite.spriteFile.transform.scale[1] = scaleYStepper.value;
			camSprite.focusOn(followPoint);
		}
		scaleBox.addComponent(scaleYStepper);
		transContents.addComponent(scaleBox);
	}

	public function reloadSpriteData()
	{
		dataBox.removeAllComponents(true);

		var spriteTab:VBox = new VBox();

		var name:TextArea = new TextArea();
		name.text = mainSprite.spriteFile.name;
		name.onChange = function(e)
		{
			mainSprite.spriteFile.name = name.value;
		}
		spriteTab.addComponent(name);

		var typeDD:DropDown = new DropDown();
		for (i in ['sparrow', 'multisparrow', 'image', 'multiimage', 'textureatlas'])
		{
			typeDD.dataSource.add({id: i, text: i});
		}
		typeDD.searchable = false;
		typeDD.text = mainSprite.spriteFile.renderType;
		typeDD.onChange = function(e)
		{
			mainSprite.spriteFile.renderType = typeDD.text;
		}
		spriteTab.addComponent(typeDD);

		var assetPath:TextArea = new TextArea();
		assetPath.text = mainSprite.spriteFile.assetPath;
		assetPath.onChange = function(e)
		{
			mainSprite.spriteFile.assetPath = assetPath.value;
			mainSprite.updateAssetPath();
		}
		spriteTab.addComponent(assetPath);

		dataBox.addComponent(spriteTab);
	}

	public function reloadAnimUI()
	{
		animationBox.removeAllComponents(true);

		var animVBox:VBox = new VBox();

		if (mainSprite.spriteFile.anims[curAnim] == null) {
			var addButton = new Button();
			addButton.text = 'Add Animation';
			addButton.onClick = function(e) {}

			animVBox.addComponent(addButton);
		}
		else {
			var animName:TextArea = new TextArea();
			animName.text = mainSprite.spriteFile.anims[curAnim].name;
			animName.onChange = function(e)
			{
				mainSprite.spriteFile.anims[curAnim].name = animName.value;
			}
			animVBox.addComponent(animName);

			var dataName:TextArea = new TextArea();
			dataName.text = mainSprite.spriteFile.anims[curAnim].xmlName;
			dataName.onChange = function(e)
			{
				mainSprite.spriteFile.anims[curAnim].xmlName = dataName.value;
			}
			animVBox.addComponent(dataName);

			var framrateStepper:NumberStepper = new NumberStepper();
			framrateStepper.pos = mainSprite.spriteFile.anims[curAnim].frameRate;
			framrateStepper.step = 1;
			framrateStepper.onChange = function(e)
			{
				mainSprite.spriteFile.anims[curAnim].frameRate = framrateStepper.value;
				mainSprite.playAnim(mainSprite.spriteFile.anims[curAnim].name);
				mainSprite.animation.pause();
				if (mainSprite.animation.curAnim != null || mainSprite.anim.curAnim != null)
					mainSprite.animation.curAnim.curFrame = 0;
			}
			animVBox.addComponent(framrateStepper);

			animationBox.addComponent(animVBox);

			var animHBox:HBox = new HBox();
			animVBox.addComponent(animHBox);

			var offsetX:NumberStepper = new NumberStepper();
			if (mainSprite.animList.exists(mainSprite.spriteFile.anims[curAnim].name))
				offsetX.pos = mainSprite.animList.get(mainSprite.spriteFile.anims[curAnim].name).offsets[0];
			offsetX.step = 1;
			offsetX.onChange = function(e)
			{
				mainSprite.spriteFile.anims[curAnim].offsets[0] = offsetX.value;
				//mainSprite.animList.get(mainSprite.spriteFile.anims[curAnim].name).offsets[0] = offsetX.value;
				mainSprite.playAnim(mainSprite.spriteFile.anims[curAnim].name);
				mainSprite.animation.pause();
				if (mainSprite.animation.curAnim != null || mainSprite.anim.curAnim != null)
					mainSprite.animation.curAnim.curFrame = 0;
			}
			animHBox.addComponent(offsetX);

			var offsetY:NumberStepper = new NumberStepper();
			if (mainSprite.animList.exists(mainSprite.spriteFile.anims[curAnim].name))
				offsetY.pos = mainSprite.animList.get(mainSprite.spriteFile.anims[curAnim].name).offsets[1];
			offsetY.step = 1;
			offsetY.onChange = function(e)
			{
				mainSprite.spriteFile.anims[curAnim].offsets[1] = offsetY.value;
				//mainSprite.animList.get(mainSprite.spriteFile.anims[curAnim].name).offsets[1] = offsetY.value;
				mainSprite.playAnim(mainSprite.spriteFile.anims[curAnim].name);
				mainSprite.animation.pause();
				if (mainSprite.animation.curAnim != null || mainSprite.anim.curAnim != null)
					mainSprite.animation.curAnim.curFrame = 0;
			}
			animHBox.addComponent(offsetY);

			var butBox:HBox = new HBox();

			playButton = new Button();
			playButton.text = 'Play';
			playButton.onClick = function(e)
			{
				if (mainSprite.animation.curAnim != null || mainSprite.anim.curAnim != null && mainSprite.animation.curAnim.paused)
				{
					mainSprite.playAnim(mainSprite.spriteFile.anims[curAnim].name);
					playButton.text = 'Pause';
				}
				else
				{
					mainSprite.animation.pause();
					playButton.text = 'Play';
				}
			}
			animVBox.addComponent(playButton);
		}
	}

	public function makeAnimWindow()
	{
		var animWindow:Window = new Window();
		animWindow.title = 'Create New Animation';
		animWindow.width = 400;
		animWindow.height = 400;
		animWindow.minimizable = false;
		windows.addWindow(animWindow);

		var newAnimation:Anim = {
			name: 'anim name',
			xmlName: 'prefix',
			loop: false,
			postFix: '',
			offsets: [0, 0],
			frameRate: 24
		};

		var animVBox:VBox = new VBox();
		animWindow.addComponent(animVBox);

		var animName:TextArea = new TextArea();
		animName.text = 'anim name';
		animName.onChange = function(e)
		{
			newAnimation.name = animName.value;
		}
		animVBox.addComponent(animName);

		var dataName:TextArea = new TextArea();
		dataName.text = 'prefix';
		dataName.onChange = function(e)
		{
			newAnimation.xmlName = dataName.value;
		}
		animVBox.addComponent(dataName);

		var framrateStepper:NumberStepper = new NumberStepper();
		framrateStepper.pos = 24;
		framrateStepper.step = 1;
		framrateStepper.onChange = function(e)
		{
			newAnimation.frameRate = framrateStepper.value;
		}
		animVBox.addComponent(framrateStepper);

		var loopAnim:CheckBox = new CheckBox();
		loopAnim.text = 'Loop?';
		loopAnim.selected = newAnimation.loop;
		loopAnim.onChange = function(e)
		{
			newAnimation.loop = loopAnim.value;
		};
		animVBox.addComponent(loopAnim);

		var animHBox:HBox = new HBox();
		animVBox.addComponent(animHBox);

		var offsetX:NumberStepper = new NumberStepper();
		offsetX.pos = 0;
		offsetX.step = 1;
		offsetX.onChange = function(e)
		{
			newAnimation.offsets[0] = offsetX.value;
		}
		animHBox.addComponent(offsetX);

		var offsetY:NumberStepper = new NumberStepper();
		offsetY.pos = 0;
		offsetY.step = 1;
		offsetY.onChange = function(e)
		{
			newAnimation.offsets[1] = offsetY.value;
		}
		animHBox.addComponent(offsetY);

		var butBox:HBox = new HBox();

		var addButton = new Button();
		addButton.text = 'Add';
		addButton.onClick = function(e)
		{
			windows.closeWindow(animWindow);
			mainSprite.spriteFile.anims.push(newAnimation);
			// mainSprite.addAnimation(animName.value, newAnimation);
		}
		butBox.addComponent(addButton);

		animVBox.addComponent(butBox);
	}

	public function makeSpriteWindow()
	{
		var newSpriteWindow:Window = new Window();
		newSpriteWindow.title = 'Create New Sprite';
		newSpriteWindow.width = 400;
		newSpriteWindow.height = 400;
		newSpriteWindow.minimizable = false;
		windows.addWindow(newSpriteWindow);

		var newSprite:SpriteFile = mainSprite.spriteFile;

		var spriteVBox:VBox = new VBox();
		newSpriteWindow.addComponent(spriteVBox);

		var spriteName:TextArea = new TextArea();
		spriteName.text = 'sprite name';
		spriteName.onChange = function(e)
		{
			newSprite.name = spriteName.value;
		}
		spriteVBox.addComponent(spriteName);

		var renderTypeDD:DropDown = new DropDown();
		for (i in ['sparrow', 'multisparrow', 'image', 'multiimage', 'textureatlas'])
		{
			renderTypeDD.dataSource.add({id: i, text: i});
		}
		renderTypeDD.selectedIndex = 0;
		renderTypeDD.onChange = function(e)
		{
			newSprite.renderType = renderTypeDD.text;
		};
		spriteVBox.addComponent(renderTypeDD);

		var loadAssetPath:Button = new Button();
		loadAssetPath.text = 'Load Asset (Test)';
		loadAssetPath.onClick = function(e)
		{
			loadAsset();
		};
		spriteVBox.addComponent(loadAssetPath);

		var createButton = new Button();
		createButton.text = 'Add';
		createButton.onClick = function(e)
		{
			windows.closeWindow(newSpriteWindow);
			mainSprite.spriteFile = newSprite;
			reloadAnimUI();

			reloadTransData();

			reloadSpriteData();
		}
		spriteVBox.addComponent(createButton);
	}

	public function updateAnimList()
	{
		while (animList.members.length > 0)
		{
			animList.remove(animList.members[0], true);
		}

		for (i in 0...mainSprite.spriteFile.anims.length)
		{
			var animTxt:FlxText = new FlxText(0, 50 + (i * 50), 0,
				'${mainSprite.spriteFile.anims[i].name} [${mainSprite.spriteFile.anims[i].offsets[0]}, ${mainSprite.spriteFile.anims[i].offsets[1]}]', 32);
			animTxt.ID = i;
			animTxt.cameras = [camUI];
			animList.add(animTxt);
		}

		for (animText in animList.members)
		{
			if (animText.ID == curAnim)
				animText.alpha = 1;
			else
				animText.alpha = 0.4;

			if (FlxG.mouse.overlaps(animText, camUI))
			{
				animText.alpha = 0.6;
				if (FlxG.mouse.justPressed)
				{
					curAnim = animText.ID;
					reloadAnimUI();
				}
				if (FlxG.mouse.justPressedRight)
				{
					var animMenu:Menu = new Menu();
					animMenu.setPosition(animText.x + animText.width, animText.y);
					add(animMenu);

					var deleteAnim:MenuItem = new MenuItem();
					deleteAnim.text = 'Delete';
					deleteAnim.onClick = function(e)
					{
						mainSprite.spriteFile.anims.remove(mainSprite.spriteFile.anims[animText.ID]);
					};
					animMenu.addComponent(deleteAnim);

					var duplicateAnim:MenuItem = new MenuItem();
					duplicateAnim.text = 'Duplicate';
					duplicateAnim.onClick = function(e)
					{
						var anim:Anim = mainSprite.spriteFile.anims[animText.ID];
						anim.name = anim.name + '(copy)';
						mainSprite.spriteFile.anims.insert(animText.ID, anim);
					};
					animMenu.addComponent(duplicateAnim);
				}
			}
		}
	}

	override public function update(elapsed:Float)
	{
		if (mainSprite.animation.curAnim != null || mainSprite.anim.curAnim != null)
		{
			if (mainSprite.spriteFile.renderType != 'textureatlas')
				animInfo.text = '${mainSprite.animation.curAnim.name} <${mainSprite.animation.curAnim.curFrame}/${mainSprite.animation.curAnim.numFrames}>';
			else
				animInfo.text = '${mainSprite.anim.curAnim.name} <${mainSprite.anim.curAnim.curFrame}/${mainSprite.animation.curAnim.numFrames}>';

			if (mainSprite.animation.curAnim.paused || mainSprite.animation.curAnim.finished)
				playButton.text = 'Play';
			else
				playButton.text = 'Pause';

			if (FlxG.keys.justPressed.LEFT)
			{
				mainSprite.animation.pause();
				mainSprite.animation.curAnim.curFrame += 1;
			}

			if (FlxG.keys.justPressed.RIGHT)
			{
				mainSprite.animation.pause();
				mainSprite.animation.curAnim.curFrame -= 1;
			}
		}
		else if (mainSprite.spriteFile.anims[curAnim] != null)
		{
			animInfo.text = '${mainSprite.spriteFile.anims[curAnim].name}';
		}

		if (FlxG.mouse.pressedMiddle)
		{
			camSprite.scroll.x = camSprite.scroll.x - FlxG.mouse.deltaViewX;
			camSprite.scroll.y = camSprite.scroll.y - FlxG.mouse.deltaViewY;
		}

		super.update(elapsed);

		if (FlxG.keys.justPressed.UP)
		{
			updateCurAnim(-1);
		}

		if (FlxG.keys.justPressed.DOWN)
		{
			updateCurAnim(1);
		}

		updateAnimList();
	}

	public function updateCurAnim(change:Int = 0)
	{
		curAnim += change;

		if (curAnim > mainSprite.spriteFile.anims.length)
		{
			curAnim = 0;
		}
		else if (curAnim < 0)
		{
			curAnim = mainSprite.spriteFile.anims.length - 1;
		}
		reloadAnimUI();
	}

	public function saveSprite(spriitefile:SpriteFile)
	{
		var data:String = Json.stringify(spriitefile, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), spriitefile.name + ".json");
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

	public function loadSprite()
	{
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	public function loadAsset()
	{
		var jsonFilter:FileFilter = new FileFilter('Any Files', '.');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onAssetLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
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
			var rawJson:String = File.getContent(fullPath);
			if (rawJson != null)
			{
				mainSprite.spriteFile = cast haxe.Json.parse(rawJson);
				mainSprite.updateAssetPath();
				reloadAnimUI();
				reloadTransData();
				reloadSpriteData();
			}
		}
		loadError = true;
		_file = null;
	}

	private function onAssetLoadComplete(_):Void
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
			trace(_file.name);
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
