class PickupVehicleHealth extends HealthPickup;

	

defaultproperties
{
     HealingAmount=100
     RespawnEmitterClass=Class'VehicleEffects.ParticlePickupResHealth'
     PickupMessage="You picked up a Repair Kit +"
     CantPickupMessage="You already have the repair kit."
     StaticMesh=StaticMesh'VehicleGamePickupMeshes.Health.pickup_carhealth'
}
