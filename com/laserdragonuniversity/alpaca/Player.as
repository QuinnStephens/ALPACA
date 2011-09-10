package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.display.DisplayObject;

	public class Player extends MovieClip{
		
		private var stageRef:Stage;
		public var walkRate:Number;
		private var targetBuffer:Number;
		private var xinc:Number;
		private var yinc:Number;
		public var targetX:Number;
		public var targetY:Number;
		private var isAvoiding:Boolean = false;
		public var currentBlock:MovieClip = new MovieClip;
		private var nodePath:Array = new Array();
		private var whichNode = 0;
		private var playerQuad;
		private var obstacles:Array;
		
		//public var hasControl:Boolean = true;
		
		public function Player(stageRef:Stage, walkRate:Number, targetBuffer:Number){
			gotoAndStop("default");
			this.stageRef = stageRef;
			this.walkRate = walkRate;
			this.targetBuffer = targetBuffer;
			obstacles = Engine.obstacles;
		}
		
		public function startWalking(inputX:Number, inputY:Number):void{
			targetX = inputX;
			targetY = inputY;
			 
			getIncrements(targetX, targetY);
			
			gotoAndStop("walk");
			addEventListener(Event.ENTER_FRAME, walk, false, 0, true);
			addEventListener("reachedPoint", stopWalking, false, 0, true);
			dispatchEvent(new Event("playerWalking"));
			//addEventListener(Event.ENTER_FRAME, Engine.checkPlayerDepth, false, 0, true);
		}
		
		public function walk(e:Event):void{
			//Move the player as long as it's not colliding with anything
			if (testForHit()==false || isAvoiding == true){
				x += xinc;
				y += yinc;
				orientPlayer();
			}else{
				removeEventListener(Event.ENTER_FRAME, walk);
				// Find the path around the block
				// Get an array of nodes from the findPath function
				nodePath = findPath();
				// Move the player around the block
				addEventListener(Event.ENTER_FRAME, avoidBlock, false, 0, true);
			}
			
			// Stop the player once it's within targetBuffer pixels of where the user clicked	
			if (x > (targetX-targetBuffer) && x < (targetX+targetBuffer) && y > (targetY-targetBuffer) && y < (targetY+targetBuffer)){
				dispatchEvent(new Event("reachedPoint"));
			}
		}
		
		private function orientPlayer():void{
			// Make sure the player is pointed in the right direction
			if (xinc < 0 && scaleX > 0){
				scaleX = -scaleX;
			}
			if (xinc > 0 && scaleX < 0){
				scaleX = -scaleX;
			}
		}
		
		private function testForHit(){
			
			var blockTemp:MovieClip = new MovieClip();
			var isHit:Boolean = false;
			
			for (var h = 0; h < Engine.obstacles.length; ++h){
				blockTemp = Engine.obstacles[h];
				if (hitspot.hitTestObject(blockTemp.proper)){
					currentBlock = Engine.obstacles[h];
					if (Engine.obstacles[h].visible){
						isHit = true;
					}
				}
			}
			if (isHit == false){
				isAvoiding = false;
			}
			return isHit;
			
		}
		
		public function stopWalking(e:Event):void{
			removeEventListener(Event.ENTER_FRAME, walk);
			gotoAndStop("default");
			isAvoiding = false;
		}
		
		private function getIncrements(targetX, targetY):void{
			var xdiff = (targetX - x);
			var ydiff = (targetY - y);
			var diff = Math.sqrt(Math.pow(xdiff, 2) + Math.pow(ydiff, 2));
			var fraction = walkRate/diff;
			xinc = fraction*xdiff;
			yinc = fraction*ydiff;
		}
		
		private function avoidBlock(e:Event):void{
			//isMoving = true;
			var i = whichNode;
			var targetNode:MovieClip;
									 
			switch (nodePath[i]){
				case "UL":
				targetNode = currentBlock.nodeUL;
				break;
		
				case "UR":
				targetNode = currentBlock.nodeUR;
				break;
		
				case "LL":
				targetNode = currentBlock.nodeLL;
				break;
		
				case "LR":
				targetNode = currentBlock.nodeLR;
				break;
			}
			

			var tempX = targetNode.x + currentBlock.x;
			var tempY = targetNode.y + currentBlock.y;
			getIncrements(tempX, tempY);
	
			//Move the player until it gets within targetBuffer pixels of the targetNode
			if (x > (tempX-targetBuffer) && x < (tempX+targetBuffer) && y > (tempY-targetBuffer) && y < (tempY+targetBuffer)){
				removeEventListener(Event.ENTER_FRAME, avoidBlock);
				if (whichNode < nodePath.length - 1){
					whichNode += 1;
					addEventListener(Event.ENTER_FRAME, avoidBlock, false, 0, true);
				} else {
					whichNode = 0;
					isAvoiding = true;
					startWalking(targetX, targetY);
				}
		
			}else {
				orientPlayer();
				x += xinc;
				y += yinc;
			}
	
		} // end avoidBlock
		
		private function findPath():Array{
			playerQuad = whichQuad(x, y);
			var targetQuad:String = whichQuad(targetX, targetY);
			var tempPath:Array = new Array();
	
			switch(playerQuad){
				case "UL":
					if (targetQuad == "UR"){
						tempPath.push("UL", "UR");
					}
					if (targetQuad == "LL"){
						tempPath.push("UL", "LL");
					}
					if (targetQuad == "LR"){
						tempPath.push("UL", "LL", "LR");
					}
					if (targetQuad == "UL"){
						tempPath.push("UL");
					}
				break;
		
				case "UR":
					if (targetQuad == "UL"){
						tempPath.push("UR", "UL");
					}
					if (targetQuad == "LL"){
						tempPath.push("UR", "UL", "LL");
					}
					if (targetQuad == "LR"){
						tempPath.push("UR", "LR");
					}
					if (targetQuad == "UR"){
						tempPath.push("UR");
					}
				break;
		
				case "LL":
					if (targetQuad == "UR"){
						tempPath.push("LL", "UL", "UR");
					}
					if (targetQuad == "UL"){
						tempPath.push("LL", "UL");
					}
					if (targetQuad == "LR"){
						tempPath.push("LL", "LR");
					}
					if (targetQuad == "LL"){
						tempPath.push("LL");
					}
				break;
		
				case "LR":
					if (targetQuad == "UR"){
						tempPath.push("LR", "UR");
					}
					if (targetQuad == "LL"){
						tempPath.push("LR", "LL");
					}
					if (targetQuad == "UL"){
						tempPath.push("LR", "LL", "UL");
					}
					if (targetQuad == "LR"){
						tempPath.push("LR");
					}
				break;
			}
			return tempPath;
		} // end findPath
		
		private function whichQuad(thisX, thisY):String{
			// Checks to see which "quadrant" the coordinates are in 
			
			var quadrant:String;
			
			// Adjust the boundary points' values for the location of the box
			var yUL = currentBlock.nodeUL.y + currentBlock.y;
			var xUL = currentBlock.nodeUL.x + currentBlock.x;
			var yLL = currentBlock.nodeLL.y + currentBlock.y;
			var xUR = currentBlock.nodeUR.x + currentBlock.x;

			// Define boundary points
			var midY = yUL + (yLL-yUL)/2;
			var midX = xUL + (xUR-xUL)/2;

			if (thisX <= midX && thisY <= midY){
				quadrant = "UL";
			}
			if (thisX <= midX && thisY > midY){
				quadrant = "LL";
			}
			if (thisX > midX && thisY <= midY){
				quadrant = "UR";
			}
			if (thisX > midX && thisY > midY){
				quadrant = "LR";
			}
			
			return quadrant;
		}
		
		public function returnTargetBuffer():int{
			return targetBuffer;
		}
		
		
			
	}// end class
}// end package