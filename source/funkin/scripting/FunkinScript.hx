package funkin.scripting;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.states.PlayState;
import funkin.system.FunkinPaths;
import haxe.Json;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

using StringTools;

class FunkinScript {
    private var interp:Interp;
    private var expr:Expr;

    public function new() {
        interp = new Interp();
        interp.variables.set('PlayState', PlayState);
        interp.variables.set('FlxMath', FlxMath);
        interp.variables.set('FlxSprite', FlxSprite);
        interp.variables.set('FlxTween', FlxTween);
        interp.variables.set('FlxEase', FlxEase);
        interp.variables.set('FlxEase', FlxEase);
        interp.variables.set('Json', Json);
        interp.variables.set('Math', Math);
        interp.variables.set('FileSystem', sys.FileSystem);
        interp.variables.set('FunkinPaths', FunkinPaths);
        interp.variables.set('FlxG', flixel.FlxG);
    }

    public function execute(script:String) {
        // Parse the script into an hscript.Expr object
        var parser = new Parser();
        expr = parser.parseString(script);

        // Execute the script using hscript.Interp.execute
        interp.execute(expr);
    }

    public function setVar(swag:String, swagVal:Dynamic) {
        interp.variables.set(swag, swagVal);
    }

    public function executeFunc(func:String, para:Array<Dynamic>) {
        // Parse the script into an hscript.Expr object
        var parser = new Parser();
        expr = parser.parseString(func);

        // Execute the script using hscript.Interp.execute
        interp.execute(parser.parseString(func + "(" + para.join(", ") + ")"));
    }
}
