//=============================================================================
// SniperRifle.uc
//=============================================================================
class SniperRifle extends PersonalWeapon;

#exec OBJ LOAD FILE="PariahEffectsTextures.utx"

var bool            bInfraBurst;
var vector          LastHitLocation;
var Vector Start, BeamStart;
var Rotator Dir, BeamDir;
var Material        ZoomScope;

var transient WarpPostFXStage LensPostFX;

var SniperLight DeathDot;

var bool bGiveClip;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientStopFiring, LastHitLocation, BeamStart, BeamDir, DeathDot;
}

simulated function MakeRefToHeatMaterial() // required to save these from cutdown procedures
{
    local Material m;
    m = Material'PariahEffectsTextures.vision.visionSkelMat';
	m = Material'PariahEffectsTextures.vision.heatmaterial';
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if(Role == ROLE_Authority)
    {
        DeathDot = Spawn(class'VehicleEffects.SniperLight',,,Location,Rotator(vect(1,0,0)));
        DeathDot.SetEnabled(true);
    }
}

simulated function Destroyed()
{
    // null these so garbage collection will get them
    LensPostFX = None;
    if(Role == ROLE_Authority && DeathDot != None)
    {
        DeathDot.Destroy();
    }

    // hi. controller is none here. pawn has been unpossessed and torn off.
    UpdateEnhancedVision(false);
    
    Super.Destroyed();
}

// zoom stuff
simulated function SetZoomBlendColor(Canvas c)
{
    local Byte    val;
    local Color   clr;
    local Color   fog;

    clr.R = 255;
    clr.G = 255;
    clr.B = 255;
    clr.A = 255;

    if( Instigator.Region.Zone.bDistanceFog )
    {
        fog = Instigator.Region.Zone.DistanceFogColor;
        val = 0;
        val = Max( val, fog.R);
        val = Max( val, fog.G);
        val = Max( val, fog.B);

        if( val > 128 )
        {
            val -= 128;
            clr.R -= val;
            clr.G -= val;
            clr.B -= val;
        }
    }
    c.DrawColor = clr;
}

simulated event RenderOverlays( Canvas Canvas )
{
    local PlayerController PC;
    
    PC = PlayerController(Instigator.Controller);
    
    if (!PC.bZoomed || IsInState('Reload') )
    {
        Super.RenderOverlays(Canvas);
        UpdateEnhancedVision(false);
        if(LensPostFX != None)
        {
            //PC.RemovePostFXStage( LensPostFX );
        }
        return;
    }
    else
    {
        if( WECLevel >= 1 && (PC.bZoomed != PC.bEnhancedVisionIsOn) )
        {
            UpdateEnhancedVision( PC.bZoomed );
        }
        else if( !IsOnConsole() )
        {
            //AddLensWarp(PC);
        }
    }
}

// Update the enhanced vision (ms)
// Note: Only call when its state should change
simulated function UpdateEnhancedVision( bool bTurnOn )
{
    local PlayerController PC;
    
    if(!Instigator.IsLocallyControlled())
    {
        return;
    }

    PC = PlayerController(Instigator.Controller);
    if(PC != None)
    {
        PC.bEnhancedVisionIsOn = bTurnOn;
    }
}

simulated function bool HasLensWarp(PlayerController PC)
{
    if(PC.FindPostFXStage(class'WarpPostFXStage') != None)
    {
        return true;
    }
    return false;
}

simulated function AddLensWarp(PlayerController PC)
{
    if(HasLensWarp(PC))
    {
        return;
    }
    if( LensPostFX == None && PC.IsA('VehiclePlayer'))
    {
        LensPostFX = WarpPostFXStage( VehiclePlayer(PC).GetSniperPostFX( class'WarpPostFXStage' ) );
    }
    LensPostFX.bRestart = true;
    LensPostFX.WarpType = 0;
    LensPostFX.SpherizeType = 0;
    LensPostFX.SpherizeAmplitude = 0.5;
    PC.AddPostFXStage( LensPostFX );
}
    
simulated event ClientStartFire(int mode)
{
    local PlayerController PC;
    Super.ClientStartFire(mode);

    PC = PlayerController(Instigator.Controller);
    
    //If the wec level is above 1 and the state of it changed, update the enhanced vision
    if( WECLevel >= 1 && (PC.bZoomed != PC.bEnhancedVisionIsOn) )
    {
        UpdateEnhancedVision( PC.bZoomed );
    }
    
    if(Instigator.Controller.IsA('PlayerController'))
    {
        if(PlayerController(Instigator.Controller).bZoomed)
        {
            SniperRifleFire(FireMode[0]).SetZoomParameters();
        }
    }
}


