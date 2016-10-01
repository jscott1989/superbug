package citizenofmelee.superbug.playstate;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
using flixel.util.FlxSpriteUtil;

class Bacteria extends FlxSprite {

    static var BASE_HEIGHT = 300;
    static var BORDER_SCALE = 1.5;
    static var BASE_OBJECT_SIZE = 60;

    // Record DNA positions
    static var DNA_SIZE = 10;
    static var HEIGHT_SCALE = 0;
    static var WIDTH_SCALE = 1;
    static var COLOUR = 2;
    static var OVERLAY_RANDOM_SEED = 3;
    static var DARKNESS = 4;
    static var OBJECT_SIZE = 5;
    static var SHAPE = 6;
    static var MIDPOINT_DISPLACEMENTS = 7;
    static var COMPRESS_SIZE = 8;

    static var NUMBER_OF_OVERLAY_OBJECTS = 1000;

    static var IDLE_ANIMATION_FRAMES = 5;
    static var IDLE_ANIMATION_FPS = 2;

    var dna:Array<Float>;

    public function new(x, y, dna: Array<Float>=null) {
        if (dna == null) {
            var r = new FlxRandom();
            dna = new Array<Float>();
            for (i in 0...DNA_SIZE) {
                dna.push(r.float());
            }
        }
        this.dna = dna;
        super(x, y);
        generateImage();
        animation.play("idle");
     }

     function getColour(colourF:Float) {
         return FlxColor.RED.getLightened(0.7);
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

        // TODO: Right now we only have idle animations
        // When we have more increase the overall size
        makeGraphic(frameWidth * IDLE_ANIMATION_FRAMES, frameHeight, FlxColor.TRANSPARENT, true);

        var basePoints = generateBasePoints(width, height, frameWidth, frameHeight);

        // Generate each frame
        for (i in 0...IDLE_ANIMATION_FRAMES) {
            renderFrame(i, frameWidth, frameHeight, generateIdleFrame(frameWidth, frameHeight, basePoints.copy(), i));
        }

        // Reload and set up animations
        loadGraphic(this.graphic, true, frameWidth, frameHeight, true);

        // TODO: There has to be a better way to do this...
        var frameNumbers = new Array<Int>();
        for (i in 0...IDLE_ANIMATION_FRAMES) {
            frameNumbers.push(i);
        }

        var reversed = frameNumbers.copy();
        reversed.reverse();
        reversed.shift();
        reversed.pop();
        frameNumbers = frameNumbers.concat(reversed);

        animation.add("idle", frameNumbers, IDLE_ANIMATION_FPS, true);
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

    // function renderFrame(offsetIndex:Int, frameWidth:Int, frameHeight:Int, points:Array<FlxPoint>) {
    //     var offsetX = (offsetIndex * frameWidth);
    //     points = offsetPoints(points, offsetX);
    //     drawPolygon(points, FlxColor.RED);
    // }

     function renderFrame(offsetIndex:Int, frameWidth:Int, frameHeight:Int, points:Array<FlxPoint>) {
         var random = new FlxRandom(Math.floor(dna[OVERLAY_RANDOM_SEED] * 100));
         var tmpFrame = new FlxSprite();
         var offsetX = (offsetIndex * frameWidth);
         tmpFrame.makeGraphic(frameWidth, frameHeight, FlxColor.TRANSPARENT, true);

        tmpFrame.drawPolygon(points, FlxColor.RED);
        points = offsetPoints(points, offsetX);

        var objectSize = BASE_OBJECT_SIZE * (dna[OBJECT_SIZE] + 0.5);
        var colour = getColour(dna[COLOUR]);

        for (i in 0...NUMBER_OF_OVERLAY_OBJECTS) {
            var randomPositionX = random.int(0, frameWidth);
            var randomPositionY = random.int(0, frameHeight);

            if (tmpFrame.pixels.getPixel(randomPositionX, randomPositionY) == 16711680) {
                // This hasn't been drawn on - check that this drawing wouldn't go off the canvas and if it's fine - draw

                if (randomPositionX - objectSize / 2 > 0 && randomPositionY - objectSize / 2 > 0 && randomPositionX + objectSize / 2 < frameWidth && randomPositionY + objectSize / 2 < frameHeight) {
                    var darkenedColour = colour.getDarkened(random.float(0, 0.8) * (dna[DARKNESS] + 0.5));
                    drawRoundRect(offsetX + randomPositionX - objectSize / 2, randomPositionY - objectSize / 2, objectSize, objectSize, objectSize * 0.1, objectSize * 0.1, darkenedColour);
                    tmpFrame.drawRoundRect(randomPositionX - objectSize / 2, randomPositionY - objectSize / 2, objectSize, objectSize, objectSize * 0.1, objectSize * 0.1, darkenedColour);
                }
            }
        }
     }

     /**
      * Modify the given points for idle animation
      */
     function generateIdleFrame(frameWidth:Float, frameHeight:Float, points:Array<FlxPoint>, frame:Int) {
         var smallest_size = (dna[COMPRESS_SIZE] * 0.5) + 0.4;

         var amount_to_shrink = (frame / IDLE_ANIMATION_FRAMES) * (1 - smallest_size); 

        //  Now each point needs to move amount_to_shrink % towards the centre

        var centrePoint = new FlxPoint(frameWidth / 2, frameHeight / 2);

        return Lambda.array(Lambda.map(points, function(p) {

            var angle = p.angleBetween(centrePoint);

            p.y -=  Math.cos(angle) * 10;
            p.x += Math.sin(angle) * 10;
            return p;
        }));
     }
}