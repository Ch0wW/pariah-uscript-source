class TitansFistFire extends VGInstantFire;

//Sounds
var()	Sound PreChargingSound;
var()	Sound ChargingSound;
var()	Sound IsReadySound;
var()   Sound IdleSound;    // mjm
var()	float PreChargingSoundTime;
var		float PreChargingSoundTimer;
var		bool  bPlayingCharging;
var		bool  bPlayedReadySound;

var()	Vector ProjSpawnOffset; // +x forward, +y right, +z up
var	bool	bShockwave;
var		float	FlashingTime; //Weapon dynamic light flash time 

//Warp params
var		transient WarpPostFXStage Warp;
var		float ChargeTime;
var()	float FullChargeTime;
var		float WarpTimer;
var()	float AborbingRippleMaxAmplitude;
var()	float EmittingTime;
var()	float CompressedWavesScreenScale;
var		bool  bRestarted;
var		bool  bWarpOn;
var()	float EffectScreenX;
var()	float EffectScreenY;
var()	float Wave1FalloffMark, Wave2FalloffMark, Wave3FalloffMark;
var()	float mWave1Speed, mWave2Speed, mWave3Speed;
var()	int	  AbsorptionRippleness;
var()	int	  AbsorptionSpeed;
var()	float AbsorptionScreenScale;

//Explosion params
var()	int ExplosionDamageMin;
var()	int ExplosionDamageMax;
var()	int ExplosionStrengthMin;
var()	int ExplosionStrengthMax;
var()	int ExplosionRadiusMin;
var()	int ExplosionRadiusMax;

var()	int NextExplosionRadiusIncrement;

//Effects
var()	class<Emitter> BigExplosionClass;
var()	class<xEmitter> BeamEffectClass;
var()	class<Emitter> ChargeEffectClass;
var		Emitter SmallExplosion;
var		TitansFist_Charging ChargeFX;
var		float SmallExplosionTimer;
var()	float SmallExplosionTime;

// Health Drain
var()   int AmmoDrainMin;
var()   int AmmoDrainMax;
var     float AmmoDrainAccum;
var     int AmmoDrainTotal;
var class<DamageType> HealthDrainDamageType;

var enum EWarpStage
{
	WS_AbsorbingEnergy,
	WS_EmittingEnergy
} WarpStage;

simulated function PostBeginPlay()
{
	//The flashing time must consider the firing rate    
    PlayAmbientSound(IdleSound);   // mjm - I'm sorry!
	FlashingTime = 0.8 * FireRate;
	Super.PostBeginPlay();
}

function bool DrainsHealth()
{
    return (AmmoDrainMax > 0);
}

function WECLevelUp(int Level)
{
	// each WEC level just increases the splash damage radius
	ExplosionRadiusMin += NextExplosionRadiusIncrement;
	ExplosionRadiusMax += NextExplosionRadiusIncrement;
	NextExplosionRadiusIncrement -= 5;
	if(NextExplosionRadiusIncrement < 1)
		NextExplosionRadiusIncrement = 1;
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
	local xEmitter Beam;
	local vector X, Y, Z;
	local float CurPower;

	GetAxes( Dir, X, Y, Z );
	Start = Weapon.GetFireStart( X, Y, Z );
	Start = Start+X*ProjSpawnOffset.X+Y*ProjSpawnOffset.Y+Z*ProjSpawnOffset.Z;
	if (BeamEffectClass!=None )
		Beam = Spawn( BeamEffectClass,,, Start, Dir);
	
	if(Beam != none)
	{
		Beam.mSpawnVecA = HitLocation;
	}

    if (ReflectNum != 0)
		Beam.Instigator = None; // prevents client side repositioning of beam start

	CurPower = GetPowerLevel();

	Spawn( BigExplosionClass,,, HitLocation, Dir);

	if (CurPower>0.9) 
	{
		Spawn(class'TitansFist_Pulse',,, HitLocation+HitNormal*150.0, Dir);
		Spawn(class'TitanFist_Rings',,, HitLocation+HitNormal*150.0, Dir);
	}

	ProjectActorsWithinRadiusAway( HitLocation, CurPower);
}

function float GetPowerLevel()
{
    //return FClamp( ChargeTime / FullChargeTime, 0, 1 );
    return FClamp( float(AmmoDrainTotal) / float(AmmoDrainMax), 0, 1);
}

simulated function ModeDoFire()
{
}

simulated function bool AllowFire()
{
    if(AmmoClip(Weapon.Ammo[0]).RemainingMagAmmo <= 0 && !IsInState('Charge'))
    {
        return false;
    }
    return Super.AllowFire();
}

