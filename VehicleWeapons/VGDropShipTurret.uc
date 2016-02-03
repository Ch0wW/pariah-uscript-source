/*
	VGDropShipTurret
	Desc: Shoots the player
			- Attack mode switch option: You can make it depend on player speed or not using
			  the bAttackModesDependOnPlayerMovement bool
			- Attack modes:
				- Laser sweep: when the player dashes it switches to that mode.
				- Dual projectiles 
	xmatt
*/

class VGDropShipTurret extends Turret;

var()	int				Health;
var		class<Emitter>	ExplosionClass;
var()	float			Range;
var		SpeedMovingAverage PlayerGroundCoveredAverage;
var		rotator			TipRoll;
var		DropShipArea	CoveredArea;

//Attack modes
var enum EAttackMode
{
	A_Sweeping,
	A_DualFire,
	A_DeadOn
} AttackMode;

var() bool	bAttackModesDependOnPlayerMovement;
var	  float TargetOnSightTimer;
var() float DeadOnAttackTime;
var() float SweepingAttackTime;
var() float DualFireTime;

//A_Sweeping attack mode
var(SweepingAttack) rotator SavedHeadRot;
var(SweepingAttack) float	RotToDesiredAlpha;
var(SweepingAttack) float	RotToDesiredTimer;
var(SweepingAttack) float	SweepingAttackFocusingSpeed;
var(SweepingAttack) float	OvershootDistanceStart;
var(SweepingAttack) float	SweepingAttackHeadMoveSpeed;
var(SweepingAttack) float	SweepingAttackVerticalRange; //the target point is location + [-SweepingAttackVerticalRange/2,SweepingAttackVerticalRange/2]
var				vector	PointAtPerpendicular;
var				vector	NewLookAtPoint;
var				float	SweepingAttackTimer;

//A_DualFire attack mode
var(DualFireMode) float	DualFirePrecision;
var(DualFireMode) float	DualFireFireRate;
var(DualFireMode) float	DualFireChangeAimTime;
var(DualFireMode) float	DualFireLeadRatio;
var(DualFireMode) int		DualFireTipRotationSpeed;
var						float	DualFireChangeAimTimer;
var						float	DualFireTimer;


//A_DeadOn attack mode
var() float DeadOnAttackFireRate;
var() float VerySlowPlayerAverageSpeed;

var()	float	RadiusOfError;

//Sounds
var ()	sound			DualFireSound;
//var ()	sound			SweepingFireSound;
var()	Sound			DestroySound;

simulated function PostBeginPlay()
{
	if( bAttackModesDependOnPlayerMovement )
		PlayerGroundCoveredAverage = new(Level)class'SpeedMovingAverage';
	Super.PostBeginPlay();
}


function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, 
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
{
	Health -= Damage;

	if( Health < 0 )
	{
		spawn( ExplosionClass, , , Location );
		if( DestroySound != None )
			PlaySound( DestroySound );
		Destroy();
	}

	Super.TakeDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage );
}


simulated function SwitchTo_DualFire()
{
	//log("Attack mode is now A_DualFire");
	AttackMode = A_DualFire;
	bContinuousFire = false;
	FireInvRate = 1.0/DualFireFireRate;
	DualFireTimer = 0;
	DualFireChangeAimTimer = 0;
	
	//It must turn real fast in that attack mode because it must shoot about the player
	HeadYawSpeed=50000;
	HeadPitchSpeed=50000;	
}


simulated function SwitchTo_DeadOn()
{
	//log("Attack mode is now A_DeadOn");
	AttackMode = A_DeadOn;
	bContinuousFire = false;
	FireInvRate = 1.0/DeadOnAttackFireRate;
	
	HeadYawSpeed=3000;
	HeadPitchSpeed=3000;

	//In DualFire mode, the barrel rolls so reset that
	TipRoll.Roll = 0;
	SetBoneRotation( 'Roll', TipRoll, 0, 1.0 );	
}


simulated function SwitchTo_Sweeping()
{
	//log("Attack mode is now A_Sweeping");
	AttackMode = A_Sweeping;
	bContinuousFire = true;
	SweepingAttackTimer = 0;
	
	HeadYawSpeed=5000;
	HeadPitchSpeed=5000;
	
	//In DualFire mode, the barrel rolls so reset that
	TipRoll.Roll = 0;
	SetBoneRotation( 'Roll', TipRoll, 0, 1.0 );	
}


