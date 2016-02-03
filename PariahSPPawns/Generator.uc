class Generator extends MultiPieceHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps);

var StocktonStage OwningStage;

var() edfindable StagePosition ChargeStagePosition;

var DavidGeneratorLightning Lightning;

var GeneratorShieldMesh MyShield;

var float NextHurtTime;
var float ZapRadius;
var float ZapDelay;

var SmallGeneratorElectricity electricity;

function PostBeginPlay()
{

	super.postbeginplay();

	electricity = spawn(class'VehicleEffects.SmallGeneratorElectricity',,,Location, Rotation);
}

event Tick(float dt)
{
	local SPPlayerPawn p;
	Super.Tick(dt);

	if(Health > 0 && Level.TimeSeconds > NextHurtTime) //do damage to nearby player
	{
		//log(self@Level.TimeSeconds@NextHurtTime);
		ForEach DynamicRadiusActors( class 'SPPlayerPawn', p, ZapRadius, Location - Vect(0,0,210) )
		{
			p.TakeDamage(10, None, Location, Vect(0,0,0), class'DamageType');
		}
		NextHurtTime = Level.TimeSeconds + ZapDelay;
	}

}

function GetBent(Pawn instigator,optional Controller ProjOwner)
{
	MyShield.shielddisabled=true;
	OwningStage.RemoveGenerator(self);

	if(electricity != None)
		electricity.Destroy();

	Super.GetBent(instigator,ProjOwner);
}

function StartCharging()
{
	//Lightning = spawn( class'VehicleEffects.DavidGeneratorLightning',self,,Location, Rotation);
}


function EndCharging()
{

	//Lightning.Destroy();
}

defaultproperties
{
     ZapRadius=270.000000
     ZapDelay=0.500000
     PieceLifeSpan=1.500000
     bDisablePartCollision=True
     HMass=0.000000
     MaxHealth=300
     DestroySound=Sound'BossFightSounds.Stockton.StocktonGeneratorExplode'
     DestroyedMesh=StaticMesh'HavokObjectsPrefabs.StocktonGenerator.GeneratorBottom_Dmg'
     DestroyEmitters(0)=(AttachPoint="Point_CoreMain_Dmg",EmitterClass=Class'VehicleEffects.BarrelShardBurst')
     DestroyEmitters(1)=(AttachPoint="Point_GeneratorBottom_Dmg",EmitterClass=Class'VehicleEffects.GeneratorFire')
     DestroyEmitters(2)=(AttachPoint="Point_GeneratorBottom_Dmg",EmitterClass=Class'VehicleEffects.GeneratorExplosionPieces')
     bCanCrushPawns=False
     bAllowHudDebug=True
     StaticMesh=StaticMesh'HavokObjectsPrefabs.StocktonGenerator.StocktonGenerator'
     Tag="Generator"
     SoundVolume=200
     bDisableKarmaEncroacher=True
}
