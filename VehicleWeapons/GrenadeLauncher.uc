class GrenadeLauncher extends PersonalWeapon;

var GrenadeDetonator Detonator;
var bool bUsingDetonator;
var array<GrenadeProjectile> CurrentGrenades;
var int NumLiveGrenades; // server sets, client reads. to see if detonator or launcher should be switched to

replication
{
	reliable if(Role == ROLE_Authority)
		Detonator, NumLiveGrenades;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
}

simulated function bool CanReload()
{
    return(false);
}

simulated function Tick(float dt)
{
	local int n;

    Super.Tick(dt);

    // update number of live grenades
    if(Role == ROLE_Authority)
    {
        NumLiveGrenades = 0;
	    for(n = 0; n < CurrentGrenades.Length; n++) 
	    {
		    if(CurrentGrenades[n] != none) 
		    {
			    NumLiveGrenades++;
		    }
	    }
	    if(NumLiveGrenades == 0)
	    {
	        CurrentGrenades.Remove(0, CurrentGrenades.Length);
	    }
    }

    if(Instigator != None && Instigator.Weapon == self && Instigator.IsLocallyControlled() && !FireMode[0].bIsFiring)
    {
    	CheckDetonator();
    }
}

// moved this here from the grenadelauncherfire class to support new grenade launcher behaviour... it also conveniently
// seems to solve a replication issue with the Detonator/launcher interaction which is a plus
function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;
	local GrenadeProjectile gp;//, gpTemp;
	local class<Projectile> ProjectileClass;

	if(Level.NetMode == NM_Client)
		return none;

	switch(WecLevel) 
	{
		case 0:
			ProjectileClass = class'VehicleWeapons.GrenadeProjectile';
			break;
		case 1:
		    ProjectileClass = class'VehicleWeapons.DetonatedGrenadeProjectile';
			break;
		case 2:
			ProjectileClass = class'VehicleWeapons.GrenadeMag';
			break;
		case 3:
			ProjectileClass = class'VehicleWeapons.GrenadeSticky';
			break;
	}
	
	if(ProjectileClass != None)
	{
	    p = Spawn(ProjectileClass,,, Start, Dir);
    }

    if( p == None )
        return None;

	p.ProjOwner = Instigator.Controller;
    p.Damage = Ceil(p.Damage * FireMode[0].DamageAtten);
	p.Instigator = Instigator;

	gp = GrenadeProjectile(p);

	CurrentGrenades[CurrentGrenades.Length] = gp;

	//Turn on the weapon dynamic light (not if it is a bot though)
	if(Instigator.Controller.IsA('PlayerController') )
		bTurnedOnDynLight = true;

    return p;
}

simulated function CheckDetonator()
{
    if(HasLiveGrenades() && WecLevel > 0) 
	{
		if(Instigator.Controller.IsA('PlayerController'))
		{
			PlayerController(Instigator.Controller).SwitchWeapon(20);
			bUsingDetonator = true;
        }
		return;
	}

	if(Role == ROLE_Authority && Detonator == none && Instigator != none) 
	{
		// make sure the player also has the Detonator!
		Instigator.GiveWeapon("VehicleWeapons.GrenadeDetonator");
		Detonator = GrenadeDetonator(Instigator.FindInventoryType(class'VehicleWeapons.GrenadeDetonator') );
		if(Detonator != none) 
		{
			Detonator.launcher = self;
		}
	}
}

simulated function RaiseWeapon()
{
	Super.RaiseWeapon();
	CheckDetonator();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);
	CheckDetonator();
}

simulated function WECLevelUp(optional bool bNoMessage)
{
	Super.WECLevelUp(bNoMessage);

    //-Remote Detonator (As it is now)
    //-Fragment Attractor (Pulls metal from ground to increase damage, longer grenade lasts, more damage)
    //-Enemy Grapple (Sticks to enemy, so original, combined with above might be very dope)

	switch( WECLevel )
	{
		case 1:
		    // handled in SwitchToDetonator
		    Ammo[0].MaxAmmo = Ammo[0].default.MaxAmmo + 2;
			break;
		case 2:
		    // handled in SpawnProjectile
		    Ammo[0].MaxAmmo = Ammo[0].default.MaxAmmo + 4;
			break;
		case 3:
		    // handled in SpawnProjectile
		    Ammo[0].MaxAmmo = Ammo[0].default.MaxAmmo + 6;
			break;
	}
}

function ConsumeAmmo(int Mode, float load)
{
    if (Ammo[Mode] != None)
        Ammo[Mode].UseAmmo(int(load));
}

simulated function PlayFiring()
{
	GotoState('DasReload');
}

simulated state DasReload
{
Begin:
	Sleep(0.25);
	GotoState('');
}

simulated function SwitchToDetonator()
{
    if(WECLevel < 1)
    {
        return;
    }
	if(Instigator.Controller.IsA('PlayerController') )
	{
		PlayerController(Instigator.Controller).SwitchWeapon(20);
    }
	bUsingDetonator = true;
}