simulated event ClientStopFire(int mode)
{
    Super.ClientStopFire(mode); 
    if(Instigator.Controller.IsA('PlayerController'))
    {
        if (FireMode[mode].IsA('ZoomFire') && PlayerController(Instigator.Controller).bZoomed)
        {
            StopOwnedSound(sndZoomIn);   // mjm - cut the zoom-in sound off when the user lifts his finger
        }
        SniperRifleFire(FireMode[0]).SetNormalParameters();
    }
}

simulated function bool PutDown()
{
    if(Instigator.Controller.IsA('PlayerController') && PlayerController(Instigator.Controller).bZoomed)
    {
//        if(LensPostFX != none)
//            PlayerController(Instigator.Controller).RemovePostFXStage(LensPostFX);
        SniperRifleFire(FireMode[0]).SetNormalParameters();
        EffectOffset = default.EffectOffset;
    }

    if( WECLevel >= 1 )
        UpdateEnhancedVision( false );

    //if(DeathDot != None)
    //{
    //    DeathDot.Destroy();
    //}
    return Super.PutDown();
}


simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp( PrevWeapon );
    
    //DeathDot = Spawn(class'VehicleEffects.SniperLight',,,Location,Rotator(vect(1,0,0)));
    //DeathDot.SetDrawScale(0.0);
}

simulated function bool StartFire(int Mode)
{
    if(Super.StartFire(Mode))
    {
        if(Instigator.Controller.IsA('PlayerController') && PlayerController(Instigator.Controller).bZoomed)
        {
            DisableAutoAim();
            EffectOffset = vect(0.0,-5.0,-20.0);
            SniperRifleFire(FireMode[0]).SetZoomParameters();
        }
        else
        {
            EnableAutoAim();
            EffectOffset = default.EffectOffset;
            SniperRifleFire(FireMode[0]).SetNormalParameters();
        }
        FireMode[mode].StartFiring();
        return true;
    }
    return false;
}


