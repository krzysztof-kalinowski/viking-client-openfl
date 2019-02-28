package;

import openfl.display.Sprite;
import viking.map.Ground;



/**
 * ...
 * @author Krzysztof Kalinowski
 */
class Main extends Sprite 
{

	public function new() 
	{
		super();
		testGround();
	}
	
	public function testGround():Void
	{
		var ground = new Ground();
		addChild(ground);
		ground.createMap(279, 3, 2);
	}

}
