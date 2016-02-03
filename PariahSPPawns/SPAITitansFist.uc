class SPAITitansFist extends SPAIController;
		
function bool MayAttack(Vector from, Actor Other)
{
    local vector A, B;
    local float Dist;

    A = from;
    B = Other.Location;
    A.Z = 0;
    B.Z = 0;

    Dist = VSize(A - B); 
    return (Dist > 1000);
}

function bool isChargeWeapon()
{
    return true;
}

function float getChargeDelay()
{
    return 7;
}

defaultproperties
{
     AssignedWeapon="VehicleWeapons.BotTitansFist"
     MinNumShots=1
     MaxNumShots=1
     NumShotsUntilReload=1
     MinShotPeriod=10.000000
     MaxShotPeriod=15.000000
}
