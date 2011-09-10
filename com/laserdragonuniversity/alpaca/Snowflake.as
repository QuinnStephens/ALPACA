package com.laserdragonuniversity.alpaca {
 
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
 
	public class Snowflake extends MovieClip
	{
 
		private var stageRef:Stage;
		private var speed:Number;
		private var wind:Number;
 
		public function Snowflake(stageRef:Stage)
		{
			this.stageRef = stageRef;
			setupSnow(true);
			addEventListener(Event.ENTER_FRAME, loop, false, 0, true);
			stageRef.addEventListener("removeSnow", removeThis, false, 0, true);
		}
 
		public function setupSnow(randomizeY:Boolean = false) : void
		{
			//inline conditional, looks complicated but it's not.
			y = randomizeY ? Math.random()*stageRef.stageHeight : 0;
			x = Math.random()*stageRef.stageWidth*2-stageRef.stageWidth;
			alpha = Math.random();
			rotation = Math.random()*360;
			scaleX = Math.random();
			scaleY = Math.random();
 
			speed = 4 + Math.random()*2;
			wind = 2 + Math.random()*2;
		}
 
		public function loop(e:Event) : void
		{
			var yRandom = Math.random()*2;
			var xRandom = Math.random()*2;
			
			y += speed+yRandom;
			x += wind+xRandom;
 
			if (y > stageRef.stageHeight)
				setupSnow();
 
		}
		
		private function removeThis(e:Event):void{
			if (stageRef.contains(this))
				stageRef.removeChild(this);
		}
									
 
	}
}