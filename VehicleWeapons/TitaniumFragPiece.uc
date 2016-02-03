class TitaniumFragPiece extends FragPiece;

function Refract(Vector HitLocation, Vector HitNormal)
{
    local Rotator RefractDir;
    local Vector ToHitLocation;
    
    SetLocation(HitLocation);
    ToHitLocation = Normal(HitLocation - Location);

    RefractDir.Yaw = 0.20 * (FRand()-0.5);
    RefractDir.Pitch = 0.20 * (FRand()-0.5);
    RefractDir.Roll = 0.20 * (FRand()-0.5);
    
    Attack(toHitLocation + ((ToHitLocation >> RefractDir) * 2000.0));
}

function AttackComplete(Actor Other, Vector HitLocation, Vector HitNormal)
{
    if(Other == None || FRand() < 0.5)
    {
        Destroy();    
    }
    else if (Other.bWorldGeometry)
    {
        SetLocation(HitLocation + (HitNormal * 8.0));
    }
    else
    {
        Refract(HitLocation, HitNormal);
    }
}

defaultproperties
{
     LifeSpan=15.000000
}
