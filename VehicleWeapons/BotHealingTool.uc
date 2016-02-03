class BotHealingTool extends PersonalWeapon;

simulated function WECLevelUp(optional bool bNoMessage)
{
	Super.WECLevelUp(bNoMessage);
	FireMode[0].WECLevelUp(WECLevel);
}

simulated function float RateSelf()
{
	return -2.0;
}

defaultproperties
{
     WeaponMessageClass=Class'VehicleWeapons.BotHealingToolMessage'
     AIRating=-2.000000
     CurrentRating=-2.000000
     AutoAimFactor=3.000000
     AutoAimRangeFactor=0.100000
     DisplayFOV=58.000000
     PutDownAnim="PutDown"
     FireModeClass(0)=Class'VehicleWeapons.BotHealingToolFire'
     FireModeClass(1)=None
     EffectOffset=(X=80.000000,Y=16.000000,Z=-9.000000)
     bCanThrow=False
     BobDamping=1.575000
     AttachmentClass=Class'VehicleWeapons.BotHealingToolAttachment'
     PlayerViewOffset=(X=11.000000,Y=3.900000,Z=3.200000)
     ItemName="Healing Tool"
     InventoryGroup=13
     BarIndex=13
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.HealingTool'
}
