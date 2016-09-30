package citizenofmelee.superbug.playstate;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Bacteria extends FlxSprite {
    public function new(x, y, dna: Array<Float>) {
         super(x, y);
         makeGraphic(32, 32, FlxColor.BLUE);
     }
}