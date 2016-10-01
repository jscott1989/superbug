package citizenofmelee.superbug.playstate;
import flixel.math.FlxPoint;

class HungryState extends BacteriaState {

    public function new() {

    }

    public override function update(bacteria:Bacteria, elapsed:Float) {
        // Now see if any food is in the centre of the bacteria
        var mid = bacteria.getGraphicMidpoint();
        var minX = mid.x - bacteria.width * 0.2;
        var maxX = mid.x + bacteria.width * 0.2;
        var minY = mid.y - bacteria.height * 0.2;
        var maxY = mid.y + bacteria.height * 0.2;

        for (b in bacteria.playState.bacteria) {
            if (b != bacteria) {
                bacteria.addSteering(bacteria.flee(b.getGraphicMidpoint()));
            }
        }

        for (food in bacteria.playState.food) {
            var foodPosition = food.getGraphicMidpoint();
            bacteria.addSteering(bacteria.seek(new FlxPoint(foodPosition.x, foodPosition.y)));
        }
    }
}