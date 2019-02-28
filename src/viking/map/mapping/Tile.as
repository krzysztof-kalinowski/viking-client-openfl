package com.taern.map.pathfinding {

public class Tile {

	public static var SIZE:Number = 20 //* MapManager3D.MAP_SCALE_FOR_ZOOM;
//    public static var SIZE:Number = 0.20;

	//should be private
	public var xPos:Number = 0;
	public var yPos:Number = 0;
	public var G:Number = 0;
	public var H:Number = 0;
	public var F:Number = 0;
	public var dir:Number = 0;
	public var parentTile:Tile;
	public var dirCount:Number = 0;

	//---------------------------------------------------------
	function Tile(myxpos:Number, myypos:Number, myG:Number, myH:Number, myF:Number) {
		this.xPos = myxpos;
		this.yPos = myypos;
		this.G = myG;
		this.H = myH;
		this.F = myF;
	}
}
}
