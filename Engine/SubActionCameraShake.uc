//=============================================================================
// SubActionCameraShake:
//
// Shakes the camera randomly.
//=============================================================================
class SubActionCameraShake extends MatSubAction
	native;

var(Shake)	rangevector		Shake;
var(Shake)  bool            bSmooth;
var(Shake)  int             smoothness;
var         int             smoothCount;

defaultproperties
{
     smoothness=1
     Icon=Texture'Engine.SubActionCameraShake'
     Desc="Shake"
}
