class BotFlameThrowerAttachment extends PersonalWeaponAttachment;

var		xEmitter			TrailEffect;
var ()	class<xEmitter>		TrailEffectClass;

var DavidFlameThrowerOff GotALight;

var		int TracerCount;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// init the light effect (on when the flame thrower effect is off)
	if(GotALight == none)
		GotALight = Spawn(class'VehicleEffects.DavidFlameThrowerOff', self);
	if(GotALight != none) {
		AttachToWeaponAttachment(GotALight, MuzzleRef);
		GotALight.SetRelativeLocation(MuzzleOffset);
	}
}

simulated function Destroyed()
{
	Super.Destroyed();
	if(GotALight != none) {
		GotALight.Destroy();
		GotALight = none;
	}
}




simulated event ThirdPersonEffects()
{
    if (Level.NetMode == NM_DedicatedServer || Instigator == None)
        return;

    if (FlashCount == 0)
    {
        bDynamicLight = false;
		if(AltMuzFlash != none) {
//			AltMuzFlash.StopFlash();
			AltMuzFlash.Emitters[0].ParticlesPerSecond=0;
			AltMuzFlash.Emitters[1].ParticlesPerSecond=0;
			AltMuzFlash.Emitters[2].ParticlesPerSecond=0;
			AltMuzFlash.Emitters[3].ParticlesPerSecond=0;
		}

		// enable the light effect
		if(GotALight != none) {
			GotALight.bHidden = false;
			GotALight.bPaused = false;
		}
    }
    if (FlashCount > 0 && MuzFlashClass != None)
    {
        if (FiringMode == 0 && bFlashForPrimary || FiringMode == 1 && bFlashForAlt)
        {
            if (MuzFlash == None)
            {
                MuzFlash = Spawn(MuzFlashClass);
				AttachToWeaponAttachment(MuzFlash, MuzzleRef);
            }
            FlashFlash(FiringMode);
        }
    }
	else if(FlashCount > 0 && AltMuzFlashClass != none) {
		if(FiringMode == 0 && bFlashForPrimary || FiringMode ==1 && bFlashForAlt) {
			if(AltMuzFlash == None || AltMuzFlash.bOnceOnly) {
				if(AltMuzFlash != none) {
					AltMuzFlash.Destroy();
					AltMuzFlash = none;

					// enable the light effect
					if(GotALight != none) {
						GotALight.bHidden = false;
						GotALight.bPaused = false;
					}
				}
				AltMuzFlash = Spawn(AltMuzFlashClass);
				AttachToWeaponAttachment(AltMuzFlash, MuzzleRef);
				AltMuzFlash.SetRelativeLocation(MuzzleOffset);

				// disable the light effect
				if(GotALight != none) {
					GotALight.bHidden = true;
					GotALight.bPaused = true;
				}
			}

			FlashFlash(FiringMode);
			AltMuzFlash.Emitters[0].ParticlesPerSecond=10;   //This hard coded hack was made so the flame thrower, when turned off
			AltMuzFlash.Emitters[1].ParticlesPerSecond=12;   //Does not BLINK off.  Particles fade out naturally.  It gets completely
			AltMuzFlash.Emitters[2].ParticlesPerSecond=30;	 // turned off in the Timer function below.
			AltMuzFlash.Emitters[3].ParticlesPerSecond=15;
		}
	}

	if ( Level.NetMode == NM_DedicatedServer )
        return;

    if ( FlashCount > 0 )
	{

        SetTimer(3.0, false);
    }
    else
    {
        AmbientSound = None;
        GotoState('');
    }
}

simulated function Timer()
{
	AltMuzFlash.StopFlash();
    AmbientSound = None;
}

defaultproperties
{
     SFXRef1="FX1"
     SFXRef2="FX1"
     AltMuzFlashClass=Class'VehicleEffects.DavidFlamethrower'
     MuzzleOffset=(X=60.000000,Y=-25.000000,Z=-5.000000)
     MuzzleRotation=(Pitch=-16384)
     bRapidFire=True
     bFlashForPrimary=True
     bFlashLight=True
     WeaponType=EWT_Bulldog
     SoundRadius=200.000000
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.Flamethrower_3rd'
     RelativeLocation=(X=18.500000,Y=-12.000000,Z=-7.000000)
     RelativeRotation=(Pitch=1700,Yaw=-800,Roll=-16384)
     SoundVolume=200
     bAlwaysRelevant=True
}
