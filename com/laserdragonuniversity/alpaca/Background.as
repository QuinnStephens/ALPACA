package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.utils.getDefinitionByName;

	public class Background extends MovieClip{
		
		private var stageRef:Stage;
		public static var obstacles:Array = new Array();
		public static var usableItems:Array = new Array();
		public static var foreground:Array = new Array();
		public static var exits:Array = new Array();
		public var currentBack:MovieClip;
		private var player:Player;
		private var puzzle:Puzzle;
		private var exitPoint:String;
		private var exitLoc:Array = new Array();
		private var targetBuffer:int;
		
		public function Background(stageRef:Stage, inputBack:String){
			this.stageRef = stageRef;
			this.puzzle = Engine.puzzle;
			targetBuffer = Engine.targetBuffer;
			var backMC = getDefinitionByName(inputBack);
			currentBack = new backMC;
			currentBack.name = inputBack;
			stageRef.addChildAt(currentBack, 0);
			
			// Extract all the items and obstacles from the background movieclip
			// Make sure to name your item instances properly!
			for (var c = 0; c < currentBack.numChildren; ++c){
				var thisChild = currentBack.getChildAt(c);
				
				if (thisChild.name.search("_L") != -1 || 
					thisChild.name.search("_U") != -1 || 
					thisChild.name.search("_G") != -1 || 
					thisChild.name.search("_T") != -1 ){ // Check if item is look-at-able
					usableItems.push(thisChild);
					var isUsable:Boolean = false;
					var isGettable:Boolean = false;
					var isTalkable:Boolean = false;
					if (thisChild.name.search("_U") != -1){ // Check if item is usable
						isUsable = true;
					}
					if (thisChild.name.search("_G") != -1){ // Check if item is gettable
						isGettable = true;
						isUsable = true;
					}
					if (thisChild.name.search("_T") != -1){ // Check if item is talk-to-able
						isTalkable = true;
						isUsable = true;
					}
					//applyAttributes(thisChild, isUsable, isGettable, isTalkable);
					thisChild.usable = isUsable;
					thisChild.gettable = isGettable;
					thisChild.talkable = isTalkable;
					// Create a display name without all the random letters
					var underscore:int = thisChild.name.search("_");
					thisChild.displayName = thisChild.name.slice(0, underscore).toUpperCase();
				}
				if (thisChild.name.search("_O") != -1){ // Check if item is an obstacle
					obstacles.push(thisChild);
				}
				if (thisChild.name.search("_F") != -1){ // Check if the item is a foreground element
					foreground.push(thisChild);
				}
				if (thisChild.name.search("EXIT") != -1){ // Add functionality for the exits
					exits.push(thisChild);
					thisChild.alpha = 0;
					thisChild.buttonMode = true;
					thisChild.addEventListener(MouseEvent.MOUSE_OVER, showExit, false, 0, true);
					thisChild.addEventListener(MouseEvent.MOUSE_OUT, hideExit, false, 0, true);
					thisChild.addEventListener(MouseEvent.CLICK, leaveRoom, false, 0, true);
				}
				
				if (thisChild.name.search("startPoint") != -1)
					thisChild.visible = false;
			}
			
			
			for (var o in obstacles){
				obstacles[o].depthSplit.visible = false;
				obstacles[o].nodeUL.visible = false;
				obstacles[o].nodeUR.visible = false;
				obstacles[o].nodeLL.visible = false;
				obstacles[o].nodeLR.visible = false;
				if (obstacles[o].usePoint)
					obstacles[o].usePoint.visible = false;
			}
			
			
			// Define all the items the player can use
			for (var u = 0; u < currentBack.numChildren; ++u){
				thisChild = currentBack.getChildAt(u);
				if (thisChild.name.search("_U") != -1){
					usableItems.push(thisChild);
				}
			}
			
			
			for (var i in usableItems){
				if (usableItems[i].usePoint){
					usableItems[i].usePoint.visible = false;
				}
			}
			

		}
		/*
		private function applyAttributes(thisItem:MovieClip, isUsable:Boolean, isGettable:Boolean, isTalkable:Boolean):void{
			thisItem.usable = isUsable;
			thisItem.gettable = isGettable;
			thisItem.talkable = isTalkable;
		}*/
		
		private function showExit(e:MouseEvent):void{
			if (Engine.playerControl)
				e.currentTarget.alpha = 1;
		}
		
		private function hideExit(e:MouseEvent):void{
			e.currentTarget.alpha = 0;
		}
		
		private function leaveRoom(e:MouseEvent):void{
			player = Engine.player;
			if (Engine.playerControl){
				stageRef.dispatchEvent(new Event("itemClicked"));
				var thisExit = e.currentTarget;
				//targetBuffer = player.returnTargetBuffer();
				var underscore = thisExit.name.search("_");
				var nextRoom:String = thisExit.name.substring(underscore + 1);
				Engine.newBack = nextRoom;
				exitPoint = "startPoint_"+nextRoom;
				exitLoc[0] = currentBack[exitPoint].x;
				exitLoc[1] = currentBack[exitPoint].y;
			
				player.addEventListener("reachedPoint", reachedExit, false, 0, true);
	
				// Make sure the player isn't already at the exit point
				if (checkForExit()){
					player.dispatchEvent(new Event("reachedPoint"));
				} else {
					player.startWalking(exitLoc[0], exitLoc[1]);
				}
			}
			
		}
		
		private function reachedExit(e:Event):void{
			if (checkForExit()){
				Engine.lastLocation = currentBack.name;
				stageRef.dispatchEvent(new Event("changeBackground"));
			}
		}
		
		private function checkForExit():Boolean{
			var exitX = exitLoc[0];
			var exitY = exitLoc[1];
			if (player.x > (exitX-targetBuffer) && player.x < (exitX+targetBuffer) && player.y > (exitY-targetBuffer) && player.y < (exitY+targetBuffer)){
				return true;
			} else{
				return false;
			}
		}
		/*
		public function returnIndex():int{
			var index = stageRef.getChildIndex(currentBack);
			return index;
		}*/
		
		public function gotoBack():void{
			stageRef.setChildIndex(currentBack, 0);
		}
		
		public function returnObstacles():Array{
			return obstacles;
		}
		
		public function returnForeground():Array{
			return foreground;
		}

		public function returnItems():Array{
			return usableItems;
		}
		
		public function returnExits():Array{
			return exits;
		}
		
		public function clearStage():void{
			stageRef.removeChild(currentBack);
			obstacles = new Array();
			usableItems = new Array();
		}
		
	}// end class
}// end package