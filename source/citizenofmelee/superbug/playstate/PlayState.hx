package citizenofmelee.superbug.playstate;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class PlayState extends FlxState {

	var movingFrom: {startX:Float, startY:Float, moveFromX: Float, moveFromY: Float};

	override public function create():Void {
		super.create();

		var background = new FlxSprite(0, 0);
		background.loadGraphic(AssetPaths.dish__png);
		add(background);

		var r = new FlxRandom();
		var dna = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0];
		var lastBacteria = new Bacteria(100, 300, dna);
		for (i in 0...10) {
			add(lastBacteria);
			lastBacteria = new Bacteria(lastBacteria.x + lastBacteria.width + 50, 300);
		}
		super.create();
		setCameraZoom(0.5);
	}

	function setCameraZoom(newZoom:Float) {
		var centrePoint = new FlxPoint(FlxG.camera.scroll.x + FlxG.camera.width / 2, FlxG.camera.scroll.y + FlxG.camera.height / 2);
		FlxG.cameras.reset(new FlxCamera(0, 0, Math.floor(FlxG.width * (1/newZoom)), Math.floor(FlxG.height * (1/newZoom)), newZoom));
		FlxG.camera.scroll.x = centrePoint.x - FlxG.camera.width / 2;
		FlxG.camera.scroll.y = centrePoint.y - FlxG.camera.height / 2;
		FlxG.camera.antialiasing = true;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.mouse.wheel != 0) {
			// Mouse wheel logic goes here, for example zooming in / out:
			var newZoom = FlxG.camera.zoom + (FlxG.mouse.wheel / 10);
			var maxZoom = 1.0;
			var minZoom = 0.1;
			if (newZoom >= minZoom && newZoom <= maxZoom) {
				setCameraZoom(newZoom);
			}
		}

		if (movingFrom != null) {
			if (!FlxG.mouse.pressed) {
				movingFrom = null;
			} else {
				var newX = movingFrom.startX - (FlxG.mouse.screenX - movingFrom.moveFromX);
				if (FlxG.camera.scroll.x != newX) { FlxG.camera.scroll.x = newX; }
				var newY = movingFrom.startY - (FlxG.mouse.screenY - movingFrom.moveFromY);
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
