package funkin.editors;

import flixel.addons.ui.StrNameLabel;
import flixel.FlxCamera;
import flixel.util.typeLimit.OneOfThree;
import funkin.obj.Stage;
import funkin.states.PlayState;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.system.Preferences;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.util.FlxColor;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;

class StageEditor extends MusicBeatState {
    var daUIBox:FlxUITabMenu;
	var stageName:String = 'stage';
    var stageFile:File;
	var camFol:FlxObject;
    var stageSprites:FlxTypedGroup<FlxSprite>;
    var curSelectedObj:Dynamic;
    var camStage:FlxCamera;
    var camUI:FlxCamera;
    var stageTypes:Array<String> = ['Image', 'Animated', 'Created'];

    override public function create() {
		super.create();

		camStage = new FlxCamera();
		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;

		FlxG.cameras.reset(camStage);
		FlxG.cameras.add(camUI, false);

        FlxG.cameras.setDefaultDrawTarget(camStage, true);

        //checking if the stage is null
        if (PlayState.song.stage == null)
            stageName = 'stage';
        else
            stageName = PlayState.song.stage;

        if (PlayState.stage != null)
            stageFile = PlayState.stage.data;
        else
		    stageFile = {
            cameraZoom: 0.9,
            sprites: {
                images: [
                    {
                       spriteName: "back",
                       image: "stageback",
                       positions: [-600, -200],
                       scrollFactor: [0.9, 0.9],
                       antialiasing: true,
                       active: false
                    },
                    {
                        spriteName: "front",
                        image: "stagefront",
                        positions: [-550, 600],
                        scrollFactor: [0.9, 0.9],
                        width: 3000,
                        height: 639.1,
                        antialiasing: true,
                        active: false
                    },
                    {
                        spriteName: "curtains",
                        image: "stagecurtains",
                        positions: [-700, -300],
                        scrollFactor: [1.3, 1.3],
                        width: 2304,
                        height: 1260,
                        antialiasing: true,
                        active: false
                    },
                ],
            },
            dadPosition: [100, 100],
            boyfriendPosition: [770, 450],
            gfPosition: [400, 130]
        };

        //setting up selection
        if (curSelectedObj == null)
            curSelectedObj = stageFile.sprites.images[0];

        //adding stages and ui
        stageSprites = new FlxTypedGroup<FlxSprite>();
        add(stageSprites);
		
		var tabs = [
			{name: "Stage", label: 'Stage'}
		];

		camFol = new FlxObject(0, 0, 1, 1);

		FlxG.camera.follow(camFol, LOCKON, 0.06);

		daUIBox = new FlxUITabMenu(null, null, tabs, null, true);

		daUIBox.resize(300, 400);
		daUIBox.x = FlxG.width / 2;
		daUIBox.y = 20;
		add(daUIBox);

		addStageDisplay();
        addStageUI(stageTypes[0]);

        stageSprites.cameras = [camStage];
        daUIBox.cameras = [camUI];
    }

	override public function update(elapsed:Float) {
		super.update(elapsed);

        updateDisplay();

        FlxG.mouse.visible = true;

        //moving cameras
		if (FlxG.keys.pressed.A) {
			camFol.x -= 3;
		}
		if (FlxG.keys.pressed.D) {
			camFol.x += 3;
		}
		if (FlxG.keys.pressed.W) {
			camFol.y -= 3;
		}
		if (FlxG.keys.pressed.S) {
			camFol.y += 3;
		}
		if (FlxG.keys.pressed.E) {
			FlxG.camera.zoom += 0.05;
		}
		if (FlxG.keys.pressed.Q) {
			FlxG.camera.zoom -= 0.05;
		}

        //selecting sprites
        if (stageFile.sprites.images != null) {
            for (i in stageFile.sprites.images) {
                if (FlxG.mouse.overlaps(stageSprites) && !FlxG.mouse.overlaps(daUIBox)) {
                    if (FlxG.mouse.justPressed)
                        curSelectedObj = i;
                }
                if (curSelectedObj == i)
                    i = curSelectedObj;
            }
        }
        if (stageFile.sprites.createdSprites != null) {
            for (i in stageFile.sprites.createdSprites) {
                if (FlxG.mouse.overlaps(stageSprites) && !FlxG.mouse.overlaps(daUIBox)) {
                    if (FlxG.mouse.justPressed)
                        curSelectedObj = i;
                }
                if (i == curSelectedObj)
                    i = curSelectedObj;
            }
        }
        if (stageFile.sprites.animatedSprites != null) {
            for (i in stageFile.sprites.animatedSprites) {
                if (FlxG.mouse.overlaps(stageSprites) && !FlxG.mouse.overlaps(daUIBox)) {
                    if (FlxG.mouse.justPressed)
                        curSelectedObj = i;
                }
                if (i == curSelectedObj)
                    i = curSelectedObj;
            }
        }

        //moving sprites
		if (FlxG.keys.justPressed.LEFT) {
            if (FlxG.keys.pressed.SHIFT)
                curSelectedObj.positions[0] -= 10;
            else
			    curSelectedObj.positions[0] -= 1;
		}
		if (FlxG.keys.justPressed.RIGHT) {
            if (FlxG.keys.pressed.SHIFT)
                curSelectedObj.positions[0] += 10;
            else
			    curSelectedObj.positions[0] += 1;
		}
		if (FlxG.keys.justPressed.UP) {
            if (FlxG.keys.pressed.SHIFT)
                curSelectedObj.positions[1] -= 10;
            else
			    curSelectedObj.positions[1] -= 1;
		}
		if (FlxG.keys.justPressed.DOWN) {
            if (FlxG.keys.pressed.SHIFT)
                curSelectedObj.positions[1] += 10;
            else
			    curSelectedObj.positions[1] += 1;
		}
    }

