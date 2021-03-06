package citizenofmelee.superbug.playstate;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import openfl.geom.Rectangle;
import openfl.geom.Point;
using flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.system.FlxSound;

class Bacteria extends FlxSprite {

    var state:BacteriaState;

    static var COLOURS = [
        FlxColor.fromString("#D7031C"),
        FlxColor.fromString("#E3573C"),
        FlxColor.fromString("#EA640B"),
        FlxColor.fromString("#F3994D"),
        FlxColor.fromString("#FFE401"),
        FlxColor.fromString("#FEED59"),
        FlxColor.fromString("#B4CB01"),
        FlxColor.fromString("#CCD755"),
        FlxColor.fromString("#32A42B"),
        FlxColor.fromString("#7FBB5B"),
        FlxColor.fromString("#06A199"),
        FlxColor.fromString("#67BCB7"),
        FlxColor.fromString("#14ACDE"),
        FlxColor.fromString("#77C2E9"),
        FlxColor.fromString("#006BB3"),
        FlxColor.fromString("#2C89C6"),
        FlxColor.fromString("#503A8D"),
        FlxColor.fromString("#7C68A7"),
        FlxColor.fromString("#7F378B"),
        FlxColor.fromString("#9E6CA7"),
        FlxColor.fromString("#A90C5D"),
        FlxColor.fromString("#CC5688"),
        FlxColor.fromString("#E2006C"),
        FlxColor.fromString("#E87392")
    ];

    static var EAT_SOUND: FlxSound;

    static var BASE_HEIGHT = 300;
    static var BORDER_SCALE = 2;
    static var BASE_OBJECT_SIZE = 60;
    static var IDLE_ANIMATION_FRAMES_BASE = 8;
    static var IDLE_ANIMATION_FPS_BASE = 20;
    static var MUTATION_RATE = 0.05;

    static var MAX_STEERING_BASE = 1;
    static var MAX_VELOCITY_BASE = 100;

    // Record DNA positions
    static var DNA_SIZE = 20;
    static var HEIGHT_SCALE = 0;
    static var WIDTH_SCALE = 1;
    static var COLOUR = 2;
    static var OVERLAY_RANDOM_SEED = 3;
    static var DARKNESS = 4;
    static var OBJECT_SIZE = 5;
    static var SHAPE = 6;
    static var MIDPOINT_DISPLACEMENTS = 7;
    static var COMPRESS_SIZE = 8;
    static var WALL_THICKESS = 9;
    static var SQUARE_LIKELIHOOD = 10;
    static var CIRCLE_LIKELIHOOD = 11;
    static var IDLE_ANIMATION_FRAMES = 12;
    static var IDLE_ANIMATION_FPS = 13;
    static var MAX_STEERING = 14;
    static var MAX_VELOCITY = 15;

    static var NUMBER_OF_OVERLAY_OBJECTS = 1000;

    var dna:Array<Float>;

    public var playState:PlayState;

    public function seek(target:FlxPoint) {
        var max_velocity = MAX_VELOCITY_BASE * (dna[MAX_VELOCITY] * 2 + 0.1);
        var max_steering = MAX_STEERING_BASE * (dna[MAX_STEERING] * 2 + 0.1);

        var mid = getGraphicMidpoint();

        var desired_velocity = new FlxVector(target.x - mid.x, target.y - mid.y).normalize().scale(max_velocity);
        var steering = new FlxVector(desired_velocity.x - _velocity.x, desired_velocity.y - _velocity.y);
        steering.truncate(max_steering);
        steering.x /= mass;
        steering.y /= mass;

        return steering;
    }

    public function flee(target:FlxPoint) {
        var max_velocity = MAX_VELOCITY_BASE * (dna[MAX_VELOCITY] * 2 + 0.1);
        var max_steering = MAX_STEERING_BASE * (dna[MAX_STEERING] * 2 + 0.1);

        var mid = getGraphicMidpoint();

        var desired_velocity = new FlxVector(mid.x - target.x, mid.y - target.y).normalize().scale(max_velocity);
        var steering = new FlxVector(desired_velocity.x - _velocity.x, desired_velocity.y - _velocity.y);
        steering.truncate(max_steering);
        steering.x /= mass;
        steering.y /= mass;

        return steering;
    }

    public function addSteering(steering:FlxVector) {
        var max_velocity = MAX_VELOCITY_BASE * (dna[MAX_VELOCITY] * 2 + 0.1);
        _velocity.x += steering.x;
        _velocity.y += steering.y;
        _velocity.truncate(max_velocity);
    }
    
