package com.taern.map.pathfinding {
public class PathFinder {
	public function PathFinder() {
	}

	private static var granulity:Number = 0.1;

	//FUNCS FOR A* ---------------------------------
	//----------------------------------------------
	//DESCRIPTION:
	public static function findPath(xIni:Number, yIni:Number, xFin:Number, yFin:Number, level:Array, smooth:Boolean = false):Array {
		var openList:Array = new Array();
		var closeList:Array = new Array();
		var newTile:Tile = new Tile(xIni, yIni, 0, 0, 0);
		newTile.parentTile = null;
		openList.push(newTile);
		var myLevel:Array = level;
		var camino:Array = searching(xFin, yFin, openList, closeList, myLevel, 1);
		//	trace("before smooth: "+ camino.length);
		if(camino != null && smooth)
			camino = smoothing(camino, level);
		//	trace("after smooth: "+ camino.length);
		return camino;
	}

	// it removes tiles that aren't necessery for smoother movement
	private static function smoothing(camino:Array, level:Array):Array {
		var checkPoint:Tile = camino[0];
		var currPoint:Tile = camino[1];
		var i:Number = 2;
		var c:Number = 0;
		while(i < camino.length) {
			//	trace("checking:"+camino[i].xPos+" / "+camino[i].yPos);
			if(c < 10 && walkable(checkPoint, camino[i], level)) {
				currPoint = camino[i];
				camino.splice(i - 1, 1);
				c++;
				//		trace("OK - removed previous");
			}
			else {
				checkPoint = currPoint;
				currPoint = camino[i];
				i++;
				c = 0;
				//		trace("UNWALKABLE");
			}
		}
		return camino;
	}

	private static function walkable(checkPoint:Tile, currPoint:Tile, level:Array):Boolean {
		var distX:Number = checkPoint.xPos - currPoint.xPos;
		var distY:Number = checkPoint.yPos - currPoint.yPos;
		var s:Number = Math.sqrt(distX * distX + distY * distY);
		var count:Number = s / granulity;
		for(var i:Number = 1; i < count; i++) {
			var px:Number = checkPoint.xPos - Math.round(i * (distX / count));
			var py:Number = checkPoint.yPos - Math.round(i * (distY / count));
			//	Dbg.trace("check: "+px+","+py+" / "+level[py][px]);
			if(level[py][px] <= 0)
				return false;
		}
		return true;
	}

	//----------------------------------------------------------------
	private static function searching(xFin:Number, yFin:Number, openList:Array, closeList:Array, level:Array, poziom:Number):Array {
		poziom++;
		if(openList.length == 0 || poziom > 260) {
			return undefined;
		}
		var tileMenorF:Tile = openList[0] as Tile; 			//	POPRAWIC OKREŚLENIE TYPU TUTAJ

		var switchIndex:int = 0;
		for(var a:Number = 0; a < openList.length; a++) {
			if(openList[a].F < tileMenorF.F) {
				tileMenorF = openList[a];
				switchIndex = a;
			}
			//	var camTab:Array=new Array();;
			if(openList[a].xPos == xFin) {
				if(openList[a].yPos == yFin) {
					var camino:Array = new Array();
					var tileAct:Tile = openList[a];
					camino.push(tileAct);
					while(tileAct.parentTile != null) {
						camino.push(tileAct.parentTile);
						tileAct = tileAct.parentTile;
					}
					//	camTab.push(camino);
					return camino;
				}
			}
		}

		closeList.push(tileMenorF);
		openList.splice(switchIndex, 1);
		for(var i:Number = -1; i < 2; i++) {
			for(var j:Number = -1; j < 2; j++) {
				if(i != 0 || j != 0) {
					var xTile:Number = tileMenorF.xPos + j;
					var yTile:Number = tileMenorF.yPos + i;
					var existCloseList:Boolean = false;
					for(var n:Number = 0; n < closeList.length; n++) {
						if(closeList[n].xPos == xTile && closeList[n].yPos == yTile) {
							existCloseList = true;
						}
					}
					if(yTile >= 0 && xTile >= 0 && level.length > yTile && level[yTile].length > xTile && level[yTile][xTile] > 0 && existCloseList == false) {
						var G:Number;
						if(Math.abs(i) == 1 && Math.abs(j) == 1) {
							G = tileMenorF.G + 14;
						}
						else {
							G = tileMenorF.G + 10;
						}

						var H:Number = 10 * (Math.abs((xTile - xFin)) + Math.abs(yTile - yFin));
						var dir:Number = getDirection(i, j);
						var dirCount:Number = 0;

						if(tileMenorF.dir == dir) {
							dirCount = tileMenorF.dirCount + 1;
							if(tileMenorF.dirCount == 2)
								H = H + 10;
						}

						//	if (level[yTile][xTile]==level[tileMenorF.yPos][tileMenorF.xPos])
						//		H=H-20;
						//	H=Math.random()*20;

						var F:Number = G + H;
						var newTile:Tile = new Tile(xTile, yTile, G, H, F);
						newTile.dir = dir;
						newTile.dirCount = dirCount;
						newTile.parentTile = tileMenorF;
						var exist:Boolean = false;
						var indexTemp:Number = 0;
						for(var nn:Number = 0; nn < openList.length; nn++) {
							if(openList[nn].xPos == newTile.xPos && openList[nn].yPos == newTile.yPos) {
								exist = true;
								indexTemp = nn;
							}
						}
						if(exist == false) {
							openList.push(newTile);
						}
						if(exist == true) {
							if(openList[indexTemp].G < tileMenorF.G) {
								if(Math.abs(i) == 1 && Math.abs(j) == 1) {
									openList[indexTemp].G = tileMenorF.G + 14;
								}
								else {
									openList[indexTemp].G = tileMenorF.G + 10;
								}
								openList[indexTemp].H = 10 * (Math.abs((xTile - xFin)) + Math.abs(yTile - yFin));
								//	openList[indexTemp].H=0;
								openList[indexTemp].F = openList[indexTemp].G + openList[indexTemp].H;
								openList[indexTemp].parentTile = tileMenorF;
							}
						}
					}
				}
			}
		}
		return searching(xFin, yFin, openList, closeList, level, poziom);
	}

	//----------------------------------------------------------------
	//Descripction: returns an array with relative parent direction (x,y based) about tileObj
	public function returnParentDirection(tileObj:Tile):Array {
		var posArray:Array = [0, 0];
		var xpos:Number = tileObj.xPos - tileObj.parentTile.xPos;
		var ypos:Number = tileObj.yPos - tileObj.parentTile.yPos;
		posArray[0] = xpos * -10;
		posArray[1] = ypos * -10;
		return posArray;
	}

	public static function getDirection(changeX:Number, changeY:Number):Number {
		if(changeX > 0) {
			if(changeY > 0)
				return 1;
			else if(changeY < 0)
				return 2;
			else
				return 3;
		}
		else if(changeX < 0) {
			if(changeY > 0)
				return 4;
			else if(changeY < 0)
				return 5;
			else
				return 6;
		}
		else {
			if(changeY > 0)
				return 7;
			else
				return 8;
		}
	}
}
}
