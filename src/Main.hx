package;

import openfl.display.StageScaleMode;
import openfl.display.Sprite;
import viking.test.TestAtlas;
import viking.test.TestFonts;


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
		
		init();
	}
	
	private function init():Void
	{
		addChild(new TestAtlas());
		
	}
	

}