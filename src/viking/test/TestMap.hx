package viking.test;
import openfl.display.Sprite;
import viking.map.GroundData;
import viking.map.Map;

/**
 * ...
 * @author Krzysiek Kalinowski
 */
class TestMap extends Sprite 
{

	public function new() 
	{
		super();
		testMap();
	}
	
	public function testMap():Void
	{
		var map:Map = new Map();
		addChild(map);
		map.createGround(GroundData.parse("279;TestName;3;2;0.0;0.0"));
	}
	
}