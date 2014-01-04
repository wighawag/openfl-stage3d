/****
* 
****/

package aglsl.assembler;

/**
 * ...
 * @author 
 */
class ERegTools
{
 
	static public function replace(s : String, sub : EReg, by : String ):String 
	{
	  
		return sub.replace(s, by);
	}
	static public function search(s : String, sub : EReg ):Int 
	{
	 
		if ( sub.match(s))
		{
			return sub.matchedPos().pos;
		}
		return -1;
	}
	static public function match(str:String,rgx:EReg,?len:Int=1):Array<String> 
	{ 
		var tmp:Array<String> = [];
		
	
		while (rgx.match(str)) {   
		  for(i in 0...len)  tmp.push(rgx.matched(i)); 
		  str = rgx.matchedRight(); 
		} 
		return tmp;
	}
	
}