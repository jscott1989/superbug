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
		var firstBacteria = new Bacteria(100, 300);
		var nextX = 0.0;
		for (i in 0...10) {
			var lastBacteria = firstBacteria.createChild();
			add(lastBacteria);
			lastBacteria.x = nextX;

			// var nextY = lastBacteria.height + 100;
			// for (n in 0...10) {
			// 	var n = lastBacteria.createChild();
			// 	add(n);
			// 	n.y = nextY;
			// 	nextY += n.height;
			// }


			nextX += lastBacteria.width + 100;
		}
		super.create();
		setCameraZoom(0.5);
	}

	function setCameraZoom(newZoom:Float) {
		var centrePoint = new FlxPoint(FlxG.camera.scroll.x + FlxG.camera.width / 2, FlxG.camera.scroll.y + FlxG.camera.height / 2);
		FlxG.cameras.reset(new FlxCamera(0, 0, Math.floor(FlxG.width * (1/newZoom)), Math.floor(FlxG.height * (1/newZoom)), newZoom));
		FlxG.camera.scroll.x = correctCameraX(centrePoint.x - FlxG.camera.width / 2);
		FlxG.camera.scroll.y = correctCameraY(centrePoint.y - FlxG.camera.height / 2);
		FlxG.camera.antialiasing = true;
	}

	function correctCameraX(newX:Float) {
		var left = newX * FlxG.camera.zoom; // This has to stay above 0
		var right = newX + FlxG.camera.width; // Less than 3776
		if (left < 0) {
			newX = 0/FlxG.camera.zoom;
		} else if (right > 3776) {
			newX = 3776 - FlxG.camera.width;
		}
		return newX;
	}

	function correctCameraY(newY:Float) {
		var top = newY * FlxG.camera.zoom;
		var bottom = newY + FlxG.camera.height;

		// Special case - if we're zoomed out larger than the dish, center it
		if (FlxG.camera.height > 3776) {
			newY = 1888 - (FlxG.camera.height / 2);
		} else {
			if (top < 0) {
				newY = 0/FlxG.camera.zoom;
			} else if (bottom > 3776) {
				newY = 3776 - FlxG.camera.height;
			}
		}
		return newY;
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
				var newY = movingFrom.startY - (FlxG.mouse.screenY - movingFrom.moveFromY);

				newX = correctCameraX(newX);
				newY = correctCameraY(newY);


				if (FlxG.camera.scroll.x != newX) { FlxG.camera.scroll.x = newX; }
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
