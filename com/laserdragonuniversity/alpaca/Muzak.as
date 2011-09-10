package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	
	public class Muzak extends MovieClip{
		
		private var music:Sound;
		private var channel:SoundChannel = new SoundChannel();
		private var transformer:SoundTransform;
		private var musicURL:String;
		
		public function Muzak(musicURL:String, musicVol:Number){
			this.musicURL = musicURL;
			if(musicURL != ""){
				music = new Sound(new URLRequest(musicURL));
				transformer  = new SoundTransform(musicVol, 0);
				playSound();
			}
		}
		
		public function playSound():void{
			channel = music.play();
			channel.soundTransform = transformer;
			channel.addEventListener(Event.SOUND_COMPLETE, loopSound, false, 0, true);
		}
		
		private function loopSound(e:Event):void{
			channel.removeEventListener(Event.SOUND_COMPLETE, loopSound);
			playSound();
		}
		
		public function changeVolume(newVol:Number):void{
			if(musicURL != ""){
				transformer.volume = newVol;
				channel.soundTransform = transformer;
			}
		}
		
		public function stopSound():void{
			channel.stop();
		}
		
	}//end class
} //end package