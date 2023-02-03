package funkin.system;

class Conductor {
    public static var bpm:Float = 100.0;
    public static var crochet:Float = ((60 / bpm) * 1000);
    public static var stepCrochet:Float = (crochet / 4) * measure;
    public static var measure:Float = 4 / 4;
    public static var songPos:Float;
    public static var safeFrames:Float = 10; //idk if its 10 my bad if its nottt
    public static var milliFrames:Float = safeFrames * 1000; //milliseconds lmao

    public function new() {}

    public static function setBPM(changedBpm:Float, measure:Float = 4 / 4) {
        bpm = changedBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = (crochet / 4) * measure;
    }

    public static function getBPM(gettingBpm:Float, getMeasure:Float = 4 / 4) {
        if (gettingBpm == bpm && getMeasure == measure) 
            return true;
        else 
            return false;
    }
}