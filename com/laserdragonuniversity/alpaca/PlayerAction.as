package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.ui.Mouse;
	import flash.utils.getDefinitionByName;
	
	public class PlayerAction extends MovieClip{
		
		private var stageRef:Stage;
		private var draggedItem:MovieClip
		private var targetItem:MovieClip;
		private var actionMC:MovieClip;
		private var toolbar:Toolbar;
		private var inv:Inventory;
		private var player:Player;
		private var usableItems:Array = new Array;
		private var special:Boolean;
		private var puzzle:Puzzle;
		
		public function PlayerAction(stageRef:Stage, draggedItem:MovieClip, targetItem:MovieClip, actionMC:MovieClip, special:Boolean){
			
			this.stageRef = stageRef;
			this.targetItem = targetItem;
			this.actionMC = actionMC;
			this.special = special; // This is not currently in use
			this.draggedItem = draggedItem;
			
			inv = Engine.inv;
			puzzle = Engine.puzzle;
			
			Engine.playerControl = false;
			Mouse.hide();
			
			actionMC.gotoAndStop(1);
			if (targetItem != null){
				actionMC.x = targetItem.x;
				actionMC.y = targetItem.y;
			}
			toolbar = Engine.toolbar;
			player = Engine.player;
			if (draggedItem == null){
				playSimpleClip();
			} else {
				var targetX:Number = targetItem.usePoint.x + targetItem.x;
				var targetY:Number = targetItem.usePoint.y + targetItem.y;
				player.startWalking(targetX, targetY);
				player.addEventListener("reachedPoint", reachedMoviePoint, false, 0, true);
			}
			actionMC.addEventListener("itemRemoved", itemRemoval, false, 0, true);
			actionMC.addEventListener("endGame", endGame, false, 0, true);
			
		}
		
		private function playSimpleClip():void{
			//Mouse.hide();
			stageRef.addChild(actionMC);
			actionMC.gotoAndPlay(1);
			player.visible = false;
			targetItem.visible = false;
			//player.hasControl = false;
			//Engine.playerControl = false;
			actionMC.addEventListener("clipFinished", returnPlayerControl, false, 0, true);
		}
		
		private function reachedMoviePoint(e:Event):void{
			if (player.currentLabel == "default"){
				alignPlayer();
				combineObjects();
				player.removeEventListener("reachedPoint", reachedMoviePoint);
				//Mouse.hide();
			}
		}	
		
		private function alignPlayer():void{
			// Make sure the player is looking at the thing
			if (targetItem.x > player.x && player.scaleX < 0){
				player.scaleX = -player.scaleX;
			}
			if (targetItem.x < player.x && player.scaleX > 0){
				player.scaleX = -player.scaleX;
			}
		}
				
		private function combineObjects():void{
			stageRef.addChild(actionMC);
			stageRef.dispatchEvent(new Event("actionClipLoaded"));
			actionMC.gotoAndPlay(1);
			player.visible = false;
			targetItem.visible = false;
			//player.hasControl = false;
			//Engine.playerControl = false;
			actionMC.addEventListener("clipFinished", returnPlayerControl, false, 0, true);
		}
		
		private function returnPlayerControl(e:Event):void{
			player.x = actionMC.playerspot.x + targetItem.x;
			player.y = actionMC.playerspot.y + targetItem.y;
			stageRef.removeChild(actionMC);
			player.visible = true;
			targetItem.visible = true;
			//player.hasControl = true;
			Engine.playerControl = true;
			Mouse.show();
			puzzle.performedAction(actionMC);
		}
		
		private function itemRemoval(e:Event):void{
			inv.removeInvItem(draggedItem.name);
		}
		
		private function endGame(e:Event):void{
			puzzle.dispatchEvent(new Event("endGame"));
		}
		
	}//end class
}//end package