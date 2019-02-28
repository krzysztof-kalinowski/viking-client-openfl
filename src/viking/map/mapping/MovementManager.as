package com.taern.map.pathfinding {

import com.eclecticdesignstudio.motion.Actuate;
import com.taern.client.Client;
import com.taern.map.MapManager3D;
import com.taern.map.action.AutoAction;
import com.taern.map.mechanics.Mechanism2DModel;
import com.taern.map.mechanics.MechanismManager;
import com.taern.map.team.Team;
import com.taern.map.team.TeamActionType;
import com.taern.map.transform.CoordinatesHelper;
import com.taern.server.BarterServer;
import com.taern.server.EquipmentServer;
import com.taern.server.FightServer;
import com.taern.server.MovementServer;
import com.taern.server.QuestServer;
import com.taern.server.TeamServer;
import com.taern.sound.TaernSoundEngine;
import com.taern.ui.ChatManager;
import com.taern.ui.UIManager;
import com.taern.utils.Dbg;
import com.taern.utils.TextUtils;
import com.taern.utils.settings.Settings;

import flash.geom.Point;

import starling.display.Sprite;

public class MovementManager {


	public static var STEP_LENGTH:Number = 40;
	protected static const MOVE_RANGE_TOLERANCE:int = 6;//in tiles

	protected static var _instance:MovementManager;

	protected var _serverX:Number = 0;
	protected var _serverY:Number = 0;
	protected var _localX:Number;
	protected var _localY:Number;

	protected var _mapping:Mapping;

	protected var _idArea:int = 2147483646;
	protected var _idInstanceUnique:int = 2147483646;

	private var _pixelPath:Array;

	protected var _tilePathTemp:Array;

	protected var _waiting:Boolean;

	public static var AUTO_ACTION:AutoAction;

	protected var _stepSound:Boolean = false;
	protected var _blocked:Boolean = false;
	private var _mechIdToUse:Number;


	public function MovementManager():void {
		AUTO_ACTION = new AutoAction();
	}

	public static function getInstance():MovementManager {
		if(_instance == null)
			_instance = new MovementManager();

		return _instance;
	}

	public function initMapping(idArea:int = 209, idInstanceUnique:int = -1):void {
		if (_idArea != idArea || _idInstanceUnique != idInstanceUnique) {
			if(_mapping) {
				_mapping = null;
			}
			_idArea = idArea;
			_idInstanceUnique = idInstanceUnique;
			_mapping = new Mapping();
			_mapping.loadMappingData(_idArea);
		}
		else {
			MapManager3D.getInstance().onMappingReady();
		}
	}

	/**
	 *
	 * @param msg
	 */
	public function onMappingUpdate(msg:String):void {

		//in case mapping have changed when you're still loading mapping from txt file
		if (_mapping == null || _mapping.mapping == null)
			return;//ignore - we will ask for it anyway
		else {
			var tab:Array = msg.split("$");
			for (var i:Number = 0; i < tab.length - 1; i++) {
				var coords:Array = tab[i].split(",");
				_mapping.mapping[parseInt(coords[1])][parseInt(coords[0])] = parseInt(coords[2]);
			}
		}

	}

	//------------------------------called in MapManager3D.onGroundClick or onMyTeamMove (server)
	public function goto2(start:Point, end:Point, x3d:int = 0, y3d:int = 0):void {

		if(_blocked) {
			trace("movemnt blocked by ai / npc");
			ChatManager.notification(TextUtils.ui("porozmawiaj_npc"));
			QuestServer.startRozmowyBlokada();
			return;
		}
		if(_mapping) {
			if(_mapping.mapping) {
				var startX:Number = start.x;
				var startY:Number = start.y;
				var x:Number = end.x;
				var y:Number = end.y;

				Client.myTeam.stepFinished.add(stepFinishedHandler);

				var path:Array;
				_pixelPath = new Array();

				if(_mapping.getMapping(x, y) > 0) {
					path = _mapping.findPath(startX, startY, x, y);
				}
				else {
					//find closest possible place
					var a:Array = _mapping.findEmptySpace(x, y, 1);
					if(a) {
						x = a[0];
						y = a[1];
						path = _mapping.findPath(startX, startY, x, y);
					}
				}
				if(path != null && path.length > 1) {
					_pixelPath = convertToPixelCoords(path);
//                    Mapping.displayPath(_pixelPath);
					stepByStep();
				}
				else if(path != null && path.length > 1 && mapping.getMapping(CoordinatesHelper.from3DToTile2D_X(x3d), CoordinatesHelper.from3DToTile2D_Y(y3d)) != 0) {
					Client.myTeam.modelGoTo(x3d, y3d, true);
				}

			}
		}
	}

//----------------------------------------------------------------------------------------------
	protected function stepByStep():void {

		var serverPoint:Point = new Point(_serverX, _serverY);
		if(_pixelPath[_pixelPath.length - 1] != undefined) {
			var startToServerLength:Number = CoordinatesHelper.getPortionLength(_pixelPath[_pixelPath.length - 1], serverPoint);

			if(startToServerLength > MovementManager.MOVE_RANGE_TOLERANCE) {
				trace("wait for synch: " + startToServerLength + " / " + MovementManager.MOVE_RANGE_TOLERANCE);
				_waiting = true;
			}
			else {
				var lastStepIndex:int = 0;
				switch(AUTO_ACTION.action) {
					case TeamActionType.ACTION_MOVE:
						lastStepIndex = 0;
						break;
					case TeamActionType.ACTION_JOIN:
						lastStepIndex = 0;
						break;
					case TeamActionType.ACTION_FIGHT:
						lastStepIndex = 1;
						break;
					case TeamActionType.ACTION_TALK:
						lastStepIndex = 1;
						break;
					case TeamActionType.ACTION_TAKE:
						lastStepIndex = 0;
						break;
					case TeamActionType.ACTION_MECHANISM:
						lastStepIndex = 1;
						break;
					case TeamActionType.ACTION_BARTER:
						lastStepIndex = 0;
						break;
				}

				if(AUTO_ACTION.action != TeamActionType.ACTION_MOVE && _pixelPath.length == lastStepIndex) {
					if(_pixelPath.length == 1)		                            //rotation on action without move
						Client.myTeam.rotateToPoint(_pixelPath[0].x, _pixelPath[0].y);

					fireAutoAction(AUTO_ACTION);
					_pixelPath.splice(0);// = null;
				}
				else if(_pixelPath.length > lastStepIndex) {
					var x:Number = _pixelPath[_pixelPath.length - 1].x;
					var y:Number = _pixelPath[_pixelPath.length - 1].y;

					Client.myTeam.modelGoTo(x, y, true);

					var tilePoint:Point = convertToTileXYReverse(x, y);
					var tileX:int = tilePoint.x;
					var tileY:int = tilePoint.y;

					if(Math.abs(tileX - localX) > 2 || Math.abs(tileY - localY) > 2) {
						Dbg.traceWin("WARNING - DISTANCE: " + localX + "," + localY + " / " + tileX + "," + tileY);
					}

					_stepSound = !_stepSound;

					if(_stepSound) {
						var region:Region = _mapping.getRegion(tileX, tileY);
						if(region != null)
							TaernSoundEngine.instance.stepsPlay(region.background);
					}

					var stepValue:int = _mapping.getMapping(tileX, tileY);
					//                  var finalStepValue:int = _mapping.getMapping(Math.round(_pixelPath[0].x/Tile.SIZE), Math.round(-Number(_pixelPath[0].y)/Tile.SIZE/ Settings.ORTOGRAPHIC_CONVERSION_FACTOR_HEIGHT));

					if(stepValue == 0) {
						Dbg.traceWin("DUMB FUCK!!! mapping = 0 on (" + tileX + "," + tileY + ") / dest: " + "(" + (x / Tile.SIZE) + "," + (-y / Tile.SIZE / Settings.ORTOGRAPHIC_CONVERSION_FACTOR_HEIGHT) + ")");
					}
					//MOVEMEMENT PREDICTION

					var nextX3D:Number = 0;
					var nextY3D:Number = 0;
					if(_pixelPath.length > lastStepIndex + 1) {
						nextX3D = _pixelPath[_pixelPath.length - 2].x;
						nextY3D = _pixelPath[_pixelPath.length - 2].y;
					}

//                    trace("MovementManager.stepByStep tile: (" + tileX + ", " + tileY + "); 3d: (" + x + ", " + y + "); next: (" + nextX3D + ", " + nextY3D + ")");
					MovementServer.moveTo(tileX, tileY, x, y, nextX3D, nextY3D);
					updateLocalPosition(tileX, tileY);

//                    trace("MOVE: "+_pixelPath.length);
					_pixelPath.splice(_pixelPath.length - 1, 1);
				}

				_waiting = false;
			}
		}
		else {
//            trace("_pixelPath[_pixelPath.length - 1] == undefined");
			trace("DUPADUPADUPA length: " + _pixelPath.length);
		}
	}

	protected function stepFinishedHandler():void {
		MapManager3D.getInstance().onMyStepFinished();
		if(_pixelPath.length > 0)
			stepByStep();
		else {
			if(AUTO_ACTION.action == TeamActionType.ACTION_JOIN || AUTO_ACTION.action == TeamActionType.ACTION_TAKE || AUTO_ACTION.action == TeamActionType.ACTION_BARTER)        //TODO poprawić na bardziej czyte
				fireAutoAction(AUTO_ACTION);
		}
	}

	protected function cancelMovement():void {
		if(_pixelPath != null)
			_pixelPath.splice(0);
	}

//---------------------------------------------------------ACTIONS---------------------------------------------
	protected function fireAutoAction(autoAction:AutoAction):void {

//        trace("MovementManager.fireAutoAction action = " + AUTO_ACTION.action);

		switch(AUTO_ACTION.action) {
			case TeamActionType.ACTION_MOVE:
				break;
			case TeamActionType.ACTION_JOIN:
				join(autoAction.team);
				break;
			case TeamActionType.ACTION_FIGHT:
				attackAi(autoAction.id);
				break;
			case TeamActionType.ACTION_TALK:
				talk(autoAction.id);
				//MainMc.getInstance().server.rozmowaDruzynaQm(autoAction.id, _serverX, _serverY);
				break;
			case TeamActionType.ACTION_MECHANISM:
				useMechanism(autoAction.id);
				break;
			case TeamActionType.ACTION_TAKE:
				take(autoAction.id);
				break;
			/*
			 case TeamActionType.ACTION_TALK_ILUSTRACJA:
			 talkIlustracja(autoAction.id)
			 break;
			 case TeamActionType.ACTION_TAKE:
			 take(autoAction.id);
			 break;
			 case Team.ACTION_ENTER_KRAINA:
			 enterKraina(parseInt(autoAction.id));
			 break;
			 case Team.ACTION_ENTER_ROOM:
			 enterRoom(parseInt(autoAction.id));
			 break;
			 */
			case TeamActionType.ACTION_BARTER:
				barter(autoAction.id, autoAction.id_user);
				break;

		}
		clearAutoAction();


	}

	protected function clearAutoAction():void {
		AUTO_ACTION.id = "0";
		AUTO_ACTION.team = null;
		AUTO_ACTION.action = TeamActionType.ACTION_MOVE;
	}

//-----------------Jesli druzyna do ktorej chcemy dolaczyc sie porusza gonimy ja
	public function onAutoJoin(dx:Number, dy:Number, id:String):void {
		/*
		 var aa:AutoAction = new AutoAction();
		 aa.action = TeamActionType.ACTION_JOIN;
		 aa.team = MapManager.getInstance().getTeamById(id);
		 aa.id = id;

		 MovementManager.getInstance().setAutoAction(aa);
		 MovementManager.getInstance().goto(dx, dy);
		 */
	}

	public function join(team:Team):void {
		if(Client.isTeamLeader()) {
			/*if(MainMc.getInstance().hero.getGildia()!=undefined && MainMc.getInstance().hero.getGildia().wojnaPrzeciwnik(team.getGildie()))       //TODO warunek dla wojny gildii
			 MainMc.getInstance().chatLeft.gildiaWStanieWojnyZakazDolaczania();
			 else*/
//				if (MainMc.getInstance().mapa.getRegion().getPk()!=Region.CZARNY && team.getStatus()==Team.WALCZY && MainMc.getInstance().hero.pvpDelay>0 && MainMc.getInstance().hero.pvpDelay>(new Date()).getTime())
			/*if (MapManager3D.getInstance().getRegion().getPk()!=Region.CZARNY && team.getStatus()==Team.WALCZY && MainMc.getInstance().hero.pvpDelay>0 && MainMc.getInstance().hero.pvpDelay>(new Date()).getTime())
			 MainMc.getInstance().chatLeft.pvpDelay(MainMc.getInstance().hero.pvpDelay);
			 else*/


			TeamServer.dolaczDruzyna(team.id);

		}
		else {
			ChatManager.notification(TextUtils.ui("druzyna_tylko_szef_kieruje"));
		}

	}

	public function attackPvP(id:String):void {
		if(Client.isTeamLeader())
			FightServer.fightDruzyna(id);
		else
			ChatManager.notification(TextUtils.ui("druzyna_tylko_szef_kieruje"));
	}

	public function attackAi(id:String):void {
		if(Client.isTeamLeader())
			FightServer.fightDruzynaAi(id);
		else
			ChatManager.notification(TextUtils.ui("druzyna_tylko_szef_kieruje"));

	}

	public function talk(id:String):void    //TODO TALK tu skocnzylem
	{
		if(Client.isTeamLeader())
			QuestServer.rozmowaDruzynaQm(id);
		else
			ChatManager.notification(TextUtils.ui("druzyna_tylko_szef_kieruje"));
	}

	public function talkIlustracja(id:String):void {
		if(Client.isTeamLeader()) {
//          MainMc.getInstance().startRozmowaIlu(parseInt(id));
		}
		else
			ChatManager.notification(TextUtils.ui("druzyna_tylko_szef_kieruje"));
	}

	public function take(rodzaj:String):void {
		if(Client.isTeamLeader()) {
			EquipmentServer.podniesSkrzynke("0");
			/*
			 if (rodzaj==2)
			 {
			 if (MainMc.getInstance().hero.getEkwipunek().znajdzPrzedmiot(Przedmiot.KLUCZ_SKRZYNKA)!=undefined)
			 MainMc.getInstance().server.podniesSkrzynke();
			 else
			 MainMc.getInstance().chatLeft.communicate(Text.ui("potrzebny_klucz_pl"));
			 }
			 else
			 {
			 MainMc.getInstance().server.podniesSkrzynke();
			 }
			 */
		}
		else
			ChatManager.notification(TextUtils.ui("druzyna_tylko_szef_kieruje"));
	}

	public function enterKraina(id:Number):void {
		if(Client.isTeamLeader()) {
//          MainMc.getInstance().mapa.pokazPotwierdzenieWejscia(id)
			trace("enterKraina id = " + id);
		}
		else
			ChatManager.notification(TextUtils.ui("druzyna_tylko_szef_kieruje"));
	}

	public function enterRoom(id:Number):void {
		if(Client.isTeamLeader()) {
			/*
			 //MovementManager.getInstance().setBlokada(true)
			 MovementManager.WALK_WAITING = true;
			 MapManager.getInstance().getMapa().teamMapView.zegar._visible = true;
			 MainMc.getInstance().server.wejdzDoPomieszczeniaP(id);
			 */
		}
		else
			ChatManager.notification(TextUtils.ui("druzyna_tylko_szef_kieruje"));
	}

	public function barter(team_id:String, user_id:Number):void {
		trace("MovementManager.barter " + team_id + "; user_id = " + user_id);

//       MainMc.getInstance().server.wymianaZapytanie(team_id,user_id);
		BarterServer.wymianaZapytanie(team_id, user_id);
	}

	public function useMechanism(id:String):void {
//		MovementServer.mechanicsAction(parseInt(id));
		_mechIdToUse = parseInt(id);
		var mech:Mechanism2DModel = MechanismManager.getInstance().getMechanismById(_mechIdToUse);

		if(mech.isDoors() && Settings.isMobile() || mech.mechanismData.clickConfirm) {
			UIManager.getInstance()
					.showConfirmWindow(Sprite(UIManager.getInstance().mainMenu), "Chcesz przejść?")
					.okPressedSignal.add(function (obj:Object):void {
						MovementServer.mechanicsAction(_mechIdToUse);
					});
		} else
			MovementServer.mechanicsAction(_mechIdToUse);

	}

	public function onBlockedByAI(type:int):void {
		if(type == 1) {
			cancelMovement();
			_blocked = true;
		}
		else {
			_blocked = false;
		}

	}


	/**
	 * if you want to convert back to tiles after previous conversion to pixelX, pixelY from tileX tileY
	 * @param x
	 * @param y
	 * @return
	 *
	 */
	public static function convertToTileXYReverse(x:Number, y:Number):Point {

		var dX:Number = (x ) / Tile.SIZE;
		var dY:Number = (-y) / Tile.SIZE / Settings.ORTOGRAPHIC_CONVERSION_FACTOR_HEIGHT;

		var tileX:int = Math.floor(dX);
		var tileY:int = Math.floor(dY);

		if(_instance == null || _instance.mapping == null) {
			return new Point(tileX, tileY);
		}

		var stepValue:int = _instance.mapping.getMapping(tileX, tileY);
		if(stepValue == 0) {
//            Dbg.trace("WARNING!!! mapping=0 stepValue = (" + tileX + "," + tileY + ") / dest: " + "(" + dX + "," + dY + ")");
			if(parseFloat((dX - int(dX)).toPrecision(3)) == 0.5) {
				if(_instance.mapping.getMapping(tileX - 1, tileY) != 0)
					tileX--;
				else if(_instance.mapping.getMapping(tileX + 1, tileY) != 0)
					tileX++;
//                else
//                    Dbg.trace("WARNING!!! XXX stepValue = (" + tileX + "," + tileY + ") / dest: " + "(" + dX + "," + dY + ")");
			}
			else {
				if(_instance.mapping.getMapping(tileX, tileY - 1) != 0)
					tileY--;
				else if(_instance.mapping.getMapping(tileX, tileY + 1) != 0)
					tileY++;
//                else
//                    Dbg.trace("WARNING!!! YYY stepValue = (" + tileX + "," + tileY + ") / dest: " + "(" + dX + "," + dY + ")");
			}
			//            tileY=tileY + (tileY%1 < 0.5 ? 1 : -1);
			stepValue = _instance.mapping.getMapping(tileX, tileY);
			if(stepValue == 0) {

				if(_instance.mapping.getMapping(Math.round(dX), tileY) != 0)
					tileX = Math.round(dX);
				else if(_instance.mapping.getMapping(tileX, Math.round(dY)) != 0)
					tileY = Math.round(dY);
				else if(_instance.mapping.getMapping(Math.round(dX), Math.round(dY)) != 0) {
					tileY = Math.round(dY);
					tileX = Math.round(dX);
				}
				else if(_instance.mapping.getMapping(Math.ceil(dX), Math.ceil(dY)) == 0) {
					Dbg.traceWin("WARNING - problem in finding path!!! stepValue = (" + tileX + "," + tileY + ") / dest: " + "(" + dX + "," + dY + ")");
					return findExisting(tileX, tileY, 1);
				}

			}
		}

		return new Point(tileX, tileY);
	}

	private static function findExisting(tileX:int, tileY:int, r:int = 1):Point {
		for(var x:int = tileX - r; x <= tileX + r; x++) {
			for(var y:int = tileY - r; y <= tileY + r; y++) {
				if(_instance.mapping.getMapping(x, y) != 0)
					return new Point(x, y);
			}
		}
		return findExisting(tileX, tileY, r + 1);
	}


	protected function convertToPixelCoords(path:Array):Array {
		var coords:Array = new Array();
		var pt:Point;
		for(var i:int = 0; i < path.length; i++) {
			pt = new Point();
			pt.x = CoordinatesHelper.fromTile2DTo3D_X(path[i].xPos);// + Tile.SIZE / 2;
			pt.y = CoordinatesHelper.fromTile2DTo3D_Y(path[i].yPos);// - Tile.SIZE / 2 * Settings.ORTOGRAPHIC_CONVERSION_FACTOR_HEIGHT;
			coords.push(pt);
		}

		var steps:Array = new Array();
		var stepsAmount:int;
		for(var j:int = 0; j < coords.length - 1; j++) {
			stepsAmount = getStepsAmount(coords[j], coords[j + 1], MovementManager.STEP_LENGTH);
			//trace("convertToPixelCoords stepsAmount = "+stepsAmount);
			steps.push(addDensity(coords[j], coords[j + 1], stepsAmount));
//
		}

		//wysypuje błąd przy ilości kroków == 1 czyli przy kliknieciu w pole na którym stoi postac
//		if (steps.length > 1)
//		    steps[steps.length-1].push(coords[coords.length - 1]);

		var result:Array = new Array();
		for(var k:int = 0; k < steps.length; k++) {
			for(var l:int = 0; l < steps[k].length; l++) {
				result.push(steps[k][l]);
			}
		}
		//Dbg.trace(path[0].xPos+","+path[0].yPos+ " / "+(result[0].x/ Tile.SIZE / Settings.ORTOGRAPHIC_CONVERSION_FACTOR_WIDTH)+","+(result[0].y/ Tile.SIZE / Settings.ORTOGRAPHIC_CONVERSION_FACTOR_HEIGHT));
		return result;
	}


	//creates Array of additional points, alredy contain p1 ( but not p2, thats why u have to add last point at the end)
	protected function addDensity(p1:Point, p2:Point, steps:int = 10):Array       //TODO powoduje przechodzenie przez niezamapowane obszary -> rozsynchronizowanie
	{
		var arr:Array = new Array();
		for(var i:int = 0; i < steps; i++) {
			arr.push(linePoint(p1, p2, i * 1 / steps));
		}
		return arr;
	}


	//gives how many steps between two points
	protected function getStepsAmount(p1:Point, p2:Point, stepLength:Number):int {
		var width:Number = Math.sqrt(Math.pow((p2.x - p1.x), 2) + Math.pow((p2.y - p1.y) / Settings.ORTOGRAPHIC_CONVERSION_FACTOR_HEIGHT, 2));
		var round:Number = Math.ceil(width / stepLength);

		if(round == 0) round = 1;
		return round;
	}

	//param should be between 0 and 1;
	protected function linePoint(p1:Point, p2:Point, param:Number):Point {
		//get the function base
		var x1:Number = p1.x;
		var y1:Number = p1.y;
		var x2:Number = p2.x;
		var y2:Number = p2.y;

//		var x:Number = Math.round(x1 + (x2 - x1) * param);      //zaokraglanie wyrzucone na poczet łamanych koordynatow
		var x:Number = x1 + (x2 - x1) * param;
		var y:Number;

		if(x2 != x1)
//			y = Math.round((x - x1) * (y2 - y1) / (x2 - x1)  + y1);
			y = (x - x1) * (y2 - y1) / (x2 - x1) + y1;
		else
//			y = Math.round(y1 +(y2 - y1) * param);
			y = y1 + (y2 - y1) * param;

		return new Point(x, y);
	}

//------------------------------------------------------------SERVER COMMUNICATION--------------------------------------
	public function onServerUpdate(x:int, y:int):void {
		_serverX = x;
		_serverY = y;

		UIManager.getInstance().coords.serverCoords(_serverX, _serverY, _mapping.getRegion(_serverX, _serverY));
//        Dbg.serverCoords(_serverX, _serverY);

		if(_waiting)
			stepByStep();
	}

	//pozycja w Tileach
	public function updateServerPosition(x:int, y:int):void {
		_serverX = x;
		_serverY = y;

		UIManager.getInstance().coords.serverCoords(_serverX, _serverY, _mapping.getRegion(_serverX, _serverY));
	}

	//pozycja w Tileach
	public function updateLocalPosition(x:int, y:int):void {
		_localX = x;
		_localY = y;

//        UIManager.getInstance().coords.localCoords(_localX, _localY);
		Client.myTeam.updateCoords(x, y);
		UIManager.getInstance().coords.localCoordsAnd3D(_localX, _localY, Client.myTeam.x, Client.myTeam.y);
		TaernSoundEngine.instance.soundReload(x * 20, y * 20);
	}

	public function onSynchronize(x:Number, y:Number):void {
		Dbg.traceWin("RESYNCHRONIZE: " + x + " , " + y + " / " + _serverX + "," + _serverY);
		updateLocalPosition(x, y);
		updateServerPosition(x, y);
		_pixelPath.splice(0);

		Actuate.stop(Client.myTeam.team3D, null);
//        Tweener.removeTweens(Client.myTeam.team3D);

		Client.myTeam.modelGoTo(Client.myTeam.x, Client.myTeam.y);
//        Client.myTeam.team3D.x=Client.myTeam.x;
//        Client.myTeam.team3D.z=Client.myTeam.y;

	}


	public function getStepsToGo():int {
		var lastStepIndex:int = 0;
		switch(AUTO_ACTION.action) {
			case TeamActionType.ACTION_MOVE:
			case TeamActionType.ACTION_JOIN:
			case TeamActionType.ACTION_TAKE:
				lastStepIndex = 0;
				break;
			case TeamActionType.ACTION_FIGHT:
			case TeamActionType.ACTION_TALK:
			case TeamActionType.ACTION_MECHANISM:
				lastStepIndex = 1;
				break;
		}
		return _pixelPath.length - lastStepIndex;
	}

	//--------------------------------------------------------------GETTERS & SETTERS-----------------------------
	public function get serverX():Number {
		return _serverX;
	}

	public function set serverX(value:Number):void {
		_serverX = value;
	}

	public function get serverY():Number {
		return _serverY;
	}

	public function set serverY(value:Number):void {
		_serverY = value;
	}

	public function get localX():Number {
		return _localX;
	}

	public function set localX(value:Number):void {
		_localX = value;
	}

	public function get localY():Number {
		return _localY;
	}

	public function set localY(value:Number):void {
		_localY = value;
	}

	public function get mapping():Mapping {
		return _mapping;
	}

	public function set mapping(value:Mapping):void {
		_mapping = value;
	}

	public static function set instance(value:MovementManager):void {
		_instance = value;
	}


	public function get pixelPath():Array {
		return _pixelPath;
	}
}
}

