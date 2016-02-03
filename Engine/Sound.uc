class Sound extends Object
    native
	hidecategories(Object)
    noexport;

var native const byte Data[28]; // sizeof (FSoundData) :(
var native const Name FileType;
var native const String FileName;
var native const float Duration;
var native const int Handle;
var native const int Flags;

var(Sound) native float Likelihood;
var(Sound) float BaseRadius;
var(Sound) float VelocityScale;
var(Sound) bool bCompressable;
var(Sound) enum EXACTProps
{
	XP_None,
	XP_NoLatencyStream,
	XP_Loop,
	XP_NoLatencyStreamLoop	
} XBoxProperties;
var(Sound) int XboxSoundBoost;

defaultproperties
{
     BaseRadius=512.000000
     bCompressable=True
}
