class StocktonsFistAltFire extends VGInstantFire;

var float		LastFireTime;

var	()	Sound				FiringSound;
var ()	Sound				WindDownSound;

var StocktonsFistAltBeam Beam;
var StocktonsFist Gun;

var Array<Pawn> HitActors;


function PostBeginPlay()
{
	Super.PostBeginPlay();
	Gun = StocktonsFist(Owner);
}

function Destroyed()
{
	Gun = none;
	Super.Destroyed();

	if(Beam != none) {
		Beam.Destroy();
		Beam = none;
	}
}


function InitEffects()
{
    Super.InitEffects();

	if(Beam == none)
		Beam = Spawn(class'PariahSPPawns.StocktonsFistAltBeam', self);
	if(Beam != none) {
		//Weapon.AttachToBone(Beam, 'FX1');
		Beam.SetRelativeLocation(vect(-2, 0, 4) );
		//VGWeaponAttachment(Weapon.ThirdPersonActor).AttachToWeaponAttachment(Beam, 'FX1');
		Beam.bHidden = true;
		Beam.bPaused = true;
	}
}


function PlayAmbientSound(Sound aSound)
{
    if (Gun == None)
        return;

    Gun.AmbientSound = aSound;
}


simulated function bool CanTarget(Pawn P)
{
	if(P == none || P == Instigator)
		return false;

	if(P.IsA('MostlyDeadPawn') )
		return false;

    return (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team);
}

function EffectTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;//, HitLoc, HitNorm;
    local Actor Other;//, Target;
	local Material HitMat;

	X = Vector(Dir);
//	Start.Z -= 15;
	End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat);

	if(Other == None)
    {
        HitLocation = End;
	}

	//c = Weapon.GetBoneCoords('FX1');
	Beam.SetLocation(VGWeaponAttachment(Weapon.ThirdPersonActor).GetMuzzleLocation());
	//LOG("SETTING BEAM END TO "$HITLOCATION);
	Beam.mSpawnVecA = HitLocation;
	//Beam.mSpawnVecB = Start;

}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;//, HitLoc, HitNorm;
    local Actor Other;//, Target;
	local Material HitMat;
//	local Name boneName;
	local float damageAmount;//boneDist, //, closest;
	local Material.ESurfaceTypes HitSurfaceType;
	local int i;
	local bool dohit;

	X = Vector(Dir);
//	Start.Z -= 15;
	End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat);

	dohit=true;
	if(Other.IsA('Pawn'))
	{
		for(i=0;i<HitActors.Length;i++)
		{
			if(HitActors[i] == Pawn(Other))
				dohit = false;
		}

		if(dohit) //hit pawn not in list
		{
			HitActors[HitActors.Length] = Pawn(Other);
		}
	}


	if ( Other != None && Other != Instigator && dohit)
    {
		if(Other.bProjTarget || !Other.bWorldGeometry)
        {
			if(Other.IsA('VGVehicle')) {
				Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*X, DamageType);
			}
			else {
				damageAmount = PersonDamage;

				if(InStr(GetMeshName(), "Keeper") >= 0)
					// keepers count as vehicles rather than people
					damageAmount = VehicleDamage;

				Other.TakeDamage(damageAmount, Instigator, HitLocation, Momentum*X, DamageType);
			}

//			if(Other.IsA('StaticMeshActor') && HitEffectClass != None && HitEffectProb >= FRand() && !bExplosive) {
			if(!Other.IsA('Pawn') && HitEffectClass != None && HitEffectProb >= FRand() ) {
//				HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);
//				if(HitMat != none)
//					HitSurfaceType = HitMat.SurfaceType;
//				else
					HitSurfaceType = EST_Default;

				if(Other.bStatic)
				{
					Level.QuickDecal(HitLocation, HitNormal, Other, 50.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
				}
			}
		}
        else
        {
			//XJ can use HitMaterial from trace to determine effect since bsp doesn't work right.
            if (HitEffectClass != None && HitEffectProb >= FRand() )
            {
//                HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);
//				if(HitMat != none)
//					HitSurfaceType = HitMat.SurfaceType;
//				else
					HitSurfaceType = EST_Default;
				if(Other.bStatic)
				{
					Level.QuickDecal(HitLocation, HitNormal, Other, 50.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
				}
            }
        }
	}
	else if( !dohit )
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
	}

	Beam.mSpawnVecA = HitLocation;

	if(Other != none && Other.IsA('Pawn') && dohit ) {
		// set pawn on fire
		if(Other.IsA('VGPawn') )
			VGPawn(Other).FireInstigator = Instigator;
	}

}


