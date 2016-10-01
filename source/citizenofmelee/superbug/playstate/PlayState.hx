package citizenofmelee.superbug.playstate;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
// import cpp.vm.Thread;
import neko.vm.Thread;

class PlayState extends FlxState {

	var movingFrom: {startX:Float, startY:Float, moveFromX: Float, moveFromY: Float};

	var firstBacteria:Bacteria;

	var foodGroup = new FlxSpriteGroup();
	public var bacteria = new Array<Bacteria>();
	public var food = new Array<Food>();

	override public function create():Void {
		super.create();

		var background = new FlxSprite(0, 0);
		background.loadGraphic(AssetPaths.dish__png);
		add(background);

		var menu = new FlxSprite(-10000, -10000);
		menu.loadGraphic(AssetPaths.menu_bar__png);
		add(menu);


		var happinessicon = new FlxSprite(-10000 + 10, -10000 + 10);
		happinessicon.loadGraphic(AssetPaths.happiness__png);
		add(happinessicon);

		add(foodGroup);
		
		firstBacteria = new Bacteria(this, 300, 300);
		bacteria.push(firstBacteria);
		add(firstBacteria);

		// var r = new FlxRandom();
		// var nextX = 0.0;
		// for (i in 0...1) {
		// 	var lastBacteria = firstBacteria.createChild();
		// 	lastBacteria.x = nextX;

			// var nextY = lastBacteria.height + 100;
			// for (n in 0...10) {
			// 	var n = lastBacteria.createChild();
			// 	add(n);
			// 	n.y = nextY;
			// 	nextY += n.height;
			// }


		// 	nextX += lastBacteria.width + 100;
		// }
		super.create();
		setCameraZoom(0.5);
	}

	function setCameraZoom(newZoom:Float) {
		var centrePoint = new FlxPoint(FlxG.camera.scroll.x + FlxG.camera.width / 2, FlxG.camera.scroll.y + FlxG.camera.height / 2);
		FlxG.cameras.reset(new FlxCamera(0, 0, Math.floor(FlxG.width * (1/newZoom)), Math.floor(FlxG.height * (1/newZoom)), newZoom));
		FlxG.camera.scroll.x = correctCameraX(centrePoint.x - FlxG.camera.width / 2);
		FlxG.camera.scroll.y = correctCameraY(centrePoint.y - FlxG.camera.height / 2);
		FlxG.camera.antialiasing = true;
		FlxG.camera.bgColor = FlxColor.fromString("#F3F1DC");

		// Set up the UI camera
		var uiCamera = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
		uiCamera.scroll.set(-10000, -10000);
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		uiCamera.antialiasing = true;
		FlxG.cameras.add(uiCamera);
	}

	function correctCameraX(newX:Float) {
		var left = newX * FlxG.camera.zoom; // This has to stay above 0
		var right = newX + FlxG.camera.width; // Less than 3776
		if (left < 0) {
			newX = 0;
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
			if (top < -95) {
				newY = -95/FlxG.camera.zoom;
			} else if (bottom > (3776 + 200)) {
				newY = (3776 + 200) - FlxG.camera.height;
			}
		}
		return newY;
	}

	var addBacteriaTimeout = 0.0;
	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		addBacteriaTimeout += elapsed;

		if (addBacteriaTimeout > 2) {
			addBacteriaTimeout = 0;
			var thread = Thread.create (firstBacteria.createChild);
			// firstBacteria.createChild();
		}

		// We only adjust the window if we're not on a menu
		var onMenu = false;
		var yPos = FlxG.mouse.screenY * FlxG.camera.zoom;
		if (yPos > 585 || yPos < 89) {
			onMenu = true;
		}

		if (!onMenu && FlxG.mouse.wheel != 0) {
			var newZoom = FlxG.camera.zoom + (FlxG.mouse.wheel / 60);
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
		} else if (!onMenu && FlxG.mouse.justPressed) {
			// Place food
			var f = new Food(FlxG.mouse.x, FlxG.mouse.y);
			foodGroup.add(f);
			food.push(f);

			// Start moving
			movingFrom = {startX: FlxG.camera.scroll.x,
						  startY: FlxG.camera.scroll.y,
						  moveFromX: FlxG.mouse.screenX,
						  moveFromY: FlxG.mouse.screenY};
		}
	}
}
