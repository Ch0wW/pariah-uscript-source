//=============================================================================
//=============================================================================
class VGRocketLauncher extends PersonalWeapon;

var Actor LockedTargets[4];
var int   RocketsToFire;
var int   NumLocked;

var() float RocketSpread;
var() Sound LockOnSound;
var() float LockPosX, LockPosY;

replication
{
    reliable if (Role == ROLE_Authority && bNetOwner)
        LockedTargets, NumLocked;
}

simulated function Actor GetSeekTarget(int index)
{
    return(LockedTargets[index]);
}

simulated function Vector GetSeekPosition()
{
    return(vect(0,0,0));
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function AddLockOn(Actor Other)
{
    local float BeepPitch;
    BeepPitch = 0.2 + float(NumLocked + 1) * 0.2;
    
    PlayOwnedSound(LockOnSound, SLOT_Interact, 1.0,,,BeepPitch, false);
    LockedTargets[NumLocked++] = Other;
}

function bool ShouldCheckLockOn()
{
	switch(WECLevel)
	{
	case 0:
	        return(false);
	case 1:
	        return(NumLocked < 1);
	case 2:
	        return(NumLocked < 2);
	case 3:
	        return(NumLocked < 4);
	}
}

simulated function DrawCurrentLockStatus( Canvas C, int CurLocks )
{
    local int i, TCScale, TWScale, TOffsetX, TOffsetY;
    local float ScreenPosX, ScreenPosY;
    local int MaxLocks;
    
    MaxLocks = 1 << (WECLevel - 1);

    C.Style = ERenderStyle.STY_Alpha;
    C.SetDrawColor( 255, 255, 255, 255);
    
    ScreenPosX = C.SizeX*LockPosX;
    ScreenPosY = C.SizeY*LockPosY;

    TWScale = 16;
    TCScale = 16;
    TOffsetX = 5;
    TOffsetY = 40;

    for( i=0; i<MaxLocks; ++i )
    {  
        C.SetPos( ScreenPosX -((TWScale+ TOffsetX)*i), ScreenPosY );   
    
        if( i < CurLocks )
            C.DrawTile( Material'PariahInterface.HUD.Assets', TWScale, TWScale, 154, 0, TCScale, TCScale);
        else    
            C.DrawTile( Material'PariahInterface.HUD.Assets', TWScale, TWScale, 154, 16, TCScale, TCScale);

        
    }
}
simulated event RenderOverlays( Canvas C )
{
    Super.RenderOverlays(C);
    

    if( WECLevel > 0 )
        DrawCurrentLockStatus( C, NumLocked );

}

simulated function bool HasLocks()
{
    return(NumLocked > 0);
}

simulated function WECLevelUp(optional bool bNoMessage)
{
	Super.WECLevelUp(bNoMessage);

    // - Lock on
    // - Dual warheads
    // - Quad warheads

	switch(WECLevel)
	{
	case 1:
	        // lock/seeking - handled in fire mode
			break;
	case 2:
	        // dual warheads - handled in fire mode
	        RocketsToFire = 2;
			break;
	case 3:
	        // quad warheads - handled in fire mode
	        RocketsToFire = 4;
			break;
	}
}

function bool CanLockOnTo(Actor Other)
{
    local int i;
    local Pawn P;
    
    for(i = 0; i < NumLocked; ++i)
    {
        if(LockedTargets[i] == Other)
        {
            return(false);
        }
    }
    
    P = Pawn(Other);
    
    if (P == None || P == Instigator || !P.bProjTarget || P.Health <= 0)
		// can't lock on if target is self or it's not a valid projectile target
        return false;

    if (!Level.Game.bTeamGame && !P.Controller.SameTeamAs(Instigator.Controller) )
		// not a team game and not a friendly bot so we can lock on
        return true;

    return (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team);
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local RedRocket Rocket;
	local Bot B;
	local Vector PuffOffset;
	local int TargetIndex;
	local int i;

	if(Level.NetMode == NM_Client)
		return none;
				
    PuffOffset = vect(0,20,20) >> Instigator.Controller.Rotation;

	// decide if bot should be locked on
	B = Bot(Instigator.Controller);
	if ( (B != None) && (B.Skill > 2 + 5 * FRand()) && (FRand() < 0.6)
		&& (B.Target == B.Enemy) && (VSize(B.Enemy.Location - B.Pawn.Location) > 2000 + 2000 * FRand()) 
		&& (Level.TimeSeconds - B.LastSeenTime < 0.4) && (Level.TimeSeconds - B.AcquireTime > 1.5) )
	{
		LockedTargets[0] = B.Enemy;
	}
	
	RocketsToFire = Max(1, NumLocked);
	
	for(i = 0; i < RocketsToFire; ++i)
	{
	    if(WecLevel == 0)
	    {
            Rocket = Spawn(class'RedRocket',,, Start, Dir);
        }
        else
        {
            Dir.Yaw += RocketSpread * (FRand() - 0.5);
            Dir.Pitch += RocketSpread * (FRand() - 0.5);
            Rocket = Spawn(class'SeekingRedRocket',,, Start, Dir);
        }
		if ( Rocket != None )
		{
			Rocket.ProjOwner = Instigator.Controller;
			Rocket.Instigator = Instigator;
	        
			if(WecLevel > 0 && NumLocked > 0)
			{
				TargetIndex = i; // int(float(NumLocked) * (float(i) / float(RocketsToFire))); // spread out the rockets among locked
				SeekingRedRocket(Rocket).Seeking = LockedTargets[TargetIndex];
			}
		}
	}
	
	for(i = 0; i < ArrayCount(LockedTargets); ++i)
	{
	    LockedTargets[i] = None;
	}
	NumLocked = 0;

	if(Instigator.Controller.IsA('PlayerController') )
	{
		bTurnedOnDynLight = true;
    }
    
	return Rocket;
}

simulated function PlayIdle()
{
	switch(Ammo[0].AmmoAmount) 
	{
		default:
		    LoopAnim(IdleAnim, IdleAnimRate, 0.2);
			break;
	}
}

simulated function LowerWeapon()
{
    local int Mode;

	if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
	{
        if (Instigator.IsLocallyControlled())
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if (FireMode[Mode] != none && FireMode[Mode].bIsFiring)
                    ClientStopFire(Mode);
            }

            if (ClientState != WS_BringUp && HasAnim(PutDownAnim))
                PlayPutDown();
        }
        ClientState = WS_Lowered;
	}
}

