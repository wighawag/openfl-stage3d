/****
* 
****/

package flash.display3D;
#if (flash || display)
@:fakeEnum(String) extern enum Context3DStencilAction {
	DECREMENT_SATURATE;
	DECREMENT_WRAP;
	INCREMENT_SATURATE;
	INCREMENT_WRAP;
	INVERT;
	KEEP;
	SET;
	ZERO;
}
#else
import openfl.gl.GL;

class Context3DStencilAction 
{
public static inline var DECREMENT_SATURATE = GL.DECR;
public static inline var DECREMENT_WRAP = GL.DECR_WRAP;
public static inline var INCREMENT_SATURATE = GL.INCR;
public static inline var INCREMENT_WRAP = GL.INCR_WRAP;
public static inline var INVERT = GL.INVERT;
public static inline var KEEP = GL.KEEP;
public static inline var SET = GL.REPLACE;
public static inline var ZERO = GL.ZERO;
}

#end