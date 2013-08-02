/****
* 
****/

package flash.display3D;
#if (flash || display)
@:fakeEnum(String) extern enum Context3DCompareMode {
	ALWAYS;
	EQUAL;
	GREATER;
	GREATER_EQUAL;
	LESS;
	LESS_EQUAL;
	NEVER;
	NOT_EQUAL;
}
#else
import openfl.gl.GL;

class Context3DCompareMode 
{
   inline static public var ALWAYS = GL.ALWAYS;
   inline static public var EQUAL = GL.EQUAL;
   inline static public var GREATER = GL.GREATER;
   inline static public var GREATER_EQUAL = GL.GEQUAL;
   inline static public var LESS = GL.LESS;
   inline static public var LESS_EQUAL = GL.LEQUAL; // TODO : wrong value
   inline static public var NEVER = GL.NEVER;
   inline static public var NOT_EQUAL = GL.NOTEQUAL;
}

 #end