package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.display.DisplayObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.adobe.serialization.json.*;
	
	public class Engine extends MovieClip{
		
		public static var player:Player;
		public static var back:Background;
		public static var newBack:String;
		public static var toolbar:Toolbar;
		public static var inv:Inventory;
		public static var options:Options;
		public static var saver:SaveRestore;
		public static var useBox:UseBox;
		public static var puzzle:Puzzle;
		
		private var opening:MovieClip;
		private var ending:MovieClip;
		
		public static var obstacles:Array = new Array();
		public static var usableItems:Array = new Array();
		public static var foreground:Array = new Array();
		public static var exits:Array = new Array();
		
		private var musicURL:String;
		private var endMusicURL:String;
		private var saveURL:String;
		private var saveID:String;
		
		public static var useAudio:Boolean;
		private var playerScale:Number;
		private var walkRate:Number;
		public static var targetBuffer;
		public static var playerName:String;
		public static var playerControl:Boolean = true;
		public static var restoring:Boolean = false;
		
		private var firstLocation:String;
		public static var lastLocation:String;
		
		public static var configData:Object = new Object;
		public static var linesData:Object = new Object;
		private var speechLoader:URLLoader;
		private var configLoader:URLLoader;
		
		private var rmenu:RightClickMenu = new RightClickMenu();
		
		public function Engine(){
			/* This roundabout code is necessary to allow the exported alpaca.swf to be dynamically loaded
			into container.swf (that way we can make a load progress bar).  We get errors without it.
			This can cause movie clips to behave strangely sometimes - you may need to put code in certain
			clips in order to ensure that they stay stopped on the first frame like they're supposed to */
			addEventListener(Event.ADDED_TO_STAGE, startGame);
		}
		
		private function startGame(e:Event):void{
			
			removeEventListener(Event.ADDED_TO_STAGE, startGame);
			
			// Load external configuration data
			var jsURL = new URLRequest("data/config.js");
			configLoader = new URLLoader(jsURL);
			configLoader.addEventListener("complete", configLoaded);
			
			// Load all spoken lines
			jsURL = new URLRequest("data/speechlines.js");
			speechLoader = new URLLoader(jsURL);
			speechLoader.addEventListener("complete", linesLoaded);
			
			// Change the context menu to link back to the ALPACA home page
			// This doesn't always work, for some reason
			contextMenu = rmenu.returnMenu();
			
			stage.addEventListener("changeBackground", changeBackground, false, 0, true);
		} 
		
		private function linesLoaded(e:Event):void{
			linesData = JSON.parse(speechLoader.data);
		}
		
		private function configLoaded(e:Event):void{
			configData = JSON.parse(configLoader.data);
			useAudio = configData.useAudio;
			playerScale = configData.playerScale;
			walkRate = configData.walkRate;
			targetBuffer = configData.targetBuffer;
			playerName = configData.playerName;
			firstLocation = configData.firstLocation;
			musicURL = configData.musicURL;
			endMusicURL = configData.endMusicURL;
			saveURL = configData.saveURL;
			saveID = configData.saveID;
			
			createBackground(firstLocation);
			createUI();

			// This needs to be here or Flash gets annoyed
			useBox = new UseBox(stage, usableItems[0]);
			
			// Add the intro screen over everything else
			// This can be a fully animated intro if we want - anything that fits in a movie clip
			opening = new introScreen;
			addChild(opening);
			opening.addEventListener(MouseEvent.CLICK, removeIntro, false, 0, true);
		}
		
		private function createBackground(thisBack:String):void{
			trace("Creating new background: "+thisBack);
			var playerLoc:MovieClip;
			
			back = new Background(stage, thisBack);
			addChild(back);
			obstacles = back.returnObstacles();
			for (var i in obstacles){
				addChild(obstacles[i]);
			}
			
			if (restoring){
				playerLoc = new MovieClip();
				playerLoc.x = 0;
				playerLoc.y = 0;
			} else if (lastLocation){
				var lastLocName = "startPoint_"+lastLocation; 
				playerLoc = back.currentBack[lastLocName];
			} else {
				playerLoc = back.currentBack.startPoint;
			}
			
			player = new Player(stage, walkRate, targetBuffer);
			if (playerLoc.x > stage.stageWidth / 2){
				player.scaleX = -playerScale;
			}else {
				player.scaleX = playerScale;
			}
			player.scaleY = playerScale;
			player.x = playerLoc.x;
			player.y = playerLoc.y;
			
			if (restoring){
				saver.dispatchEvent(new Event("repose"));
				restoring = false;
			}
			
			addChild(player);
			player.addEventListener("playerWalking", startDepth, false, 0, true);
			player.name = playerName;
			
			foreground = back.returnForeground();
			for (i in foreground){
				addChild(foreground[i]);
			}
			
			usableItems = back.returnItems();
			exits = back.returnExits();
			for (i in exits){
				addChild(exits[i]);
			}
			
			// Add event listeners for all the usable items
			for (i in usableItems){
				var thisClip = usableItems[i];
				thisClip.buttonMode = true;
				thisClip.addEventListener(MouseEvent.CLICK, examine, false, 0, true);
				thisClip.gotoAndStop(1);
			}
			
			back.currentBack.ground.addEventListener(MouseEvent.CLICK, movePlayer, false, 0, true);
			
			// Keep the toolbar at the highest depth
			if (toolbar){
				puzzle.newBackground(thisBack);
				changeUIDepth();
				toolbar.addListeners();
				
				// Remove any items the player has already picked up
				var allInv:Array = inv.returnItems("all");
				for (i in usableItems){
					for (var j in allInv){
						if (usableItems[i].displayName == allInv[j].displayName){
							usableItems[i].visible = false;
						}
					}
				}
			}
			
		}
		
		private function changeBackground(e:Event){
			back.clearStage();
			removeChild(back);
			for (var i in obstacles){
				removeChild(obstacles[i]);
				obstacles[i].visible = false;
			}
			for (i in foreground){
				removeChild(foreground[i]);
				foreground[i].visible = false;
			}
			for (i in usableItems){
				usableItems[i].visible = false;
			}
			for (i in exits){
				removeChild(exits[i]);
				exits[i].visible = false;
			}
			removeChild(player);
			createBackground(newBack);
		}
			
		
		private function createUI():void{
			
			toolbar = new Toolbar(stage);
			addChild(toolbar);
			toolbar.x = 0;
			toolbar.y = 400;

			inv = new Inventory(stage);
			addChild(inv);
			inv.x = 100;
			inv.y = 50;
			inv.visible = false;
			
			options = new Options(stage, musicURL);
			addChild(options);
			options.x = 100;
			options.y = 50;
			options.visible = false;
			
			saver = new SaveRestore(stage, saveURL, saveID);
			addChild(saver);
			saver.x = 100;
			saver.y = 50;
			saver.visible = false;
			
			puzzle = new Puzzle(stage);
			
			stage.addEventListener("endGame", endGame, false, 0, true);
		}
		
		private function removeIntro(e:MouseEvent):void{
			removeChild(opening);
			opening.removeEventListener(MouseEvent.CLICK, removeIntro);
			puzzle.firstAction();
		}
		
		private function movePlayer(e:MouseEvent):void{
			if (playerControl){
				stage.dispatchEvent(new Event("playerMoving"));
				player.startWalking(mouseX, mouseY);
				if (stage.contains(useBox)){
					stage.removeChild(useBox);
				}
			}
		}
		
		private function examine(e:MouseEvent):void{
			if (player.hasEventListener(Event.ENTER_FRAME)==false){
				stage.dispatchEvent(new Event("itemClicked"));
				if (inv.draggingItem == false  && playerControl){
					useBox = new UseBox(stage, e.currentTarget);
					useBox.x = mouseX;
					useBox.y = mouseY;
					stage.addChild(useBox);
				}
			}
		}
		
		private function startDepth(e:Event):void{
			addEventListener(Event.ENTER_FRAME, checkPlayerDepth, false, 0, true);
		}
		
		private function checkPlayerDepth(e:Event):void{
			if (player.currentLabel == "walk"){
				var playerDepth = getChildIndex(player);
				for (var i in obstacles){
					var blockDepth = getChildIndex(obstacles[i]);
					if (player.y > obstacles[i].depthSplit.y + obstacles[i].y && playerDepth < blockDepth){
						changePlayerDepth("front", obstacles[i]);
					} 
					if (player.y < obstacles[i].depthSplit.y + obstacles[i].y && playerDepth > blockDepth){
						changePlayerDepth("behind", obstacles[i]);
					}
				}
			}else {
				removeEventListener(Event.ENTER_FRAME, checkPlayerDepth);
			}
			
		}
		
		private function changePlayerDepth(where:String, what:MovieClip):void{
			
			var playerindex = getChildIndex(player);
			var otherindex = getChildIndex(what);
			
			if (where == "behind"){
				setChildIndex(player, otherindex);
			} else {
				setChildIndex(what, playerindex);
				setChildIndex(player, otherindex);
			}
		}
			
		private function changeUIDepth():void{
			
			setChildIndex(toolbar, 0);
			setChildIndex(inv, 0);
			for (var i in exits){
				setChildIndex(exits[i], 0);
			}
			for (i in foreground){
				setChildIndex(foreground[i], 0);
			}
			setChildIndex(player, 0);
			for (i in obstacles){
				setChildIndex(obstacles[i], 0);
			}
			
			back.gotoBack();
			
		}
			
		private function endGame(e:Event):void{
			ending = new endScreen;
			addChild(ending);
			options.changeMusic(endMusicURL);
		}
	} //end Engine class
} // end package