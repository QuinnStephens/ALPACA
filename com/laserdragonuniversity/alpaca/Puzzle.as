package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.utils.getDefinitionByName;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Timer;
	import flash.ui.Mouse;
	import com.adobe.serialization.json.*;

	public class Puzzle extends MovieClip{
		
		private var stageRef:Stage;
		private var back:Background;
		private var inv:Inventory;
		private var player:Player;
		private var actionMC:MovieClip;
		private var speech:Speech;
		private var muzak:Muzak;
		private var toolbar:Toolbar;
		private var dialog:Dialog;
		private var darkness:MovieClip;
		private var allPuzzles:Object;
		
		private var newSpeech:Sound = new Sound();
		private var channel:SoundChannel = new SoundChannel();
		
		public function Puzzle(stageRef:Stage){
			
			this.stageRef = stageRef;
			
			back = Engine.back;
			inv = Engine.inv;
			player = Engine.player;
			toolbar = Engine.toolbar;
			
			allPuzzles = new Object;
		}
		
		public function returnPuzzles():Object{
			//trace ("Returning puzzles");
			return allPuzzles;
		}
		
		public function restorePuzzles(savedPuzzles:Object){
			//trace("Restoring puzzles...");
			allPuzzles = savedPuzzles;
		}
		
		public function firstAction():void{
			
		}
		
		public function newBackground(thisBack:String):void{
			var room = back.currentBack;
			switch (thisBack){
				default:
				break;
			}
		}
		
		public function gotItem(thisItem:String):void{
			// This is empty now, but it gets called every time something is added to the inventory, in case anything special needs to happen
		}
		
		public function usedItem(thisItem:String):void{
			switch (thisItem){
				default:
				break;
			}
		}
			
						
		public function performedAction(actionMC:MovieClip):void{
			this.actionMC = actionMC;
			var clipString:String = String(actionMC); // I can't figure out how to identify the movieclip without converting it to a string (instance names are inconsistent), hence this goofy workaround
			switch (clipString){
				default:
				break;
			}
		}
		
		public function spokeDialog(thisDialog:Object):void{
			// Empty for now, but can be used for dialog puzzles
			// Gets called after each exchange
		}
			
	}//end class
}//end package