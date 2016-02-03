//
//	ShadowProjector
//

class ShadowProjector extends Projector
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() Actor					ShadowActor;
var() Actor					ShadowActorProxy;	// use this actor to do actual render
var() array<Actor>			ExtraShadowActors;
var() vector				LightDirection;
var() float					LightDistance;
var() bool					RootMotion;
var() bool					bBlobShadow;
var transient ShadowBitmapMaterial	ShadowTexture; // sjs[sg]
var float					UpdateInterval;
var vector					LocationOffset;

//
//	PostBeginPlay
//

native function UpdateShadow();

event PostBeginPlay()
{
	UpdateInterval = FRand() * 0.1; // try to offset the updates to shadows
	Super(Actor).PostBeginPlay();
}

//
//	Destroyed
//

event Destroyed()
{
	Shutdown();

	Super.Destroyed();
}

function Shutdown()
{
	DetachProjector();
	if(ShadowTexture != None)
	{
		ShadowTexture.ShadowActor = None;
		ShadowTexture.ShadowActorProxy = None;
		ShadowTexture.ExtraShadowActors.Length = 0;
		Level.GetObjectPool().FreeObject(ShadowTexture);  // sjs[sg]
		ShadowTexture = None;
	}
	ExtraShadowActors.Length = 0;
	ProjTexture = None;
}

//
//	InitShadow
//

function InitShadow( optional float FOVMult, optional byte ShadowDarkness, optional float StartFadeDistance )
{
	local Plane		BoundingSphere;
	local float		BaseFOV;
	//local float		ProjectorDist;

	if(ShadowActor != None)
	{
		if  ( FOVMult <= 0 )
		{
			FOVMult = 1.2;
		}
		BoundingSphere = ShadowActor.GetRenderBoundingSphere();
		BaseFOV = Asin(BoundingSphere.W /  LightDistance) * 360 / PI;
		FOV = BaseFOV * FOVMult;

		ShadowTexture = ShadowBitmapMaterial(Level.GetObjectPool().AllocateObject(class'ShadowBitmapMaterial'));  // sjs[sg]
		ProjTexture = ShadowTexture;

		if(ShadowTexture != None)
		{
			LightDirection = Normal(LightDirection);
			LocationOffset = LightDirection * BoundingSphere.W;

			if ( bBlobShadow )
				SetDrawScale( 1.0f );
			else
				SetDrawScale((LightDistance-BoundingSphere.W) * tan(FOV * PI / 360) / (0.5 * ShadowTexture.USize));

			ShadowTexture.Invalid = False;
			ShadowTexture.bBlobShadow = bBlobShadow;
			ShadowTexture.ShadowActor = ShadowActor;
			ShadowTexture.ShadowActorProxy = ShadowActorProxy;
			ShadowTexture.ExtraShadowActors = ExtraShadowActors;
			ShadowTexture.LightDirection = LightDirection;
			ShadowTexture.LightDistance = LightDistance;
			ShadowTexture.LightFOV = FOV;
            ShadowTexture.CullDistance = CullDistance; // sjs
			ShadowTexture.StartFadeDistance = StartFadeDistance; // rj@bb
            if ( ShadowDarkness > 0 )
            {
				ShadowTexture.ShadowDarkness = ShadowDarkness;
			}

			Enable('Tick');
			UpdateShadow();
		}
		else
			Log(Name$".InitShadow: Failed to allocate texture");
	}
	else
		Log(Name$".InitShadow: No actor");
}

//
//	UpdateShadow
//

//function UpdateShadow(optional float DeltaTime)
//{
//	local coords	C;
//
//	DetachProjector(true);
//
//	if(ShadowActor != None && !ShadowActor.bHidden && ShadowTexture != None)
//	{
//		if(ShadowTexture.Invalid)
//			Destroy();
//		else
//		{
//			if(RootMotion && ShadowActor.DrawType == DT_Mesh && ShadowActor.Mesh != None)
//			{
//				C = ShadowActor.GetBoneCoords('');
//				SetLocation(C.Origin+LocationOffset);
//			}
//			else
//				SetLocation(ShadowActor.Location+LocationOffset);
//
//            if( Level.bHighDetailMode==false )
//            {
//                ShadowTexture.bBlobShadow = true;
//                SetRotation(Rotator(vect(0,0,-1)));
//            }
//            else
//            {
//                ShadowTexture.bBlobShadow = false;
//			    SetRotation(Rotator(-LightDirection));
//            }
//
//			UpdateInterval -= DeltaTime;
//            if( UpdateInterval <= 0 )
//            {
//			    ShadowTexture.Dirty = true;
//				UpdateInterval = 0.05;
//            }
//
//            ShadowTexture.CullDistance = CullDistance; // sjs
//
//			AttachProjector();
//		}
//	}
//}

//
//	Tick
//

//function Tick(float DeltaTime)
//{
//	local PlayerController P;
//	local float cameraDistance;
//	local float fovBias;
//
//	super.Tick(DeltaTime);
//	
//	// Get camera location
//	P = Level.GetLocalPlayerController();
//	if ( P != None && P.Pawn != None )
//	{
//		// Check distance if shadow should be updated
//		cameraDistance = VSize( ShadowActor.Location - P.Pawn.Location );
//		fovBias = Tan( P.DesiredFOV*(0.00872664625997.f) ); // PI/360.0f
//		if ( (cameraDistance * (fovBias * fovBias)) < CullDistance )
//			UpdateShadowA( DeltaTime );
//	}
//	else
//	{
//		UpdateShadowA(DeltaTime);
//	}
//}

function AddExtraShadowActor(Actor A)
{
	if ( A != None && A.bActorShadows )
	{
		ExtraShadowActors.Length = ExtraShadowActors.Length + 1;
		ExtraShadowActors[ExtraShadowActors.Length - 1] = A;
		if ( ShadowTexture != None )
		{
			ShadowTexture.AddExtraShadowActor( A );
		}
	}
}

//
//	Default properties
//

defaultproperties
{
     GradientTexture=Texture'Engine.GRADIENT_Clip'
     bProjectActor=False
     bClipBSP=True
     bGradient=True
     bProjectOnAlpha=True
     bProjectOnParallelBSP=True
     bDynamicAttach=True
     CullDistance=3000.000000
     bStatic=False
     bOwnerNoSee=True
}
