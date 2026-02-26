package funkin.backend.scripts;

import scripts.SockitScript;

class FunkinImport {
    //oh my god this looks like shit but it works
    //and yes i DID try nd put it over the funcion instead :(
    public static function setImports(script:SockitScript) {
        @:privateAccess
        script.interp.imports.set('funkin.editors.chart.ChartEditor', funkin.editors.chart.ChartEditor);
        @:privateAccess
        script.interp.imports.set('funkin.editors.sprites.SpriteEditor', funkin.editors.sprites.SpriteEditor);
        @:privateAccess
        script.interp.imports.set('funkin.meta.states.GameState', funkin.meta.states.GameState);
        @:privateAccess
        script.interp.imports.set('funkin.meta.states.PlayState', funkin.meta.states.PlayState);
    }
}