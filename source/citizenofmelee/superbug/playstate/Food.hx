package citizenofmelee.superbug.playstate;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Food extends FlxSprite {
    public function new(x, y) {
        super(x, y);
        makeGraphic(10, 10, FlxColor.BLUE);
    }
}