simulated function DecideOnAttackMode()
{
	local float PlayerAverageSpeed;
	
		//log("TargetOnSightTimer=" $ TargetOnSightTimer);
		PlayerGroundCoveredAverage.Add( Target.Location, TargetOnSightTimer );
		PlayerAverageSpeed = PlayerGroundCoveredAverage.GetAverage();
		//log("PlayerAverageSpeed="$PlayerAverageSpeed);
		
		//If the player dashes it goes to the sweeping attack mode
		if( VGPawn(Target).DashState == DSX_Dashing )
		{
			if( AttackMode != A_Sweeping )
				SwitchTo_Sweeping();
		}
		//If the player moves slowly make a deadly attack
		else if( PlayerAverageSpeed <= VerySlowPlayerAverageSpeed )
		{
			if( AttackMode != A_DeadOn )
				SwitchTo_DeadOn();
		}
		//If he is not moving slowly, shoot about him with slower projectiles
		else
		{
			if( AttackMode != A_DualFire )
				SwitchTo_DualFire();
		}
}


simulated function SetTarget( VGPawn P )
{
	CoveredArea.Targetted = P;
	Target = P;
}


simulated function SetActive( bool on )
{
	bIsOn = on;
	if( !bIsOn )
	{
		if( AttackMode == A_Sweeping )
		{
			log("Calling stop firing sound");
			StopFiringSound();
		}
	}
}


simulated function ResetOrientation()
{
}


simulated function Timer()
{
	if( !bIsOn )
		return;
	
	if( Role == ROLE_Authority )
	{
		//If the dropshiparea has no targetted pawn, it came out so
		//you have to get a new one
		if( NoTarget() || CoveredArea.Targetted == None )
		{
			//log( "NO TARGET" );
			
			//Set to the preferred starting attack mode
			if( bAttackModesDependOnPlayerMovement )
			{
				PlayerGroundCoveredAverage.Clear();	
				SwitchTo_DeadOn();
			}
			
			//Reset the time that the target has been seen
			TargetOnSightTimer = 0;

			//See if you can get another target
			GetTarget();
			
			//Disable the turret if no target have been found
			if( Target == None )
				bDisabled = true;
			else
				bDisabled = false;
		}
	}

	//Decide on attack mode
	if( bAttackModesDependOnPlayerMovement && PlayerGroundCoveredAverage != None )
		DecideOnAttackMode();
}


simulated function GetTarget()
{
	local int i, num;
	local bool bFoundNewOne;

	CoveredArea.RemoveDeadReferences();
	num = CoveredArea.Detected.Length;
	
	//If the player is in the monitored area pick him first
	if( CoveredArea.IsPlayerIn() )
	{
		if( CanSeeTarget( CoveredArea.Detected[i].Instigator ) )
		{
			SetTarget( VGPawn(CoveredArea.Detected[i].Instigator) );
			bFoundNewOne = true;
		}
	}
	
	//If the player wasn't targetted look for another pawn
	if( !bFoundNewOne )
	{
		for( i=0; i < num; i++ )
		{
			if( CanSeeTarget( CoveredArea.Detected[i].Instigator ) /*&& InRange( CoveredArea.Detected[i].Instigator )*/ )
			{
				//log( "new target found - element " $ i );
				SetTarget( CoveredArea.Detected[i] );
				bFoundNewOne = true;
				break;
			}
		}
	}
	
	if( !bFoundNewOne )
		SetTarget( none );
	
	if( bFire )
		bFire = false;
}


