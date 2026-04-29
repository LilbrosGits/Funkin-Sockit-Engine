package funkin.data;

import funkin.data.Song.EventData;
import funkin.backend.scripts.FunkinImport;
import scripts.SockitScript;

class ScriptedEvent {
    public var script:SockitScript;
    public var data:EventData;
    public function new(eventName:String = 'FocusCamera') {
        data = {name: eventName,
        strumTime: 0,
        values: []};
    }
    public function loadEvent() {
        script = new SockitScript('data/scripts/events/${data.name}');
        FunkinImport.setImports(script);
        script.execute();
        script.call('newEvent', [data]);
        data = script.call('newEvent', [data]).returnValue;
    }
}