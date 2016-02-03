class FluidSurfaceInfo extends Info
	showcategories(Movement,Collision,Lighting,LightColor,Karma,Force)
	native
	noexport
	placeable;

var () enum EFluidGridType
{
	FGT_Square,
	FGT_Hexagonal
} FluidGridType;

var () float						FluidGridSpacing; // distance between grid points
var () int							FluidXSize; // num vertices in X direction
var () int							FluidYSize; // num vertices in Y direction

var () float						FluidHeightScale; // vertical scale factor

var () float						FluidSpeed; // wave speed
var () float						FluidDamping; // between 0 and 1

var () float						FluidNoiseFrequency;
var () range						FluidNoiseStrength;

var () bool							TestRipple;
var () float						TestRippleSpeed;
var () float						TestRippleStrength;
var () float						TestRippleRadius;

var () float						UTiles;
var () float						UOffset;
var	() float						VTiles;
var () float						VOffset;
var () float						AlphaCurveScale;
var () float						AlphaHeightScale;
var () byte 						AlphaMax;

var () float						ShootStrength; // How hard to ripple water when shot
var () float						ShootRadius; // How large a radius is affected when water is shot

// How much to ripple the water when interacting with actors
var () float						RippleVelocityFactor;
var () float						TouchStrength;

// Effect spawned when water surface it shot or touched by an actor
var () class<Effects>				ShootEffect;
var () bool							OrientShootEffect;

var () class<Effects>				TouchEffect;
var () bool							OrientTouchEffect;

// Bitmap indicating which water verts are 'clamped' ie. dont move
var const array<int>				ClampBitmap;

// Terrain used for auto-clamping water verts if below terrain level.
var () edfindable TerrainInfo		ClampTerrain;

var () bool							bShowBoundingBox;
var () bool							bUseNoRenderZ;
var () float						NoRenderZ;

// Amount of time to simulate during postload before water is first displayed
var () float						WarmUpTime;

// Rate at which fluid sim will be updated
var () float						UpdateRate;

// Sim storage
var transient const array<float>	Verts0;
var transient const array<float>	Verts1;
var transient const array<byte>		VertAlpha;

var transient const int				LatestVerts;

var transient const box				FluidBoundingBox;	// Current world-space AABB
var transient const vector			FluidOrigin;		// Current bottom-left corner

var transient const float			TimeRollover;
//var transient const float			AverageTimeStep;
//var transient const int  			StepCount;
var transient const float			TestRippleAng;

var transient const FluidSurfacePrimitive Primitive;
var transient const array<FluidSurfaceOscillator>	Oscillators;
var transient const bool			bHasWarmedUp;

// Functions

// Ripple water at a particlar location.
// Ignores 'z' componenet of position.
native final function Pling(vector Position, float Strength, optional float Radius);

// Default behaviour when shot is to apply an impulse and kick the KActor.
simulated function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	//Log("FS TakeDam:"$hitlocation);

	// Vibrate water at hit location.
	Pling(hitLocation, ShootStrength, ShootRadius);

	// If present, spawn splashy hit effect.
	if( (ShootEffect != None) && EffectIsRelevant(HitLocation,false) )
	{
		if(OrientShootEffect)
			spawn(ShootEffect, self, , hitLocation, rotator(momentum));
		else
			spawn(ShootEffect, self, , hitLocation);
	}
}

simulated function Touch(Actor Other)
{
	local vector touchLocation;

	Super.Touch(Other);

	if(Other.bDisturbFluidSurface == false)
		return;

	touchLocation = Other.Location;
	touchLocation.Z = Location.Z;

	Pling(touchLocation, TouchStrength, Other.CollisionRadius);

	if( (TouchEffect != None) && EffectIsRelevant(touchLocation,false) )
	{
		if(OrientTouchEffect)
			spawn(TouchEffect, self, , touchLocation, rotator(Other.Velocity));
		else
			spawn(TouchEffect, self, , touchLocation);
	}
}

defaultproperties
{
     FluidGridType=FGT_Hexagonal
     FluidGridSpacing=24.000000
     FluidXSize=48
     FluidYSize=48
     FluidHeightScale=1.000000
     FluidSpeed=170.000000
     FluidDamping=0.500000
     FluidNoiseFrequency=60.000000
     FluidNoiseStrength=(Min=-70.000000,Max=70.000000)
     TestRippleSpeed=3000.000000
     TestRippleStrength=-20.000000
     TestRippleRadius=48.000000
     UTiles=1.000000
     VTiles=1.000000
     AlphaHeightScale=10.000000
     AlphaMax=128
     ShootStrength=-300.000000
     RippleVelocityFactor=-0.050000
     TouchStrength=-200.000000
     WarmUpTime=2.000000
     UpdateRate=50.000000
     Texture=Texture'Engine.S_TerrainInfo'
     DrawType=DT_FluidSurface
     bHidden=False
     bNoDelete=True
     bUnlit=True
     bCollideActors=True
     bProjTarget=True
     bEdShouldSnap=True
}