simulated function PickDesiredRotation_SweepingAttack()
{
	local float		t; //parameter in in the equation of a line
	local vector	d; //unit lookat vector
	local vector	f; //unit vector pointing towards target and perpendicular to lookat vector
	local coords	TipCoords;
	local rotator	TipRot;
	local vector	SweepingAttackTargetPoint;
	local float		OvershootFactor;
	local float		OvershootDistance;
	

	/*
		For a line l(t) = p + t*d,
		the closest distance to a point in space x is at t = -(p-x) dot d
		The line from x to l that has this distance is perpendicular to l,
		Let the point of intersection be l(t0) = p + t0*d
		f = ||x - l(t0)|| is then a unit vector from l(t0) pointing towards x,
		
		For this attack mode, I let p be the tip of the turret, x be the target, 
		l(t) be the look at line of the turret.
		
		I pick the desired rotation to be in the direction of the line
		passing through p and x + overshoot*w. This ensures that the turret
		always shoots through the target and in a very controllable way.
		
		Need to add:
		1) Move to position where the pitch of the turret is equal to that of the player
		
		
	*/
		TipCoords = GetBoneCoords( 'Point01' );
		TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );
		// have rotation of turret
		d = Normal(vector(TipRot));
		// d = direction it's pointing (unit vector)
				
		SweepingAttackTargetPoint = target.location;
		SweepingAttackTargetPoint.Z += SweepingAttackVerticalRange*(Frand()-0.5);
		//log("z offset = " $ SweepingAttackVerticalRange*(Frand()-0.5) );
		t = -( TipCoords.Origin - SweepingAttackTargetPoint ) dot d;		// 'location' is canon's location.
		PointAtPerpendicular = TipCoords.Origin + t*d; 
		f = Normal( SweepingAttackTargetPoint - PointAtPerpendicular );		//

		//OvershootFactor = FClamp( 1.0 - SweepingAttackFocusingSpeed * SweepingAttackTimer / SweepingAttackTime, 0.0, 1.0 );
		OvershootDistance = OvershootFactor * OvershootDistanceStart;
		NewLookAtPoint = SweepingAttackTargetPoint + OvershootDistance*f;
		
		DesiredRotation = Rotator(NewLookAtPoint - TipCoords.Origin);
		
		//Save the head rotation
		//HeadCoords = GetBoneCoords( 'Pitch' );	
		// HeadCoords = GetBoneCoords( 'Yaw' );	
		//SavedHeadRot = OrthoRotation( HeadCoords.XAxis, HeadCoords.YAxis, HeadCoords.ZAxis );
		
		//log("pick DesiredRotation = " $ DesiredRotation );
		//log("pick SavedHeadRot = " $ SavedHeadRot );
		
		RotToDesiredAlpha = 0.0;
		RotToDesiredTimer = 0.0;
}


simulated function PickDesiredRotation_DualFire()
{
	local Coords	BarrelCoords;
	local vector	NewLookAt;
	
	//Find the line through the turret tip and the target
	BarrelCoords = GetBoneCoords( 'Roll' );
		
	//Lead the aim
	NewLookAt = target.Location + DualFireLeadRatio * Target.Velocity;
	//NewLookAt += DualFirePrecision * VRand();
	DesiredRotation = rotator(NewLookAt - BarrelCoords.Origin);
}


simulated function SetDesiredRotation()
{
	local vector BarrelPos, TargetPoint;
	local Coords BarrelCoords;

	//log("SetDesiredRotation, AttackMode: " $ AttackMode);

	if( AttackMode == A_Sweeping )
	{
		//When you get to the desired rotation pick new rotation
		//such that the turret shoots through the player if he didn't
		//move
		if( RotToDesiredAlpha == 1.0 )
		{
			//log( "Picking another one... (2)" );
			SavedHeadRot = HeadRot;
			//log("HeadRot = " $HeadRot );
			PickDesiredRotation_SweepingAttack();
			
		}
	}
	else if( AttackMode == A_DualFire )
	{
		PickDesiredRotation_DualFire();
		
		//if( DualFireChangeAimTimer > DualFireChangeAimTime )
		//{
		//	DualFireChangeAimTimer = 0;
		//	PickDesiredRotation_DualFire();
		//}
	}
	else if( AttackMode == A_DeadOn )
	{
		BarrelCoords = GetBoneCoords( 'Roll' );
		BarrelPos = BarrelCoords.Origin;

		TargetPoint = Target.Location;
		TargetPoint.Z += HitDistanceAboveHip;

		DesiredRotation = Rotator(TargetPoint - BarrelPos);
	}
}


simulated function bool InRange( Actor A )
{
	local coords TipCoords;
	TipCoords = GetBoneCoords( 'Point01' );
	return (VSize( TipCoords.Origin - A.Location ) <= Range );
}


simulated function bool NoTarget()
{
	if( Target == None || Target.Instigator.bPlayedDeath )
		return true;
	return false;
}