	function addStageUI(type:String):Void {
        var typeDD = new FlxUIDropDownMenu(140, 150, FlxUIDropDownMenu.makeStrIdLabelArray(stageTypes, true), function(type:String)
        {
            addStageUI(stageTypes[Std.parseInt(type)]);
        });

        typeDD.selectedLabel = 'Image';
        switch(type) {
            case 'Image':
                var stageImgTxt = new FlxInputText(0, 0, 150, curSelectedObj.image);
                var reloadImg = new FlxUIButton(300, 400, 'Reload Stage', function() {
                    curSelectedObj.image = stageImgTxt.text;
                });
        
                var tab_group_stage = new FlxUI(null, daUIBox);
                tab_group_stage.name = "Stage";
                tab_group_stage.add(stageImgTxt);
                tab_group_stage.add(reloadImg);
                tab_group_stage.add(reloadImg);
                tab_group_stage.add(typeDD);
                daUIBox.addGroup(tab_group_stage);
                daUIBox.scrollFactor.set();
            case 'Animated':
                var stageImgTxt = new FlxInputText(0, 0, 150, curSelectedObj.image);
                var reloadImg = new FlxUIButton(300, 400, 'Reload Stage', function() {
                    curSelectedObj.image = stageImgTxt.text;
                });
        
                var tab_group_stage = new FlxUI(null, daUIBox);
                tab_group_stage.name = "Stage";
                tab_group_stage.add(stageImgTxt);
                tab_group_stage.add(reloadImg);
                tab_group_stage.add(reloadImg);
                tab_group_stage.add(typeDD);
                daUIBox.addGroup(tab_group_stage);
                daUIBox.scrollFactor.set();
            case 'Created':
                var reloadImg = new FlxUIButton(300, 400, 'Reload Stage', function() {
                    
                });
        
                var tab_group_stage = new FlxUI(null, daUIBox);
                tab_group_stage.name = "Stage";
                tab_group_stage.add(reloadImg);
                tab_group_stage.add(reloadImg);
                tab_group_stage.add(typeDD);
                daUIBox.addGroup(tab_group_stage);
                daUIBox.scrollFactor.set();
        }
    }

