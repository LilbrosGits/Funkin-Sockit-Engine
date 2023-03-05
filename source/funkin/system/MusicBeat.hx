package funkin.system;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIState;
import openfl.system.System;

class MusicBeatState extends FlxUIState {
    var beats:Int = 0;
    var steps:Int = 0;

    override public function create() {
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