simulated function IncrementFlashCount(int Mode)
{
    if ( WeaponAttachment(ThirdPersonActor) != None )
    {
        WeaponAttachment(ThirdPersonActor).FiringMode = Mode;
        if(Mode == 0 && FireMode[0] != none ) {
            // don't do the effect when zooming
            WeaponAttachment(ThirdPersonActor).FlashCount++;
            SniperRifleAttachment(ThirdPersonActor).LastHitLocation = LastHitLocation;
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
        if(FireMode[0] != none && Mode == 0) {
            WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
        }
    }
}

simulated function WECLevelUp(optional bool bNoMessage)
{   
    Super.WECLevelUp(bNoMessage);

    switch(WECLevel)
    {
    case 1: 
        // enhanced vision
        ZoomFactor = 4.0;
        SniperRifleFire(FireMode[0]).SetNormalParameters();
        if(LensPostFX != none)
        {
            //PlayerController(Instigator.Controller).RemovePostFXStage(LensPostFX);
        }
        if(PlayerController(Instigator.Controller).bZoomed)
        {
            UpdateEnhancedVision( true );
        }
        break;
    case 2:
        // extra clip
        // handled in tick (hooray) because Ammo might not be replicated at this time
        bGiveClip = true;
        break;
    case 3:
        // armor piercing in fire mode
        break;
    }
    FireMode[0].WECLevelUp(WECLevel);
}

simulated function ClientStopFiring()
{
    SniperRifleFire(FireMode[0]).StopFiring();
    bTurnedOnDynLight = false;  
}

simulated function ClientTracerFire(vector HitLocation)
{
    if(!SniperRifleFire(FireMode[0]).bZoomed) 
    {
        if(ThirdPersonActor != none)
            SniperRifleAttachment(ThirdPersonActor).ThirdPersonTracer(HitLocation);
    }
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

    // ...because AnimEnd will play the FireEndAnim which we only want to play if there's actually any ammo left
    if(Ammo[0].HasAmmo() )
        Super.AnimEnd(channel);
    else
        PlayIdle();
}

simulated function MarkSpot()
{
    local vector HitLocation, HitNormal, X, Y, Z, projStart;
    local actor HitActor;
    local Rotator aim;
    
    if(Instigator.Controller == None || VGPawn(Instigator).RiddenVehicle != None || VGPawn(Instigator).DrivenVehicle != None)
    {
        DeathDot.SetEnabled(false);
        return;
    }

    aim = Instigator.Controller.Rotation;
    // blind for a quick sec??
    if(Instigator.Controller.IsA('PlayerController'))
    {
        aim.Pitch += PlayerController(Instigator.Controller).Vertical_cam_spring.spring_pos.X * 50;
	    aim.Yaw += PlayerController(Instigator.Controller).Vertical_cam_spring.spring_pos.Y * 50;
    }
		
    GetAxes(aim, X,Y,Z);
    projStart = GetFireStart(X,Y,Z);
    HitActor = Trace(HitLocation, HitNormal, projStart + X * 25000, projStart, true);
    if(HitActor != None)
    {   
        DeathDot.SetLocation(HitLocation - (X * 4.0));
        DeathDot.SetEnabled(true);
    }
    else
    {
        DeathDot.SetEnabled(false);
    }
}

simulated function Tick(float dt)
{
    local PlayerController PC;
    Super.Tick(dt);

	if ( Instigator != None )
	{
		if(Instigator.Weapon == Self && DeathDot != None)
		{
			MarkSpot();
		}

		if(Instigator.IsLocallyControlled())
		{
			if(Instigator.Weapon != Self)
			{
				//log("TICK KILL "@Instigator);
				UpdateEnhancedVision(false);
			}
		}
	
		if(Role == ROLE_Authority && Instigator.Weapon != Self)
		{
			DeathDot.SetEnabled(false);
		}

		PC = PlayerController(Instigator.Controller);
	}

    if (FireMode[1].IsA('ZoomFire') && (PC != None) && PC.bZoomed && (PC.DesiredFOV == PC.FOVAngle) )
    {
        StopOwnedSound(sndZoomIn);   // mjm - cut the sound off when we stop zooming
    }

    if(bGiveClip && Ammo[0] != None)
    {
        bGiveClip = false;
        AmmoClip(Ammo[0]).MagAmount = 6;
        AmmoClip(Ammo[0]).MaxAmmo = 18;
        AmmoClip(Ammo[0]).CompletedReload();
    }
}

simulated function HolderDied()
{
    Super.HolderDied();
    UpdateEnhancedVision( false );
    if(Instigator.Controller.IsA('PlayerController') && PlayerController(Instigator.Controller).bZoomed)
    {
        if(LensPostFX != none) {
            //PlayerController(Instigator.Controller).RemovePostFXStage(LensPostFX);
        }
        SniperRifleFire(FireMode[0]).SetNormalParameters();
        EffectOffset = default.EffectOffset;
    }
}

simulated function EMPHit(bool bEnhanced)
{
}

simulated function SwitchFireMode()
{
}

simulated function StopFireEffects()
{
}

defaultproperties
{
     ReloadTime=3.750000
     sndZoomIn=Sound'PariahWeaponSounds.hit.SniperRifleZoomIn'
     ReloadAnim="Reload01"
     WeaponDynLightRelPos=(X=-30.000000,Y=-20.000000,Z=10.000000)
     WecAttachDescs(0)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.025000,WecRelativeLoc=(X=-75.000000,Y=-4.000000,Z=11.500000),WecRelativeRot=(Roll=-16384),AttachPoint="FX1")
     WecAttachDescs(1)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.025000,WecRelativeLoc=(X=-79.500000,Y=-4.000000,Z=11.500000),WecRelativeRot=(Roll=-16384),AttachPoint="FX1")
     WecAttachDescs(2)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.025000,WecRelativeLoc=(X=-84.000000,Y=-4.000000,Z=11.500000),WecRelativeRot=(Roll=-16384),AttachPoint="FX1")
     WeaponMessageClass=Class'VehicleWeapons.SniperRifleMessage'
     BulletsStartingOffsetX=-30
     BulletsStartingOffsetY=24
     BulletsPerRow=2
     BulletSpaceDX=75
     BulletSpaceDY=15
     CrosshairIndex=-1
     SelectAnimRate=1.000000
     PutDownAnimRate=2.000000
     BulletsScale=0.700000
     AIRating=0.400000
     CurrentRating=0.400000
     AutoAimFactor=0.500000
     AutoAimRangeFactor=0.600000
     ZoomFactor=2.500000
     DisplayFOV=60.000000
     AmmoClipTexture=Texture'PariahInterface.HUD.Assets'
     BulletTexture=Texture'PariahInterface.HUD.Assets'
     SelectSound=Sound'PariahWeaponSounds.AR_Select'
     IdleAnim="Breathe"
     FireModeClass(0)=Class'VehicleWeapons.SniperRifleFire'
     BulletCoords=(X1=98,Y1=32,X2=169,Y2=43)
     EffectOffset=(X=96.000000,Y=10.000000,Z=25.000000)
     bCanThrow=False
     BobDamping=1.700000
     IconMaterial=Texture'PariahInterface.HUD.Assets'
     PickupClass=Class'VehicleWeapons.SniperRiflePickup'
     AttachmentClass=Class'VehicleWeapons.SniperRifleAttachment'
     PlayerViewOffset=(X=14.000000,Y=7.000000,Z=-22.500000)
     PlayerViewPivot=(Pitch=375,Yaw=-400)
     IconCoords=(X1=256,Y1=128,X2=319,Y2=191)
     ItemName="Sniper Rifle"
     InventoryGroup=8
     BarIndex=1
     bExtraDamping=True
     SoundRadius=400.000000
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.SniperRifle'
     bReplicateInstigator=True
}
