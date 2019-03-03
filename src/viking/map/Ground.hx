package viking.map;

import openfl.display.Sprite;
import viking.config.Settings;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class Ground extends Sprite 
{

	public function new() 
	{
		super();
		
	}
	
	public function createMap(id:Int, widthInTiles:Int, heightInTiles:Int, offsetX:Float = 0.0, offsetY:Float = 0.0):Void {	
		var count:Int = 1;
		var row:Int = 0;
		var col:Int = 0;
		while (row < heightInTiles) 
		{
			while (col < widthInTiles) 
			{
				var mapObj:GroundTile = new GroundTile(id, count, row, col);
				mapObj.x = col * Settings.MAP_CELL_SIZE + offsetX;
				mapObj.y = row * Settings.MAP_CELL_SIZE + offsetY;
				//_groundObjects.push(mapObj);
				addChild(mapObj);
				count++;
				col++;
			}
			col = 0;
			row++;
		}	
		
	}
	
	public function dispose():Void
	{
		
	}
	
}