class StocktonsFistFire extends BotTitansFistFire;


simulated function float GetDamageScale(float Dist, float ExplodeRadius)
{
	if(Dist < ExplodeRadius/2.0)
		return 1.0;
	else
		return 1.0 - FMax(0.0,( Dist - ExplodeRadius/2.0) / (ExplodeRadius/2.0));
}

function float GetPowerLevel()
{
    return 1.0; // always max power
}


simulated function bool AllowFire()
{
	return (Instigator.Health > 0);
}

defaultproperties
{
     ExplosionDamageMax=40
     ExplosionRadiusMax=1000
     FullChargeTime=0.200000
     FireCount=1
     FireRate=0.200000
}
