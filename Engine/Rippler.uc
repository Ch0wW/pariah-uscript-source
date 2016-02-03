/*
	Rippler: Warps the screen with ripples that expands from the center of the screen
	xmatt
*/

class Rippler extends VertexModifier
	native;

var	bool  bInitialized;
var float StartTime;

var int   eType;
var int	  TileSize;
var	float Speed;				//Speed at which warping occurs
var float Amplitude;
var float Rippleness;
var float ScreenScale;
var float ScreenPosX;
var float ScreenPosY;

defaultproperties
{
     TileSize=60
     Speed=0.800000
     Amplitude=2.000000
     Rippleness=20.000000
}
