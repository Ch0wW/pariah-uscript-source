class HealingToolPickup extends VehicleWeaponPickupPlaceable;

defaultproperties
{
     bVehiclePickup=False
     bCharacterPickup=True
     MaxDesireability=0.700000
     InventoryType=Class'VehicleWeapons.HealingTool'
     PickupMessage="You got the Healing Tool."
     CantPickupMessage="You already have the Healing Tool."
     CollisionHeight=18.000000
     StaticMesh=StaticMesh'PariahGametypeMeshes.alarm.CenteredHealthPack'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
