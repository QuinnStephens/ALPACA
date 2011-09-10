package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.text.*;
	import flash.display.SimpleButton;
	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class Toolbar extends MovieClip{
		
		private var stageRef:Stage;
		private var player:Player;
		public var muzak:Muzak;
		private var options:Options;
		public var saver:SaveRestore;
		
		public function Toolbar(stageRef:Stage){
			
			this.stageRef = stageRef;
			player = Engine.player;
			options = Engine.options;
			
			invButton.addEventListener(MouseEvent.MOUSE_OVER, showBarDesc, false, 0, true);
			invButton.addEventListener(MouseEvent.MOUSE_OUT, removeBarDesc, false, 0, true);
			invButton.addEventListener(MouseEvent.CLICK, showInventory, false, 0, true);
			
			optionsButton.addEventListener(MouseEvent.MOUSE_OVER, showBarDesc, false, 0, true);
			optionsButton.addEventListener(MouseEvent.MOUSE_OUT, removeBarDesc, false, 0, true);
			optionsButton.addEventListener(MouseEvent.CLICK, showOptions, false, 0, true);
			
			saveButton.addEventListener(MouseEvent.MOUSE_OVER, showBarDesc, false, 0, true);
			saveButton.addEventListener(MouseEvent.MOUSE_OUT, removeBarDesc, false, 0, true);
			saveButton.addEventListener(MouseEvent.CLICK, showSaver, false, 0, true);
			
			useText.text = "";
			
			addEventListener("closedWindow", closedWindow, false, 0, true);
			
			addListeners();
		}
		
		public function addListeners():void{
			// Add event listener to show the names of the usable items
			for (var i in Engine.usableItems){
				var thisClip = Engine.usableItems[i];
				thisClip.addEventListener(MouseEvent.MOUSE_OVER, showDesc, false, 0, true);
				thisClip.addEventListener(MouseEvent.MOUSE_OUT, removeDesc, false, 0, true);
			}
		}
		
		private function showBarDesc(e:MouseEvent):void{
			if (Engine.playerControl){
				switch (e.currentTarget){
					case invButton:
						useText.text = "INVENTORY";
					break;
					
					case optionsButton:
						useText.text = "OPTIONS";
					break;
					
					case saveButton:
						useText.text = "SAVE / RESTORE";
					break;
					
				}
			}
		}
		
		private function removeBarDesc(e:MouseEvent):void{
			if (Engine.playerControl)
				useText.text = "";
		}
		
		private function showDesc(e:MouseEvent):void{
			if (Engine.playerControl)
				useText.text = e.currentTarget.displayName;
		}
		
		private function removeDesc(e:MouseEvent):void{
			useText.text = "";
		}
		
		private function showInventory(e:MouseEvent):void{
			if (Engine.playerControl || Engine.options.visible || Engine.saver.visible){
				Engine.inv.showItems();
				stageRef.dispatchEvent(new Event("itemClicked"));
				resetListeners();
				invButton.removeEventListener(MouseEvent.CLICK, showInventory);
				invButton.addEventListener(MouseEvent.CLICK, closeInventory, false, 0, true);
				if (Engine.options.visible)
					Engine.options.visible = false;
				if (Engine.saver.visible)
					Engine.saver.visible = false;
			}
		}
		
		private function closeInventory(e:MouseEvent):void{
			Engine.inv.visible = false;
			Engine.playerControl = true;
			resetListeners();
		}
			
		
		private function showOptions(e:MouseEvent):void{
			if (Engine.playerControl || Engine.inv.visible || Engine.saver.visible){
				Engine.options.showOptions();
				resetListeners();
				optionsButton.removeEventListener(MouseEvent.CLICK, showOptions);
				optionsButton.addEventListener(MouseEvent.CLICK, closeOptions, false, 0, true);
				stageRef.dispatchEvent(new Event("itemClicked"));
				if (Engine.inv.visible)
					Engine.inv.visible = false;
				if (Engine.saver.visible)
					Engine.saver.visible = false;
			}
		}
		
		private function closeOptions(e:MouseEvent):void{
			Engine.options.visible = false;
			Engine.playerControl = true;
			resetListeners();
		}
		
		private function showSaver(e:MouseEvent):void{
			if (Engine.playerControl || Engine.options.visible || Engine.inv.visible){
				Engine.saver.showSaver();
				resetListeners();
				saveButton.removeEventListener(MouseEvent.CLICK, showSaver);
				saveButton.addEventListener(MouseEvent.CLICK, closeSaver, false, 0, true);
				stageRef.dispatchEvent(new Event("itemClicked"));
				if (Engine.inv.visible)
					Engine.inv.visible = false;
				if (Engine.options.visible)
					Engine.options.visible = false;
			}
		}
		
		private function closeSaver(e:MouseEvent){
			Engine.saver.visible = false;
			Engine.playerControl = true;
			resetListeners();
		}
		
		private function closedWindow(e:Event):void{
			resetListeners();
		}
		
		private function resetListeners():void{
			invButton.removeEventListener(MouseEvent.CLICK, closeInventory);
			invButton.addEventListener(MouseEvent.CLICK, showInventory, false, 0, true);
			optionsButton.removeEventListener(MouseEvent.CLICK, closeOptions);
			optionsButton.addEventListener(MouseEvent.CLICK, showOptions, false, 0, true);
			saveButton.removeEventListener(MouseEvent.CLICK, closeSaver);
			saveButton.addEventListener(MouseEvent.CLICK, showSaver, false, 0, true);
			
		}
			
		
	} //end class
} // end package