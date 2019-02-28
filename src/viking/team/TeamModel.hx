package viking.team;
import viking.map.MapManager;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class TeamModel 
{
	
	private var _x:Float;
	private var _y:Float;
	private var _team:Team;
	
	public function new(x:Float, y:Float) 
	{
		_x = x;
		_y = y;
	}
	
	public function initTeamView():Void {

		_team = MapManager.getInstance().map.createTeam(this);
		//_highlightFlag = true;
		//_selectedFlag = false;
		setPosition(_x, _y);
		//setModelRotation();
		//_team3D.tweenAlpha(1, 0);
	}
	
	public function setPosition(x:Float, y:Float):Void
	{
		_team.x = x;
		_team.y = y;
	}
	
}