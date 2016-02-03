class RibbonEmitter extends ParticleEmitter
	native;

struct native RibbonPoint
{
	var() vector Location;
	var() vector AxisNormal;
	var() float Width;
	var() float Alpha;
	var() float AlphaTime;
//	var() float AlphaMax;
};

enum EGetPointAxis
{
	PAXIS_OwnerX, // owners X axis based on rotation
	PAXIS_OwnerY, // owners Y axis based on rotation
	PAXIS_OwnerZ, // owners Z axis based on rotation
	PAXIS_BoneNormal, // (end - start) or start bone direction if no end bone found
	PAXIS_StartBoneDirection, // start bones direction
	PAXIS_AxisNormal, // specified normal
	PAXIS_ActorAttach // attached the ribbon behind an actor (xmatt)
};

// main vars
var(Ribbon) float SampleRate;
var(Ribbon) float DecayRate;
var(Ribbon) int NumPoints;
var(Ribbon) float RibbonWidth;
var(Ribbon) EGetPointAxis GetPointAxisFrom;
var(Ribbon) vector AxisNormal; // used for PAXIS_AxisNormal
var(Ribbon) float MinSampleDist;
var(Ribbon) float MinSampleDot;
var(Ribbon) float PointOriginOffset;

var(Ribbon) float AlphaMaxTime;	// time for each ribbon point to fade out
var(Ribbon) bool bAlphaFade;

// texture UV scaling
var(RibbonTexture) float RibbonTextureUScale;
var(RibbonTexture) float RibbonTextureVScale;
var(RibbonTexture) float RibbonTextureVStart;

// axis rotated sheets
var(RibbonSheets) int NumSheets; // number of sheets used
var(RibbonSheets) array<float> SheetScale;

// bone vars (emitter must have an actor with a skeletal mesh as its owner)
var(RibbonBones) vector StartBoneOffset;
var(RibbonBones) vector EndBoneOffset;
var(RibbonBones) name BoneNameStart;
var(RibbonBones) name BoneNameEnd;

// ribbon point array
var(Ribbon) array<RibbonPoint> RibbonPoints;

// flags
var(Ribbon) bool bSamplePoints;
var(Ribbon) bool bDecayPoints;
var(Ribbon) bool bDecayPointsWhenStopped;
var(Ribbon) bool bSyncDecayWhenKilled;
var(RibbonTexture) bool bLengthBasedTextureU;
var(RibbonSheets) bool bUseSheetScale;
var(RibbonBones) bool bUseBones;
var(RibbonBones) bool bUseBoneDistance; // get width from distance between start and end bones

// internal vars
var transient float SampleTimer; // sample timer (samples point at SampleTimer >= SampleRate)
var transient float DecayTimer;
var transient float RealSampleRate;
var transient float RealDecayRate;
var transient int SheetsUsed;
var transient RibbonPoint LastSampledPoint;

var transient bool bKilled; // used to init vars when particle emitter is killed
var transient bool bDecaying;

defaultproperties
{
     NumPoints=20
     SampleRate=0.050000
     RibbonWidth=20.000000
     MinSampleDist=1.000000
     MinSampleDot=0.995000
     PointOriginOffset=0.500000
     RibbonTextureUScale=1.000000
     RibbonTextureVScale=1.000000
     AxisNormal=(Z=1.000000)
     GetPointAxisFrom=PAXIS_AxisNormal
     bSamplePoints=True
     bDecayPoints=True
     MaxParticles=1
     InitialParticlesPerSecond=10000.000000
     StartSizeRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
     UseRegularSizeScale=False
     AutomaticInitialSpawning=False
}
