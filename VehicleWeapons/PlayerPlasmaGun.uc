class PlayerPlasmaGun extends PersonalWeapon;
    
#exec LOAD FILE="PariahWeaponEffectsTextures.utx"
#exec LOAD FILE="PariahWeaponTextures.utx"

var float GoggleAlpha;
var float GoggleAlphaDir;
var float GoggleDimmer;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    if(Level.NetMode != NM_DedicatedServer)
    {
        // override panning plasma skin. reenabled on first wec upgrade.
        SetSkin(0, Shader'PariahWeaponTextures.LaserRail.LRailShader'); // default
        SetSkin(1, Shader'PariahWeaponTextures.LaserRail.LEnergyShader'); // default
        SetSkin(2, Shader'PariahWeaponTextures.LaserRail.LGlassOpaqueShader'); // skin that gets changed
    }
}

simulated function WECLevelUp(optional bool bNoMessage)
{
	Super.WECLevelUp(bNoMessage);

	switch(WECLevel)
	{
	case 1: // blinding projectile
    	break;
	case 2:	// projectile chains
		break;
	case 3:	// projectile explosion
		break;
	}
	FireMode[0].WECLevelUp(WECLevel);
}

simulated function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile pp;
	
	GoggleDimmer = 1.0;

	if(Role < ROLE_Authority)
		return None;

	//If the pulse of dynamic light is slower than the fire rate reset the timer
	if(LightIntensityTimer != 0)
		LightIntensityTimer = 0;

	//Turn on the weapon dynamic light (not if it is a bot though)
	if( Instigator.Controller.IsA('PlayerController') )
		bTurnedOnDynLight = true;
	
	if(FireMode[0].HoldTime >= PlayerPlasmaGunFire(FireMode[0]).ChargeTime) 
	{
        if(WECLevel >= 1)
        {
            // spawn plasma chain
            pp = Spawn(class'VehicleWeapons.PlayerPlasmaBall', self,, Start, Dir);
            PlayerPlasmaBall(pp).SetWECLevel(WECLevel);
		    FireMode[0].HoldTime = 0;
        }
	}
	else
	{
		// spawn a regular plasma shot
        pp = Spawn(FireMode[0].ProjectileClass, self,, Start, Dir);
	}

    if(pp != None)
    {
	    pp.ProjOwner = Instigator.Controller;
	    pp.Instigator = Instigator;
        pp.Damage = Ceil(pp.Damage*FireMode[0].DamageAtten);
    }

	return pp;
}

simulated function Tick(float dt)
{
    Super.Tick(dt);
    GoggleAlpha = FClamp(GoggleAlpha + dt * GoggleAlphaDir, 0.0, 0.6);
    GoggleDimmer = FClamp(GoggleDimmer - dt * 1.0, 0.0, 1.0);
}

simulated function bool PutDown()
{
	// jim: Removed.
    //class'DistortionPostFXStage'.static.GetDistortionPostFXStage( Level ).RemoveHudRef();
    GoggleAlphaDir = -8.0;
    AmbientSound = None;
	return Super.PutDown();	
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	// jim: Removed.
    //class'DistortionPostFXStage'.static.GetDistortionPostFXStage( Level ).AddHudRef();
    GoggleAlpha = 0;
    GoggleAlphaDir = 8.0;
    Super.BringUp( PrevWeapon );
}

simulated event RenderOverlaysPostFXStage( Canvas Canvas, Object Stage )
{
    local float overscan;
    local float halfScreenX;

	// jim: Removed.
	return;

    if(!Stage.IsA('DistortionPostFXStage'))
    {
        return;
    }
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	Canvas.DrawColor.A = 200;
	
	halfScreenX = Canvas.SizeX * 0.5;
    overscan = (Canvas.SizeY * 2 * (1 - GoggleAlpha));
    
	Canvas.SetPos(0, 0); // upper right
    Canvas.DrawTile( Texture'PariahWeaponEffectsTextures.Plasma.VisorDistort', Canvas.SizeX, Canvas.SizeY + (Canvas.SizeY * 0.1), 0, 0, 128, 128); // !! hardcoded size
}

