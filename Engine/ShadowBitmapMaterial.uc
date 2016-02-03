class ShadowBitmapMaterial extends BitmapMaterial
	native;

#exec Texture Import file=Textures\blobshadow.tga Name=BlobTexture Mips=On UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP DXT=3

var const transient int	TextureInterfaces[2];

var const transient int LastDirtyMarker;

var Actor			ShadowActor;
var Actor			ShadowActorProxy;
var array<Actor>	ExtraShadowActors;
var vector			LightDirection;
var float			LightDistance,
					LightFOV;
var bool			Dirty,
					Invalid,
					bBlobShadow;
var float			StartFadeDistance, CullDistance;
var byte			ShadowDarkness;

var BitmapMaterial	BlobShadow;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function AddExtraShadowActor(Actor A)
{
	ExtraShadowActors.Length = ExtraShadowActors.Length + 1;
	ExtraShadowActors[ExtraShadowActors.Length - 1] = A;
}

//
//	Default properties
//

defaultproperties
{
     BlobShadow=Texture'Engine.BlobTexture'
     ShadowDarkness=200
     Dirty=True
     Format=TEXF_RGBA8
     UClampMode=TC_Clamp
     VClampMode=TC_Clamp
     UBits=7
     VBits=7
     USize=128
     VSize=128
     UClamp=128
     VClamp=128
}
