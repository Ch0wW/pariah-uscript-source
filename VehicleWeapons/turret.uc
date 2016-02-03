/*
	Turret

	Desc:
		- Shoots any Pawn in its DetectedPawns list
		- (*) This class detects no pawn, it must be done by child classes
		- Does not need to activate
		- Turns towards target at a certain speed
		- Gets turned off by EMP

	note: 'barrel' bone name should be changed to 'TurretTip' by artists since 
		  this class does not deal is not a barrel type turret

	note:
										DumbTurret
											|
										  Turret
										    |
						---------------------------------------
						|									  |
				VGActivationTurret					   VGDropShipTurret
						|
			VGBarrelActivationTurret				   
						|
	VGVolumeCheckingBarrelActivationTurret (ch.3)


	xmatt
*/

class Turret extends DumbTurret
	notplaceable;

var() bool	bIsOn;
var() float HeadYawSpeed;
var() float HeadPitchSpeed;
var Rotator HeadRot;
var() vector PivotToTraceStart;
var() int	HitDistanceAboveHip;
var() int	MaxSpreadAngle;

// vars for disabling via emp
var bool bDisabled;
var float EMPTime, EMPTimer;

//Shells
//var TurretBulletCasings BulletShells;
//var bool bBulletShellsComingOut;

//Maintained list of pawns that were detected by the turret
//Note: pawns and not vgpawn because the dropship is a pawn
var array<Pawn> DetectedPawns;


var(Events) editconst const Name hDestroy;

function PreBeginPlay()
{
    super.PreBeginPlay();
}


function bool RemoveDetected( Pawn P )
{
	local int i,num;
	local bool bItWasTarget;
	
	bItWasTarget = false;

	num = DetectedPawns.Length;
	for( i=0; i < num; i++ )
	{
		if( DetectedPawns[i] == P )
		{
			if( DetectedPawns[i] == Target )
			{
				bItWasTarget = true;
				Target = None;
			}
			DetectedPawns.Remove(i,1);
			break;
		}
	}
	return bItWasTarget;
}


simulated function bool CanSeeTarget( Actor A )
{
	local vector Start, TargetPoint;
	local Rotator TargetRot;
	
	TargetPoint = A.Location;
	TargetPoint.Z += HitDistanceAboveHip;
	
	TargetRot = Rotator( TargetPoint - Location );
	Start = Location + (PivotToTraceStart >> TargetRot);

	if( !FastTrace( TargetPoint, Start ) )
		return false;

	return true;
}


function RemoveDeadReferences()
{
	local int i, num;

	//Remove dead references
	num = DetectedPawns.Length;
	i = 0;
	while( i < DetectedPawns.Length )
	{
		if( DetectedPawns[i] == None || (DetectedPawns[i].Health <= 0) )
		{
			DetectedPawns.Remove(i,1);
			if( DetectedPawns.Length == 0 )
				break;
		}
		else
		{
			i++;
		}
	}
}


function GetTargetCommon()
{
	local int i, num;

	
	RemoveDeadReferences();

	num = DetectedPawns.Length;
	
	//log("GetTargetCommon - num detected after clean = " $ DetectedPawns.Length );
	
	for( i=0; i < num; i++ )
	{		
		if( DetectedPawns[i] != None && CanSeeTarget( DetectedPawns[i].Instigator ) )
		{
			//log( "new target found - element " $ i );
			Target = DetectedPawns[i];
			break;
		}
	}
}


function GetTarget()
{
	GetTargetCommon();
	
	if( NoTarget() )
	{
		//log("7");
		Target = None;
	}

	if( bFire )
	{
		bFire = false;
	}
}


simulated function SetDesiredRotation()
{
	local vector BarrelPos, TargetPoint;
	local Coords BarrelCoords;

	if( Target == none )
		DesiredRotation = Rot(0,0,0);
	else
	{
		BarrelCoords = GetBoneCoords( 'Barrel' );
		BarrelPos = BarrelCoords.Origin;

		TargetPoint = Target.Location;
		TargetPoint.Z += HitDistanceAboveHip;

		if( bShowDebug )
		{
			//drawdebugline( HeadPos, TargetPoint, 0, 0, 255 );
		}

		//DesiredRotation = Rotator(TargetPoint - BarrelPos) - DefaultRotation;
		DesiredRotation = Rotator(TargetPoint - BarrelPos);

		//log( "DefaultRot = " $ DefaultRotation );
		//log( "R_desired_calc= " $ DesiredRotation );
	}
}


simulated function UpdateHeadRotation( float dt )
{
	local Coords HeadCoords;
	local vector HeadPos;
	
	HeadCoords = GetBoneCoords( 'head' );
	HeadPos = HeadCoords.Origin;
	
	if( bShowDebug )
	{
		//drawdebugline( start, start + 1200*Vector( Dir ), 0, 255, 0 );
		//drawdebugline( HeadPos, HeadPos + 400*Vector(DesiredRotation), 0, 0, 255 );
		//drawdebugline( HeadPos, HeadPos + 400*Vector(DefaultRotation), 255, 0, 0 );
	}
	
	HeadRot.Yaw = CircularAddToDesired( HeadRot.Yaw, DesiredRotation.Yaw, HeadYawSpeed * dt );
	HeadRot.Pitch = CircularAddToDesired( HeadRot.Pitch, DesiredRotation.Pitch, HeadPitchSpeed * dt );
	SetBoneDirection( 'Head01', HeadRot, vect(0,0,0), 1.0, 1 );	
}


