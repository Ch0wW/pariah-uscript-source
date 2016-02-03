//=============================================================================
//=============================================================================
class TitansFist extends PersonalWeapon;

var int WECsForNextLevel;

var()	class<Emitter> EffectClass;
var Emitter FEffect;
var() vector EOffset;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(EffectClass != none) {
		FEffect=Spawn(EffectClass);
		AttachToBone(FEffect, 'FX1');
		FEffect.SetRelativeLocation(EOffset );
	}
}

// destroy the energy balls
simulated function Destroyed()
{
	if (FEffect!=None) FEffect.Destroy();

	Super.Destroyed();
}

simulated function AddWEC(int WECAmmount)
{
}

simulated function WECLevelUp(optional bool bNoMessage)
{
}

simulated function bool PutDown()
{
	Super.PutDown();
    AmbientSound = None;
	return false;
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp( PrevWeapon );
    AmbientSound = TitansFistFire(FireMode[0]).IdleSound;
}

defaultproperties
{
     WECsForNextLevel=1
     EffectClass=Class'VehicleEffects.TitanFistEnergy'
     EOffset=(X=-110.000000)
     WECMaxLevel=0
     WeaponMessageClass=Class'VehicleWeapons.TitansFistMessage'
     BulletsStartingOffsetX=-15
     BulletsStartingOffsetY=-5
     BulletsPerRow=100
     BulletSpaceDX=1
     CrosshairIndex=1
     PutDownAnimRate=2.000000
     AIRating=0.400000
     CurrentRating=0.400000
     AutoAimFactor=1.000000
     DisplayFOV=58.000000
     AmmoClipTexture=Texture'PariahInterface.HUD.Assets'
     BulletTexture=Texture'PariahInterface.HUD.Assets'
     SelectSound=Sound'PariahWeaponSounds.SSWIG_select'
     IdleAnim="Breathe"
     FireModeClass(0)=Class'VehicleWeapons.TitansFistFire'
     BulletCoords=(X1=20,Y1=105,X2=20,Y2=120)
     EffectOffset=(X=80.000000,Y=16.000000,Z=-9.000000)
     bCanThrow=False
     bAmmoFromPack=False
     BobDamping=1.575000
     IconMaterial=Texture'PariahInterface.HUD.Assets'
     PickupClass=Class'VehicleWeapons.TitansFistPickup'
     AttachmentClass=Class'VehicleWeapons.TitansFistAttachment'
     PlayerViewOffset=(X=30.000000,Y=11.500000,Z=-26.000000)
     PlayerViewPivot=(Pitch=200,Yaw=-650)
     IconCoords=(X1=64,Y1=128,X2=127,Y2=191)
     ItemName="Titan's Fist"
     InventoryGroup=6
     BarIndex=14
     bExtraDamping=True
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.TitansFist'
}
