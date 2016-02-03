class PlayerTurretDualCannonFire extends PlayerTurretDummyWeaponFire;

//var float RollSpeed;	// speed at which barrels are rotating
var rotator BarrelRotL;	// current amount of (left) barrel rotation
var rotator BarrelRotR;	// current amount of (right) barrel rotation

// emitters for left and right bullet shells
var Emitter BulletShellsL;
var Emitter BulletShellsR;

var Sound    SpinningSound;

function InitEffects()
{
    Super.InitEffects();
}

function DoFireEffect()
{
}

auto state Idle
{
	event ModeDoFire() {}
	function ModeTick(float dt) {}
	function BeginState()
	{
	}
	function StartFiring()
	{
        Turret = PlayerTurretDummyWeapon(Weapon).Turret;
		GotoState('SpinUp');
	}
}

simulated function FireCommon(vector start, vector end, vector TracerStart, optional bool bFireTracer)
{
	local Actor	Other;
	local vector HitLocation, HitNormal, trajectory;
	local rotator TraceRot;
	local Material HitMat;
 
	if( Weapon.Role < ROLE_Authority )
		return;

    Other = Trace(HitLocation, HitNormal, End, Start, true, , HitMat );

	if( Other != none && Other != self && Other != Turret)
	{
		trajectory = Normal(HitLocation - start);
        if ( !Other.bWorldGeometry )
        {
			if(Other.IsA('VGVehicle'))
				Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*trajectory, DamageType);
			else
				Other.TakeDamage(PersonDamage, Instigator, HitLocation, Momentum*trajectory, DamageType);
        }

		if( !Other.IsA('Pawn') && !Other.IsA('LevelInfo') )
			Spawn(class'VehicleEffects.C12GenSpark',,,Hitlocation-HitNormal*10,rotator(-HitNormal));
	}
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

	//Tracer
	// James - Only spawn tracer if you are hitting something greater than 3000 units away.
	if (VSize(HitLocation - TracerStart) > 3000.0)
	{
		TraceRot = rotator(HitLocation - TracerStart);
		Tracer(spawn(TracerClass,self,,TracerStart, TraceRot) );
	}

}

simulated function vector GetTurretTarget()
{
	local vector start, end;
	local rotator TipRot, R;
	local Coords TipCoords;

	local vector HitLocation, HitNormal;
	local Material HitMat;

	if(Turret == none)
		return vect(0,0,0);

	TipCoords = Turret.GetBoneCoords('SwingArm');
	TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );

	//Start does not start from top barrel, but from the very center
	R = TipRot;
	R.Roll = 0;
	start = TipCoords.Origin;// + (TraceOffset >> R);
	end = start + TraceDist * Vector(TipRot);

	Trace(HitLocation, HitNormal, End, Start, true, , HitMat );
	return HitLocation;
}

