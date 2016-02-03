//=============================================================================
// Material: Abstract material class
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Material extends Object
	native
	hidecategories(Object)
	collapsecategories
	noexport;

#exec Texture Import File=Textures\DefaultTexture.tga

var(Texture) Material FallbackMaterial;
var Material DefaultMaterial;
var const transient bool UseFallback;	// Render device should use the fallback.
var const transient bool Validated;		// Material has been validated as renderable.
var const transient bool Corrupted;		// The material is corrupted in someway
var(Texture) bool bAlwaysTick; // sjs - tick even if game is paused

var () transient int MaterialType; // jim - used only in native, but needed sizes to match

// sjs ---
var(Texture) enum ESurfaceTypes// !! - must mirror with Actor.uc in order for BSP geom surface's to match
{
	EST_Default,
	EST_Rock,
	EST_Dirt,
	EST_Metal,
	EST_Wood,
	EST_Plant,
	EST_Flesh,
    EST_Ice,
    EST_Snow,
    EST_Water,
    EST_Glass,
	EST_Wet,
	EST_Stone,
	EST_Sand,
	EST_ThinDefault,
	EST_ThinRock,
	EST_ThinDirt,
	EST_ThinMetal,
	EST_ThinWood,
	EST_ThinPlant,
	EST_ThinFlesh,
    EST_ThinIce,
    EST_ThinSnow,
    EST_ThinWater,
    EST_ThinGlass,
	EST_ThinWet,
	EST_ThinStone,
	EST_ThinSand,
	EST_HeatPipes,
    EST_Concrete
} SurfaceType;
// --- sjs

function Reset()
{
	if( FallbackMaterial != None )
		FallbackMaterial.Reset();
}

function Trigger( Actor Other, Actor EventInstigator )
{
	if( FallbackMaterial != None )
		FallbackMaterial.Trigger( Other, EventInstigator );
}

defaultproperties
{
     DefaultMaterial=Texture'Engine.DefaultTexture'
}
