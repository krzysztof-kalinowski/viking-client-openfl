/**
 * Created by flashdeveloper.pl on 2016-04-28.
 */
package com.taern.editor.mapping {

import away3d.events.MouseEvent3D;
import away3d.library.AssetLibrary;
import away3d.materials.TextureMaterial;
import away3d.textures.BitmapTexture;

import com.crazydb.DBKraina;
import com.crazydb.DBObject;
import com.taern.editor.MapEditorManager;
import com.taern.editor.MapEditorUIManager;
import com.taern.editor.map.MapManager3DEditor;
import com.taern.editor.map.ground.GroundView3DEditor;
import com.taern.editor.margins.MarginsEditor;
import com.taern.map.MapManager;
import com.taern.map.MapManager3D;
import com.taern.map.ground.GroundTile3D;
import com.taern.map.ground.GroundView3D;
import com.taern.map.mechanics.Stage2DAbuser;
import com.taern.map.pathfinding.Mapping;
import com.taern.map.pathfinding.Region;
import com.taern.map.pathfinding.Tile;
import com.taern.map.transform.CoordinatesHelper;
import com.taern.map.vo.AtlasData;
import com.taern.map.vo.GroundData;
import com.taern.server.EditorServer;
import com.taern.ui.ChatManager;
import com.taern.ui.UIManager;
import com.taern.ui.loader.UIAssetLoaderModel;
import com.taern.utils.settings.Atlas;
import com.taern.utils.settings.Path;
import com.taern.utils.settings.Settings;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.Dictionary;

public class MappingEditor extends Mapping {


	private static var REGIONS_ATLAS_AMOUNT:int = 40; // only 40 tex in atlas for now


	public static var _instance:MappingEditor;

	protected var _offsetX2D:Number;
	protected var _offsetY2D:Number;

	private var _atlasData:Dictionary;

	protected var _groundView:GroundView3D;

	protected var _meshDataVector:Vector.<Vector.<MappingTile>>;
	protected var _mappingMeshes:Vector.<MappingMesh>;

	protected var _mappingMaterial:TextureMaterial;

	//----------------
	protected var _downPoint:Point = new Point();
	protected var _upPoint:Point = new Point();
	//----------------

	protected var _rectangleStartPoint:Point;
	protected var _rectangle:Sprite;


	public static var editMapping:Boolean = true;
	public static var mappingRegion1Value:int = 0;
	public static var mappingRegion2Value:int = -1;


	private var _mappingAlpha:Number = 0.5;

	private var _mappingVisible:Boolean = false;

	public function MappingEditor() {
	}

	public static function getInstance():MappingEditor {
		if(_instance == null)
			_instance = new MappingEditor();

		return _instance;
	}

	public function initGround(groundData:GroundData, groundView:GroundView3D):void {
		_offsetX2D = groundData.offsetX2D;
		_offsetY2D = groundData.offsetY2D;
		_groundView = groundView;

		addGroundListeners();

		_rectangle = new Sprite();
		_rectangle.mouseEnabled = false;

		Stage2DAbuser.getInstance().stage.addChild(_rectangle);
	}

	public function drawMapping():void {
		if(_mappingMaterial == null) {
			//_mappingMaterial = new TextureMaterial(BitmapTexture(AssetLibrary.getAsset(Settings.MAPPING_EDITOR_ATLAS, Settings.MAPPING_EDITOR_ATLAS)));
			_mappingMaterial = new TextureMaterial(BitmapTexture(AssetLibrary.getAsset(
					Path.forName(Atlas.MAPPING_EDITOR),
					Path.forName(Atlas.MAPPING_EDITOR)
			)));
			_mappingMaterial.alphaBlending = true;

			//var atlasXml:XML = UIAssetLoaderModel.assetManager.getXml(Settings.MAPPING_EDITOR_XML);
			var atlasXml:XML = UIAssetLoaderModel.assetManager.getXml(Path.forNameWithExtension(Atlas.MAPPING_EDITOR, 'xml'));
			_atlasData = parseAtlasXML(atlasXml);
		}

		_mappingMaterial.alpha = _mappingAlpha;
		_meshDataVector = new Vector.<Vector.<MappingTile>>();

		if(_mapping.length > 0) {

			var max:int = _mapping.length * _mapping[0].length;
			var index:int = 0;
			var i:int = 0;
			while(index < max) {
				_meshDataVector.push(arrangeMappingTiles(_mapping, _atlasData, index, -1));
				i++;
				index = i * MappingRenderer.MAX_TILES_PER_MESH;
			}
			if(_mappingMeshes)
				for(var j:int = 0; j < _mappingMeshes.length; j++) {
					if(_mappingMeshes[j].parent == _groundView)
						_groundView.removeChild(_mappingMeshes[j]);
				}
			_mappingMeshes = new Vector.<MappingMesh>();
			for(var k:int = 0; k < _meshDataVector.length; k++) {
				_mappingMeshes.push(new MappingMesh(_mappingMaterial));
			}

			for(var l:int = 0; l < _meshDataVector.length; l++) {
				_mappingMeshes[l].updateMapping(_meshDataVector[l]);
				_groundView.addChild(_mappingMeshes[l]);
			}
			_mappingVisible = true;
		}

		MapEditorUIManager.getInstance().addMappingCoords();

		if(MapManager3D.getInstance().dungeonMask)
			UIManager.getInstance().removeDungeonMask();
	}


	public function switchMappingVisibility():void {
		if(mappingVisible) {
			removeMapping();
			if(MapManager3D.getInstance().dungeonMask)
				UIManager.getInstance().addDungeonMask();
		}
		else {
			drawMapping();
			if(MapManager3D.getInstance().dungeonMask)
				UIManager.getInstance().removeDungeonMask();
		}


	}


	public function addGroundListeners():void {
		_groundView.addEventListener(MouseEvent3D.MOUSE_DOWN, onGroundMouseDownHandler);
		_groundView.addEventListener(MouseEvent3D.MOUSE_UP, onGroundMouseUpHandler);
		_groundView.addEventListener(MouseEvent3D.MOUSE_MOVE, drawRectangle);
	}

	public function removeGroundListeners():void {
		if(_groundView && _groundView.hasEventListener(MouseEvent3D.MOUSE_DOWN)) {
			_groundView.removeEventListener(MouseEvent3D.MOUSE_DOWN, onGroundMouseDownHandler);
			_groundView.removeEventListener(MouseEvent3D.MOUSE_UP, onGroundMouseUpHandler);
			_groundView.removeEventListener(MouseEvent3D.MOUSE_MOVE, drawRectangle);
		}
	}

	protected function drawRectangle(e:MouseEvent3D):void {
		if(MapEditorManager.getInstance().mappingToolWindow == null || MapEditorManager.getInstance().mappingToolWindow.parent == null)
			return;

		if(_rectangleStartPoint && !MapManager3DEditor.getInstance().tildaMapMove && !MapManager3DEditor.getInstance().simulationMode) {
			var endPoint:Point = new Point(Stage2DAbuser.getInstance().stage.stageWidth * e.screenX / 100, Stage2DAbuser.getInstance().stage.stageHeight * e.screenY / 100);
			_rectangle.graphics.clear();
			_rectangle.graphics.beginFill(0x336699, 0.5);
			_rectangle.graphics.drawRect(_rectangleStartPoint.x, _rectangleStartPoint.y, endPoint.x - _rectangleStartPoint.x, endPoint.y - _rectangleStartPoint.y);
			_rectangle.graphics.endFill();

		}

		if(e.object.parent is GroundTile3D) {
			var row:int = (e.object.parent as GroundTile3D).row;
			var col:int = (e.object.parent as GroundTile3D).column;

			var p:Point = new Point();
			CoordinatesHelper.cell3DToTile2D(p, e.localPosition.x, e.localPosition.z, row, col);

			MapEditorUIManager.getInstance().updateMappingCoords(p);
		}

	}


	private function clearRectangle():void {
		_rectangle.graphics.clear();
	}

	protected function onGroundMouseDownHandler(e:MouseEvent3D):void {

		if(MapEditorManager.getInstance().mappingToolWindow == null || MapEditorManager.getInstance().mappingToolWindow.parent == null)
			return;

//        if(!MapManager3DEditor.getInstance().tildaMapMove && !MapManager3DEditor.getInstance().simulationMode)
		if(!MapManager3DEditor.getInstance().tildaMapMove && !MapEditorManager.getInstance().menu.gameSimulation.selected && e.object.parent is GroundTile3D) {
			_rectangleStartPoint = new Point(Stage2DAbuser.getInstance().stage.stageWidth * e.screenX / 100, Stage2DAbuser.getInstance().stage.stageHeight * e.screenY / 100);
			var row:int = (e.object.parent as GroundTile3D).row;
			var col:int = (e.object.parent as GroundTile3D).column;
			CoordinatesHelper.cell3DToTile2D(_downPoint, e.localPosition.x, e.localPosition.z, row, col);
		}

	}

	protected function onGroundMouseUpHandler(e:MouseEvent3D):void {
		if(MapEditorManager.getInstance().mappingToolWindow == null || MapEditorManager.getInstance().mappingToolWindow.parent == null)
			return;

//        if(!MapManager3DEditor.getInstance().tildaMapMove && !MapManager3DEditor.getInstance().simulationMode)
		if(!MapManager3DEditor.getInstance().tildaMapMove && !MapEditorManager.getInstance().menu.gameSimulation.selected && e.object.parent is GroundTile3D) {
			var row:int = (e.object.parent as GroundTile3D).row;
			var col:int = (e.object.parent as GroundTile3D).column;
			CoordinatesHelper.cell3DToTile2D(_upPoint, e.localPosition.x, e.localPosition.z, row, col);

			_rectangleStartPoint = null;
			clearRectangle();

			if(editMapping && _downPoint && _upPoint)
				editPointsBetween(_downPoint, _upPoint);
		}

	}


	override public function getMapping(x:int, y:int):int {
		if(_mapping && x > -1 && y > -1) {
			if(y >= _mapping.length)
				return 0;
			else if(x >= _mapping[y].length)
				return 0;
			else
				return _mapping[y][x];
		}
		else
			return 0;

	}

	private function editPointsBetween(down:Point, up:Point):void {
		if(!validateRegion(mappingRegion1Value))
			return;

		var start_col:int;
		var end_col:int;

		if(down.x < up.x) {
			start_col = down.x;
			end_col = up.x + 1;
		}
		else {
			start_col = up.x;
			end_col = down.x + 1;
		}

		var start_row:int;
		var end_row:int;

		if(down.y < up.y) {
			start_row = down.y;
			end_row = up.y + 1;
		}
		else {
			start_row = up.y;
			end_row = down.y + 1;
		}

		var indexesArray:Array = new Array();
		for(var i:int = start_row; i < end_row; i++) {
			for(var j:int = start_col; j < end_col; j++) {
				/*
				 var iPositive:Boolean = i >= 0;
				 var jPositive:Boolean = j >= 0;
				 var mappingLength:Boolean = _mapping.length;
				 var mappingILength:Boolean = _mapping[i].length;
				 var valueChange:Boolean = _mapping[i][j] != mappingRegion1Value;
				 trace("MappingEditor.editPointsBetween iPositive = " +iPositive+"; jPositive = "+jPositive+"; mappingLength = "+mappingLength+"; mappingILength = "+mappingILength+"; valueChange = "+valueChange);
				 */

				if(i >= 0 && j >= 0 && i < _mapping.length && j < _mapping[i].length && _mapping[i][j] != mappingRegion1Value && _mapping[i][j] != mappingRegion2Value) {
					_mapping[i][j] = mappingRegion1Value;
					indexesArray.push(getMappingRectangleIndex(i, j));
				}
			}
		}

		var uniqueIndexes:Array = new Array();
		if(indexesArray.length > 0) {
			indexesArray.sort(Array.NUMERIC);
			uniqueIndexes.push(indexesArray[0]);
			for(var k:int = 1; k < indexesArray.length; k++) {
				if(indexesArray[k] > uniqueIndexes[uniqueIndexes.length - 1]) {
					uniqueIndexes.push(indexesArray[k]);
				}
			}
		}

		for(var l:int = 0; l < uniqueIndexes.length; l++) {
			refreshMappingRectangleByIndex(uniqueIndexes[l]);
		}
	}


	private function refreshMappingRectangleByIndex(index:int):void {
		_meshDataVector[index] = arrangeMappingTiles(_mapping, _atlasData, index * MappingRenderer.MAX_TILES_PER_MESH);
		_mappingMeshes[index].updateMapping(_meshDataVector[index]);
	}

	private function getMappingRectangleIndex(row:int, col:int):int {
		var tile_index:int = row * _mapping[0].length + col;
		return Math.floor(tile_index / MappingRenderer.MAX_TILES_PER_MESH);
	}

	/*private function convertToTileXY(x:Number,y:Number):Point
	 {
	 var dX:Number = x / Tile.SIZE;
	 var dY:Number = -y / Tile.SIZE / Settings.ORTOGRAPHIC_CONVERSION_FACTOR_HEIGHT;

	 var tileX:int = Math.floor(dX);
	 var tileY:int = Math.floor(dY);

	 return new Point(tileX, tileY);
	 }*/

	public function validateRegion(region:int):Boolean {
		if(region == 0 || _regions[region] != null)
			return true;
		else {
//            ChatManager.infoMessage("Region "+region+" doesn't exist in this area");
			ChatManager.communicateMainChat("Region " + region + " doesn't exist in this area");
			return false;
		}

	}


	public function removeMapping():void {
		if(_mappingMeshes && _mappingMeshes[0].parent == _groundView) {
			for(var i:int = 0; i < _mappingMeshes.length; i++) {
				_groundView.removeChild(_mappingMeshes[i]);

//                _mappingMeshes[i] = null;
			}
//            _mappingMeshes = null;
		}
		_mappingVisible = false;
		MapEditorUIManager.getInstance().removeMappingCoords();

		if(MapManager3D.getInstance().dungeonMask)
			UIManager.getInstance().addDungeonMask();

	}


	public function showMapping():void {
		if(_mappingMeshes && _mappingMeshes[0].parent == null) {
			for(var i:int = 0; i < _mappingMeshes.length; i++) {
				_groundView.addChild(_mappingMeshes[i]);
//                _mappingMeshes[i] = null;
			}
//            _mappingMeshes = null;
		}
	}


	public function parseAtlasXML(atlasXml:XML):Dictionary {
		var atlasData:Dictionary = new Dictionary();

		var aData:AtlasData;
		for each (var subTexture:XML in atlasXml.SubTexture) {
			aData = new AtlasData();
			aData.name = subTexture.attribute("name");
			aData.x = parseFloat(subTexture.attribute("x"));
			aData.y = parseFloat(subTexture.attribute("y"));
			aData.width = parseFloat(subTexture.attribute("width"));
			aData.height = parseFloat(subTexture.attribute("height"));

			atlasData[int(aData.name)] = aData;
		}

		return atlasData;
	}

	private function arrangeMappingTiles(mapping:Array, atlasData:Dictionary, start_index:int = 0, tileDebug:int = -1):Vector.<MappingTile> {
		var mappingTileVec:Vector.<MappingTile> = new Vector.<MappingTile>();
		var mt:MappingTile;

		var end_index:int = start_index + MappingRenderer.MAX_TILES_PER_MESH;

		var row_width:int = mapping[0].length;
		var column_height:int = mapping.length;

		var max_index:int = (row_width) * (column_height);

		if(end_index > max_index)
			end_index = max_index;

		var start_col:int = start_index % row_width;  //start x
		var start_row:int = Math.floor(start_index / row_width);

		var index:int = start_index;
		var col:int = start_col;
		var row:int = start_row;


		while(index < end_index) {
			var frame:int = int(mapping[row][col]);
			if(frame > REGIONS_ATLAS_AMOUNT) frame = REGIONS_ATLAS_AMOUNT;

			if(tileDebug != -1)
				frame = tileDebug;

			mt = new MappingTile();
			mt.x = col * Tile.SIZE;
			mt.y = 1;
			mt.z = -(((row + 1) * Tile.SIZE)) * Settings.ORTOGRAPHIC_CONVERSION_FACTOR_HEIGHT;
			mt.atlasX = atlasData[frame].x;
			mt.atlasY = atlasData[frame].y;
			mappingTileVec.push(mt);

			col++;
			if(col > row_width - 1) {
				col = 0;
				row++;
			}

			index++;
		}

		return mappingTileVec;

	}

//-------------------GETTERS AND SETTERS-----------------------------------------------

	public static function get mapping():Array {
		return getInstance().mapping;
	}

	public static function set mapping(value:Array):void {
		getInstance().mapping = value;
	}

	public static function get regions():Array {
		return getInstance().regions;
	}

	public static function set regions(value:Array):void {
		getInstance().regions = value;
	}

	public function updateMappingAlpha(alpha:Number):void {
		_mappingAlpha = alpha;
		if(_mappingMaterial)
			_mappingMaterial.alpha = alpha;
	}


//-------------------------------------------------------------------------------------
	public function switchRegions():void {
		if(!validateRegion(mappingRegion1Value) || !validateRegion(mappingRegion2Value))
			return;

		if(mappingRegion1Value >= 0 && mappingRegion2Value >= 0 && mappingRegion1Value != mappingRegion2Value) {
			for(var i:int = 0; i < _mapping.length; i++) {
				for(var j:int = 0; j < _mapping[i].length; j++) {
					if(_mapping[i][j] == mappingRegion1Value) {
						_mapping[i][j] = mappingRegion2Value;
					}
				}
			}
		}
		drawMapping();
	}

//-------------------------------------------------------------------------------------
	public function generateMapping(width:int, height:int, idRegion:int = 0):void {
		_mapping = new Array();

		for(var i:int = 0; i < height; i++) {
			var row:Array = new Array();
			for(var j:int = 0; j < width; j++) {
				row.push(idRegion);
			}
			_mapping.push(row);
		}

		drawMapping();
	}


	public function generateMappingToGraphicSize():void {
		var widthInCells:int = MapManager3DEditor.getInstance().mapView3D.groundView.mapWidthInCells;
		var heightInCells:int = MapManager3DEditor.getInstance().mapView3D.groundView.mapHeightInCells;

		var width:int = (widthInCells * Settings.MAP_CELL_SIZE) / Tile.SIZE;
		var height:int = (heightInCells * Settings.MAP_CELL_SIZE) / Tile.SIZE;

		generateMapping(width, height, 1);

		reloadMappingWidth();
	}

//-------------------------------------------------------------------------------------

	public function updateMappingWidthHeight(width:int, height:int):void {
		if(_mapping.length > 0) {
			if(_mapping[0].length < width) {
				while(_mapping[_mapping.length - 1].length < width) {
					for(var i:int = 0; i < _mapping.length; i++) {
						_mapping[i].push(0);
					}
				}
			}
			else if(_mapping[0].length > width) {
				while(_mapping[_mapping.length - 1].length > width) {
					for(var j:int = 0; j < _mapping.length; j++) {
						_mapping[j].pop();
					}
				}
			}
		}

		if(_mapping.length < height) {
			var row:Array = new Array();
			for(var k:int = 0; k < width; k++) {
				row.push(0);
			}

			while(_mapping.length < height)
				_mapping.push(row);
		}
		else if(_mapping.length > height) {
			while(_mapping.length > height)
				_mapping.pop();
		}

		drawMapping();
		MarginsEditor.getInstance().refreshMarginsDisplay();
	}

//--------------------------------------------------------------------------------------


	public function saveMappingData():void {
		var mappingString:String = "";

		for(var i:int = 0; i < _mapping.length; i++) {
			mappingString += _mapping[i].join(",") + ";"
		}

		var dbKraina:DBKraina = new DBKraina();
		dbKraina.addEventListener(DBObject.ON_UPDATE, dataUpdateDb);
		dbKraina.updateMappingAndOffsetsById(MapManager3DEditor.getInstance().areaId, mappingString, _offsetX2D, _offsetY2D, MapManager3DEditor.getInstance().marginTop, MapManager3DEditor.getInstance().marginBottom, MapManager3DEditor.getInstance().marginLeft, MapManager3DEditor.getInstance().marginRight);

	}

	private function dataUpdateDb(e:Event):void {
		EditorServer.mappingChanged();
	}

//------------------------------------------------------------------------------------------------

	public function reloadTxtMappingData():void {
		_dataLoader = new URLLoader();
		_dataLoader.addEventListener(Event.COMPLETE, dataLoadedTxt);
		_dataLoader.load(new URLRequest(Settings.BASE_URL_EDITOR + "data/krainy/" + MapManager3DEditor.getInstance().areaId + ".txt?kill=" + (new Date().getTime())));
	}

	private function dataLoadedTxt(e:Event):void {
		var msg:String = String(e.target.data);
		var mainTab:Array = msg.split("@@");
		_dataLoader.removeEventListener(Event.COMPLETE, dataLoadedTxt);

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


		if(MapEditorManager.getInstance().mappingToolWindow != null && MapEditorManager.getInstance().mappingToolWindow.parent != null) {
			reloadMappingWidth();
		}

		drawMapping();
	}


	public function reloadDBMappingData():void {
		var dbKraina:DBKraina = new DBKraina();
		dbKraina.addEventListener(DBObject.ON_SELECT, dataLoadedDb)
		dbKraina.getMappingAndOffsetsById(MapManager3DEditor.getInstance().areaId);
	}

	private function dataLoadedDb(e:Event):void {
		var msg:String = String(e.target.data);
		var tab:Array = msg.split("%");

		_mapping = new Array();
		var tabMapowaniePom:Array = tab[0].split(";");
		for(var i:Number = 0; i < tabMapowaniePom.length - 1; i++) {
			var tab2:Array = tabMapowaniePom[i].split(",");
			_mapping[i] = new Array();
			for(var j:Number = 0; j < tab2.length; j++) {
				_mapping[i][j] = parseInt(tab2[j]);
			}
		}

		if(MapEditorManager.getInstance().mappingToolWindow != null && MapEditorManager.getInstance().mappingToolWindow.parent != null) {
			MapEditorManager.getInstance().mappingToolWindow.reloadOffsets(Number(tab[1]), Number(tab[2]));
			reloadMappingWidth();
		}

		GroundView3DEditor(MapEditorManager.getInstance().mapView3D.groundView).updateOffset(Number(tab[1]), Number(tab[2]));

		drawMapping();
	}

	private function reloadMappingWidth():void {
		if(_mapping.length > 0)
			MapEditorManager.getInstance().mappingToolWindow.reloadMappingWidthHeight(_mapping[0].length, _mapping.length)
		else
			MapEditorManager.getInstance().mappingToolWindow.reloadMappingWidthHeight(0, 0)
	}


	public function get mappingVisible():Boolean {
		return _mappingVisible;
	}

	public function set mappingVisible(value:Boolean):void {
		_mappingVisible = value;
	}

	public function get offsetX2D():Number {
		return _offsetX2D;
	}

	public function set offsetX2D(value:Number):void {
		_offsetX2D = value;
	}

	public function get offsetY2D():Number {
		return _offsetY2D;
	}

	public function set offsetY2D(value:Number):void {
		_offsetY2D = value;
	}

	public function get mappingAlpha():Number {
		return _mappingAlpha;
	}
}
}
