package com.laserdragonuniversity.alpaca {
	
	import flash.events.*;
	import com.adobe.serialization.json.*;
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.net.SharedObject;
	import flash.net.*;
	import flash.display.Loader;
	import flash.utils.getDefinitionByName;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class SaveRestore extends MovieClip {
		
		private var inv:Inventory;
		private var puzzle:Puzzle;
		private var player:Player;
		private var back:Background;
		private var options:Options;
		private var stageRef:Stage;
		private var shared:SharedObject;
		private var useExternalFile:Boolean = false; //Set this to false if you don't want to deal with server-side scripts
		private var useShared:Boolean = true; // Set this to false if you don't want to use Flash player's local memory
		private var exLoader:URLLoader;
		private var exReq:URLRequest;
		private var saveURL:String;
		private var saveID:String;
		private var userID:String;
		private var checkDialog:MovieClip;
		private var slotsTaken:Array = new Array(false, false, false);
		private var currentEvent;
		private var confirm:MovieClip;
		
		private var allSaveData:Object;

		public function SaveRestore(stageRef:Stage, saveURL:String, saveID:String) {
			
			this.stageRef = stageRef;
			this.saveURL = saveURL;
			this.saveID = saveID;
			
			switchSave.gotoAndStop("on");
			switchRestore.gotoAndStop("off");
			
			// Un-comment this if you want save data to be cleared each time the SWF is opened
			// Probably only necessary for testing purposes
			//shared = SharedObject.getLocal(saveID);
			//shared.clear();
			
			populateSaves();
			
			restore1.visible = false;
			restore2.visible = false;
			restore3.visible = false;
			
			checkDialog = new saveOverwrite;
			addChild(checkDialog);
			checkDialog.visible = false;
			
			addEventListener(Event.ADDED_TO_STAGE, setUpListeners);
		}
		
		public function populateSaves(){
			if(useExternalFile){
				// Here's where you can grab data from external .js files if you choose. This will require the use of server-side scripts
			} else if(useShared){
				shared = SharedObject.getLocal(saveID);
				var saveNum:String;
				var shotNum:String;
				for (var i = 1; i < 4; i++){
					saveNum = "save" + i;
					if (shared.data[saveNum]){
						slotsTaken[i-1] = true;
						var thisSave = JSON.parse(shared.data[saveNum]);
						this[saveNum].savedetail.text = thisSave.datetime;
						this["restore"+i].savedetail.text = thisSave.datetime;
						
						// Use a MovieClip of the background as a screenshot
						var bg:Object = fakeScreenshot(thisSave.playerLoc.room);
						this["save"+i].addChild(bg.bg);
						this["save"+i].addChild(bg.bgmask);
						
						var bg2:Object = fakeScreenshot(thisSave.playerLoc.room);
						this["restore"+i].addChild(bg2.bg);
						this["restore"+i].addChild(bg2.bgmask);
						
					}
				}
				
			}
		}
		
		public function setUpListeners(e){
			switchSave.addEventListener(MouseEvent.CLICK, gotoSave, false, 0, true);
			switchSave.buttonMode = true;
			switchRestore.addEventListener(MouseEvent.CLICK, gotoRestore, false, 0, true);
			switchRestore.buttonMode = true;
			
			save1.btn.addEventListener(MouseEvent.CLICK, overwriteCheck, false, 0, true);
			save2.btn.addEventListener(MouseEvent.CLICK, overwriteCheck, false, 0, true);
			save3.btn.addEventListener(MouseEvent.CLICK, overwriteCheck, false, 0, true);
			
			
			restore1.btn.addEventListener(MouseEvent.CLICK, restore, false, 0, true);
			restore2.btn.addEventListener(MouseEvent.CLICK, restore, false, 0, true);
			restore3.btn.addEventListener(MouseEvent.CLICK, restore, false, 0, true);
			
			checkDialog.canceller.addEventListener(MouseEvent.CLICK, cancelled, false, 0, true);
			checkDialog.saver.addEventListener(MouseEvent.CLICK, overwrite, false, 0, true);
			
			
			closer.addEventListener(MouseEvent.CLICK, closeSaver, false, 0, true);
			addEventListener("closeThis", closeSaver);
		}
		
		public function gotoSave(e){
			gotoAndStop("save");
			switchSave.gotoAndStop("on");
			switchRestore.gotoAndStop("off");
			
			restore1.visible = false;
			restore2.visible = false;
			restore3.visible = false;
			
			save1.visible = true;
			save2.visible = true;
			save3.visible = true;
		}
		
		public function gotoRestore(e){
			gotoAndStop("restore");
			switchSave.gotoAndStop("off");
			switchRestore.gotoAndStop("on");
			
			restore1.visible = true;
			restore2.visible = true;
			restore3.visible = true;
			
			save1.visible = false;
			save2.visible = false;
			save3.visible = false;
		}
		
		public function showSaver(){
			if(checkDialog.visible){
				checkDialog.visible = false;
			}
			populateSaves();
			visible = true;
			Engine.playerControl = false;
			gotoSave(null);
		}
		
		public function overwriteCheck(e){
			currentEvent = e;
			var parentBtn = e.target.parent.name;
			var slotNum = parentBtn.substr(parentBtn.length-1, 1);
			if (slotsTaken[slotNum-1]){
				trace("Save taken, confirming overwrite");
				checkDialog.visible = true;
			} else {
				save(e);
			}
		}
		
		public function cancelled(e){
			showSaver();
		}
		
		public function overwrite(e){
			save(currentEvent);
		}
		
		public function save(e){
			puzzle = Engine.puzzle;
			inv = Engine.inv;
			player = Engine.player;
			back = Engine.back;
			options = Engine.options;
			
			var saveNum:String = e.target.parent.name;
								   
			//Get the status of all the puzzles
			allSaveData = new Object;
			allSaveData.puzzleStatus = new Object;
			allSaveData.puzzleStatus = puzzle.returnPuzzles();
			
			//Get the inventory
			allSaveData.allInv = new Array();
			var allItems =  inv.returnItems("all");
			for (var i in allItems){
				if(allItems[i].displayName){
					//trace ("Saving " + allItems[i]);
					allSaveData.allInv.push(allItems[i].displayName);
				}
			}
			allSaveData.currentInv = new Array();
			var currentItems = inv.returnItems(null);
			for (i in currentItems){
				allSaveData.currentInv.push([currentItems[i].displayName, currentItems[i].lookTag]);
			}
			
			//Get the player's current location
			allSaveData.playerLoc = new Object;
			allSaveData.playerLoc.x = player.x;
			allSaveData.playerLoc.y = player.y;
			allSaveData.playerLoc.scaleX = player.scaleX;
			allSaveData.playerLoc.room = back.currentBack.name;
			
			//Get the settings
			allSaveData.optset = options.saveOptions();
			
			// Get the date and time
			var thisDate = new Date;
			var dateString = thisDate.toLocaleString();
			allSaveData.datetime = dateString;
			
			var jsonSave = JSON.stringify(allSaveData);
			trace("Saving: " + jsonSave);
			
			//Save data in local memory
			if(useShared){
				shared = SharedObject.getLocal(saveID);
				shared.data[saveNum] = jsonSave;
				shared.flush();
			}
			
			if(useExternalFile){
				// Here's where you can post the data to a server-side script and save it as an external .js file
				// The trick would be to figure out how to distinguish one user from another
				// Either by creating login functionality, or just identifying by IP or something like that 
			}
			
			//Update save info
			e.target.parent.savedetail.text = dateString;
			showConfirm("saved", saveNum.substr(saveNum.length-1, 1));
			dispatchEvent(new Event("closeThis"));
		}
		
		private function restore(e){
			puzzle = Engine.puzzle;
			inv = Engine.inv;
			player = Engine.player;
			back = Engine.back;
			options = Engine.options;
			
			var parentBtn = e.target.parent.name;
			var slotNum = parentBtn.substr(parentBtn.length-1, 1);
			var saveNum = "save" + slotNum;
			trace(saveNum);
		
			Engine.restoring = true;
			
			allSaveData = null;
			
			if(useExternalFile){
				// Get data from external .js file
			} else if (useShared){
				// Get data from local memory
				shared = SharedObject.getLocal(saveID);
				if(shared.data[saveNum]){
					trace("Restoring: " + shared.data[saveNum]);
					allSaveData = new Object;
					allSaveData = JSON.parse(shared.data[saveNum]);
				}
			}
			
			// Restore game data
			if(allSaveData){
				puzzle.restorePuzzles(allSaveData.puzzleStatus);
				inv.restoreInv(allSaveData.currentInv, allSaveData.allInv);
				options.restoreOptions(allSaveData.optset);
				
				Engine.newBack = allSaveData.playerLoc.room;
				addEventListener("repose", reposePlayer);
				stageRef.dispatchEvent(new Event("changeBackground"));
				showConfirm("restored", slotNum);
				dispatchEvent(new Event("closeThis"));
			} else {
				trace ("No save data found");
				Engine.restoring = false;
			}
			
		}
		
		private function fakeScreenshot(bgName:String):Object{
			// Flash's local memory is too small to contain real screenshots, so we can fake it by creating an instance of the background
			var fakeShot:Object = new Object;
			var bgRef = getDefinitionByName(bgName);
			var bg = new bgRef;
			
			// Remove all the interface junk from the background movieclip
			for (var c = 0; c < bg.numChildren; ++c){
				var thisChild = bg.getChildAt(c);
				if (thisChild.name.search("_L") != -1 || 
					thisChild.name.search("_U") != -1 || 
					thisChild.name.search("_G") != -1 || 
					thisChild.name.search("_T") != -1 ){ 
					
					if (thisChild.usePoint)
						thisChild.usePoint.visible = false;
				}
				if(thisChild.name.search("_O") != -1){
					thisChild.usePoint.visible = false;
					thisChild.depthSplit.visible = false;
					thisChild.nodeUL.visible = false;
					thisChild.nodeUR.visible = false;
					thisChild.nodeLR.visible = false;
					thisChild.nodeLL.visible = false;
				}
				if (thisChild.name.search("EXIT") != -1)
					thisChild.visible = false;
				
				if (thisChild.name.search("startPoint") != -1)
					thisChild.visible = false;
			}
			
			bg.scaleX = .1;
			bg.scaleY = .1;
			bg.x = 10;
			bg.y = 5;
	
			var bgmask:MovieClip = new MovieClip;
			bgmask.graphics.beginFill(0x000000, .5);
			bgmask.graphics.drawRect(0, 0, 70, 45);
			bgmask.graphics.endFill();
			bgmask.x = bg.x;
			bgmask.y = bg.y;
			bg.mask = bgmask;
			
			fakeShot.bg = bg;
			fakeShot.bgmask = bgmask;
			
			return fakeShot;
			
		}
		
		private function reposePlayer(e){
			player = Engine.player;
			player.x = allSaveData.playerLoc.x;
			player.y = allSaveData.playerLoc.y;
			player.scaleX = allSaveData.playerLoc.scaleX;
		}
		
		private function showConfirm(type:String, slot){
			confirm = null;
			confirm = new MovieClip;
			confirm.graphics.beginFill(0x000000, .75);
			confirm.graphics.drawRoundRect(0, 0, 200, 25, 10);
			confirm.graphics.endFill();
			
			stageRef.addChild(confirm);
			
			var conftext:TextField = new TextField();
			conftext.text =  "Game " + type + " at slot " + slot;
			
			var format1:TextFormat = new TextFormat();
			format1.font = "Arial";
			format1.size = 18;
			format1.color = 0xFFFFFF;
			conftext.setTextFormat(format1);
			
			conftext.width = confirm.width - 5;
			conftext.x = 5;
			
			confirm.addChild(conftext);
			confirm.addEventListener(Event.ENTER_FRAME, fadeConf);
			
		}
		
		private function fadeConf(e){
			if (confirm.alpha > 0){
				confirm.alpha -= .05;
			} else {
				confirm.removeEventListener(Event.ENTER_FRAME, fadeConf);
				stageRef.removeChild(confirm);
			}
		}
		
		private function closeSaver(e):void{
			visible = false;
			Engine.playerControl = true;
			Engine.toolbar.dispatchEvent(new Event("closedWindow"));
		}
	}
}
