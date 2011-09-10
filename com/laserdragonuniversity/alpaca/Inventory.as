package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.display.SimpleButton;
	import flash.utils.getDefinitionByName;

	public class Inventory extends MovieClip{
		
		private var allItems:Array = new Array;// This is everything that's ever been in the inventory
		public static var playerItems:Array = new Array;// This is the current inventory
		private var stageRef:Stage;
		private var useBox:UseBox;
		private var toolbar:Toolbar;
		public var draggingItem:Boolean = false;
		private var removedItem:String;
		private var puzzle:Puzzle;
		
		public function Inventory(stageRef:Stage){
			
			this.stageRef = stageRef;
			toolbar = Engine.toolbar;
			puzzle = Engine.puzzle;
			
			closer.addEventListener(MouseEvent.CLICK, closeInventory, false, 0, true);
		}
		
		public function restoreInv(currentInv:Array, allInv:Array){
			var currentItems = returnItems(null);
			for (i in currentItems){
				removeInvItem(currentItems[i].displayName);
			}
			allItems.splice(0, allItems.length);
			playerItems.splice(0, playerItems.length);
			for (i in currentInv){
				addInvItem(currentInv[i][0]);
				for (i in playerItems){
					if (playerItems[i].displayName == currentInv[i][0]){
						if(currentInv[i][1])
							playerItems[i].lookTag = currentInv[i][1];
					}
						
				}
			}
			for (var i in allInv){
				var itemRef= getDefinitionByName(allInv[i].toLowerCase()+"Inv");
				var thisItem = new itemRef;
				thisItem.displayName = allInv[i];
				if (isUnique(thisItem)){
					allItems.push(thisItem);
				}
			}
		}
		
		public function addInvItem(itemName:String):void{
			var itemRef:Object = getDefinitionByName(itemName.toLowerCase()+"Inv");
			var addedItem:MovieClip = new itemRef;
			addedItem.displayName = itemName;
			if (playerItems.length < 4){ // This is for the top row of up to 4 items
				addedItem.y = 75;
				addedItem.x = 60 + (playerItems.length) * 100;
			} else { // This creates a bottom row if the player has more than 4 items
				addedItem.y = 175;
				addedItem.x = 60 + (playerItems.length - 4) * 100;
			}
			if (isUnique(addedItem)){
				this.addChild(addedItem);
				playerItems.push(addedItem); 
				allItems.push(addedItem); 
				addedItem.buttonMode = true;
				addedItem.invItem = true;
				addedItem.addEventListener(MouseEvent.CLICK, useItem, false, 0, true);
				puzzle = Engine.puzzle;
				puzzle.gotItem(addedItem.displayName);
			}
			
		}
		
		private function isUnique(thisItem:Object):Boolean{
			var unique:Boolean = true;
			for (var i in playerItems){
				if (playerItems[i].displayName == thisItem.displayName)
					unique = false;
			}
			return unique;
		}
		
		public function removeInvItem(itemName:String):void{
			removedItem = itemName;
			var itemNum:int;
			for (var i in playerItems){
				if (playerItems[i].displayName == itemName){
					playerItems[i].visible = false;
					itemNum = i;
				} else {
					playerItems[i].visible = true;
				}
			}
			playerItems = playerItems.filter(checkForItem);
			
			// Rearrange the rest of the items
			for (i in playerItems){
				if (i >= itemNum){
					if (playerItems[i].y == 175 && playerItems[i].x == 60){
						playerItems[i].x = 360;
						playerItems[i].y = 75;
					} else {
						playerItems[i].x -= 100;
					}
				}
			}
		}
		
		private function checkForItem(item:*, index:int, array:Array):Boolean{
			return (item.displayName != removedItem);
		}
		
		public function returnItems(whichItems:String):Array{
			if (whichItems == "all"){
				return allItems;
			} else {
				return playerItems;
			}
		}

		public function showItems():void{
			this.visible = true;
			Engine.playerControl = false;
			if (playerItems.length == 0){
				blankText.text = "Your inventory is empty.";
			} else {
				blankText.text = "Inventory";
			}
		}
		
		private function closeInventory(e:MouseEvent):void{
			this.visible = false;
			if (useBox){
				useBox.visible = false;
			}
			Engine.playerControl = true;
			Engine.toolbar.dispatchEvent(new Event("closedWindow"));
		}
		
		private function useItem(e:MouseEvent):void{
			stageRef.dispatchEvent(new Event("itemClicked"));
			useBox = new UseBox(stageRef, e.currentTarget);
			useBox.x = mouseX + x;
			useBox.y = mouseY + y;
			stageRef.addChild(useBox);
		}
	} // end class
}//end package