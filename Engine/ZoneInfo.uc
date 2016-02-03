//=============================================================================
// ZoneInfo, the built-in Unreal class for defining properties
// of zones.  If you place one ZoneInfo actor in a
// zone you have partioned, the ZoneInfo defines the 
// properties of the zone.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ZoneInfo extends Info
	native
	placeable;

#exec Texture Import File=Textures\ZoneInfo.pcx Name=S_ZoneInfo Mips=Off MASKED=1

//-----------------------------------------------------------------------------
// Zone properties.

var skyzoneinfo SkyZone; // Optional sky zone containing this zone's sky.
var() name ZoneTag;
var() localized String LocationName; // gam

//-----------------------------------------------------------------------------
// Zone flags.

var() const bool   bFogZone;     // Zone is fog-filled.
var()		bool   bTerrainZone;	// There is terrain in this zone.
var()		bool   bDistanceFog;	// There is distance fog in this zone.
var()		bool   bClearToFogColor;	// Clear to fog color if distance fog is enabled.

var const array<TerrainInfo> Terrains;

//-----------------------------------------------------------------------------
// Zone light.
var            vector AmbientVector;
var(ZoneLight) byte AmbientBrightness, AmbientHue, AmbientSaturation;

var(ZoneLight) color DistanceFogColor;
var(ZoneLight) float DistanceFogStart;
var(ZoneLight) float DistanceFogEnd;
var(ZoneLight) float DistanceFogBlendTime;

var(ZoneLight) const texture EnvironmentMap;
var(ZoneLight) float TexUPanSpeed, TexVPanSpeed;

var(ZoneSound) editinline I3DL2Listener ZoneEffect;

//------------------------------------------------------------------------------

var(ZoneVisibility) bool bLonelyZone;								// This zone is the only one to see or never seen
var(ZoneVisibility) editinline array<ZoneInfo> ManualExcludes;		// No Idea.. just sounded cool

//=============================================================================
// Iterator functions.

// Iterate through all actors in this zone.
native(308) final iterator function ZoneActors( class<actor> BaseClass, out actor Actor );

simulated function LinkToSkybox()
{
	local skyzoneinfo TempSkyZone;

	// SkyZone.
	foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
		SkyZone = TempSkyZone;
	foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
		if( TempSkyZone.bHighDetail == Level.bHighDetailMode )
			SkyZone = TempSkyZone;
}

//=============================================================================
// Engine notification functions.

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// call overridable function to link this ZoneInfo actor to a skybox
	LinkToSkybox();
}

// When an actor enters this zone.
event ActorEntered( actor Other );

// When an actor leaves this zone.
event ActorLeaving( actor Other );

defaultproperties
{
     DistanceFogStart=3000.000000
     DistanceFogEnd=8000.000000
     DistanceFogBlendTime=1.000000
     TexUPanSpeed=1.000000
     TexVPanSpeed=1.000000
     DistanceFogColor=(B=128,G=128,R=128)
     AmbientSaturation=255
     Texture=Texture'Engine.S_ZoneInfo'
     bStatic=True
     bNoDelete=True
}
