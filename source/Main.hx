package;

import flixel.FlxGame;
import openfl.display.Sprite;
import citizenofmelee.superbug.menu.MenuState;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, MenuState, 1, 60, 60, true, false));
	}
}
