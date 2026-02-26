package funkin.backend;

import assets.Paths;
import sys.io.File;
import funkin.data.Option;

class OptionCache {
    public static var handler:OptionHandler;
    public static var options:Map<String, Option> = [];

        public static function reloadOptions(data:Array<OptionData>) {
            if (data != null) {
                handler.options = data;
                for (opt in handler.options) {
                    trace(opt);
                    var option:Option = new Option(opt);
                    options.set(opt.dataName, option);
                }
            }
        }

    public static function saveOptions() {
        var okay = haxe.Json.stringify(handler.options, "\t");
        File.saveContent('engine/options.data', okay);
    }

    public static function setOption(name:String, value:Dynamic) {
        if (handler != null) {
            for (i in handler.options) {
                if (i.dataName == name) {
                    i.value = value;
                    options.get(i.dataName).data.value = i.value;
                }
            }
        }
    }

    public static function getOption(name:String):OptionData {
        if (handler != null) {
            for (i in handler.options) {
                if (i.dataName == name) {
                    return i;
                }
                else
                    return options.get(name).data;
            }
        }
        return options.get(name).data;
    }
}