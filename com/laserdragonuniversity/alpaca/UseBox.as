package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.display.SimpleButton;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	public class UseBox extends MovieClip{
		
		private var stageRef:Stage;
		private var boxTimer:Timer = new Timer(2500, 1);
		private var thisThing:Object;
		private var player:Player;
		private var inv:Inventory;
		public var speech:Speech;
		private var dialog:Dialog;
		private var toolbar:Toolbar;
		public var draggedItem:DraggedItem;
		private var playerAction:PlayerAction;
		private var puzzle:Puzzle;
		
		public function UseBox(stageRef:Stage, thisThing:Object){
			this.stageRef = stageRef;
			this.thisThing = thisThing;
			
			player = Engine.player;
			inv = Engine.inv;
			toolbar = Engine.toolbar;
			puzzle = Engine.puzzle;
			
			this.visible = true;
			useButton.buttonMode = true;
			lookButton.buttonMode = true;
			
			if (thisThing.talkable){
				useButton.gotoAndStop("talk");
			} else {
				useButton.gotoAndStop("use");
			}
				
			boxTimer.addEventListener(TimerEvent.TIMER, boxTimeOut);
			boxTimer.start();
			
			stageRef.addEventListener("itemClicked", removeThis, false, 0, true);
			
			lookButton.addEventListener(MouseEvent.CLICK, lookAt, false, 0, true);
			useButton.addEventListener(MouseEvent.CLICK, useThing, false, 0, true);
			
			lookButton.addEventListener(MouseEvent.MOUSE_OVER, showDesc, false, 0, true);
			useButton.addEventListener(MouseEvent.MOUSE_OVER, showDesc, false, 0, true);
			lookButton.addEventListener(MouseEvent.MOUSE_OUT, removeDesc, false, 0, true);
			useButton.addEventListener(MouseEvent.MOUSE_OUT, removeDesc, false, 0, true);
		
		}
		
		private function showDesc(e:MouseEvent):void{
			var tempText:String;
			if (e.currentTarget == useButton){
				if (thisThing.gettable){
					tempText = "Get ";
				} else {
					if (thisThing.talkable){
						tempText = "Talk to ";
					} else {
						tempText = "Use ";
					}
				}
			}
			if (e.currentTarget == lookButton){
				tempText = "Look at ";
			}
			toolbar.useText.text = tempText + thisThing.displayName;
		}
		
		private function removeDesc(e:MouseEvent):void{
			toolbar.useText.text = "";
		}
		
		private function lookAt(e:MouseEvent):void{
			alignPlayer();
			boxClicked();
			speech = new Speech(stageRef, thisThing, "Look");
			lookButton.removeEventListener(MouseEvent.CLICK, lookAt);
		}
				
			
		private function useThing(e:MouseEvent):void{
			if (thisThing.invItem){
				inv.visible = false;
				this.visible = false;
				draggedItem = new DraggedItem(stageRef, thisThing);
				begoneEventListeners();
			} else{
				if (thisThing.usable){
					var thingX = thisThing.usePoint.x + thisThing.x;
					var thingY = thisThing.usePoint.y + thisThing.y;
					player.startWalking(thingX, thingY);
					player.addEventListener("reachedPoint", reachedThing, false, 0, true);
				} else {
					alignPlayer();
					speech = new Speech(stageRef, thisThing, "Use");
				}
				boxClicked();
				useButton.removeEventListener(MouseEvent.CLICK, useThing);
			}
			
		}
		
		
		private function reachedThing(e:Event):void{
			alignPlayer();
			if (thisThing.gettable){
				pickUpThing();
			} else {
				manipulateThing();
			}
			player.removeEventListener("reachedPoint", reachedThing);
			
		}	
			
		private function pickUpThing():void{
			player.gotoAndStop("grab");
			player.addEventListener("clipFinished", pickedUpThing, false, 0, true);
		}
			
		private function pickedUpThing(e:Event):void{
			speech = new Speech(stageRef, thisThing, "Get");
			thisThing.visible = false;
			inv.addInvItem(thisThing.displayName);
			player.removeEventListener("clipFinished", pickedUpThing);
		}
			
		private function manipulateThing():void{
			if (thisThing.talkable){
				alignPlayer();
				dialog = new Dialog(stageRef, thisThing, null, true);
				stageRef.addChild(dialog);
			} else {
				try {
					var nameofMC:String = "action_"+thisThing.displayName+"_USE";
					var tempMC = getDefinitionByName(nameofMC);
					var targetMC = thisThing;
					//trace ("MC found.");
					tempMC = new tempMC;
					playerAction = new PlayerAction(stageRef, null, targetMC, tempMC, true);
				} 
				catch (e:ReferenceError){
					//trace ("No MC found.  Defaulting to grab action");
					player.gotoAndStop("grab");
					player.addEventListener("clipFinished", usedThing, false, 0, true);
				}
			}
		}
		
		private function usedThing(e:Event):void{
			player.gotoAndStop("default");
			puzzle.usedItem(thisThing.displayName);
			player.removeEventListener("clipFinished", usedThing);
		}
			
				
			
		public function alignPlayer():void{
			// Make sure the player is looking at the thing
					
			if (thisThing.x > player.x && player.scaleX < 0){
				player.scaleX = -player.scaleX;
			}
			if (thisThing.x < player.x && player.scaleX > 0){
				player.scaleX = -player.scaleX;

			}
		}
			
		
		private function boxTimeOut(e:TimerEvent):void{
			removeEventListener(MouseEvent.MOUSE_OUT, boxTimeOut);
			boxTimer.stop();
			boxTimer.reset();
			begoneEventListeners();
		}
		
		private function boxClicked():void{
			boxTimer.stop();
			boxTimer.reset();
			begoneEventListeners();
		}
		
		private function removeThis(e:Event):void{
			begoneEventListeners();
		}
		
		private function begoneEventListeners():void{
			if (stageRef.contains(this))
				stageRef.removeChild(this);
			lookButton.removeEventListener(MouseEvent.CLICK, lookAt);
			useButton.removeEventListener(MouseEvent.CLICK, useThing);
			lookButton.removeEventListener(MouseEvent.MOUSE_OVER, showDesc);
			useButton.removeEventListener(MouseEvent.MOUSE_OVER, showDesc);
			lookButton.removeEventListener(MouseEvent.MOUSE_OUT, removeDesc);
			useButton.removeEventListener(MouseEvent.MOUSE_OUT, removeDesc);
			stageRef.removeEventListener("itemClicked", removeThis);
		}
	}//end class
}// end package
			