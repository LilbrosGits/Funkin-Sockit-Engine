package funkin.system;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.ui.FlxUIState;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import openfl.system.System;

class MusicBeatState extends FlxUIState {
    var beats:Int = 0;
    var steps:Int = 0;

    override public function create() {
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileSquare);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
        System.gc();
        super.create();
    }

    override public function update(elapsed:Float)
    {
        var safeSteps = steps; // baby stepss
        updateStep();
        updateBeat();
        if (safeSteps != steps && steps > 0)
        {
            onStep();
        }
        super.update(elapsed);
    }

    public function updateStep()
    {
        steps = Math.floor(Conductor.songPos / Conductor.stepCrochet);
    }

    public function updateBeat()
    {
        beats = Math.floor(steps / 4);
    }

    public function onStep()
    {
        if (steps % 4 == 0)
            onBeat();
    }

    public function onBeat()
    {
        // handled in game
    }
}

class MusicBeatSubState extends FlxSubState {
    var beats:Int = 0;
    var steps:Int = 0;

    public function new() {
        super();
    }

    override public function update(elapsed:Float)
    {
        var safeSteps = steps; // baby stepss
        updateStep();
        updateBeat();
        if (safeSteps != steps && steps > 0)
        {
            onStep();
        }
        super.update(elapsed);
    }

    public function updateStep()
    {
        steps = Math.floor(Conductor.songPos / Conductor.stepCrochet);
    }

    public function updateBeat()
    {
        beats = Math.floor(steps / 4);
    }

    public function onStep()
    {
        if (steps % 4 == 0)
            onBeat();
    }

    public function onBeat()
    {
        // handled in game
    }
}