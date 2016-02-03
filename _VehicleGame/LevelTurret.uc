class LevelTurret extends VGVehicle
	native
	;//abstract;

//const	MaxFireLocations = 8;

/*
var () int					DefaultGunPitch;
var () vector				WeaponOffset;
var () rotator				WeaponRotation;
*/
var () int					MaxYaw;
var () int					MinYaw;
var () int					MaxPitch;
var () int					MinPitch;
var	() int					VehicleDamage;
var	() int					PersonDamage;


var () vector				CameraOffset;

var		LevelTurretBase		TurretBase;

//var () StaticMesh			WeaponStaticMesh;
//var () string				WeaponClassString;

//var int						NumFirePoints;
var rotator					DefaultRotation;
var int						AbsMaxYaw;
var int						AbsMinYaw;
var int						AbsMaxPitch;
var int						AbsMinPitch;

replication
{
	reliable if(Role == ROLE_Authority)
		DefaultRotation;
}

simulated function SetupVehicleWeapons()
{
	GiveWeapon(DefaultWeaponName);
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug( Canvas, YL, YPos );
	Weapon.DisplayDebug(Canvas,YL,YPos);

	Canvas.DrawText("Controller = "$Controller$" bFire = "$Controller.bFire$" bAltFire = "$Controller.bAltFire);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

simulated function SetupTurret()
{
	AbsMaxYaw = DefaultRotation.Yaw + MaxYaw;
	AbsMinYaw = DefaultRotation.Yaw + MinYaw;
	AbsMaxPitch = DefaultRotation.Pitch + MaxPitch;
	AbsMinPitch = DefaultRotation.Pitch + 65535 + MinPitch;
	//WeaponMountOffset[0] = TurretBase.WeaponOffset;
	//WeaponMountRotation[0] = TurretBase.WeaponRotation;
	if(Weapon == none)
		GiveWeapon(DefaultWeaponName);
	if(PersonDamage != 0)
		//VGWeaponFire(DefaultWeapon.FireMode[0]).PersonDamage = PersonDamage;
		VGWeaponFire(Weapon.FireMode[0]).PersonDamage = PersonDamage;
	if(VehicleDamage != 0)
		//VGWeaponFire(DefaultWeapon.FireMode[0]).VehicleDamage = VehicleDamage;
		VGWeaponFire(Weapon.FireMode[0]).VehicleDamage = VehicleDamage;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	DefaultRotation = Rotation;
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	AbsMaxYaw = DefaultRotation.Yaw + MaxYaw;
	AbsMinYaw = DefaultRotation.Yaw + MinYaw;
	AbsMaxPitch = DefaultRotation.Pitch + MaxPitch;
	AbsMinPitch = DefaultRotation.Pitch + 65535 + MinPitch;
}

//to make the turret work properly with the camera, I have the camera pumping the turret update.
//It seems a little hackish, but it's the best solution given what we have.  Problem was that the
//camera's position was being updated first, rather than last as it probably should be in this case.
//the camera would set it's position, then the turret would move, causing it to appear jittery when
//you moved it around.  With the camera code triggering the turret update, they are synched. 

//function UpdateTurret(float Delta)
/*
simulated function Tick(float Delta)
{
	local Controller C;
	local rotator BaseRot, GunRot, newRot, Rot;

	if( IsDead() )
		return;

	// check if need to enter delaying death state
	// - for remote clients
	if ( bDelayingDeath && !IsInState('DelayingDeath') && !IsInState('VehicleDying') )
	{
		GotoState('DelayingDeath');
	}
	if ( bIsDriven ^^ bWasDriven )
	{
		if ( bIsDriven )
		{
			DriverEntered();
		}
		else
		{
			DriverExited();
		}
		bWasDriven = bIsDriven;
	}

	if ( bIsDriven )
	{
		C = Controller;
		if ( C != None )
		{
			Rot = C.Rotation;

			newRot=Rot;
			BaseRot=rot(0,0,0);
			GunRot=rot(0,0,0);

			BaseRot.Yaw=Clamp(Rot.Yaw, AbsMinYaw, AbsMaxYaw);
			SetRotation(BaseRot);

			//newR.Pitch=Clamp(R.Pitch, AbsMinPitch, AbsMaxPitch);
			//This is so ASS!!! why oh why do I have to do this shit?!?!
			if(Rot.Pitch > 32768)
			{
				if(Rot.Pitch > AbsMinPitch)
					GunRot.Pitch = Rot.Pitch;
				else
					GunRot.Pitch = AbsMinPitch;
			}
			else
			{
				if(Rot.Pitch < AbsMaxPitch)
					GunRot.Pitch = Rot.Pitch;
				else
					GunRot.Pitch = AbsMaxPitch;
			}
			if(WeaponMount[0] != none)
				WeaponMount[0].SetRelativeRotation(GunRot);

			newRot.Yaw = BaseRot.Yaw;
			newRot.Pitch = GunRot.Pitch;
			C.SetRotation(newRot);
		}
	}
}
*/
/*
simulated function DriverEntered()
{
	Super.DriverEntered();
	if ( Controller != None )
	{
		Controller.SetRotation(WeaponMount[0].Rotation);
	}
}
*/

defaultproperties
{
     MaxYaw=16384
     MinYaw=-16384
     maxPitch=16384
     MinPitch=-16384
     CameraOffset=(X=-75.000000,Z=75.000000)
     WeaponMounts=1
     ExitPos(0)=(X=-150.000000,Y=0.000000)
     ExitPos(1)=(Y=150.000000)
     ExitPos(2)=(X=0.000000,Y=-150.000000)
     ExitPos(3)=(X=150.000000)
     DrivePos=(X=-50.000000,Z=50.000000)
     DefaultWeaponName="VehicleWeapons.BogieLauncher"
     HideDriver=True
     bEnableHeadLightEmitter=False
     bNeedsPlayerOwner=False
     LandMovementState="PlayerInTurret"
     WaterMovementState="PlayerInTurret"
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bDisableKarmaEncroacher=True
}
