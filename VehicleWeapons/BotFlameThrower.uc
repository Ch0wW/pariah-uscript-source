class BotFlameThrower extends PersonalWeapon;

var transient float LastFOV;

function byte BestMode()
{
	if ( Instigator.Controller.bFire != 0 )
		return 0;
	else if ( Instigator.Controller.bAltFire != 0 )
		return 1;

	return 0;
}

simulated function bool StartFire(int Mode)
{
	if(Super.StartFire(Mode))
	{
//		EnableAutoAim();
//		EffectOffset = default.EffectOffset;
		FireMode[mode].StartFiring();
		return true;
	}
	return false;
}

simulated state Reload
{
	simulated function EndState() {
	}

Begin:
	GotoState('');
}

defaultproperties
{
     WeaponDynLightRelPos=(X=20.000000,Y=-10.000000)
     WeaponMessageClass=Class'VehicleWeapons.VGAssaultMessage'
     SelectAnimRate=1.000000
     PutDownAnimRate=2.000000
     AIRating=0.400000
     CurrentRating=0.400000
     AutoAimFactor=0.500000
     AutoAimRangeFactor=0.600000
     DisplayFOV=60.000000
     SelectSound=Sound'PariahWeaponSounds.AR_Select'
     IdleAnim="Breathe"
     FireModeClass(0)=Class'VehicleWeapons.BotFlameThrowerFire'
     FireModeClass(1)=Class'VehicleWeapons.BotFlameThrowerAltFire'
     EffectOffset=(X=96.000000,Y=10.000000,Z=25.000000)
     bCanThrow=False
     BobDamping=1.700000
     PickupClass=Class'VehicleWeapons.VGAssaultRiflePickup'
     AttachmentClass=Class'VehicleWeapons.BotFlameThrowerAttachment'
     PlayerViewOffset=(X=14.000000,Y=7.000000,Z=-22.500000)
     PlayerViewPivot=(Pitch=375,Yaw=-400)
     IconCoords=(X1=159,X2=237,Y2=58)
     ItemName="FlameThrower"
     BarIndex=1
     bExtraDamping=True
     SoundRadius=400.000000
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.Bulldog'
     bReplicateInstigator=True
}
