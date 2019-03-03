package;

import openfl.display.StageScaleMode;
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
		this.stage.scaleMode = StageScaleMode.NO_SCALE;
		super();
		testGround();
	}
	
	public function testGround():Void
	{
		var ground = new Ground();
		addChild(ground);
		ground.createMap(279, 2, 2);
		trace("stage.width " + stage.width + " stage.height = " + stage.height);
		trace("stage.stageWidth " + stage.stageWidth + " stage.stageHeight = " + stage.stageHeight);
	}

}
