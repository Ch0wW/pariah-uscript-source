//=============================================================================
// Texture: An Unreal texture map.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Texture extends BitmapMaterial
	safereplace
	native
	noteditinlinenew
	dontcollapsecategories
	noexport;

// Palette.
var(Texture) palette Palette;

// Detail texture.
var(Texture) Material Detail;
var(Texture) float DetailScale;

// Internal info.
var const color MipZero;
var const color MaxColor;
var const int   InternalTime[2];

// Deprecated stuff.
var deprecated texture DetailTexture;	// Detail texture to apply.
var deprecated texture EnvironmentMap;// Environment map for this texture
var deprecated enum EEnvMapTransformType 
{
	EMTT_ViewSpace,
	EMTT_WorldSpace,
	EMTT_LightSpace,
} EnvMapTransformType;
var deprecated float Specular;		// Specular lighting coefficient.


// Texture flags.
var()					bool bMasked;
var()					bool bAlphaTexture;
var() private			bool bHighColorQuality;   // High color quality hint.
var() private			bool bHighTextureQuality; // High color quality hint.
var private				bool bRealtime;           // Texture changes in realtime.
var private				bool bParametric;         // Texture data need not be stored.
var private transient	bool bRealtimeChanged;    // Changed since last render.
var const editconst private  bool bHasComp;		//!!OLDVER Whether a compressed version exists.

// Level of detail set (gam) ---
var() enum ELODSet
{
	LODSET_None,
	LODSET_World,
	LODSET_PlayerSkin,
	LODSET_WeaponSkin,
	LODSET_Terrain,
	LODSET_Interface,
	LODSET_RenderMap,
	LODSET_Lightmap,
	LODSET_PlayerFace,
	LODSET_Normalmap,
	LODSET_TerrainLayer //xmatt
} LODSet;

var() int NormalLOD;
var() editconst int MinLOD;
var transient int MaxLOD;
// --- gam

// Animation.
var(Animation) texture AnimNext;
var transient  texture AnimCurrent;
var(Animation) byte    PrimeCount;
var transient  byte    PrimeCurrent;
var(Animation) float   MinFrameRate, MaxFrameRate;
var transient  float   Accumulator;

// Mipmaps.
var private native const array<int> Mips;
var const editconst ETextureFormat CompFormat; //!!OLDVER

var const transient int	RenderInterface;
var const transient int	__LastUpdateTime[2];

defaultproperties
{
     DetailScale=8.000000
     MipZero=(B=64,G=128,R=64)
     MaxColor=(B=255,G=255,R=255,A=255)
     LODSet=LODSET_World
}
