package citizenofmelee.superbug.playstate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;

class PlayState extends FlxState {

	var movingFrom: {startX:Float, startY:Float, moveFromX: Float, moveFromY: Float};

	override public function create():Void {
		super.create();
		
		var r = new FlxRandom();
		for (i in 0...100) {
			add(new Bacteria(r.float(0, 3000),r.float(0, 3000),[]));
		}
		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (movingFrom != null) {
			if (!FlxG.mouse.pressed) {
				movingFrom = null;
			} else {
				var newX = movingFrom.startX - (FlxG.mouse.screenX - movingFrom.moveFromX);
				if (FlxG.camera.scroll.x != newX) { FlxG.camera.scroll.x = newX; }
				var newY = movingFrom.startY - (FlxG.mouse.screenY - movingFrom.moveFromY);
				trace(newX, newY);
				if (FlxG.camera.scroll.y != newY) { FlxG.camera.scroll.y = newY; }
			}
		} else if (FlxG.mouse.pressed) {
			// Start moving
			// TODO: Move this so it doesn't impact on buttons/chrome/etc
			movingFrom = {startX: FlxG.camera.scroll.x,
						  startY: FlxG.camera.scroll.y,
						  moveFromX: FlxG.mouse.screenX,
						  moveFromY: FlxG.mouse.screenY};
		}
	}
}