event ModeHoldFire()
{
	Super.ModeHoldFire();
    GotoState('Charge');
}

simulated function ModeTick(float dt)
{
	local float trueDelta;
	local float MuzzleLightIntensity;
	local float Wave1AmplitudeRatio, Wave2AmplitudeRatio, Wave3AmplitudeRatio;

	trueDelta = Level.TimeSeconds - LastHeatTime;
	LastHeatTime = Level.TimeSeconds;

	if( SmallExplosion != None )
	{
		SmallExplosionTimer += dt;
		if( SmallExplosionTimer >= SmallExplosionTime )
		{
			SmallExplosionTimer = 0;
			SmallExplosion.Destroy();
		}
	}

	//If the light has been turned on
	if( PersonalWeapon(Weapon).bTurnedOnDynLight )
	{
		//If it has been on for FLASHING_TIME, turn it off
		if( PersonalWeapon(Weapon).LightIntensityTimer > FlashingTime )
		{
			PersonalWeapon(Weapon).bTurnedOnDynLight = false;
			PersonalWeapon(Weapon).LightIntensityTimer = 0;
			PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = 0;
		}
		else
		{
			PersonalWeapon(Weapon).LightIntensityTimer += dt;
			MuzzleLightIntensity = 800 * SeeSaw( 2.0 / FlashingTime, PersonalWeapon(Weapon).LightIntensityTimer );
			PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = MuzzleLightIntensity;
			PlayerController(Instigator.Controller).MuzzleFlashLight.LightSaturation = 255;
		}
	}

	//Remove Warp and Save memory! (jds) ... why not on PC :) (ms)
	if( !IsOnConsole() && WarpStage == WS_EmittingEnergy )
	{
		WarpTimer += dt;
		//Fall off the amplitude after a specified time
		if( WarpTimer < EmittingTime )
		{
			Wave1AmplitudeRatio = 1.0;
			Wave2AmplitudeRatio = 1.0;
			Wave3AmplitudeRatio = 1.0;

			if( WarpTimer >= Wave1FalloffMark * EmittingTime )
				Wave1AmplitudeRatio = 1.0 - (WarpTimer - Wave1FalloffMark*EmittingTime)/((1.0-Wave1FalloffMark)*EmittingTime);
				
			if( WarpTimer >= Wave2FalloffMark * EmittingTime )
				Wave2AmplitudeRatio = 1.0 - (WarpTimer - Wave2FalloffMark*EmittingTime)/((1.0-Wave2FalloffMark)*EmittingTime);

			if( WarpTimer >= Wave3FalloffMark * EmittingTime )
				Wave3AmplitudeRatio = 1.0 - (WarpTimer - Wave3FalloffMark*EmittingTime)/((1.0-Wave3FalloffMark)*EmittingTime);

			if(Warp != None)
			{
			Warp.Wave1Amplitude = Wave1AmplitudeRatio * 0.06;
			Warp.Wave2Amplitude = Wave2AmplitudeRatio * 0.06;
			Warp.Wave3Amplitude = Wave3AmplitudeRatio * 0.06;
			}
		}
		else
		{
			//Need to run through another frame so that the shader uc objects get their bRestart applied
			if( bRestarted )
			{
				WarpTimer=0;
				PlayerController(Instigator.Controller).RemovePostFXStage( Warp );
				WarpStage = WS_AbsorbingEnergy;
				bRestarted = false;
				bWarpOn = false;
			}
			else
			{
				if(Warp != None)
				{
					Warp.bRestart = true;
				}
				bRestarted = true;
			}
		}
	}
}

