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
	import flash.net.URLRequest;

	
	public class Speech extends MovieClip{
		
		private var useAudio:Boolean;
		private var player:Player;
		private var newSpeech:Sound = new Sound();
		private var channel:SoundChannel = new SoundChannel();
		private var transformer:SoundTransform = new SoundTransform();
		private var thisThing:Object;
		private var stageRef:Stage;
		private var action:String;
		private var subtitle:Subtitle;
		private var lineID:String;
		private var lineURL:String;
		public static var lineText:String;
		private var options:Options;
		
		public function Speech(stageRef:Stage, thisThing:Object, action:String){
			this.stageRef = stageRef;
			this.thisThing = thisThing;
			this.action = action;
			useAudio = Engine.useAudio;
			player = Engine.player;
			options = Engine.options;
			
			if (thisThing.lookTag)
				action = action+thisThing.lookTag;
				
			lineID = thisThing.displayName+"_"+action.toLowerCase();
			
			// Audio controls begin
			if(useAudio){
				// This looks for the audio clip in the library.  This makes for a larger .swf but guarantees
				// that the clip will play immediately without any lag
				try {
					var soundIdent = getDefinitionByName(lineID);
				}
				catch(e:ReferenceError){ // Gives you some leeway with the capitalization of your linked library items
					try {
						lineID = thisThing.displayName.toLowerCase()+"_"+action.toLowerCase();
						soundIdent = getDefinitionByName(lineID);
					}
					catch (e:ReferenceError){
						try {
							lineID = thisThing.displayName+"_"+action;
							soundIdent = getDefinitionByName(lineID);
						}
						catch (e:ReferenceError){
							try {
								lineID = thisThing.displayName+"_usenot";
								soundIdent = getDefinitionByName(lineID);
							}
							
							catch (e:ReferenceError){
								var no = getDefinitionByName("generalNo");
								if(no)
									soundIdent = no;
							}
						}
					}
				}
				finally {
					newSpeech = new soundIdent;
				}
				
				// This alternative gets the audio clip from an external .mp3 file.  This helps keep the .swf file
				// size down, but it might lead to some lag
				/*
				lineURL = "audio/"+lineID+".mp3";
				trace(lineURL);
				newSpeech = new Sound(new URLRequest(lineURL));
				newSpeech.addEventListener(IOErrorEvent.IO_ERROR, loadError, false, 0, true);
				*/
				transformer.volume = options.returnVol();
				channel = newSpeech.play();
				channel.soundTransform = transformer;
				channel.addEventListener(Event.SOUND_COMPLETE, doneTalking, false, 0, true);
			}
			// Audio controls end
			
			this.addEventListener("stopTalking", doneTalking, false, 0, true);
			stageRef.addEventListener("playerMoving", doneTalking, false, 0, true);
			stageRef.addEventListener("itemClicked", doneTalking, false, 0, true); 
			player.gotoAndStop("talk");
			
			if (options.getSubStatus())
				addSubtitle();
		}
		
		private function loadError(e:IOErrorEvent){ 
			newSpeech.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
			lineID = thisThing.displayName+"_usenot";
			lineURL = "audio/"+lineID+".mp3";
			newSpeech = new Sound(new URLRequest(lineURL));
			channel = newSpeech.play();
			channel.addEventListener(Event.SOUND_COMPLETE, doneTalking, false, 0, true);
			newSpeech.addEventListener(IOErrorEvent.IO_ERROR, finalError, false, 0, true);
		}
		
		private function finalError(e:IOErrorEvent){
			trace ("Cannot open file "+lineURL);
			newSpeech.removeEventListener(IOErrorEvent.IO_ERROR, finalError);
			this.dispatchEvent(new Event("stopTalking"));
		}
		
		private function addSubtitle(){
			subtitle = new Subtitle(lineID, stageRef, player);
			stageRef.addChild(subtitle);
			subtitle.addEventListener("subRemoved", doneTalking, false, 0, true);
		}
		
		public function doneTalking(e:Event):void{
			if (player.currentLabel == "talk")
				player.gotoAndStop("default");
			if(useAudio){
				channel.removeEventListener(Event.SOUND_COMPLETE, doneTalking);
				channel.stop();
			}
			if (subtitle){
				if (stageRef.contains(subtitle)){
					subtitle.dispatchEvent(new Event("removeSub"));
					subtitle.removeEventListener(MouseEvent.CLICK, doneTalking);
				}
			}
			this.removeEventListener("stopTalking", doneTalking);
			stageRef.removeEventListener("playerMoving", doneTalking);
			stageRef.removeEventListener("itemClicked", doneTalking); 
		}
		
	}//end class
} //end package