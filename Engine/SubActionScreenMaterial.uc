//=============================================================================
// SubActionScreenMaterial:
//
// Shows a Material on screen
//=============================================================================

class SubActionScreenMaterial extends MatSubAction
	native;

var(ScreenMaterial)	bool	bFade;		// If TRUE, the text will fade in and out
var(ScreenMaterial) float	FadePct;
var(ScreenMaterial) float	X, Y;
var(ScreenMaterial) EDrawPivot Pivot;
var(ScreenMaterial) Material M;
var(ScreenMaterial) int Width, Height;

//changes to this stuff will have to be propagated down to MatineeMaterial in playercontroller.uc

defaultproperties
{
     bFade=True
     Icon=Texture'Engine.SubActionMaterial'
     Desc="Material"
}