// weapon charging state
state Charge
{
	simulated function BeginState()
	{
		//Remove Warp and Save memory! (jds) ... why not on PC :) (ms)
		if ( !IsOnConsole() )
		{
			if ( Instigator.Controller.IsA('VehiclePlayer'))
			{
				Warp = WarpPostFXStage( VehiclePlayer(Instigator.Controller).GetTitanPostFX(class'WarpPostFXStage') );
			}
			
			if(Warp != None)
			{
				Warp.ScreenPosX = EffectScreenX;
				Warp.ScreenPosY = EffectScreenY;
				Warp.RippleAmplitude = AborbingRippleMaxAmplitude;
				Warp.Rippleness = AbsorptionRippleness;
				Warp.RippleSpeed = AbsorptionSpeed; 
				Warp.WarpType = 1;
				Warp.RippleType = 4;
				Warp.bRestart = true;
				Warp.RippleScreenScale = AbsorptionScreenScale;
			}
			
			if( Instigator.Controller.IsA('PlayerController') )
			{
				PlayerController(Instigator.Controller).AddPostFXStage( Warp );
				bWarpOn = true;
			}
		}
		
		PreChargingSoundTimer=0;
        PlayAmbientSound(None);
		
		Weapon.PlayOwnedSound( PreChargingSound, SLOT_Interact,TransientSoundVolume, false,,, false );
		
		Weapon.LoopAnim(FireLoopAnim, FireLoopAnimRate, TweenTime);
		
		if( ChargeFX == None )
		{
			ChargeFX = TitansFist_Charging(Spawn( ChargeEffectClass,,, vect(0,0,0), rot(0,0,0) ));
			Weapon.AttachToBone( ChargeFX, 'FX1' );
		}
		ChargeFX.Run();

        if(DrainsHealth())
        {
            AmmoDrainAccum = -AmmoDrainMin;
            AmmoDrainTotal = AmmoDrainMin;

        	//Instigator.TakeDamage(AmmoDrainMin, Instigator, Vect(0,0,0), Vect(0,0,0), HealthDrainDamageType,, true);
            Weapon.Ammo[0].UseAmmo(AmmoDrainMin);
        }
	}
 
	simulated function EndState()
	{
		//Remove Warp and Save memory! (jds) ... why not on PC :) (ms)
		if ( !IsOnConsole() )
		{
			if(Warp != None)
			{
				Warp.SpherizeAmplitude = 0;
				Warp.bRestart = true;
				Warp.WarpType = 2;
				Warp.CompressionType = 2;
				Warp.CompressedWavesScreenScale = CompressedWavesScreenScale;
				Warp.Wave1Amplitude = 0.06;
				Warp.Wave2Amplitude = 0.06;
				Warp.Wave3Amplitude = 0.06;
				Warp.Wave1Speed = mWave1Speed;
				Warp.Wave2Speed = mWave2Speed;
				Warp.Wave3Speed = mWave3Speed;
			}
			WarpTimer = 0;
			WarpStage = WS_EmittingEnergy;
		}

		ChargeTime = 0;
		//		Weapon.LoopAnim(Weapon.IdleAnim, Weapon.IdleAnimRate, TweenTime);
		HoldTime = 0;
		PlayAmbientSound(IdleSound);

		bPlayingCharging = false;
		bPlayedReadySound = false;
		ChargeFX.Stop();
	}
 
	simulated function Tick( float dt )
	{
        local float AmmoDrainRate;

		PreChargingSoundTimer += dt;
		if( !bPlayingCharging && PreChargingSoundTimer >= PreChargingSoundTime )
		{
			bPlayingCharging = true;
			PreChargingSoundTimer = 0;
			PlayAmbientSound( ChargingSound );
		}

		if( !bPlayedReadySound && (ChargeTime > FullChargeTime || !Weapon.HasAmmo()))
		{
			bPlayedReadySound = true;
			Weapon.PlayOwnedSound( IsReadySound, SLOT_Interact, TransientSoundVolume, false,,, false );
		}

        if(DrainsHealth() && Weapon.HasAmmo() && (ChargeTime<=FullChargeTime) )
        {
            // drain health while charging
            AmmoDrainRate = AmmoDrainMax / FullChargeTime;
            AmmoDrainAccum += dt * AmmoDrainRate;
            if(AmmoDrainAccum > 1.0f && AmmoDrainTotal < AmmoDrainMax)
            {
                AmmoDrainAccum -= 1.0f;
                AmmoDrainTotal += 1;

    		    //Instigator.TakeDamage(1, Instigator, Vect(0,0,0), Vect(0,0,0), HealthDrainDamageType,, true);
                Weapon.Ammo[0].UseAmmo(1);
            }
			ChargeTime += dt;
        }

		ClientPlayForceFeedback(FireForce);
	}
	
	event ModeDoFire()
	{
		local playercontroller PC;
		
		PC = PlayerController(Instigator.Controller);
		if( PC != None )		
			PC.AddImpulse( spring_force_applied ); //new cam shake (xmatt)

		Super.ModeDoFire();

        GotoState('');
	}
}

simulated function float GetDamageScale(float Dist, float ExplodeRadius)
{

	return 1.0 - Dist/ExplodeRadius;
}

