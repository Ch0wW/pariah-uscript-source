class BotGrenadeProjectile extends GrenadeProjectile;

//MH: It sucks to have the bots grenades explode on impact
simulated function ProcessTouch (Actor Other, vector HitLocation)
{
}

defaultproperties
{
     explodeTime=2.500000
     minExplodeTime=3.000000
     maxExplodeTime=3.500000
     VehicleDamage=20
}
