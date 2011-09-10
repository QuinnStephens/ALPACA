package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;

	public class Tundra extends MovieClip{
		
		private var stageRef:Stage;
		private var walkRate:Number = 10;
		public static var obstacles:Array = new Array();
		public static var usableItems:Array = new Array();
		public static var backgroundMusic:String = "audio/terra.mp3";
		private var player:Player;
		
		public function Tundra(stageRef:Stage){
			
			stop();
			this.stageRef = stageRef;
			
			// Define everything the player needs to avoid while moving
			for (var c = 0; c < numChildren; ++c){
				var thisChild = getChildAt(c);
				if (thisChild.name.search("_O") != -1){
					obstacles.push(thisChild);
				}
			}
			
			
			for (var o in obstacles){
				obstacles[o].depthSplit.visible = false;
				obstacles[o].nodeUL.visible = false;
				obstacles[o].nodeUR.visible = false;
				obstacles[o].nodeLL.visible = false;
				obstacles[o].nodeLR.visible = false;
			}
			
			
			// Define all the items the player can use
			for (var u = 0; u < numChildren; ++u){
				thisChild = getChildAt(u);
				if (thisChild.name.search("_U") != -1){
					usableItems.push(thisChild);
				}
			}
			
			
			for (var i in usableItems){
				if (usableItems[i].usePoint){
					usableItems[i].usePoint.visible = false;
				}
			}
			
			//Make it snow
			
			for (var s:int = 0; s < 100; s++){
				stageRef.addChildAt(new Snowflake(stageRef), 1);
			}
			
		}
		
		public function addListeners():void{
			player = Engine.player;
			player.addEventListener("playerWalking", checkExit, false, 0, true);
			player.addEventListener("reachedPoint", stopCheck, false, 0, true);
		}

		
		private function checkExit(e:Event):void{
			addEventListener(Event.ENTER_FRAME, checkPlayerLoc, false, 0, true);
		}
		
		private function checkPlayerLoc(e:Event):void{
			if (player.x < 50){
				Engine.newBack = Room;
				stageRef.dispatchEvent(new Event("changeBackground"));
				removeEventListener(Event.ENTER_FRAME, checkPlayerLoc);
			}
		}
		
		private function stopCheck(e:Event):void{
			removeEventListener(Event.ENTER_FRAME, checkPlayerLoc);
		}
		
		public function returnObstacles():Array{
			return obstacles;
		}

		public function returnItems():Array{
			return usableItems;
		}
		
		public function returnMusic():String{
			return backgroundMusic;
		}
		
	}// end class
}// end package