package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.Timer;
	
	public class Subtitle extends MovieClip{
		
		private var useAudio:Boolean;
		private var stageRef:Stage;
		private var thisChar:Object;
		private var lineID:String;
		private var lineSplit:Array;
		private var linesData:Object;
		private var player:Player;
		private var speakTimer:Timer;
		private var clickBox:MovieClip = new MovieClip;
		
		public function Subtitle(lineID:String, stageRef:Stage, thisChar:Object){
			
			this.stageRef = stageRef;
			this.thisChar = thisChar;
			this.lineID = lineID;
			useAudio = Engine.useAudio;
			linesData = Engine.linesData;
			
			//Draw an invisible rectangle over the scene, so no matter where the player clicks, the Subtitle will go away
			clickBox.graphics.beginFill(0x000000);
			clickBox.graphics.drawRect(0, 0, stageRef.stageWidth, stageRef.stageHeight);
			clickBox.alpha = 0;
			stageRef.addChild(clickBox);
			clickBox.addEventListener(MouseEvent.CLICK, removeThis, false, 0, true);

			if (thisChar.name == "Player"){
				thisChar = Engine.player;
				textbox.textColor = 0xFFFFFF;
			} else {
				textbox.textColor = 0xCC0000; // This color is bright red to match the look of the door.  May not always be appropriate
				for (var i in Engine.usableItems){
					if (Engine.usableItems[i].displayName == thisChar.displayName){
						thisChar = Engine.usableItems[i];
					}
				}
			}
			lineSplit = lineID.split("_");
			
			buttonMode = true;
			
			textbox.selectable = false;
			
			var fullString:String;
			var partString;
			var thisLine:int;
			var itemName:String;
			
			if (lineSplit[0] == "dialog"){// This is for regular dialog lines
				var thisOption:int = int(lineSplit[2]);
				thisLine = int(lineSplit[3]);
				if (lineSplit.length > 4){ // Use a submenu if there is one
					var thisSub:int = int(lineSplit[4]);
					var thisSubLine:int = int(lineSplit[5]);
					partString = linesData.dialog[lineSplit[1]].talk[thisOption].submenu[thisSub];
					if (thisSubLine < 1)
						fullString = partString.option;
					else
						fullString = partString.response[thisSubLine - 1][1];
				} else {
					partString = linesData.dialog[lineSplit[1]].talk[thisOption];
					if (thisLine < 1){
						fullString = partString.option;
					} else {
						fullString = partString.response[thisLine - 1][1];
					}
				}
			} else if (lineSplit[0] == "objectdialog"){// This is for dialog when the player uses an item on a character
				var targetChar:String = lineSplit[1];
				itemName = lineSplit[2];
				thisLine = int(lineSplit[3]);
				fullString = linesData.dialog[targetChar].useObject[itemName][thisLine][1];
			} else { // This is for when the player uses an item on another item
				itemName = lineSplit[0];
				var actionName:String = lineSplit[1].toLowerCase();
				if (lineSplit[2])
					actionName = actionName+lineSplit[2].toUpperCase();
				fullString = linesData.observations[itemName][actionName];
				if (fullString == "" || fullString == null){
					if (lineSplit[2]){
						fullString = linesData.observations[itemName].usenot;
					} else {
						fullString = linesData.observations.DEFAULT;
					}
				}
			}
			
			textbox.text = fullString;
			var format1:TextFormat = new TextFormat();
			format1.font = "Arial";
			textbox.setTextFormat(format1);
			textbox.height = textbox.height * textbox.numLines;
			back.height = textbox.height + 10;
			
			x = thisChar.x - this.width/2; // Centers the box over the speaking character
			y = thisChar.y - thisChar.height - back.height; // Puts the lower edge of the box just above the character
			
			// Make sure the subititle doesn't extend beyond the edge of the screen
			// Registration point is on the top left of the box
			if (x + width > stageRef.stageWidth){
				x = stageRef.stageWidth - width - 10;
			}
			if (x < 0){
				x = 10;
			}
			if (y < 0){
				y = 10;
			}
			if (y + height > stageRef.stageHeight){
				y = stageRef.stageHeight - height - 10;
			}
			
			// Stop the player's mouth from moving once a reasonable amount of time has passed
			// Only use this if there's no audio for the players' lines
			if (!useAudio){
				speakTimer = new Timer(65*textbox.length, 1);
				speakTimer.addEventListener(TimerEvent.TIMER, speakTimeOut);
				speakTimer.start();
			}
				
		
			this.addEventListener("removeSub", removeThis, false, 0, true);
			
		}
		
		private function speakTimeOut(e:TimerEvent):void{
			if (thisChar.currentLabel == "talk")
				thisChar.gotoAndStop("default");
			speakTimer.removeEventListener(TimerEvent.TIMER, speakTimeOut);
			speakTimer.stop();
			speakTimer.reset();
		}
		
		private function removeThis(e:Event):void{
			// Only use these lines if there's no audio for player lines
			/*
			speakTimer.removeEventListener(TimerEvent.TIMER, speakTimeOut);
			speakTimer.stop();
			speakTimer.reset();
			*/
			if (stageRef.contains(this))
				stageRef.removeChild(this);
			if (stageRef.contains(clickBox))
				stageRef.removeChild(clickBox);
			dispatchEvent(new Event("subRemoved"));
		}
	}
}