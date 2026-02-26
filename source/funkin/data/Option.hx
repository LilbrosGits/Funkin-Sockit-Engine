package funkin.data;

typedef OptionHandler = {
    options:Array<OptionData>
}
typedef OptionData = {
    displayName:String,
    dataName:String,
    type:String,
    value:Dynamic,
    ?scrollSpeed:Float
}

class Option {
    public var data:OptionData;

    public function new(data:OptionData) {
        this.data = data;
    }
}