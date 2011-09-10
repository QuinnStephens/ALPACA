package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.getDefinitionByName;
	import flash.ui.Mouse;
	import flash.ui.Keyboard;
	import flash.net.URLRequest;

	
	public class Dialog extends MovieClip{
		
		private var useAudio:Boolean;
		private var player:Player;
		private var targetChar:Object;
		private var thisItem:Object;
		private var playerSpeech:Sound = new Sound();
		private var channel:SoundChannel = new SoundChannel();
		private var transformer:SoundTransform = new SoundTransform();
		private var stageRef:Stage;
		private var gameOptions:Options;
		private var puzzle:Puzzle;
		private var optionArray:Array;
		private var currentOption:int;
		private var optionTag:String = "";
		private var totalLines:int;
		private var currentLine:int = 0;
		private var currentSub:int;
		private var showOptions:Boolean;
		private var isSubmenu:Boolean;
		private var isObject:Boolean;
		private var optionButtons:Array;
		
		private var linesData:Object;
		private var currentData:Object;
		
		private var subtitle:Subtitle;
		private var lineName:String;
		private var lineURL:String;
		
		public function Dialog(stageRef:Stage, targetChar:Object, thisItem:Object, showOptions:Boolean){
			this.stageRef = stageRef;
			this.targetChar = targetChar;
			this.thisItem = thisItem;
			this.showOptions = showOptions;
			useAudio = Engine.useAudio;
			player = Engine.player;
			puzzle = Engine.puzzle;
			linesData = Engine.linesData;
			gameOptions = Engine.options;
			
			Engine.playerControl = false;
			
			x = 100;
			y = 200;
			if (showOptions){
				visible = true;
			} else {
				// This will start a dialog when the player uses an item on the target character
				visible = false;
				isObject = true;
				currentData= linesData.dialog[targetChar.displayName].useObject[thisItem.displayName];
				totalLines = currentData.length;
				startLine();
			}
			optionButtons = new Array(option0, option1, option2, option3);
			for (var i in optionButtons){
				optionButtons[i].visible = false;
			}
			populateOptions("option");
			
			
		}
		
		private function activateOptions(i:int){
			optionButtons[i].visible = true;
			optionButtons[i].buttonMode = true;
			optionButtons[i].number = i;
			optionButtons[i].addEventListener(MouseEvent.CLICK, selectOption, false, 0, true);
			optionButtons[i].addEventListener(MouseEvent.MOUSE_OVER, optionOn, false, 0, true);
			optionButtons[i].addEventListener(MouseEvent.MOUSE_OUT, optionOff, false, 0, true);
		}
		
		private function populateOptions(type:String):void{
			optionArray = new Array();
			var theseOptions:Array = linesData.dialog[targetChar.displayName].talk;
			bg.scaleY = theseOptions.length/ 4;
			var thisOption;
			for (var i in theseOptions){
				activateOptions(i);
				if (type == "option"){
					isSubmenu = false;
					thisOption = theseOptions[i].option;
				} else {
					isSubmenu = true;
					thisOption = theseOptions[currentOption].submenu[i].option;
				}
				if (thisOption){
					optionArray.push(thisOption);
				} else{
					optionArray.push("");
				}
			}
			for (i in optionArray){
				var currentOption:MovieClip = this["option"+i];
				currentOption.optionText.text = optionArray[i];
			}
		}
		
		private function selectOption(e:MouseEvent):void{
			visible = false;
			currentLine = 0;
			optionTag = ""; //Only needed for audio
			if (isSubmenu){
				currentSub = e.currentTarget.number; 
				currentData = linesData.dialog[targetChar.displayName].talk[currentOption].submenu[currentSub];
			}else {
				currentOption = e.currentTarget.number;
				currentData = linesData.dialog[targetChar.displayName].talk[currentOption];
			}
			if (currentData.response)
				totalLines = currentData.response.length + 1; // Length of response, plus the player's first line
			else
				totalLines = 1;
			startLine();
		}
		
		private function addSubtitle(whichChar){
			subtitle = new Subtitle(lineName, stageRef, whichChar);
			stageRef.addChild(subtitle);
			subtitle.addEventListener("subRemoved", lineClicked, false, 0, true);
		}
		
		private function startLine():void{
			// Audio controls begin
			Mouse.hide();
			if (isObject){
				lineName = "objectdialog_"+targetChar.displayName+"_"+thisItem.displayName+"_"+currentLine;
			} else if (isSubmenu){
				lineName = "dialog_"+targetChar.displayName+"_"+currentOption+"_SUB_"+currentSub+"_"+currentLine;
			} else {
				lineName = "dialog_"+targetChar.displayName+"_"+currentOption+"_"+currentLine;
			}
			if(useAudio){
				try {
					var soundIdent = getDefinitionByName(lineName);
					playerSpeech = new soundIdent;
					transformer.volume = gameOptions.returnVol();
					channel = playerSpeech.play();
					channel.soundTransform = transformer;
				}
				catch(e:ReferenceError){
					trace ("Cannot find dialog line "+lineName);
					Mouse.show();
				}
				// Like in the Speech class, this is an alternate method you can use to get the audio clips
				// from external files if you don't mind the lag
				/*
				lineURL = "audio/"+lineName+".mp3";
				playerSpeech = new Sound(new URLRequest(lineURL));
				playerSpeech.addEventListener(IOErrorEvent.IO_ERROR, loadError, false, 0, true);
				channel = playerSpeech.play();
				*/
			}
			
			
			var currentChar:String;
			if (isObject){
				currentChar = currentData[currentLine][0];
			} else if (currentLine == 0){
				currentChar = "player";
			} else {
				currentChar = currentData.response[currentLine - 1][0];
			}
			
			if (currentChar == "player"){
				player.gotoAndStop("talk");
				if (gameOptions.getSubStatus())
					addSubtitle(player);
			} else {
				targetChar.gotoAndStop("talk");
				if (gameOptions.getSubStatus())
					addSubtitle(targetChar);
			}
			// Allow the player to skip dialog by pressing any key - only necessary if using audio
			
			if(useAudio){
				stageRef.addEventListener(KeyboardEvent.KEY_DOWN, skipLine, false, 0, true);
				channel.addEventListener(Event.SOUND_COMPLETE, lineEnds, false, 0, true);
			}
		}
		
		private function loadError(e:IOErrorEvent){
			trace ("Cannot open file "+lineURL);
			Mouse.show();
			playerSpeech.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
		}
			
		
		private function lineEnds(e:Event):void{
			if (subtitle){
				subtitle.dispatchEvent(new Event("removeSub"));
			} else {
				nextStep();
			}
		}
		
		private function lineClicked(e:Event):void{
			nextStep();
		}
		
		private function skipLine(e:KeyboardEvent):void{
			if (subtitle)
				subtitle.dispatchEvent(new Event("removeSub"));
			nextStep();
		}
			
		private function nextStep():void{
			if (player.currentLabel == "talk"){
				player.gotoAndStop("default");
			}
			if (targetChar.currentLabel == "talk"){
				targetChar.gotoAndStop("default");
			}
			channel.stop(); // Only needed for audio
			if (currentLine < totalLines-1){
				currentLine += 1;
				startLine();
			} else {
				stageRef.removeEventListener(KeyboardEvent.KEY_DOWN, skipLine); // Only needed for audio
				if (currentData.action == "end"){
					removeThis();
				} else if (showOptions){
					if (currentData.submenu){
						populateOptions("suboption");
					} else {
						populateOptions("option");
					}
					visible = true;
					Mouse.show(); // Only needed for audio
				} else {
					removeThis();
				}
				puzzle.spokeDialog(currentData);
			}
		}
		
		private function optionOn(e:MouseEvent):void{
			e.currentTarget.optionText.textColor = 0x00CC33;
		}
			
		private function optionOff(e:MouseEvent):void{
			e.currentTarget.optionText.textColor = 0xFFFFFF;
		}
		
		private function isEven(thisNumber:int):Boolean{
    		return (thisNumber%2 == 0) ? true : false;
		}
		
		private function removeThis():void{
			Engine.playerControl = true;
			Mouse.show();
			if (stageRef.contains(this))
				stageRef.removeChild(this);
			dispatchEvent(new Event("dialogFinished"));
		}
	}//end class
}//end package