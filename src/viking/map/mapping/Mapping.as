
package viking.map.pathfinding {



public class Mapping {


	private var _dataLoader:URLLoader;
	private var _mapping:Array;
	private var _regions:Array;
	private var _path:Array;
	private var _distance:Number = 60;
	private var _cropDistance:int = 10;

	public function Mapping() {
	}

	/*public function loadMappingData(id:Number):void {
		//trace("Mapping.loadMappingData = "+_url + "dane/krainy/" + id + ".txt");
//        _id=id;
		_dataLoader = new TaernURLLoader("Mapping.loadMappingData()");
		_dataLoader.addEventListener(Event.COMPLETE, dataLoaded);
//        _dataLoader.addEventListener(Event.COMPLETE, dataLoaded);
		_dataLoader.addEventListener(ErrorEvent.ERROR, onError);
		_dataLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
//        _dataLoader.addEventListener(Event, dataLoaded);
//        if ()

//        _dataLoader.load(new URLRequest(Settings.BASE_URL + "data/krainy/" + id + ".txt"));
		_dataLoader.load(new URLRequest(Settings.BASE_URL_EDITOR + "data/krainy/" + id + ".txt?kill=" + (new Date().getTime())));
	}*/

	/**
	 * In case mapping file is missing we are creating empty mapping
	 * for TEST ONLY
	 * @param event
	 *
	 */
	
	/*private function onError(event:ErrorEvent):void {
		_mapping = new Array();
		for(var i:Number = 0; i < 250; i++) {
			_mapping[i] = new Array();
			for(var j:Number = 0; j < 250; j++) {
				_mapping[i][j] = 1;
			}
		}
		_regions = new Array();
		_regions.push(new Region("1$Test$0$0$arena$"));
		MapManager3D.getInstance().onMappingReady();
	}

	private function dataLoaded(e:Event):void {
		var msg:String = String(e.target.data);
		//trace("mapping msg = "+msg);
		var mainTab:Array = msg.split("@@");
		_dataLoader.removeEventListener(Event.COMPLETE, dataLoaded);

		_mapping = new Array();
		var tabMapowaniePom:Array = mainTab[0].split(";");
		for(var i:Number = 0; i < tabMapowaniePom.length - 1; i++) {
			var tab2:Array = tabMapowaniePom[i].split(",");
			_mapping[i] = new Array();
			for(var j:Number = 0; j < tab2.length; j++) {
				_mapping[i][j] = parseInt(tab2[j]);
			}
		}

		var tabRegionyPom:Array = mainTab[1].split(";");
		_regions = new Array();
		for(i = 0; i < tabRegionyPom.length - 1; i++) {
			var r:Region = new Region(tabRegionyPom[i]);
			_regions[r.id_region] = r;
		}

		MapManager3D.getInstance().onMappingReady();
		//findPath(89,48,89,54);
	}

	public function getRegionId(x:Number, y:Number):Number {
		if(_mapping) {
			if(y >= _mapping.length)
				return 0;
			else if(x >= _mapping[y].length)
				return 0;
			else
				return _mapping[y][x];
		}
		else
			return 0;
		//sprawdzanie czy jest w zakresie
	}

	public function getRegion(x:Number, y:Number):Region {
		if(_regions != null)
			return _regions[getRegionId(x, y)];
		else
			return null;
	}

	//4. Znajdz drogę do wybranej lokacji
	public function findPath(xIni:Number, yIni:Number, xFin:Number, yFin:Number):Array {
		_path = PathFinder.findPath(xIni, yIni, xFin, yFin, _mapping, true);
//        displayTiles(_path);
		return _path;
	}


	public static function displayTiles(a:Array):void {
		for(var i:int = 0; i < a.length; i++)
			trace(">> Mapping.path x = " + ((a[i] as Tile).xPos) + "; y = " + ((a[i] as Tile).yPos));
	}

	public static function displayPath(a:Array):void {
		for(var i:int = 0; i < a.length; i++)
			trace(">> Mapping.path[" + i + "]:  " + ((a[i] as Point).x) + " , " + ((a[i] as Point).y));
	}


	private function cropMapping(x:Number, y:Number):Array {
		var mapa:Array = new Array(2 * _cropDistance + 1);

		for(var i:Number = 0; i <= 2 * _cropDistance + 1; i++) {
			mapa[i] = new Array(2 * _cropDistance + 1);
			for(var j:Number = 0; j < 2 * _cropDistance + 1; j++) {
				if((y - _cropDistance + i) > 0 && (y - _cropDistance + i) < _mapping.length && (x - _cropDistance + i) > 0 && (x - _cropDistance + i) < _mapping[y - _cropDistance + i].length)
					mapa[i][j] = _mapping[y - _cropDistance + i][x - _cropDistance + j];
			}
		}
		//trace("wycieta mapa: "+mapa.length);
		return mapa;
	}


	public function spliceTo(x:Number, y:Number):void {
		for(var i:Number = 0; i < _path.length; i++) {
			if(_path[i].xPos == x && _path[i].yPos == y) {
				_path.splice(0, i);
			}
		}
	}

	public function findEmptySpace(nearX:Number, nearY:Number, r:Number = 1):Array {
		var tab:Array = new Array();
		if(r < 8) {
			for(var i:Number = nearY - r; i <= nearY + r; i++) {
				var j:Number = 0;
				for(j = nearX - r; j <= nearX + r; j++) {
					if(i > 0 && j > 0 && i < _mapping.length && j < _mapping[i].length && _mapping[i][j] != 0) {
						tab.push([j, i]);
					}
				}
			}
			if(tab.length > 0) {
				var best:Number = 0;
				var odl:Number = 100;//Math.abs(obokX-tab[0][0])+Math.abs(obokY-tab[0][1]);
				for(var k:Number = 1; k < tab.length; k++) {
					if(odl > Math.abs(nearX - tab[k][0]) + Math.abs(nearY - tab[k][1]))
						best = k;
				}
				return tab[best];
			}
			else
				return findEmptySpace(nearX, nearY, r + 1);
		}
		else
			return null;
	}

	public function getMapping(x:int, y:int):int {
		if(_mapping) {
			if(y >= _mapping.length)
				return 0;
			else if(x >= _mapping[y].length)
				return 0;
			else
				return _mapping[y][x];
		}
		else
			return 0;
		//sprawdzanie czy jest w zakresie
	}

	public function getWidthInTiles():int {
		return _mapping[0].length;
	}

	public function getHeightInTiles():int {
		return _mapping.length;
	}

	public function getWidth():int {
		return getWidthInTiles() * Tile.SIZE;
	}

	public function getHeight():int {
		return getHeightInTiles() * Tile.SIZE;
	}


	public function get mapping():Array {
		return _mapping;
	}

	public function set mapping(value:Array):void {
		_mapping = value;
	}

	public function get regions():Array {
		return _regions;
	}

	public function set regions(value:Array):void {
		_regions = value;
	}*/
}
}