simulated function MoveParts( float dt )
{
	//
	//Head
	//
	UpdateHeadRotation( dt );
}


simulated function Tick( float dt )
{
	//If it is on move the parts
	if( !bIsOn )
		return;
		
	if(bDisabled) {
		EMPTimer += dt;
		if(EMPTimer >= EMPTime)
			bDisabled = false;

		return;
	}

	MoveParts( dt );

	Super.Tick( dt );
}


simulated function DoFireEffect( vector TraceStart, rotator TraceRotation )
{
    if ( Level.NetMode == NM_DedicatedServer )
        return;

	if( MuzFlash == None )
	{
		MuzFlash = Spawn( MuzFlashClass, self, , TraceStart, TraceRotation );
	}
	else
	{
		MuzFlash.SetLocation( TraceStart );
		MuzFlash.SetRotation( TraceRotation );
	}

	MuzFlash.Flash(0);
}


simulated function Fire()
{
	local vector start, end;
	local rotator TipRot, R;
	local Coords TipCoords;
	local Rotator RandDeltaRot;

	LastFireTime = Level.TimeSeconds;
	
	RandDeltaRot.Yaw = MaxSpreadAngle * (2.0*FRand() - 1.0);
	RandDeltaRot.Pitch = MaxSpreadAngle * (2.0*FRand() - 1.0);
	RandDeltaRot.Roll = MaxSpreadAngle * (2.0*FRand() - 1.0);

	TipCoords = GetBoneCoords( 'barrel' );

	if( bShowDebug )
	{
		//From barrel in direction of the desired rotation
		//drawdebugline( TipCoords.Origin,  TipCoords.Origin + 400*Vector(DesiredRotation), 0, 0, 255 );
	}

	TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );

	//Start does not start from top barrel, but from the very center
	R = TipRot;
	R.Roll = 0;
	start = TipCoords.Origin + (TraceOffset >> R);
	end = start + TraceDist * Vector(TipRot + RandDeltaRot);
 
	FireCommon( start, end );
	
	//if( BulletShells == none )
	//{
	//	//BulletShells = spawn( class'TurretBulletCasings' );
	//	//AttachToBone( BulletShells, 'FX2' );
	//	//BulletShells.Stop();
	//}
}


simulated function bool AreEqual( Rotator A, Rotator B )
{
	if( Vector(A) == Vector(B) )
		return true;
	return false;
}


function bool NoTarget()
{
	if( Target == None || Target.Instigator.bPlayedDeath || !CanSeeTarget( Target ) )
	{
		//if( Target == None )
		//	log("NoTarget returns true since: Target == None");
		//else
		//	log("NoTarget returns true since: !CanSeeTarget( Target )");
		return true;
	}

	return false;
}


simulated function Timer()
{
	if( !bIsOn || bDisabled )
		return;

	if( Role == ROLE_Authority )
	{
		if( NoTarget() )
		{
			//log( "Turret - Timer() - NoTarget" );
			GetTarget();
		}
	}
	
	//Set the desired rotation
	SetDesiredRotation();

	//It should be shooting as soon as it starts moving
	if( Target != none && AreEqual( HeadRot, DesiredRotation ) )
	{
		//log( "bFire!" );
		bFire = true;
	}
	else if( bFire )
	{
		//log( "bFire = FALSE" );
		bFire = false;
	}
}


simulated function EMPHit(bool bEnhanced)
{
	if(bEnhanced)
		EMPTime = 2;
	else
		EMPTime = 5;

	EMPTimer = 0;
	bDisabled = true;
}

simulated function Destroyed()
{
	//if( BulletShells != none )
	//{
	//	BulletShells.Destroy();
	//}
	Super.Destroyed();
}


event TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch( handler )
	{
	case hDestroy:
		Destroy();
		break;
	default: 
		Super.TriggerEx(sender, instigator, handler, realevent);
		break;
	}
}

defaultproperties
{
     HitDistanceAboveHip=30
     HeadYawSpeed=10000.000000
     HeadPitchSpeed=10000.000000
     hDestroy="Destroy"
     PivotToTraceStart=(X=184.000000,Z=151.000000)
     PersonDamage=8
     FireInvRate=0.100000
     HitEffectClass=Class'VehicleWeapons.VGTurretHitEffects'
     TraceOffset=(X=110.000000,Z=28.000000)
     DrawScale=1.000000
     TransientSoundVolume=1.000000
     Mesh=SkeletalMesh'PariahTurrets.Chap03Turret'
     DrawScale3D=(X=1.000000)
     DrawType=DT_Mesh
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bRotateToDesired=False
}
