//=============================================================================
//=============================================================================
class HavokDebris extends HavokActor
	placeable;

//
// This is the Debris from an explosion
//

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetDrawScale(FRand()*2.0+0.1);
	HavokParams(HParams).StartAngVel.X = FRand()*20;
	HavokParams(HParams).StartAngVel.Y = FRand()*20;
	HavokParams(HParams).StartLinVel.Z = Frand() * 1000 + 1200;
	HavokParams(HParams).StartLinVel.Y = Frand() * 1000 - 500;
	HavokParams(HParams).StartLinVel.X = Frand() * 1000 - 500;		
	SetPhysics(PHYS_Havok);
}

defaultproperties
{
     LifeSpan=7.000000
     StaticMesh=StaticMesh'JS_Forest.Debris'
     Begin Object Class=HavokParams Name=HavokParams3
         Mass=40.000000
         LinearDamping=0.300000
         AngularDamping=0.300000
         StartEnabled=True
         Restitution=1.000000
         ImpactThreshold=100000.000000
     End Object
     HParams=HavokParams'VehicleEffects.HavokParams3'
     Physics=PHYS_None
     bNoDelete=False
}
