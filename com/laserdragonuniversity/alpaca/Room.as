package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;

	public class Room extends MovieClip{
		
		private var stageRef:Stage;
		private var player:Player;
		private var walkRate:Number = 10;
		public static var obstacles:Array = new Array();
		public static var usableItems:Array = new Array();
		public static var backgroundMusic:String = "audio/terra.mp3";
		
		public function Room(stageRef:Stage){
			this.stageRef = stageRef;
			
			stop();
			
			stageRef.dispatchEvent(new Event("removeSnow"));
			
			// Define everything the player needs to avoid while moving
			obstacles.push(box);
			
			for (var o in obstacles){
				obstacles[o].depthSplit.visible = false;
				obstacles[o].nodeUL.visible = false;
				obstacles[o].nodeUR.visible = false;
				obstacles[o].nodeLL.visible = false;
				obstacles[o].nodeLR.visible = false;
			}
			
			
			// Define all the items the player can use
			usableItems.push(box);
			
			
			
			for (var i in usableItems){
				if (usableItems[i].usePoint){
					usableItems[i].usePoint.visible = false;
				}
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
			if (player.x > 650){
				Engine.newBack = "tundra";
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