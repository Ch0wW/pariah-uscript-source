//=============================================================================
// VGAssaultRifle.uc
//=============================================================================
class VGAssaultRifle extends PersonalWeapon;

var Vector          Start;
var Rotator         Dir;

simulated function AnimEnd(int channel)
{
}

simulated function DetachFromPawn(Pawn P)
{
    ReturnToIdle();
    Super.DetachFromPawn(P);
}

simulated function bool PutDown()
{
	ReturnToIdle();
    return Super.PutDown();
}

simulated function ReturnToIdle()
{
	if (FireMode[0] != None)
	{
		FireMode[0].GotoState('Idle');
    }
}

simulated function bool StartFire(int Mode)
{
	if(Super.StartFire(Mode))
	{
		EnableAutoAim();
		EffectOffset = default.EffectOffset;
		FireMode[mode].StartFiring();
		return true;
	}
	return false;
}


simulated function IncrementFlashCount(int Mode)
{
    if ( WeaponAttachment(ThirdPersonActor) != None && HasAmmo() )
    {
        WeaponAttachment(ThirdPersonActor).FiringMode = Mode;
		if(Mode == 0 && FireMode[0] != none ) 
		{
			// don't do the effect when zooming
	        WeaponAttachment(ThirdPersonActor).FlashCount++;
			WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
		}
    }
}

simulated function ZeroFlashCount(int Mode)
{
    if ( WeaponAttachment(ThirdPersonActor) != None )
    {
        WeaponAttachment(ThirdPersonActor).FiringMode = Mode;
        WeaponAttachment(ThirdPersonActor).FlashCount = 0;
		ThirdPersonActor.Instigator = Instigator;
		if(FireMode[0] != none && Mode == 0)
		{
	        WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
		}
    }
}

simulated function WECLevelUp(optional bool bNoMessage)
{
    local VGAssaultFire af;
    
    af = VGAssaultFire(FireMode[0]);
   
	Super.WECLevelUp(bNoMessage);
	
	// -Fire Accelerator (Faster fire rate - need to lower current default)
    // -Recoil Stabilizer (Less spread)
    // -Armor Piercing (More damage)

	switch(WECLevel)
	{
	case 1:
	    af.FireRate = 0.084;
	    af.FireAnimRate = af.default.FireAnimRate * 1.25;
		break;
	case 2:
	    af.MaxHeatTime = af.default.MaxHeatTime * 2.0;
	    af.spring_force_applied = af.default.spring_force_applied * 0.7;
		break;
	case 3:
	    af.PersonDamage = 22;
	    af.VehicleDamage = 15;
		break;
	}
}

defaultproperties
{
     ReloadAnimRate=1.500000
     ReloadAnim="Overheat"
     WeaponDynLightRelPos=(X=20.000000,Y=-10.000000)
     WecAttachDescs(0)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.015000,WecRelativeLoc=(X=-38.000000,Y=-2.500000,Z=13.500000),WecRelativeRot=(Yaw=16384,Roll=12000),AttachPoint="FX1")
     WecAttachDescs(1)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.015000,WecRelativeLoc=(X=-38.000000,Y=-0.650000,Z=13.500000),WecRelativeRot=(Yaw=16384,Roll=12000),AttachPoint="FX1")
     WecAttachDescs(2)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.015000,WecRelativeLoc=(X=-38.000000,Y=1.200000,Z=13.500000),WecRelativeRot=(Yaw=16384,Roll=12000),AttachPoint="FX1")
     WeaponMessageClass=Class'VehicleWeapons.VGAssaultMessage'
     BulletsStartingOffsetX=-15
     BulletsStartingOffsetY=20
     BulletsPerRow=20
     BulletSpaceDX=5
     BulletSpaceDY=12
     IdleAnimRate=0.500000
     SelectAnimRate=1.000000
     PutDownAnimRate=2.000000
     AIRating=0.400000
     CurrentRating=0.400000
     AutoAimFactor=0.500000
     AutoAimRangeFactor=0.600000
     DisplayFOV=60.000000
     AmmoClipTexture=Texture'PariahInterface.HUD.Assets'
     BulletTexture=Texture'PariahInterface.HUD.Assets'
     SelectSound=Sound'PariahWeaponSounds.AR_Select'
     IdleAnim="Breathe"
     FireModeClass(0)=Class'VehicleWeapons.VGAssaultFire'
     BulletCoords=(X1=88,Y1=30,X2=90,Y2=39)
     EffectOffset=(X=96.000000,Y=10.000000,Z=25.000000)
     bCanThrow=False
     BobDamping=1.700000
     IconMaterial=Texture'PariahInterface.HUD.Assets'
     PickupClass=Class'VehicleWeapons.VGAssaultRiflePickup'
     AttachmentClass=Class'VehicleWeapons.VGAssaultAttachment'
     PlayerViewOffset=(X=14.000000,Y=7.000000,Z=-22.500000)
     PlayerViewPivot=(Pitch=375,Yaw=-400)
     IconCoords=(X1=192,Y1=128,X2=255,Y2=191)
     ItemName="Bulldog"
     BarIndex=1
     bExtraDamping=True
     SoundRadius=400.000000
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.Bulldog'
     bReplicateInstigator=True
}
