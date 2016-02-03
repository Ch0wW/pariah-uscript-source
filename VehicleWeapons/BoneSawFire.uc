class BoneSawFire extends VGInstantFire;

var int lastFireAnim;

simulated function bool AllowFire()
{
	return true;
}

event ModeDoFire()
{
    local AIController AIC;

    // Local Machine
    if(Instigator != none && Instigator.IsLocallyControlled() )
    {
        Weapon.PlayOwnedSound(FireSound, SLOT_Interact,TransientSoundVolume,,,,false);
        PlayFiring();
    }

    if (MaxHoldTime > 0.0)
        HoldTime = FMin(HoldTime, MaxHoldTime);

    if (Weapon.Role == ROLE_Authority)
    {
        if (Weapon == None || Instigator == None)
            return;

        Instigator.Controller.PlayerReplicationInfo.Stats.RegisterShot( Weapon.class, ProjPerFire * int(Load) );

        AIC = AIController(Instigator.Controller);

        if ( AIC != None )
		{
			if(AIC.Pawn.DefaultWeapon == Weapon)
				AIC.DefaultWeaponFireAgain(BotRefireRate*Weapon.FireRateAtten, true);
			else
				AIC.WeaponFireAgain(BotRefireRate*Weapon.FireRateAtten, true);
		}

    }

	if(Role == ROLE_Authority && Weapon.ThirdPersonActor != none) {
		DoFireEffect();
	}

	// servers need to play the sound to replicate to clients.
	//if(Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer)
	//else
	//{
		//ServerPlayFiring();
		Weapon.PlaySound(FireSound, SLOT_Interact,,,,,false,true);
		//Weapon.PlayOwnedSound(FireSound, SLOT_Interact,TransientSoundVolume,,,,true);
	//}

	if(!bFireOnRelease)
		Weapon.IncrementFlashCount(ThisModeNum);

    // set the next firing time. must be careful here so client and server do not get out of sync
    if (bFireOnRelease)
    {
        if (bIsFiring)
            NextFireTime += MaxHoldTime + FireRate*Weapon.FireRateAtten;
        else
            NextFireTime = Level.TimeSeconds + FireRate*Weapon.FireRateAtten;
    }
    else
    {
        NextFireTime += FireRate*Weapon.FireRateAtten;
        NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    }

	Load = AmmoPerFire;
    HoldTime = 0;

    if (Instigator != none && Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    {
        if (Weapon.PutDown())
            bIsFiring = false;
    }
}

function DoTrace(Vector Start, Rotator Dir)
{
	local Vector HitLocation, HitNormal, X, End;
	local Actor Other;
	local Material HitMat;

	X = Vector(Dir);
	End = Start+TraceRange*X;
    Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat);
//	log("Other = "$Other);

	if ( Other != None && Other != Instigator ) {
		if(!Other.bWorldGeometry)
        {
			if(Other.IsA('VGVehicle')) {
				Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*X, DamageType);
			}
			else {
				// check to see if we're hitting the victim from behind
				End = Vector(Other.Rotation);
				if( (X dot End) > 0.8)
					Other.TakeDamage(150, Instigator, HitLocation, Momentum*X, DamageType);
				else
					Other.TakeDamage(PersonDamage, Instigator, HitLocation, Momentum*X, DamageType);
			}
		}
        else
        {
		}
	}
}

function PlayFiring()
{
	local int n;

	n = Rand(3);
	while(n == lastFireAnim)
		n = Rand(3);

	switch(n) {
		case 0:
			Weapon.PlayAnim('Fire01', FireAnimRate, TweenTime);
			break;
		case 1:
			Weapon.PlayAnim('Fire02', FireAnimRate, TweenTime);
			break;
		case 2:
			Weapon.PlayAnim('Fire03', FireAnimRate, TweenTime);
			break;
	}
	
	if(bUseForceFeedback)
	{
	    ClientPlayForceFeedback(FireForce);
	}

	lastFireAnim = n;
}

defaultproperties
{
     lastFireAnim=-1
     TraceRange=150.000000
     DamageType=Class'VehicleWeapons.BoneSawDamage'
     VehicleDamage=10
     PersonDamage=50
     AmmoPerFire=1
     FireRate=0.400000
     FireAnim="Fire01"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     FireForce="BoneSaw"
     SpreadStyle=SS_Line
}
