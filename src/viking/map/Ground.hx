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

		//_mapHeightInCells = heightInTiles;
		//_mapWidthInCells = widthInTiles;
//
		//_groundObjects = new Vector.<GroundTile3D>();
		/*var count:Int = 0;
		for (row in 0...2) {
			for (col in 0...2) {
				count++;
				var mapObj:GroundTile = new GroundTile(id, count, row, col);
				mapObj.x = col * Settings.MAP_CELL_SIZE + offsetX;
				mapObj.y = row * Settings.MAP_CELL_SIZE + offsetY;
				//_groundObjects.push(mapObj);
				addChild(mapObj);
			}
		}*/
		
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
	
}