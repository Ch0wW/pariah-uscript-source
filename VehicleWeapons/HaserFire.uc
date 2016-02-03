class HaserFire extends VGInstantFire;

var	LaserChargeEffect	WarmupEffect;
var class<xEmitter>		HitEmitterClass;
var float				ChargedPersonDamage, ChargedVehicleDamage, ChargedAmmo, ChargedKMomentum;
var float				FreezeAnimTime;
var float				SplashDamage;
var float				SplashRadius;

simulated function DestroyEffects()
{
	Super.DestroyEffects();
	if(WarmupEffect != none)
		WarmupEffect.Destroy();
}


/*function ModeHoldFire()
{
	Super.ModeHoldFire();
	if(WarmupEffect == none)
	{
		WarmupEffect = spawn(class'LaserChargeEffect');
		WarmupEffect.SetOwner(Weapon.ThirdPersonActor);
		VGWeaponAttachment(Weapon.ThirdPersonActor).AttachToWeaponAttachment(WarmupEffect, VGWeaponAttachment(Weapon.ThirdPersonActor).MuzzleRef);
	}
	if(WarmupEffect != none)
	{
		WarmupEffect.Charge();
	}
	GotoState('Charge');
}*/

// need to override to do dynamic ammounts of ammo and effects
event ModeDoFire()
{
    local Vector X,Y,Z, End, HitLocation, HitNormal;
    local Actor Other;
    local int Damage;
	local Material HitMat;
	local xEmitter	tmpEmitter;

	local vector Start, vect;
	local rotator Dir;

	local float HeldTime;

	HeldTime = FMin(HoldTime, 2.0);
	Load = ChargedAmmo * (HeldTime + 1);
	Super.ModeDoFire();
	if(WarmupEffect != none)
	{
		WarmupEffect.DisCharge();
	}
	//

	Instigator.MakeNoise(1.0);
	GetAxes(Weapon.ThirdPersonActor.Rotation,X,Y,Z);
//	Start = Weapon.GetFireStart(X,Y,Z);
	vect = VGWeaponAttachment(Weapon.ThirdPersonActor).GetMuzzleLocation();

	if(Instigator.Controller.IsA('VehiclePlayer') ) {
		Start = VehiclePlayer(Instigator.Controller).LastCamLocation;
		Other = Trace(HitLocation, HitNormal, Start+20000*vector(VehiclePlayer(Instigator.Controller).LastCamRotation), Start, true);
		log(" Base = "$Weapon.Base$", Owner = "$Weapon.Owner$", TPA.Base = "$Weapon.ThirdPersonActor.Base);
		log(" Other 1 = "$Other);
		if(Other != none && Other != Weapon.ThirdPersonActor.Base) {
			Dir = Rotator(HitLocation-vect);
			// double check to make sure we're not hitting the bogie the launcher is situated on
			Other = Trace(HitLocation, HitNormal, vect+20000*vector(Dir), vect, true);
			if(Other == Weapon.ThirdPersonActor.Base)
				Dir = Weapon.ThirdPersonActor.GetBoneRotation('Weapon');
		}
		else
			Dir = Weapon.ThirdPersonActor.GetBoneRotation('Weapon');
	}
	else
		Dir = Weapon.ThirdPersonActor.GetBoneRotation('Weapon');

//	Dir = AdjustAim(Start, AimError);
	Start = vect;
//	Dir = Weapon.ThirdPersonActor.GetBoneRotation('Weapon');
	X = Vector(Dir);
	End = Start + TraceRange * X;

    Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat);

	if(Weapon.Role == ROLE_Authority)
	{
		if ( Other != None && Other != Instigator )
		{
			if (!Other.bWorldGeometry)
			{
//				Damage = ChargedVehicleDamage * (HeldTime + 1);
//				Damage = Ceil(Damage * DamageAtten);
				Damage = 200;
				Momentum = ChargedKMomentum;//  * (HeldTime + 1);
				//log("Damage="$Damage);
				Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
				HitNormal = Vect(0,0,0);
			}
			else
			{
				//XJ can use HitMaterial from trace to determine effect since bsp doesn't work right.
				if (HitEffectClass != None && HitEffectProb >= FRand() )
				{
					HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);
				}
			}
		}
		else
		{
			HitLocation = End;
			HitNormal = Vect(0,0,0);
		}
	}
	if(Level.NetMode != NM_DedicatedServer)
	{
		if(Other == None || Other == Instigator)
			HitLocation = End;
		tmpEmitter = Spawn(HitEmitterClass,,,Start,Dir);
		tmpEmitter.mSpawnVecA = HitLocation;
		tmpEmitter.mSizeRange[0] = 20.0 * ((HeldTime*2) + 1);
		tmpEmitter.mSizeRange[1] = 20.0 * ((HeldTime*2) + 1);
		//log("XJ: DoTrace HeldTime: "$HeldTime$" size: "$tmpEmitter.mSizeRange[0]);
	}

	// do splash
	HurtRadius(SplashDamage, SplashRadius, DamageType, Momentum, HitLocation, Instigator.Controller);
}

function DoTrace(Vector Start, Rotator Dir)
{
}

/*state Charge
{
	simulated function BeginState()
	{
		VGWeaponAttachment(Weapon.ThirdPersonActor).PlayAnim('Charge',1.0,0.1,0);
		Weapon.Ammo[0].bRegen=false;
		SetTimer(FreezeAnimTime,false);
	}
	simulated function EndState()
	{
		Weapon.Ammo[0].bRegen=true;
	}
	simulated function Timer()
	{
		FreezeAnimAt(FreezeAnimTime);
	}
	event ModeDoFire()
	{
		Global.ModeDoFire();
		GotoState('');
	}
}*/

defaultproperties
{
     ChargedPersonDamage=30.000000
     ChargedVehicleDamage=40.000000
     ChargedAmmo=7.000000
     ChargedKMomentum=7000.000000
     FreezeAnimTime=2.000000
     SplashDamage=50.000000
     SplashRadius=500.000000
     HitEmitterClass=Class'VehicleEffects.LaserEffect'
     Momentum=1000.000000
     DamageType=Class'VehicleWeapons.HaserDamage'
     HitEffectClass=Class'VehicleWeapons.VGHitEffect'
     AmmoPerFire=1
     FireRate=5.000000
     BotRefireRate=0.100000
     aimerror=800.000000
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     FireForce="HaserFire"
}
