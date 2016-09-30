package citizenofmelee.superbug.playstate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

class PlayState extends FlxState {
	override public function create():Void {
		super.create();

        var f = new FlxSprite(0, 0);
        f.loadGraphic(AssetPaths.tmpbg__png);
        add(f);
		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