    var _velocity = new FlxVector(0, 0);
    public override function update(elapsed:Float) {
        // Now see if any food is in the centre of the bacteria
        var mid = getGraphicMidpoint();
        var minX = mid.x - width * 0.2;
        var maxX = mid.x + width * 0.2;
        var minY = mid.y - height * 0.2;
        var maxY = mid.y + height * 0.2;

        for (food in playState.food) {
            var foodPosition = food.getGraphicMidpoint();
            if (foodPosition.x > minX && foodPosition.x < maxX && foodPosition.y > minY && foodPosition.y < maxY) {
                // eat it
                EAT_SOUND.play();
                playState.food.remove(food);
                food.destroy();
            }
        }
        
        state.update(this, elapsed);

        x += (_velocity.x * elapsed);
        y += (_velocity.y * elapsed);

        super.update(elapsed);
    }

    /**
     * Create a new bacteria at the same location with the same DNA (+ mutations)
     */
    public function createChild() {
        var random = new FlxRandom();
        var b = new Bacteria(playState, x, y, Lambda.array(Lambda.map(dna, function(n) {
            var newValue = n + random.floatNormal(0, MUTATION_RATE);
            if (newValue < 0) {
                newValue = 0 - newValue;
            }

            if (newValue > 1) {
                newValue = 1 - (newValue - 1);
            }

            return newValue;
        })));
        playState.bacteria.push(b);
        playState.add(b);
    }

    public function new(playState:PlayState, x, y, dna: Array<Float>=null) {
        if (dna == null) {
            var r = new FlxRandom();
            dna = new Array<Float>();
            for (i in 0...DNA_SIZE) {
                dna.push(r.float());
            }
        }
        this.playState = playState;
        this.dna = dna;
        super(x, y);
        generateImage();
        animation.play("idle");
        EAT_SOUND = FlxG.sound.load(AssetPaths.eat__wav);

        state = new HungryState();
     }

     function getColour(colourF:Float) {
         var c = COLOURS[Math.round(colourF * 24)];
         if (c == null) {
             trace("NULL", c, colourF);
         }
         return c;
     }

     /**
      * Generate the image including all frames of animation
      */
     function generateImage() {
        //  Figure out the frame size
        var height = BASE_HEIGHT * (dna[HEIGHT_SCALE] + 0.5);
        var width = height * (dna[WIDTH_SCALE] + 0.5);

        var frameWidth = Math.floor(width * BORDER_SCALE);
        var frameHeight = Math.floor(height * BORDER_SCALE);

        var pattern = generatePattern(frameWidth, frameHeight);

        // TODO: Right now we only have idle animations
        // When we have more increase the overall size
        var frames = Math.floor(IDLE_ANIMATION_FRAMES_BASE * (dna[IDLE_ANIMATION_FRAMES] + 0.5));
        makeGraphic(frameWidth * frames, frameHeight, FlxColor.TRANSPARENT, true);

        var basePoints = generateBasePoints(width, height, frameWidth, frameHeight);

        // Generate each frame
        for (i in 0...frames) {
            renderFrame(i, frameWidth, frameHeight, pattern, generateIdleFrame(frameWidth, frameHeight, basePoints.copy(), i));
        }

        // Reload and set up animations
        loadGraphic(this.graphic, true, frameWidth, frameHeight, true);

        // TODO: There has to be a better way to do this...
        var frameNumbers = new Array<Int>();
        for (i in 0...frames) {
            frameNumbers.push(i);
        }

        var reversed = frameNumbers.copy();
        reversed.reverse();
        reversed.shift();
        reversed.pop();
        frameNumbers = frameNumbers.concat(reversed);

        var fps = Math.floor(IDLE_ANIMATION_FPS_BASE * (dna[IDLE_ANIMATION_FPS] + 0.5));

        animation.add("idle", frameNumbers, fps, true);
     }

     function generateBasePoints(width:Float, height:Float, frameWidth:Float, frameHeight:Float) {
         var midPoint = new FlxPoint(frameWidth / 2, frameHeight / 2);
         var points = [
            new FlxPoint(midPoint.x - width / 2, midPoint.y - height / 2),
            new FlxPoint(midPoint.x + width / 2, midPoint.y - height / 2),
            new FlxPoint(midPoint.x + width / 2, midPoint.y + height / 2),
            new FlxPoint(midPoint.x - width / 2, midPoint.y + height / 2)
        ];

        var random = new FlxRandom(Math.floor(dna[SHAPE] * 100));
        var max_displacement = ((frameWidth - width) * 0.3);

        for (x in 0...Math.floor((dna[MIDPOINT_DISPLACEMENTS] * 5) + 3)) {
            var newPoints = [];

            for (i in 0...points.length) {
                var point1 = points[i];
                var point2:FlxPoint;
                if (i == points.length - 1) {
                    // Special case, the two points are 0 and the last point
                    point2 = points[0];
                } else {
                    // The two points are i and i + 1
                    point2 = points[i + 1];
                }

                var newPoint = new FlxPoint((point1.x + point2.x) / 2, (point1.y + point2.y) / 2);

                var angle = (point1.angleBetween(point2) + 90) * Math.PI / 180;
                var d = random.float(-max_displacement, max_displacement);
                max_displacement *= 0.9;

                newPoint.y -=  Math.cos(angle) * d;
                newPoint.x += Math.sin(angle) * d;

                newPoints.push(points[i]);
                newPoints.push(newPoint);
            }

            points = newPoints;
        }
        
        return points;
     }