function DetonateGrenades()
{
	local int n;
    local GrenadeProjectile G;

	for(n = 0; n < CurrentGrenades.Length; n++) 
	{
        G = CurrentGrenades[n];
		// make sure that we're only exploding grenades that belong to us
		if(G != none && G.Instigator == Owner) 
		{
			G.BlowUp(G.Location);
	        G.Explode(G.Location,Vect(0,0,1) );
		}
	}

	CurrentGrenades.Remove(0, CurrentGrenades.Length);
}

simulated function bool HasLiveGrenades()
{
    return(NumLiveGrenades > 0);
}

simulated function CheckRevert()
{
    // called every tick from detonator
	if(!bUsingDetonator)
		return;

    if(NumLiveGrenades > 0)
        return;

	if(Instigator.Controller.IsA('PlayerController') )
	{
		PlayerController(Instigator.Controller).SwitchWeapon(7);
    }

	if(Pawn(Owner).Weapon != self && Instigator.IsLocallyControlled() )
	{
		DoAutoSwitch();
    }

	bUsingDetonator = false;
}

function bool CanAttack(Actor Other)
{
    local float ThetaLow;
	local float ThetaHigh; 
	local float InterceptTimeLow;
	local float InterceptTimeHigh; 
    
	local int NumSolutions;
	local float LeapSpeed;
	
	local vector X,Y,Z, startLocation, targetLocation;
    
    GetAxes(Instigator.Controller.Rotation, X,Y,Z);
    startLocation = GetFireStart(X,Y,Z);
    targetLocation = Other.Location;
    
    LeapSpeed = 1.1*FireMode[0].ProjectileClass.default.speed;

    if(class'TrajectoryCalculator'.static.GetMaxRange( Instigator,class'Pawn', LeapSpeed ) < VSize(targetLocation - startLocation) )
    {
        //log("TOOFAR");
        return false;
    }

	NumSolutions = class'TrajectoryCalculator'.static.GetInverseTrajectory(
			Instigator,
			class'Pawn',
			LeapSpeed, 
			StartLocation, 
			TargetLocation, 
			ThetaLow, 
			ThetaHigh, 
			InterceptTimeLow, 
			InterceptTimeHigh );

	
    if( InterceptTimeLow > class<GrenadeProjectile>(FireMode[0].ProjectileClass).default.explodeTime )
        return false;

    return class'TrajectoryCalculator'.static.VerifyTrajectory( 
			Instigator, 
			class'Pawn', 
			LeapSpeed, 
			StartLocation, 
			TargetLocation, 
			Other, 
			ThetaLow
			);
}

simulated function Destroyed()
{
	if(Detonator != none)
		Detonator.Destroy();
	Detonator = none;
	Super.Destroyed();
}

defaultproperties
{
     ReloadSound=Sound'PariahWeaponSounds.hit.GL_Overheat3'
     WeaponDynLightRelPos=(X=25.000000,Y=-20.000000)
     WecAttachDescs(0)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.012000,WecRelativeLoc=(X=-1.900000,Y=-1.200000,Z=2.300000),WecRelativeRot=(Pitch=8192),AttachPoint="Boot")
     WecAttachDescs(1)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.012000,WecRelativeLoc=(X=-1.900000,Z=2.300000),WecRelativeRot=(Pitch=8192),AttachPoint="Boot")
     WecAttachDescs(2)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.012000,WecRelativeLoc=(X=-1.900000,Y=1.200000,Z=2.300000),WecRelativeRot=(Pitch=8192),AttachPoint="Boot")
     WeaponMessageClass=Class'VehicleWeapons.GrenadeLauncherMessage'
     BulletsStartingOffsetX=30
     BulletsPerRow=1
     BulletSpaceDX=50
     BulletSpaceDY=30
     CrosshairIndex=1
     PutDownAnimRate=4.000000
     AIRating=0.400000
     CurrentRating=0.400000
     DisplayFOV=52.000000
     AmmoClipTexture=Texture'PariahInterface.HUD.Assets'
     BulletTexture=Texture'PariahInterface.HUD.Assets'
     SelectSound=Sound'PariahWeaponSounds.GL_Select'
     SelectAnim="Select"
     PutDownAnim="PutDown"
     FireModeClass(0)=Class'VehicleWeapons.GrenadeLauncherFire'
     BulletCoords=(X1=92,Y1=47,X2=168,Y2=75)
     EffectOffset=(X=15.000000,Y=6.700000,Z=1.200000)
     bCanThrow=False
     BobDamping=1.650000
     IconMaterial=Texture'PariahInterface.HUD.Assets'
     PickupClass=Class'VehicleWeapons.GrenadeLauncherPickup'
     AttachmentClass=Class'VehicleWeapons.GrenadeLauncherAttachment'
     PlayerViewOffset=(X=6.000000,Y=4.700000,Z=3.000000)
     PlayerViewPivot=(Pitch=200,Yaw=-500)
     IconCoords=(X1=448,Y1=128,X2=511,Y2=191)
     ItemName="Grenade Launcher"
     InventoryGroup=7
     BarIndex=6
     bExtraDamping=True
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.GrenadeLauncher_1st'
}
