package;

import openfl.display.StageScaleMode;
import openfl.display.Sprite;
import viking.map.Ground;
import viking.map.GroundData;
import viking.map.Map;



/**
 * ...
 * @author Krzysztof Kalinowski
 */
class Main extends Sprite 
{

	public function new() 
	{
		this.stage.scaleMode = StageScaleMode.NO_SCALE;
		super();
		//testGround();
		testMap();
	}
	
	public function testMap():Void
	{
		var map = new Map();
		addChild(map);
		map.createGround(GroundData.parse("279;TestName;3;2;0.0;0.0"));
		
	}
	
	public function testGround():Void
	{
		var ground = new Ground();
		addChild(ground);
		ground.createMap(279, 3, 2);
		
	}

}