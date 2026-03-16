package funkin.data;

import funkin.data.Song.EventData;
import funkin.backend.scripts.FunkinImport;
import scripts.SockitScript;

class ScriptedEvent {
    public var script:SockitScript;
    public var data:Null<EventData>;
    public function new(eventName:String) {
        data.name = eventName;
    }
    public function loadEvent() {
        script = new SockitScript('data/scripts/events/${data.name}');
        FunkinImport.setImports(script);
        script.execute();
    }
}