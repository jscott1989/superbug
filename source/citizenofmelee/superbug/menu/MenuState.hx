package citizenofmelee.superbug.menu;

import flixel.FlxState;
import flixel.FlxG;
import citizenofmelee.superbug.playstate.PlayState;

class MenuState extends FlxState {
	override public function create():Void {
        FlxG.switchState(new PlayState());
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