simulated function ModeTick(float dt)
{
	local float trueDelta;

	trueDelta = Level.TimeSeconds - LastHeatTime;

	Super.ModeTick(dt);
}

function StartFiring()
{
	GotoState( 'Firing' );
	Weapon.Ammo[0].bRegen=false;
}

simulated state Firing
{
    simulated function BeginState()
    {
//		bWasFiring = true;
//		Gun.LoopAnim(FireLoopAnim, FireLoopAnimRate, TweenTime);
		PlayAmbientSound(FiringSound);
		if(Beam != none) {
			Beam.bHidden = false;
			Beam.bPaused = false;
		}
		HitActors.Length=0;
	}

	function EndState()
	{
//		local PlayerController PC;

//		PlayAmbientSound(WindDownSound);

		PlayAmbientSound(none);
		Gun.PlaySound(WindDownSound,Slot_Misc);
		if(Beam != none) {
			Beam.bHidden = true;
			Beam.bPaused = true;
		}

		HitActors.Length=0;
	}

	function ModeDoFire()
	{
		Super.ModeDoFire();
	}

    simulated function ModeTick(float dt)
    {
		local float trueDelta;
		local Vector StartTrace;
		local Rotator R, Aim;
		local vector X, Y, Z;

		trueDelta = Level.TimeSeconds - LastHeatTime;

		R = Weapon.ThirdPersonActor.Rotation;
		if(Weapon.bIndependantPitch) 
		{
			R.Pitch += Weapon.RealPitch;
		}
		GetAxes( R, X, Y, Z );
		StartTrace = Weapon.GetFireStart( X, Y, Z );
		
		Aim = AdjustAim(StartTrace, AimError);

		EffectTrace(StartTrace, Aim);

        Super.ModeTick(dt);

	}
    function StopFiring()
    {
		GotoState('');
    }
}

simulated state Reload
{
	simulated function BeginState()
	{
//		bWasFiring = false;
		Weapon.PlayIdle();
	}
	
	function EndState()
	{
		NextFireTime = Level.TimeSeconds;
	}

	event ModeDoFire()
	{
		local AIController AIC;
		AIC = AIController(Instigator.Controller);

        if ( AIC != None )
		{
			AIC.StopFiring();
		}
	}
//	function StartFiring(){}
    simulated function ModeTick(float dt)
    {
//		if(Weapon.Ammo[0].CheckReload() )
//			Weapon.DoReload();
	}
}

simulated function bool AllowFire()
{
	return true;
}

defaultproperties
{
     FiringSound=Sound'PariahDropShipSounds.Millitary.DropshipLaserLoopA'
     WindDownSound=Sound'PariahWeaponSounds.hit.TF_PreCharging'
     TraceRange=6000.000000
     Momentum=500.000000
     TracerFreq=0.000000
     DamageType=Class'VehicleWeapons.VGAssaultDamage'
     HitEffectClass=Class'VehicleWeapons.VGFragHitEffects'
     VehicleDamage=25
     PersonDamage=25
     MaxHeatTime=5.000000
     MaxCoolTime=3.000000
     bAnimateThird=False
     AmmoPerFire=1
     RecoilPitch=300
     FireRate=0.015000
     RecoilTime=0.200000
     BotRefireRate=0.990000
     aimerror=500.000000
     MaxFireNoiseDist=2500.000000
     FireLoopAnim="PreFire"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     FireForce="VGAssaultRifleFire"
     PreFireForce="PlayerPlasmaGunFire"
     SpreadStyle=SS_Line
     bModeExclusive=False
}
