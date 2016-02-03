/*
	TitanWeaponEffect:
		(1) Spherizes the middle of the screen out then into the screen
		(2) Makes a wave that expands from the middle of the screen

	xmatt

	- renamed it WarpPostFXStage when converting it to new PostFXManager framework (rj)
*/

class WarpPostFXStage extends PostFXStage
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

//General params
var int			WarpType;
//var const int	RenderTarget;
var bool		bRestart;
var float		ScreenPosX;
var float		ScreenPosY;

//Spherize warp params
var int			SpherizeTileSize;
var float		SpherizeRadius;
var int			SpherizeType;
var float		SpherizeSpeed;
var float		SpherizeAmplitude;
var float		PinchAmplitude;

//Ripple warp params
var int			RippleTileSize;
var int			RippleType;
var float		RippleSpeed;
var float		RippleAmplitude;
var float		Rippleness;
var float		RippleScreenScale;

//Compression waves warp params
var int			CompressionTileSize;
var int			CompressionType;
var	float		Wave1Speed;
var	float		Wave2Speed;
var	float		Wave3Speed;
var float		Wave1Amplitude;
var float		Wave2Amplitude;
var float		Wave3Amplitude;
var float		Wave1Size;
var float		Wave2Size;
var float		Wave3Size;
var float		CompressedWavesScreenScale;

defaultproperties
{
     SpherizeTileSize=30
     RippleTileSize=60
     CompressionTileSize=40
     SpherizeRadius=0.500000
     SpherizeSpeed=2.800000
     SpherizeAmplitude=1.200000
     PinchAmplitude=1.600000
     RippleSpeed=1.100000
     RippleAmplitude=20.000000
     Rippleness=30.000000
     Wave1Speed=2.000000
     Wave2Speed=4.800000
     Wave3Speed=2.500000
     Wave1Amplitude=0.040000
     Wave2Amplitude=0.030000
     Wave3Amplitude=0.020000
     Wave1Size=0.200000
     Wave2Size=0.200000
     Wave3Size=0.200000
     CompressedWavesScreenScale=0.800000
     bEnabled=True
}