simulated function Tick( float dt )
{
	local coords	TipCoords;
	local rotator	TipRot;
	
	if( !bIsOn || bDisabled )
		return;
	
	//If the player on sight
	if( Target != None )
	{
		TargetOnSightTimer += dt;
		if( AttackMode == A_Sweeping )
		{
			SweepingAttackTimer += dt;
		}
		else if( AttackMode == A_DualFire )
		{
			DualFireTimer += dt;
			DualFireChangeAimTimer += dt;
			
			TipRoll.Roll += float(DualFireTipRotationSpeed) * dt;
			SetBoneRotation( 'Roll', TipRoll, 0, 1.0 );
		
			// Visual debug: To see projectile starts
			//
			TipCoords = GetBoneCoords( 'Roll' );
			TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );
			//drawdebugline( TipCoords.Origin + (25*TipCoords.YAxis), Target.Location, 255, 255, 0 );
			//drawdebugline( TipCoords.Origin - (25*TipCoords.YAxis), Target.Location, 255, 255, 0 );
			//drawdebugline( Location, target.Location, 255, 255, 255 );
		}
		
		if( bShowDebug )
			DrawFiringLines();
	}
	
	//Set the desired rotation
	SetDesiredRotation();
	
	if( Target == none )
	{
		if( bFire == true )
		{
			//log("bFire = false");
			bFire = false;
		}
	}
	else
	{
		if( bFire == false )
		{
			//log("bFire = true");
			bFire = true;
		}
	}
	
	//
	// Visual debug
	//

	if( AttackMode == A_Sweeping )
	{
		TipCoords = GetBoneCoords( 'Point01' );
	//	drawdebugline( TipCoords.Origin, PointAtPerpendicular, 0, 0, 255 );			//blue  (current direction)
	//	drawdebugline( PointAtPerpendicular, NewLookAtPoint, 255, 0, 0 );	//red	(path between the two)
	//	drawdebugline( TipCoords.Origin, NewLookAtPoint, 0, 255, 0 );				//green	(trying to get to)
	}
	else if( AttackMode == A_DualFire )
	{
		//drawdebugline( Target.Location, Target.Location+DualFireLeadRatio*Target.Velocity, 255, 255, 0 );
		//drawdebugline( Location, Location + 3500 * vector(DesiredRotation), 255, 255, 0 );
	}

	Super.Tick( dt );
}


simulated function DrawFiringLines()
{
	local coords	TipCoords;
	local rotator	TipRot;
	
	if( AttackMode == A_Sweeping )
	{
		TipCoords = GetBoneCoords( 'Point01' );
		TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );
		drawdebugline( TipCoords.origin, TipCoords.origin + 3000 * vector(TipRot), 255, 255, 255 );
	}
	else if( AttackMode == A_DualFire )
	{
		TipCoords = GetBoneCoords( 'Point02' );
		TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );
		drawdebugline( TipCoords.origin, TipCoords.origin + 500 * vector(TipRot), 255, 255, 0 );
		TipCoords = GetBoneCoords( 'Point03' );
		TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );
		drawdebugline( TipCoords.origin, TipCoords.origin + 500 * vector(TipRot), 255, 255, 0 );
	}
}


simulated function UpdateHeadRotation( float dt )
{
	local Coords HeadCoords;
	local vector HeadPos;
	local int LineShootingUSpeed;
	local float RotToDesiredTime;
	local rotator Delta;
	local rotator YawRot;
	local rotator PitchRot;
	
	HeadCoords = GetBoneCoords( 'Yaw' );
	HeadPos = HeadCoords.Origin;
	
	if( AttackMode == A_Sweeping )
	{
		LineShootingUSpeed = SweepingAttackHeadMoveSpeed * 65536.0f / 360.0f;
		
		//Find out the time to rotate to the desired rotation
		Delta = DesiredRotation - SavedHeadRot;
		//log( "Delta = " $ Delta );
		RotToDesiredTime = (1.0/LineShootingUSpeed) * Sqrt(Delta.Yaw*Delta.Yaw + Delta.Pitch*Delta.Pitch );
		
		if( RotToDesiredTime < 0 )
			RotToDesiredTime = -RotToDesiredTime;
		
		RotToDesiredTimer += dt;
		//log( "RotToDesiredTime = " $ RotToDesiredTime );
		RotToDesiredAlpha = lerp( RotToDesiredTimer / RotToDesiredTime, 0.0, 1.0, true );
		
		//log( " RotToDesiredAlpha= " $ RotToDesiredAlpha );
		HeadRot.Yaw = CircularInterpToDesired( SavedHeadRot.Yaw, DesiredRotation.Yaw, RotToDesiredAlpha );
		HeadRot.Pitch = CircularInterpToDesired( SavedHeadRot.Pitch, DesiredRotation.Pitch, RotToDesiredAlpha );
		
		//Set the bones
		YawRot.Yaw = HeadRot.Yaw;
		PitchRot.Yaw = YawRot.Yaw;
		PitchRot.Pitch = HeadRot.Pitch;
		SetBoneDirection( 'Yaw', YawRot, vect(0,0,0), 1.0, 1 );
		SetBoneDirection( 'Pitch', PitchRot, vect(0,0,0), 1.0, 1 );			
	}
	else if( AttackMode == A_DualFire || AttackMode == A_DeadOn )
	{
		HeadRot = DesiredRotation;
		HeadRot.Roll = 0;
		//SetBoneDirection( 'Pitch', HeadRot, vect(0,0,0), 1.0, 1 );
		
		//Set the bones
		YawRot.Yaw = DesiredRotation.Yaw;
		PitchRot.Yaw = YawRot.Yaw;
		PitchRot.Pitch = DesiredRotation.Pitch;
		SetBoneDirection( 'Yaw', YawRot, vect(0,0,0), 1.0, 1 );
		SetBoneDirection( 'Pitch', PitchRot, vect(0,0,0), 1.0, 1 );
		
		//SetBoneRotation( 'Yaw', YawRot, 1.0, 1 );
		//SetBoneRotation( 'Pitch', PitchRot, 1.0, 1 );
	}
}


