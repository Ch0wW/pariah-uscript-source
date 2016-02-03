//=============================================================================
// SubActionScreenText:
//
// Shows text on screen.
//=============================================================================
class SubActionScreenText extends MatSubAction
	native;

var(ScreenText)	color	Color;
var(ScreenText)	bool	bFade;		// If TRUE, the text will fade in and out
var(ScreenText) float	FadePct;
var(ScreenText) float	X, Y;
var(ScreenText) String TextID;  //this is going to be a problem. It'll need to be localized... but not statically.  An ID perhaps?
var(ScreenText) EDrawPivot Pivot;

//changes to this stuff will have to be propagated down to MatineeText in playercontroller.uc

defaultproperties
{
     bFade=True
     Icon=Texture'Engine.SubActionText'
     Desc="Text"
}