state Firing
{
	function BeginState()
	{
        NextFireTime = Level.TimeSeconds - 0.1; //fire now!
        Turret.SetAnimAction('Fire');

        Turret.StartFlash();

		// set up bullet shell emitters
		if(BulletShellsL == none)
			BulletShellsL = Spawn(class'TurretCasings', self);
		if(BulletShellsL != none) {
			Turret.AttachToBone(BulletShellsL, 'FX3');
			BulletShellsL.Start();
		}
		if(BulletShellsR == none)
			BulletShellsR = Spawn(class'TurretCasings', self);
		if(BulletShellsR != none) {
			Turret.AttachToBone(BulletShellsR, 'FX4');
			BulletShellsR.Start();
		}

        Weapon.AmbientSound = FiringSound;//PlayOwnedSound( FiringSound, SLOT_Misc, TransientSoundVolume, , 3000 );
	}
	function EndState()
	{
        Weapon.AmbientSound = None;//Weapon.StopOwnedSound( FiringSound);
    }
	simulated function ModeTick(float dt)
	{
		Super.ModeTick(dt);

		// rotate the barrel
		BarrelRotL.Roll += RollSpeed*dt;
		BarrelRotR.Roll -= RollSpeed*dt;
		Turret.SetBoneRotation('LftBarrel', BarrelRotL, 0, 1.0);
		Turret.SetBoneRotation('RtBarrel', BarrelRotR, 0, 1.0);
		Turret.SetBoneRotation('AmmoBinLft', BarrelRotR, 0, 1.0);
		Turret.SetBoneRotation('AmmoBinRt', BarrelRotL, 0, 1.0);
	}
	event ModeDoFire()
	{
		local vector start, end, tracerStart;
		local rotator TipRot, R;
		local Coords TipCoords;
		local Rotator RandDeltaRot;

		if(Turret == none)
			return;

		LastFireTime = Level.TimeSeconds;

		CurrentBarrel++;
		if(CurrentBarrel >= 2)
			CurrentBarrel = 0; 
	
		if(Weapon.Role == ROLE_Authority)
        {
			RandDeltaRot.Yaw = MaxSpreadAngle * (2.0*FRand() - 1.0);
			RandDeltaRot.Pitch = MaxSpreadAngle * (2.0*FRand() - 1.0);
			RandDeltaRot.Roll = MaxSpreadAngle * (2.0*FRand() - 1.0);

			if(CurrentBarrel == 1)
				TipCoords = Turret.GetBoneCoords('FX1');
			else
				TipCoords = Turret.GetBoneCoords('FX2');

			TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );


			// James - adjusted above code so that traces occur from actual barrel tips.  
			// This is more accurate for hitting closer objects.

			R = TipRot;
			R.Roll = 0;
			start = TipCoords.Origin+vector(tipRot)*300;
			end = start + TraceDist*(vector(tipRot)+VRand()*FRand()*Spread);

			tracerStart = TipCoords.Origin+(vect(1600, 0, 0)>>TipRot); 

			FireCommon(start, end, tracerStart, true);
		}

		NextFireTime += FireRate*Weapon.FireRateAtten;
        NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
        if(bUseForceFeedback)
	        ClientPlayForceFeedback(FireForce); 
	}

	function StopFiring()
	{
		// stop the bullet shells
		if(BulletShellsL != none) {
			BulletShellsL.Kill();
			BulletShellsL = none;
		}
		if(BulletShellsR != none) {
			BulletShellsR.Kill();
			BulletShellsR = none;
		}

        Turret.StopFlash();

		GotoState('SpinDown');
	}
}

state SpinUp
{
	event ModeDoFire() {}
	simulated function ModeTick(float dt)
	{
		RollSpeed = FClamp(RollSpeed+dt*BarrelWindUpAcc, 0, MaxRollSpeed);
		if(RollSpeed == MaxRollSpeed)
			GotoState('Firing');
		BarrelRotL.Roll += RollSpeed*dt;
		BarrelRotR.Roll -= RollSpeed*dt;
		Turret.SetBoneRotation('LftBarrel', BarrelRotL, 0, 1.0);
		Turret.SetBoneRotation('RtBarrel', BarrelRotR, 0, 1.0);
		Turret.SetBoneRotation('AmmoBinLft', BarrelRotR, 0, 1.0);
		Turret.SetBoneRotation('AmmoBinRt', BarrelRotL, 0, 1.0);
	}

	function StopFiring()
	{
		GotoState('SpinDown');
	}

Begin:    
	Sleep(0.5);
	CurrentBarrel = -1;
}

state SpinDown
{
	event ModeDoFire() {}
	simulated function ModeTick(float dt)
	{
		RollSpeed = FClamp(RollSpeed-dt*BarrelWindDownAcc, 0, MaxRollSpeed);
		BarrelRotL.Roll += RollSpeed*dt;
		BarrelRotR.Roll -= RollSpeed*dt;
		if(RollSpeed == 0)
			GotoState('Idle');
		Turret.SetBoneRotation('LftBarrel', BarrelRotL, 0, 1.0);
		Turret.SetBoneRotation('RtBarrel', BarrelRotR, 0, 1.0);
		Turret.SetBoneRotation('AmmoBinLft', BarrelRotR, 0, 1.0);
		Turret.SetBoneRotation('AmmoBinRt', BarrelRotL, 0, 1.0);
	}

	function StartFiring()
	{
        Turret = PlayerTurretDummyWeapon(Weapon).Turret;		
		GotoState('SpinUp');
	}

Begin:
    Turret.SetAnimAction('FireEnd');
	Sleep(0.5);
//	GotoState('Idle');
}

defaultproperties
{
     SpinningSound=Sound'PlayerTurretSounds.Spinning.TrainTurretSpin'
     FiringSound=Sound'PlayerTurretSounds.Firing.TrainTurretFireA'
     Momentum=3000.000000
     TracerClass=Class'VehicleEffects.TracerTurretMesh'
     VehicleDamage=65
     PersonDamage=35
     spring_mass=0.600000
     spring_stiffness=40.000000
     spring_damping=7.500000
     spring_force_applied=1900.000000
     UseSpringImpulse=True
     FireEndAnim="'"
}