     function offsetPoints(points:Array<FlxPoint>, xOffset=0, yOffset=0) {
         return Lambda.array(Lambda.map(points, function(p) { return new FlxPoint(xOffset + p.x, yOffset + p.y); }));
     }

    function renderFrame(offsetIndex:Int, frameWidth:Int, frameHeight:Int, pattern:FlxSprite, points:Array<FlxPoint>) {
        var mask = new FlxSprite();
        mask.makeGraphic(frameWidth, frameHeight, FlxColor.TRANSPARENT, true);
        mask.drawPolygon(points, FlxColor.RED);

        var tmpSprite = new FlxSprite();
        tmpSprite.makeGraphic(frameWidth, frameHeight, FlxColor.TRANSPARENT, true);
        FlxSpriteUtil.alphaMaskFlxSprite(pattern, mask, tmpSprite);

        pixels.copyPixels(tmpSprite.pixels, new Rectangle(0, 0, frameWidth, frameHeight), new Point(frameWidth * offsetIndex, 0));

        points = offsetPoints(points, offsetIndex * frameWidth);

        drawPolygon(points, FlxColor.TRANSPARENT, { color: getColour(dna[COLOUR]), thickness: dna[WALL_THICKESS] * 8 + 1 });
    }

     function generatePattern(frameWidth:Int, frameHeight:Int) {
         var random = new FlxRandom(Math.floor(dna[OVERLAY_RANDOM_SEED] * 100));
         var tmpFrame = new FlxSprite();
         tmpFrame.makeGraphic(frameWidth, frameHeight, FlxColor.TRANSPARENT, true);

        var objectSize = BASE_OBJECT_SIZE * (dna[OBJECT_SIZE] + 0.5);
        var colour = getColour(dna[COLOUR]);

        for (i in 0...NUMBER_OF_OVERLAY_OBJECTS) {
            var nextObjectType = random.float();
            var randomPositionX = random.int(0, frameWidth);
            var randomPositionY = random.int(0, frameHeight);
            var darkenedColour = colour.getDarkened(random.float(0, 0.8) * (dna[DARKNESS] + 0.5));
            if (nextObjectType < dna[SQUARE_LIKELIHOOD]) {
                tmpFrame.drawRoundRect(randomPositionX - objectSize / 2, randomPositionY - objectSize / 2, objectSize, objectSize, objectSize * 0.1, objectSize * 0.1, darkenedColour);
            } else if (nextObjectType < dna[SQUARE_LIKELIHOOD] + dna[CIRCLE_LIKELIHOOD]) {
                tmpFrame.drawCircle(randomPositionX, randomPositionY, objectSize, darkenedColour);
            } else {
                tmpFrame.drawTriangle(randomPositionX, randomPositionY, objectSize, darkenedColour);
            }
        }

        return tmpFrame;
     }

     function getAmountToShrink(frame:Int) {
         var smallestSize = (dna[COMPRESS_SIZE] * 0.5) + 0.4;
         var frames = Math.floor(IDLE_ANIMATION_FRAMES_BASE * (dna[IDLE_ANIMATION_FRAMES] + 0.5));
         return (frame / frames) * (1 - smallestSize);
     }

     /**
      * Modify the given points for idle animation
      */
     function generateIdleFrame(frameWidth:Float, frameHeight:Float, points:Array<FlxPoint>, frame:Int) {
         var amountToShrink = getAmountToShrink(frame); 

        //  Now each point needs to move amount_to_shrink % towards the centre

        var centrePoint = new FlxPoint(frameWidth / 2, frameHeight / 2);

        return Lambda.array(Lambda.map(points, function(p) {

            var angle = p.angleBetween(centrePoint);

            var amountToMove = p.distanceTo(centrePoint) * amountToShrink;
            return new FlxPoint(p.x + Math.sin(angle) * amountToMove, p.y -  Math.cos(angle) * amountToMove);
        }));
     }
}