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
enum Context3DStencilAction 
{
   DECREMENT_SATURATE;
   DECREMENT_WRAP;
   INCREMENT_SATURATE;
   INCREMENT_WRAP;
   INVERT;
   KEEP;
   SET;
   ZERO;
}

#end