simulated function ProjectActorsWithinRadiusAway( vector HitLocation, float PowerLevel )
{
	local float ExplosionImpulse;
	local Vector ExplosionToEnemyDistVector;
	local Vector ImpulseDirection;
	local float ExplosionToEnemyDist, DamageScale;
	local Pawn PawnAffected;
	local float DamageInflicted;
    local float ExplosionRadius;

	local float DamageSelf, ImpulseSelf;
	local Vector ImpulseDirSelf, HitSelf;

	DamageSelf = 0;

	//PlaySound(sound'WeaponSounds.expl04');

    ExplosionRadius = Lerp(PowerLevel, ExplosionRadiusMin, ExplosionRadiusMax);

	ForEach RadiusActors( class'Pawn', PawnAffected, ExplosionRadius, HitLocation )
	{
		ExplosionToEnemyDistVector = PawnAffected.Location - HitLocation;
		ImpulseDirection = Normal(ExplosionToEnemyDistVector);
		ExplosionToEnemyDist = VSize(ExplosionToEnemyDistVector);
		ExplosionToEnemyDist = FMax( 1.0, ExplosionToEnemyDist );

		DamageScale = GetDamageScale(ExplosionToEnemyDist, ExplosionRadius);
		ExplosionImpulse = Lerp(PowerLevel, ExplosionStrengthMin, ExplosionStrengthMax);

		//Add some upwards impulse
		ImpulseDirection.Z += 1.0;
		
		DamageInflicted = DamageScale * Lerp(PowerLevel, ExplosionDamageMin, ExplosionDamageMax);

		if(Instigator == PawnAffected) {
			DamageSelf = DamageInflicted;
			ImpulseSelf = ExplosionImpulse;
			ImpulseDirSelf = ImpulseDirection;
			HitSelf = HitLocation;
		}
		else
			PawnAffected.TakeDamage(DamageInflicted, Instigator, HitLocation, (ExplosionImpulse * ImpulseDirection), DamageType,, true);
	}

// - don't damage self!	if(DamageSelf > 0)
//							Instigator.TakeDamage(DamageSelf, Instigator, HitSelf, ImpulseSelf*ImpulseDirSelf, DamageType,, true);
}

simulated function Destroyed()
{
	//Remove Warp and Save memory! (jds) ... why not on PC :) (ms)
	if ( !IsOnConsole() )
	{
		if( bWarpOn )
		{
			WarpTimer=0;
			if(Instigator.Controller.IsA('PlayerController'))
				PlayerController(Instigator.Controller).RemovePostFXStage( Warp );
			bWarpOn = false;
		}

		Warp = None;	// keep garbage collection happy
	}
	
	if( ChargeFX != None )
	{
		ChargeFX.Destroy();
	}
}

defaultproperties
{
     AbsorptionRippleness=35
     AbsorptionSpeed=20
     ExplosionDamageMin=110
     ExplosionDamageMax=200
     ExplosionStrengthMin=400
     ExplosionStrengthMax=700
     ExplosionRadiusMin=200
     ExplosionRadiusMax=500
     NextExplosionRadiusIncrement=50
     PreChargingSoundTime=1.400000
     FullChargeTime=5.000000
     AborbingRippleMaxAmplitude=0.008000
     EmittingTime=0.800000
     CompressedWavesScreenScale=0.800000
     EffectScreenX=0.300000
     EffectScreenY=-0.250000
     Wave1FalloffMark=0.200000
     Wave2FalloffMark=0.600000
     Wave3FalloffMark=0.700000
     mWave1Speed=1.700000
     mWave2Speed=1.800000
     mWave3Speed=1.900000
     AbsorptionScreenScale=0.700000
     SmallExplosionTime=1.000000
     PreChargingSound=Sound'PariahWeaponSounds.hit.TF_PreCharging'
     ChargingSound=Sound'PariahWeaponSounds.hit.TF_Charging2'
     IsReadySound=Sound'PariahWeaponSounds.hit.TF_Ready3'
     IdleSound=Sound'PariahWeaponSounds.WeaponAmbience.TitansFistAmbience'
     BigExplosionClass=Class'VehicleEffects.TitansFistExplosion'
     BeamEffectClass=Class'VehicleEffects.TitansFistBeam'
     ChargeEffectClass=Class'VehicleEffects.TitansFist_Charging'
     ProjSpawnOffset=(X=30.000000,Y=15.000000,Z=-5.000000)
     bShockwave=True
     Momentum=28000.000000
     DamageType=Class'VehicleWeapons.TitansFistDamage'
     VehicleDamage=10
     PersonDamage=10
     spring_mass=1.400000
     spring_stiffness=70.000000
     spring_damping=15.200000
     spring_force_applied=300.000000
     bAnimateThird=False
     UseSpringImpulse=True
     FireRate=2.000000
     BotRefireRate=0.990000
     FireSound=Sound'PariahWeaponSounds.hit.TF_Fire9'
     FireLoopAnim="PreFire"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.TitansFistAmmo'
     FireForce="PlayerPlasmaGunFire"
     SpreadStyle=SS_Random
     bFireOnRelease=True
}
