package com.laserdragonuniversity.alpaca {
	
	import flash.events.*;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	public class RightClickMenu extends Sprite{

		private var cmenu:ContextMenu = new ContextMenu();
		private var alpacaLink:ContextMenuItem = new ContextMenuItem("About ALPACA Engine...");
		
		public function RightClickMenu(){
 
			alpacaLink.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, alpacaSite);
			cmenu.hideBuiltInItems();
			cmenu.customItems.push(alpacaLink);
		}
		
		public function returnMenu():ContextMenu{
			return cmenu;
		}
 
		private function alpacaSite(e:Event):void{
			var alpacaLink:URLRequest = new URLRequest( "http://www.laserdragonuniversity.com/alpaca" );
			navigateToURL(alpacaLink, "_blank" );
		}
	}
}