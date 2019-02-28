package viking.map;

import flash.geom.Point;
import openfl.display.DisplayObjectContainer;
import openfl.events.MouseEvent;
import viking.team.Team;
import viking.team.TeamModel;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class Map extends DisplayObjectContainer 
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
	
	
	private function createGround(groundData:GroundData):Void {
		_groundView = new Ground();
		addChild(_groundView);
		
		//_groundView.createMap(groundData.idArea, groundData.width, groundData.height, groundData.offsetX2D, groundData.offsetY2D);
		
		//addGroundListeners();
	}
	
	private function addGroundListeners():void {
		_groundView.addEventListener(MouseEvent.CLICK, onGroundClickHandler);
		_groundView.addEventListener(MouseEvent.MOUSE_MOVE, onGroundMoveHandler);
	}
	
	private function onGroundClickHandler(e:MouseEvent):Void {
		//var row:int = cast(e.relatedObject.parent, GroundTile).row;
		//var col:int = cast(e.relatedObject.parent, GroundTile).column;
		var row:Int = cast(e.relatedObject, GroundTile).row;
		var col:Int = cast(e.relatedObject, GroundTile).column;
		
		CoordinatesHelper.getTile(_point, e.localX, e.localY, row, col);
		//clicked.dispatch(_point.x, _point.y);
	}
	
}