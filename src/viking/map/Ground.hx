package viking.map;

import openfl.display.Sprite;
import viking.config.Settings;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class Ground extends Sprite 
{
	private var _groundObjects:Array<GroundTile>;
	public function new() 
	{
		super();
		
	}
	
	public function createMap(id:Int, widthInTiles:Int, heightInTiles:Int, offsetX:Float = 0.0, offsetY:Float = 0.0):Void {	
		var count:Int = 1;
		var row:Int = 0;
		var col:Int = 0;
		_groundObjects = new Array<GroundTile>();
		while (row < heightInTiles) 
		{
			while (col < widthInTiles) 
			{
				var tile:GroundTile = new GroundTile(id, count, row, col);
				tile.x = col * Settings.MAP_CELL_SIZE + offsetX;
				tile.y = row * Settings.MAP_CELL_SIZE + offsetY;
				_groundObjects.push(tile);
				addChild(tile);
				count++;
				col++;
			}
			col = 0;
			row++;
		}	
		
	}
	
	public function dispose():Void
	{
		for (tile in _groundObjects) 
		{
			removeChild(tile);
			tile.dispose();
			tile = null;
		}
		_groundObjects = null;
	}
	
}