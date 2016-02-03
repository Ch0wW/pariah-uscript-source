/*
	SpherizeTwo: Implements the photoshop spherize filter but animates it so it bubbles on out the screen
				 then bubbles into the screen
	xmatt
*/

class SpherizeTwo extends VertexModifier
	native;

var	  bool	bInitialized;
var   float StartTime;

var int   eType;
var int	  TileSize;
var float Radius;
var float Speed;				//Speed at which warping occurs
var float SpherizeAmplitude;	//Amount of spherize
var float PinchAmplitude;		//Amount of pinch
var float ScreenPosX;
var float ScreenPosY;

defaultproperties
{
     TileSize=30
     Radius=0.500000
}
