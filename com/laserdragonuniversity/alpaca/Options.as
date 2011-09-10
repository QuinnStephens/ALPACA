package com.laserdragonuniversity.alpaca {
	
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.events.*;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.display.SimpleButton;

	public class Options extends MovieClip{
		
		private var stageRef:Stage;
		public var muzak:Muzak;
		private var musicURL:String;
		private var musicVol:Number = .5;
		private var speechVol:Number = .75;
		public static var subtitlesOn:Boolean;
		public static var musicPlays:Boolean;
		private var bounds:Rectangle;
		private var widthPos:Number;
		private var currentSlider:MovieClip;
		private var sliderValue:Number;
		
		public function Options(stageRef:Stage, musicURL:String){
			
			this.stageRef = stageRef;
			
			subtitlesOn = true;
			
			muzak = new Muzak(musicURL, musicVol);
			musicSlider.slider.x = musicVol * musicSlider.width;
			
			speechSlider.slider.x = speechVol * speechSlider.width;
			
			btn_subOff.addEventListener(MouseEvent.CLICK, subOff, false, 0, true);
			btn_subOff.buttonMode = true;
			btn_subOff.gotoAndStop("off");
			
			btn_subOn.addEventListener(MouseEvent.CLICK, subOn, false, 0, true);
			btn_subOn.buttonMode = true;
			btn_subOn.gotoAndStop("on");
			
			addBounds(speedSlider);
			addBounds(musicSlider);
			addBounds(speechSlider);
			
			closer.addEventListener(MouseEvent.CLICK, closeOptions, false, 0, true);
		}
		
		private function addBounds(currentSlider:MovieClip):void{
			var trackBounds:Rectangle = currentSlider.getBounds(currentSlider);
			var xPos:Number = trackBounds.x;
			var yPos:Number = trackBounds.y;
			widthPos = trackBounds.width-currentSlider.slider.width;
			var heightPos:Number = 0;
			bounds = new Rectangle(xPos,yPos,widthPos,heightPos);
			currentSlider.slider.addEventListener(MouseEvent.MOUSE_DOWN, dragSlider);
			stageRef.addEventListener(MouseEvent.MOUSE_UP, stopSlider);
		}
			
		private function subOff(e:MouseEvent):void{
			subtitlesOn = false;
			btn_subOff.gotoAndStop("on");
			btn_subOn.gotoAndStop("off");
		}
		
		private function subOn(e:MouseEvent):void{
			subtitlesOn = true;
			btn_subOff.gotoAndStop("off");
			btn_subOn.gotoAndStop("on");
		}
		
		private function dragSlider(e:MouseEvent):void{
			currentSlider = e.currentTarget.parent;
			currentSlider.slider.startDrag(false, bounds);
			addEventListener(Event.ENTER_FRAME, sliderLoop);
		}
		
		private function stopSlider(e:MouseEvent):void{
			if (currentSlider){
				currentSlider.slider.stopDrag();
				removeEventListener(Event.ENTER_FRAME, sliderLoop);
			}
		}
		
		private function sliderLoop(e:Event):void{
			sliderValue = currentSlider.slider.x / widthPos;
			switch (currentSlider.name){
				case "musicSlider":
				musicVol = sliderValue;
				muzak.changeVolume(musicVol);
				break;
				
				case "speechSlider":
				speechVol = sliderValue;
				break;
				
				case "speedSlider":
				stageRef.frameRate = Math.floor(5 + 20 * sliderValue);
				break;
				
			}
		}
		
		public function changeMusic(newURL:String):void{
			muzak.stopSound();
			muzak = new Muzak(newURL, musicVol);
		}
		
		public function getSubStatus():Boolean{
			return subtitlesOn;
		}
		
		public function showOptions():void{
			visible = true;
			Engine.playerControl = false;
		}

		private function closeOptions(e:MouseEvent):void{
			visible = false;
			Engine.playerControl = true;
			Engine.toolbar.dispatchEvent(new Event("closedWindow"));
		}
		
		public function returnVol():Number{
			return speechVol;
		}
		
		public function saveOptions(){
			var allOptions:Object = new Object;
			allOptions.speechVol = speechVol;
			allOptions.musicVol = musicVol;
			allOptions.subtitlesOn = subtitlesOn;
			allOptions.framerate= stageRef.frameRate;
			return allOptions;
		}
		
		public function restoreOptions(savedOptions:Object){
			speechVol = savedOptions.speechVol;
			musicVol = savedOptions.musicVol;
			subtitlesOn = savedOptions.subtitlesOn;
			stageRef.frameRate = savedOptions.framerate;
			if (subtitlesOn){
				btn_subOn.gotoAndStop("on");
				btn_subOff.gotoAndStop("off");
			} else{
				btn_subOn.gotoAndStop("off");
				btn_subOff.gotoAndStop("on");
			}
			muzak.changeVolume(musicVol);
			musicSlider.slider.x = musicVol * musicSlider.width;
			speechSlider.slider.x = speechVol * speechSlider.width;
			speedSlider.slider.x = (stageRef.frameRate / 20) * speechSlider.width;
		}
	} // end class
}//end package