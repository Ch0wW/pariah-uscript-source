class LevelTurretBase extends Actor
	placeable;

var			LevelTurret				Turret;
var	()		class<LevelTurret>		TurretClass;
/*
var () int					MaxYaw;
var () int					MinYaw;
var () int					MaxPitch;
var () int					MinPitch;
var	() int					VehicleDamage;
var	() int					PersonDamage;
*/
var () vector				WeaponOffset;
var () rotator				WeaponRotation;


function SpawnTurret()
{
	if(TurretClass != none)
	{
		Turret = Spawn(TurretClass,,,Location+WeaponOffset,Rotation+WeaponRotation);
		Turret.TurretBase = self;
		Turret.SetupTurret();
	}
}

function PostBeginPlay()
{
	SpawnTurret();
}

defaultproperties
{
     TurretClass=Class'VehicleGame.LevelTurret'
     WeaponOffset=(Z=99.800003)
     DrawType=DT_StaticMesh
     bStatic=True
}