simulated function bool PutDown()
{
    ClientStopFire(0);
	if( Super.PutDown() )
	{
		PlayPutDown();
		return true;
	}
	return false;
}

simulated function PlayPutDown()
{
	switch(Ammo[0].AmmoAmount) 
	{
		default:
            PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
			break;
	}
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	SetupWeaponDynLight();

    if (ClientState == WS_Hidden)
    {
		if(PrevWeapon != none)
		{
			PlayOwnedSound(SelectSound, SLOT_Interact, 0.5,,,, false);

			if (Instigator.IsLocallyControlled())
			{
				if (HasAnim(SelectAnim))
					PlaySelect();
			}
		}
        ClientState = WS_BringUp;
        SetTimer(0.3, false);
    }
    Super.BringUp(PrevWeapon);
}

simulated function PlaySelect()
{
    PlayAnim(SelectAnim, SelectAnimRate, 0.0);
}

simulated function StopFireEffects()
{
}

defaultproperties
{
     RocketsToFire=1
     RocketSpread=850.000000
     LockPosX=0.750000
     LockPosY=0.105000
     LockOnSound=Sound'PariahGameSounds.Camera.DetectionBeepA'
     ReloadTime=3.000000
     WeaponDynLightRelPos=(X=50.000000,Y=-25.000000,Z=20.000000)
     WecAttachDescs(0)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.040000,WecRelativeLoc=(X=4.000000,Y=19.000000,Z=-3.000000),WecRelativeRot=(Roll=-32768),AttachPoint="Tip")
     WecAttachDescs(1)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.040000,WecRelativeLoc=(X=-2.000000,Y=19.000000,Z=-3.000000),WecRelativeRot=(Roll=-32768),AttachPoint="Tip")
     WecAttachDescs(2)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.040000,WecRelativeLoc=(X=-8.000000,Y=19.000000,Z=-3.000000),WecRelativeRot=(Roll=-32768),AttachPoint="Tip")
     WeaponMessageClass=Class'VehicleWeapons.VGRocketLauncherMessage'
     BulletsStartingOffsetX=-10
     BulletsStartingOffsetY=10
     BulletsPerRow=1
     BulletSpaceDX=2
     BulletSpaceDY=18
     CrosshairIndex=3
     PutDownAnimRate=2.000000
     AIRating=0.400000
     CurrentRating=0.400000
     DisplayFOV=60.000000
     TurnMax=450.000000
     TurnSpeedFactor=1.000000
     MoveMax=1.500000
     MoveSpeedFactor=2.000000
     MoveUpMax=1.500000
     AmmoClipTexture=Texture'PariahInterface.HUD.Assets'
     BulletTexture=Texture'PariahInterface.HUD.Assets'
     SelectSound=Sound'PariahWeaponSounds.RL_Select'
     SelectAnim="Select"
     PutDownAnim="PutDown"
     FireModeClass(0)=Class'VehicleWeapons.VGRocketLauncherFire'
     BulletCoords=(Y1=74,X2=88,Y2=89)
     EffectOffset=(X=30.000000,Y=10.000000,Z=-10.000000)
     bCanThrow=False
     BobDamping=1.800000
     IconMaterial=Texture'PariahInterface.HUD.Assets'
     PickupClass=Class'VehicleWeapons.VGRocketLauncherPickup'
     AttachmentClass=Class'VehicleWeapons.VGRocketLauncherAttachment'
     PlayerViewOffset=(X=20.000000,Y=7.000000,Z=-2.000000)
     IconCoords=(X1=384,Y1=128,X2=447,Y2=191)
     ItemName="Rocket Launcher"
     InventoryGroup=4
     BarIndex=5
     bExtraDamping=True
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.RocketLauncher_1st'
}
