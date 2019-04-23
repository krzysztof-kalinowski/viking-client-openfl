package viking.map;

import flash.geom.Point;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import viking.core.Disposable;
import viking.team.Team;
import viking.team.TeamModel;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class Map extends Sprite implements Disposable
{
	private var _groundView:Ground;
	
	private var _point:Point = new Point();
	
	
	public function new() 
	{
		super();
		
	}
	
	
	public function createTeam(teamModel:TeamModel):Team
	{
		var team:Team = new Team(teamModel);
		addChild(team);
		return team;
	}
	
	
	public function createGround(data:GroundData):Void 
	{
		_groundView = new Ground();
		addChild(_groundView);
		
		_groundView.createMap(data.idArea, data.widthInTiles, data.heightInTiles, data.offsetX, data.offsetY);
		
		//addGroundListeners();
	}
	
	private function addGroundListeners():Void 
	{
		//_groundView.addEventListener(MouseEvent.CLICK, onGroundClickHandler);
		//_groundView.addEventListener(MouseEvent.MOUSE_MOVE, onGroundMoveHandler);
	}
	
	private function onGroundClickHandler(e:MouseEvent):Void {
		//var row:int = cast(e.relatedObject.parent, GroundTile).row;
		//var col:int = cast(e.relatedObject.parent, GroundTile).column;
		var row:Int = cast(e.relatedObject, GroundTile).row;
		var col:Int = cast(e.relatedObject, GroundTile).column;
		
		CoordinatesHelper.getTile(_point, e.localX, e.localY, row, col);
		//clicked.dispatch(_point.x, _point.y);
	}
	
	public function dispose()
	{
		
	}
	
}