class Haser extends VehicleWeapon;

simulated function AttachToPawn(Pawn P) 
{
	Super.AttachToPawn(P);
	if(ThirdPersonActor != none)
		ThirdPersonActor.SetRelativeLocation(vect(0, 0, 75) );
}

defaultproperties
{
     AIRating=0.400000
     CurrentRating=0.400000
     AutoAimFactor=1.000000
     FireModeClass(0)=Class'VehicleWeapons.HaserFire'
     bCanThrow=False
     bDontDrawVehicleReticle=True
     PickupClass=Class'VehicleWeapons.HaserPickup'
     AttachmentClass=Class'VehicleWeapons.HaserAttachment'
     ItemName="Haser"
     InventoryGroup=3
     BarIndex=3
}
