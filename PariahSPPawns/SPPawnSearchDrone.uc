class SPPawnSearchDrone extends SPPawnDrone;

var DroneSearchLight SearchLight;

var array<SPAIKamikazeDrone> summonedDrones;	// list of summoned drones so we can deal with them if the searcher is destroyed

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SearchLight = Spawn(class'DroneSearchLight', self,, Location, Rotation);
	if(SearchLight != none)
		SearchLight.SetBase(self);
}

function addSupportDrone(SPAIKamikazeDrone drone)
{
	summonedDrones[summonedDrones.Length] = drone;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local int n;
	local vector theSpot;

	for(n = 0; n < summonedDrones.Length; n++) {
		if(summonedDrones[n] != none) {
			theSpot = Normal(summonedDrones[n].Pawn.Location-Location)*100+Location;
			summonedDrones[n].AttractLocation = theSpot;
			summonedDrones[n].GotoState('SearcherDestroyed');
		}
	}

	if(SearchLight != none) {
		SearchLight.Destroy();
		SearchLight = none;
	}

	Super.Died(Killer, damageType, HitLocation);
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	local SPAISearchDrone aiDrone;

	if(EventInstigator.IsA('SPPawn') && SPPawn(EventInstigator).race == race)
		// don't respond to members of own team
		return;

	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);

	// we've been hit so we should really go into attack mode now
	aiDrone = SPAISearchDrone(Controller);
	if(aiDrone != none && Health > 0 && !aiDrone.IsInState('Extending') && !aiDrone.IsInState('Annoying') ) {
		aiDrone.Target = EventInstigator;
		aiDrone.SetMultiTimer(1, 0, false);
		aiDrone.GotoState('Extending');
	}
}

function Destroyed()
{
	Super.Destroyed();
	if(SearchLight != none) {
		SearchLight.Destroy();
		SearchLight = none;
	}
}

defaultproperties
{
     ExplodeSound=Sound'PariahGameSounds.Mines.MineExplosionA'
     ExplodeEmitter=Class'VehicleEffects.VGRocketExplosion'
     ExplosionDistortionClass=Class'VehicleEffects.VGRocketExplosionDistort'
     AirSpeed=250.000000
     FlyingBrakeAmount=10.000000
     race=R_Clan
     bDontReduceSpeed=True
     StaticMesh=StaticMesh'DronesStaticMeshes.searchDrone'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem107
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem107'
     Skins(0)=Shader'DroneTex.Search.SearchShader'
}
