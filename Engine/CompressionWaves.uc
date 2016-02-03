/*
	CompressionWaves: Warps the screen with triangular waves that expand from the center of the screen
	xmatt
*/

class CompressionWaves extends VertexModifier
	native;

var	bool  bInitialized;
var float StartTime;

var int   eType;
var int	  TileSize;
var	float Wave1Speed; //Travelling speed of the waves
var	float Wave2Speed;
var	float Wave3Speed;

var float Wave1Amplitude; //Amplitude of the waves
var float Wave2Amplitude;
var float Wave3Amplitude;

var float Wave1Size; //Slopes of the waves
var float Wave2Size;
var float Wave3Size;

var float ScreenScale;
var float ScreenPosX;
var float ScreenPosY;

defaultproperties
{
     TileSize=40
     Wave1Speed=2.000000
     Wave2Speed=4.800000
     Wave3Speed=2.500000
     Wave1Amplitude=0.040000
     Wave2Amplitude=0.030000
     Wave3Amplitude=0.020000
     Wave1Size=0.200000
     Wave2Size=0.200000
     Wave3Size=0.200000
}
