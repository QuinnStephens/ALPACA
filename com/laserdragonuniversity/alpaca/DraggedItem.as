package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.ui.Mouse;
	import flash.utils.getDefinitionByName;


	public class DraggedItem extends MovieClip{
		
		private var stageRef:Stage;
		private var draggedItem:MovieClip;
		private var newFriend:MovieClip;
		private var itemRef:Object;
		private var playerAction:PlayerAction;
		private var toolbar:Toolbar;
		private var inv:Inventory;
		private var player:Player;
		private var usableItems:Array = new Array;
		private var speech:Speech;
		private var puzzle:Puzzle;
		private var dialog:Dialog;
		private var linesData:Object;
		
		private var itemScale:Number = .75;
		
		public function DraggedItem(stageRef:Stage, grabbedItem:Object){
			
			this.stageRef = stageRef;
			toolbar = Engine.toolbar;
			usableItems = Engine.usableItems;
			inv = Engine.inv;
			puzzle = Engine.puzzle;
			player = Engine.player;
			linesData = Engine.linesData;
			
			inv.draggingItem = true;
			Mouse.hide();
			
			itemRef = getDefinitionByName(grabbedItem.displayName.toLowerCase()+"Proper");
			draggedItem = new itemRef;
			stageRef.addChild(draggedItem);
			draggedItem.displayName = grabbedItem.displayName;
			if (grabbedItem.lookTag)
				draggedItem.lookTag = grabbedItem.lookTag;
			draggedItem.x = mouseX + x;
			draggedItem.y = mouseY + y;
			draggedItem.scaleX = itemScale;
			draggedItem.scaleY = itemScale;
			stageRef.addEventListener(MouseEvent.MOUSE_MOVE, dragItem, false, 0, true);
			stageRef.addEventListener(Event.ENTER_FRAME, itemHitTest, false, 0, true);
			draggedItem.addEventListener(MouseEvent.CLICK, itemClick, false, 0, true);
			
		}
		
		private function dragItem(e:MouseEvent):void{
			draggedItem.x = mouseX + x;
			draggedItem.y = mouseY + y;
		}

			
		private function itemHitTest(e:Event):void{
			newFriend = null;
			itemGlow(false);
			toolbar.useText.text = "";
			for (var i in usableItems){
				var thisHitArea = usableItems[i];
				if (usableItems[i].usableArea)
					thisHitArea = usableItems[i].usableArea;
				if (draggedItem.hitTestObject(thisHitArea) && usableItems[i].visible){
					itemGlow(true);
					newFriend = usableItems[i];
					var currentText:String = "Use "+draggedItem.displayName+" on "+newFriend.displayName;
					toolbar.useText.text = currentText;
				}
			}
				
		}
		public function itemClick(e:Event):void{
			inv.draggingItem = false;
			var nameofMC:String;
			var tempMC;
			var draggedName:String = draggedItem.displayName;
			if (draggedItem.lookTag)
				draggedName = draggedName + draggedItem.lookTag;
			if (newFriend){
				nameofMC = "action_"+draggedName+"_"+newFriend.displayName;
				//trace ("Looking for "+nameofMC);
				try {
					tempMC = getDefinitionByName(nameofMC);
					//trace ("MC found.");
					removeDraggedItem();
					if (speech)
						speech.dispatchEvent(new Event("stopTalking"));
					tempMC = new tempMC;
					playerAction = new PlayerAction(stageRef, draggedItem, newFriend, tempMC, false);
				}
				catch(e){
					//trace ("No MC found.  Checking for dialog option...");
					try {
						var tempData = linesData.dialog[newFriend.displayName].useObject[draggedItem.displayName];
						if (tempData != "" && tempData != null){
							//trace ("Dialog option found.");
							removeDraggedItem();
							alignPlayer();
							if (speech)
								speech.dispatchEvent(new Event("stopTalking"));
							dialog = new Dialog(stageRef, newFriend, draggedItem, false);
						} 
					}
					catch(e){
						//trace ("No dialog option found.  Defaulting to player line.");
						alignPlayer();
						if (speech)
							speech.dispatchEvent(new Event("stopTalking"));
						var actionName:String = "Use_"+newFriend.displayName;
						if (newFriend.lookTag)
							actionName = actionName+newFriend.lookTag;
						speech = new Speech(stageRef, draggedItem, actionName);
					}
						
				}
			} else {
				removeDraggedItem();
			}
				
		}
		
		private function removeDraggedItem():void{
			stageRef.removeEventListener(MouseEvent.MOUSE_MOVE, dragItem);
			stageRef.removeEventListener(Event.ENTER_FRAME, itemHitTest);
			draggedItem.removeEventListener(MouseEvent.CLICK, itemClick);
				
			stageRef.removeChild(draggedItem);
			toolbar.useText.text = "";
				
			if (stageRef.contains(this))
				stageRef.removeChild(this);
				
			Mouse.show();
			Engine.playerControl = true;
		}
			
		
		private function alignPlayer():void{
			// Make sure the player is looking at the thing
					
			if (newFriend.x > player.x && player.scaleX < 0){
				player.scaleX = -player.scaleX;
			}
			if (newFriend.x < player.x && player.scaleX > 0){
				player.scaleX = -player.scaleX;

			}
		}
		
		private function itemGlow(isGlowing:Boolean):void{
			if (isGlowing){
				var glow:GlowFilter = new GlowFilter();
				glow.color = 0xFFFF00;
				glow.alpha = .75;
				glow.blurX = 10;
				glow.blurY = 10;
				glow.quality = BitmapFilterQuality.MEDIUM;

				draggedItem.filters = [glow];
			} else {
				draggedItem.filters = null;
			}
		}
	}//end class
}//end package