simulated function DualFireFire()
{
	local Coords TipCoords;
	local Rotator TipRot;
	local VGProjectile P;
	
	if( Role != ROLE_Authority )
		return;
		
	LastFireTime = Level.TimeSeconds;
	
	TipCoords = GetBoneCoords( 'Point02' );
	TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );
	
	P = Spawn( class'DropShipTurretEnergyShot', Self, , TipCoords.Origin, TipRot );
	
	TipCoords = GetBoneCoords( 'Point03' );
	TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );
	P = Spawn( class'DropShipTurretEnergyShot', Self, , TipCoords.Origin, TipRot );
	
	//PlayOwnedSound( DualFireSound, SLOT_Interact,TransientSoundVolume,,,,false);
}


simulated function Fire()
{
	local vector start, end;
	local rotator TipRot, R;
	local Coords TipCoords;

	if( AttackMode == A_DualFire )
	{ 
		DualFireFire();
	}
	else
	{
		// Don't fire if the target is out of range
		if( !InRange(Target) )
		{
			log( "not in range");
			return;
		}

		LastFireTime = Level.TimeSeconds;

		TipCoords = GetBoneCoords( 'Point01' );

		//
		// Visual debug: From barrel in direction of the desired rotation
		//
		//drawdebugline( TipCoords.Origin,  TipCoords.Origin + 400*Vector(DesiredRotation), 0, 0, 255 );

		TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );

		//Start does not start from top barrel, but from the very center
		R = TipRot;
		R.Roll = 0;
		start = TipCoords.Origin;
		end = start + Range * Vector(TipRot);
	 
		FireCommon( start, end );
	}
}

defaultproperties
{
     Health=2000
     DualFireTipRotationSpeed=50000
     Range=4500.000000
     DeadOnAttackTime=3.000000
     SweepingAttackTime=2.000000
     DualFireTime=8.000000
     SweepingAttackFocusingSpeed=0.600000
     OvershootDistanceStart=1000.000000
     SweepingAttackHeadMoveSpeed=100.000000
     SweepingAttackVerticalRange=100.000000
     DualFirePrecision=40.000000
     DualFireFireRate=1.300000
     DualFireChangeAimTime=1.000000
     DualFireLeadRatio=0.500000
     DeadOnAttackFireRate=2.000000
     DualFireSound=Sound'PariahDropShipSounds.Millitary.DropshipTurretFireA'
     DestroySound=Sound'SM-chapter03sounds.ExplosionWithMetal'
     ExplosionClass=Class'VehicleEffects.ParticleGrenadeExplosion'
     AttackMode=A_DeadOn
     HeadYawSpeed=4000.000000
     HeadPitchSpeed=4000.000000
     PersonDamage=2
     FireInvRate=0.050000
     FiringSound=Sound'PariahDropShipSounds.Millitary.DropshipLaserLoopA'
     TracerClass=Class'VehicleEffects.SniperTrail'
     Mesh=SkeletalMesh'PariahTurrets.DropShipTurret'
}
