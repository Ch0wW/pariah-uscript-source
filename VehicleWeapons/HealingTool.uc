class HealingTool extends PersonalWeapon;

simulated function bool StartFire(int Mode)
{
    if(ReadyToFire(Mode))
    {
        HealingToolFire(FireMode[0]).StartFire();
    }
    return Super.StartFire(Mode);
}

simulated function WECLevelUp(optional bool bNoMessage)
{
    local HealingToolFire htf;
    
	Super.WECLevelUp(bNoMessage); // call first!
    
    htf = HealingToolFire(FireMode[0]);
    
    //-Quick Injector (Double speed of healing tool application)
    //-Health Booster (Add another health bubble)
    //-Adrenal Increase (Increase dash time?)

	switch(WECLevel)
	{
	case 1:
	    htf.PreFireTime = htf.default.PreFireTime * 0.5;
	    htf.FireRate = htf.default.FireRate * 0.5;
	    htf.FireAnimRate = htf.default.FireAnimRate * 2.0;
	    htf.FireAnimRateB = htf.default.FireAnimRateB * 2.0;
	    htf.PreFireAnimRate = htf.default.PreFireAnimRate * 2.0;
		break;
	case 2:
	    Instigator.HealthMax = 125;
        if(Role == ROLE_Authority)
	        Instigator.Health = Min(Instigator.Health + 25, Instigator.HealthMax);
		break;
	case 3:
	    Instigator.HealthMax = 150;
        if(Role == ROLE_Authority)
    	    Instigator.Health = Min(Instigator.Health + 25, Instigator.HealthMax);
	    VGPawn(Instigator).DashTime = VGPawn(Instigator).default.DashTime * 2.0;
	    VGPawn(Instigator).HealthUnitRegenRate = VGPawn(Instigator).default.HealthUnitRegenRate * 1.5;
		break;
	}
}

simulated function float RateSelf()
{
	return -2.0;
}

simulated function AnimEnd( int channel )
{
    local name Anim;
    local float frame, rate;
	local int mode;
	local HealingToolFire htf;

    GetAnimParams( 0, Anim, frame, rate );

	if(FireMode[0] != none && FireMode[0].bIsFiring)
		mode = 0;
	else if(FireMode[1] != none && FireMode[1].bIsFiring)
		mode = 1;

    htf = HealingToolFire(FireMode[mode]);
    if(htf == None)
        return;

	//If it was playing the PreFireAnim, now play the FireLoopAnim
	if(Anim == htf.PreFireAnim && HasAnim( htf.FireLoopAnim ) )
	{
		LoopAnim(htf.FireLoopAnim, htf.FireAnimRate, 0.1);
	}
	else if(Anim == htf.PreFireAnimB && HasAnim(htf.FireLoopAnimB) )
    {
		LoopAnim(htf.FireLoopAnimB, htf.FireAnimRateB, 0.1);
	}
	else if(Anim == htf.FireEndAnim)
    {
        PlayIdle();
	}
    
	//If it is ready to fire, and not firing, play the IdleAnim
    else if (ClientState == WS_ReadyToFire)
    {
		if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
        {
            PlayIdle();
        }
    }
}

simulated event RenderOverlays(Canvas Canvas)
{
	Super.RenderOverlays(Canvas);
}

simulated function StopFireEffects()
{
    FireMode[0].AmbientSound = None;
}

simulated function OutOfAmmo()
{
    if(Instigator.IsLocallyControlled())
    {
        FireMode[0].PlayFireEnd();
    }
}

simulated function DoAutoSwitch()
{
    PlayerController(Instigator.Controller).ToggleHealingTool();
}

defaultproperties
{
     ReloadTime=3.000000
     WecAttachDescs(0)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.012000,WecRelativeLoc=(X=2.500000,Y=1.000000,Z=1.400000),WecRelativeRot=(Yaw=-5000,Roll=16834),AttachPoint="HealingTool")
     WecAttachDescs(1)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.012000,WecRelativeLoc=(X=2.500000,Y=1.000000,Z=-0.100000),WecRelativeRot=(Yaw=-5000,Roll=16834),AttachPoint="HealingTool")
     WecAttachDescs(2)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.012000,WecRelativeLoc=(X=2.500000,Y=1.000000,Z=-1.700000),WecRelativeRot=(Yaw=-5000,Roll=16834),AttachPoint="HealingTool")
     WeaponMessageClass=Class'VehicleWeapons.HealingToolMessage'
     BulletsStartingOffsetX=-5
     BulletsStartingOffsetY=15
     BulletsPerRow=20
     BulletSpaceDX=7
     BulletSpaceDY=17
     CrosshairIndex=-1
     SelectAnimRate=1.000000
     PutDownAnimRate=2.000000
     AIRating=-2.000000
     CurrentRating=-2.000000
     AutoAimFactor=3.000000
     AutoAimRangeFactor=0.100000
     DisplayFOV=60.000000
     AmmoClipTexture=Texture'PariahInterface.HUD.Assets'
     BulletTexture=Texture'PariahInterface.HUD.Assets'
     IdleAnim="Breathe"
     FireModeClass(0)=Class'VehicleWeapons.HealingToolFire'
     FireModeClass(1)=None
     BulletCoords=(X1=87,Y1=29,X2=91,Y2=43)
     EffectOffset=(X=80.000000,Y=16.000000,Z=-9.000000)
     bCanThrow=False
     BobDamping=1.575000
     IconMaterial=Texture'PariahInterface.HUD.Assets'
     PickupClass=Class'VehicleWeapons.HealingToolPickup'
     AttachmentClass=Class'VehicleWeapons.HealingToolAttachment'
     PlayerViewOffset=(X=15.000000,Y=5.000000,Z=-24.000000)
     PlayerViewPivot=(Pitch=375)
     IconCoords=(X1=128,Y1=128,X2=191,Y2=191)
     ItemName="Healing Tool"
     InventoryGroup=5
     BarIndex=13
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.HealingTool'
}
