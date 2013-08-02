/****
* 
****/

package flash.display3D;
#if (flash || display)
@:fakeEnum(String) extern enum Context3DTriangleFace {
	BACK;
	FRONT;
	FRONT_AND_BACK;
	NONE;
}
#else
import openfl.gl.GL;

class Context3DTriangleFace 
{
   inline public static var BACK = GL.FRONT;
   inline public static var FRONT = GL.BACK;
   inline public static var FRONT_AND_BACK = GL.FRONT_AND_BACK;
   inline public static var NONE = 0;
}

#end