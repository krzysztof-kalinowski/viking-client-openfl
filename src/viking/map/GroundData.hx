package viking.map;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class GroundData 
{
	public var idArea(get, null):Int;
	public var nameArea(get, null):String;
	
	public var widthInTiles(get, null):Int;
	public var heightInTiles(get, null):Int;

	public var offsetX(get, null):Float;
	public var offsetY(get, null):Float;
	
	public function new(idArea:Int, nameArea:String, groundWidth:Int, groundHeight:Int, offsetX:Float, offsetY:Float) 
	{
		this.idArea = idArea;
		this.nameArea = nameArea;
		this.widthInTiles = groundWidth;
		this.heightInTiles = groundHeight;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}
	
	public static function parse(raw:String):GroundData
	{
		var a = raw.split(";");
		return new GroundData(Std.parseInt(a[0]), a[1], Std.parseInt(a[2]), Std.parseInt(a[3]), Std.parseFloat(a[4]), Std.parseFloat(a[5]));
	}
	
	function get_idArea():Int 
	{
		return idArea;
	}
	
	function get_nameArea():String 
	{
		return nameArea;
	}
	
	function get_widthInTiles():Int 
	{
		return widthInTiles;
	}
	
	function get_heightInTiles():Int 
	{
		return heightInTiles;
	}
	
	function get_offsetX():Float 
	{
		return offsetX;
	}
	
	function get_offsetY():Float 
	{
		return offsetY;
	}
	

}