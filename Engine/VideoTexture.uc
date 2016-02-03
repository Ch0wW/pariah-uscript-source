//=============================================================================
// sjs - this is a proxy texture for splatting bink on surfaces?!
//=============================================================================
class VideoTexture extends Texture
	safereplace
	native
	noteditinlinenew
	dontcollapsecategories
	noexport;

var() string	VideoFile;
var transient string OverrideVideoFile;
var() bool		NoLoop;
var() bool		Paused;
var() bool		UpdateOffscreen;
var() bool		PlaySoundTrack;
var() float     SoundVolume;
var transient int	CurFrame;	// updated with current frame
var transient int	NumFrames;	// total frames in video
var transient int	SetFrame;	// can set this at runtime to start at a specific frame (gets reset to 0 when frame is changed)
var const int   UStride, VStride;

defaultproperties
{
     SoundVolume=1.000000
}