    function addStageDisplay():Void {
        if (stageFile.sprites.images != null) {
            for (img in stageFile.sprites.images) {
                var image:FlxSprite = new FlxSprite(img.positions[0], img.positions[1]).loadGraphic(FunkinPaths.image('stages/$stageName/${img.image}'));
                if (img.angle != null)
                    image.angle = img.angle;
                if (img.width != null)
                    image.width = img.width;
                if (img.height != null)
                    image.height = img.height;
                if (img.color != null)
                    image.color = FlxColor.fromRGB(img.color[0], img.color[1], img.color[2]);
                if (img.scrollFactor != null)
                    image.scrollFactor.set(img.scrollFactor[0], img.scrollFactor[1]);
                if (img.active != null)
                    image.active = img.active;
                if (img.scale != null)
                    image.scale.set(img.scale[0], img.scale[1]);
                if (img.antialiasing != false)
                    image.antialiasing = Preferences.antialiasing;
                stageSprites.add(image);
            }
        }

        if (stageFile.sprites.createdSprites != null) {
            for (swag in stageFile.sprites.createdSprites) {
                var swagSpr:FlxSprite = new FlxSprite(swag.positions[0], swag.positions[1]).makeGraphic(swag.width, swag.height, FlxColor.fromRGB(swag.color[0], swag.color[1], swag.color[2]));
                swagSpr.angle = swag.angle;
                if (swag.active != null)
                    swagSpr.active = swag.active;
                if (swag.scrollFactor != null)
                    swagSpr.scrollFactor.set(swag.scrollFactor[0], swag.scrollFactor[1]);
                if (swag.scale != null)
                    swagSpr.scale.set(swag.scale[0], swag.scale[1]);
                stageSprites.add(swagSpr);
            }
        }

        if (stageFile.sprites.animatedSprites != null) {
            for (animSpr in stageFile.sprites.animatedSprites) {
                var anim:FlxSprite = new FlxSprite(animSpr.positions[0], animSpr.positions[1]);
                anim.frames = FunkinPaths.sparrowAtlas('stages/$stageName/${animSpr.image}');
                for (i in 0...animSpr.animations.length) {
                    anim.animation.addByPrefix(animSpr.animations[i].name, animSpr.animations[i].prefix, animSpr.animations[i].framerate);
                    if (animSpr.animations[i].defaultAnim)
                        anim.animation.play(animSpr.animations[i].name);
                }
                if (animSpr.angle != null)
                    anim.angle = animSpr.angle;
                if (animSpr.width != null)
                    anim.width = animSpr.width;
                if (animSpr.height != null)
                    anim.height = animSpr.height;
                if (animSpr.color != null)
                    anim.color = FlxColor.fromRGB(animSpr.color[0], animSpr.color[1], animSpr.color[2]);
                if (animSpr.scrollFactor != null)
                    anim.scrollFactor.set(animSpr.scrollFactor[0], animSpr.scrollFactor[1]);
                if (animSpr.active != null)
                    anim.active = animSpr.active;
                if (animSpr.scale != null)
                    anim.scale.set(animSpr.scale[0], animSpr.scale[1]);
                if (animSpr.antialiasing != false)
                    anim.antialiasing = Preferences.antialiasing;
                stageSprites.add(anim);
            }
        }
    }
    function updateDisplay():Void {
        stageSprites.forEach(function(spr:FlxSprite) {
            if (stageFile.sprites.images != null) {
                for (img in stageFile.sprites.images) {
                    if (img.angle != null)
                        spr.angle = img.angle;
                    if (img.width != null)
                        spr.width = img.width;
                    if (img.height != null)
                        spr.height = img.height;
                    if (img.color != null)
                        spr.color = FlxColor.fromRGB(img.color[0], img.color[1], img.color[2]);
                    if (img.scrollFactor != null)
                        spr.scrollFactor.set(img.scrollFactor[0], img.scrollFactor[1]);
                    if (img.active != null)
                        spr.active = img.active;
                    if (img.scale != null)
                        spr.scale.set(img.scale[0], img.scale[1]);
                    if (img.antialiasing != false)
                        spr.antialiasing = Preferences.antialiasing;
                }
            }
            if (stageFile.sprites.createdSprites != null) {
                for (swag in stageFile.sprites.createdSprites) {
                    spr.angle = swag.angle;
                    if (swag.active != null)
                        spr.active = swag.active;
                    if (swag.scrollFactor != null)
                        spr.scrollFactor.set(swag.scrollFactor[0], swag.scrollFactor[1]);
                    if (swag.scale != null)
                        spr.scale.set(swag.scale[0], swag.scale[1]);
                }
            }
            if (stageFile.sprites.animatedSprites != null) {
                for (animSpr in stageFile.sprites.animatedSprites) {
                    spr.frames = FunkinPaths.sparrowAtlas('stages/$stageName/${animSpr.image}');
                    for (i in 0...animSpr.animations.length) {
                        spr.animation.addByPrefix(animSpr.animations[i].name, animSpr.animations[i].prefix, animSpr.animations[i].framerate);
                        if (animSpr.animations[i].defaultAnim)
                            spr.animation.play(animSpr.animations[i].name);
                    }
                    if (animSpr.angle != null)
                        spr.angle = animSpr.angle;
                    if (animSpr.width != null)
                        spr.width = animSpr.width;
                    if (animSpr.height != null)
                        spr.height = animSpr.height;
                    if (animSpr.color != null)
                        spr.color = FlxColor.fromRGB(animSpr.color[0], animSpr.color[1], animSpr.color[2]);
                    if (animSpr.scrollFactor != null)
                        spr.scrollFactor.set(animSpr.scrollFactor[0], animSpr.scrollFactor[1]);
                    if (animSpr.active != null)
                        spr.active = animSpr.active;
                    if (animSpr.scale != null)
                        spr.scale.set(animSpr.scale[0], animSpr.scale[1]);
                    if (animSpr.antialiasing != false)
                        spr.antialiasing = Preferences.antialiasing;
                }
            }
        });
    }
}