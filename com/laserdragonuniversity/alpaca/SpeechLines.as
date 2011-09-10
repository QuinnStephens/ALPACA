package com.laserdragonuniversity.alpaca {
	
	public class SpeechLines{
		
		private var lineID:String;
		private var lineText:String;
		private var lineSplit:Array;
		
		public function SpeechLines(lineID:String){
			
			this.lineID = lineID;
			lineSplit = lineID.split("_");
			//trace (lineSplit);
			
			// This would probably be a lot more elegant if you created an XML file with all this data in it,
			// but this basically works for the time being
			
			switch(lineSplit[0]){
				
				case "BOX":
				switch(lineSplit[1]){
					
					case "Look":
					lineText = "It's a box.  Apparently an extremely boring one.";
					break;
					
					case "Use":
					lineText = "I'll need something sharp to make it through that extra-strong packing tape.";
					break;
				}
				break;
				
				case "WALL":
				switch(lineSplit[1]){
					
					case "Look":
					lineText = "It's a rocky wall with metal support columns.  Exciting stuff.";
					break;
					
					case "Use":
					lineText = "I can't really do anything with just a wall.";
					break;
				}
				break;
				
				case "ROCK":
				switch(lineSplit[1]){
					
					case "Look":
					lineText = "It's a rock.";
					break;
					
					case "Use":
					lineText = "I don't need a rock for anything right now.";
					break;
				}
				break;
				
				case "LEDGE":
				switch(lineSplit[1]){
					
					case "Look":
					lineText = "Sure is a long way down to those jagged rocks down there...";
					break;
					
					case "Use":
					lineText = "Do I look like a BASE jumper to you?";
					break;
				}
				break;
				
				case "HANGAR":
				switch(lineSplit[1]){
					
					case "Look":
					lineText = "This hangar looks too small to admit anything larger than a motorcycle.  Odd.";
					break;
					
					case "Use":
					lineText = "As soon as I want to store a motorcycle-sized plane, I'll get right on that.";
					break;
				}
				break;
					
				
				default:
				lineText = "Nah, I don't think I'm gonna do that.";
				break;
				
			}
			
		}
		
		public function returnText():String{
			return lineText;
		}
		
	} // end class
}// end package
				