simulated event RenderOverlays( Canvas Canvas )
{
    local float halfScreenX;
    local float overscan;
    local Color goggleColor;

    Super.RenderOverlays(Canvas);

	// jim: Removed.
	return;

    // apply fire calibration of goggles
    goggleColor.R = Lerp(GoggleDimmer, 150, 130);
    goggleColor.G = Lerp(GoggleDimmer, 180, 255);
    goggleColor.B = Lerp(GoggleDimmer, 150, 96);
    	
	// render some edge darkening
    Canvas.Style = ERenderStyle.STY_Modulated;
    Canvas.DrawColor.R = Lerp(GoggleAlpha, 127, goggleColor.R);
	Canvas.DrawColor.G = Lerp(GoggleAlpha, 127, goggleColor.G);
	Canvas.DrawColor.B = Lerp(GoggleAlpha, 127, goggleColor.B);
	Canvas.DrawColor.A = 255;
	
    halfScreenX = Canvas.SizeX * 0.5;
    
    overscan = (Canvas.SizeY * 2 * (1 - GoggleAlpha));

    // Corners    
    Canvas.SetPos(-overscan,-overscan); // upper left
    Canvas.DrawTile( Texture'PariahWeaponEffectsTextures.Plasma.Goggles', halfScreenX + overscan, Canvas.SizeY + overscan * 2, 0, 0, 128, 256); // !! hardcoded size

    Canvas.SetPos(Canvas.SizeX + overscan, -overscan); // upper right
    Canvas.DrawTile( Texture'PariahWeaponEffectsTextures.Plasma.Goggles', -halfScreenX - overscan, Canvas.SizeY + overscan * 2, 0, 0, 128, 256); // !! hardcoded size
}

simulated function bool FilterBlindness( Name BlindType )
{
    if( BlindType == 'Plasma' )
    {
        GoggleDimmer = 1.0;
        return(true);
    }
    else
    {
        return( Super.FilterBlindness( BlindType ) );
    }
}

simulated function SetupWecAttachments()
{
    Super.SetupWecAttachments();

    // clear skins to reenable plasma shader
    if(WECLevel == 1)
    {
        Skins.length = 0;
    }
}

simulated function bool CanReload()
{
    if(PlayerPlasmaGunFire(FireMode[0]).CoolOff > 0.0f)
        return false;
    return Super.CanReload();
}

defaultproperties
{
     GoggleAlphaDir=8.000000
     ReloadTime=4.000000
     ReloadAnim="Overheat"
     WeaponDynLightRelPos=(X=-5.000000,Y=-20.000000,Z=10.000000)
     WecAttachDescs(0)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.020000,WecRelativeLoc=(X=-43.000000,Y=-4.500000,Z=11.000000),WecRelativeRot=(Roll=-8192),AttachPoint="FX1")
     WecAttachDescs(1)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.020000,WecRelativeLoc=(X=-46.400002,Y=-4.500000,Z=11.000000),WecRelativeRot=(Roll=-8192),AttachPoint="FX1")
     WecAttachDescs(2)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.020000,WecRelativeLoc=(X=-50.000000,Y=-4.500000,Z=11.000000),WecRelativeRot=(Roll=-8192),AttachPoint="FX1")
     WeaponMessageClass=Class'VehicleWeapons.PlayerPlasmaGunMessage'
     BulletsStartingOffsetX=-15
     BulletsStartingOffsetY=20
     BulletsPerRow=20
     BulletSpaceDX=5
     BulletSpaceDY=12
     CrosshairIndex=2
     PutDownAnimRate=2.000000
     AIRating=0.400000
     CurrentRating=0.400000
     AutoAimFactor=1.000000
     DisplayFOV=45.000000
     AmmoClipTexture=Texture'PariahInterface.HUD.Assets'
     BulletTexture=Texture'PariahInterface.HUD.Assets'
     SelectSound=Sound'PariahWeaponSounds.hit.PR_Select'
     SelectAnim="Select"
     PutDownAnim="PutDown"
     FireModeClass(0)=Class'VehicleWeapons.PlayerPlasmaGunFire'
     BulletCoords=(X1=88,Y1=30,X2=90,Y2=39)
     EffectOffset=(X=65.000000)
     bCanThrow=False
     BobDamping=1.700000
     IconMaterial=Texture'PariahInterface.HUD.Assets'
     PickupClass=Class'VehicleWeapons.PlayerPlasmaGunPickup'
     AttachmentClass=Class'VehicleWeapons.PlayerPlasmaGunAttachment'
     PlayerViewOffset=(X=13.000000,Y=6.000000,Z=-2.000000)
     PlayerViewPivot=(Pitch=1000,Yaw=-1000)
     IconCoords=(Y1=128,X2=63,Y2=191)
     ItemName="Plasma Gun"
     InventoryGroup=2
     BarIndex=2
     bExtraDamping=True
     DrawScale=0.800000
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.LaserRail_1st'
}
