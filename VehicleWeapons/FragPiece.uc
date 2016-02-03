class FragPiece extends Actor;

var		xEmitter		    Trail;
var     Vector              AttackPos;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    Trail = Spawn(class'VehicleEffects.FlakBall',self);
}

simulated function Timer()
{
    QueuedAttack(AttackPos);
}

simulated function Attack(vector Pos)
{
    AttackPos = Pos;
    SetTimer(FRand() * 0.4, false);
}

simulated function QueuedAttack(vector Pos)
{
    local Actor Other;
    local Vector HitLocation;
    local Vector HitNormal;
    local Material HitMat;
    local xEmitter Beam;
    
    Other = Owner.Trace(HitLocation, HitNormal, Pos, Location, true, ,HitMat, true);
    if(Other != None)
    {
        Beam = Spawn(class'VehicleWeapons.FragBeamEffect',,,Location);
	    Beam.mSpawnVecA = HitLocation;
        if(Other.bWorldGeometry)
        {
            class'VGFragHitEffects'.static.SpawnHitEffect(Other, HitLocation, HitNormal, Owner, HitMat);
        }
        else
        {
            Spawn(class'VehicleEffects.DavidBulletSparks',,,Location,Rotator(Vector(Rotation) * -1.0));
            Other.TakeDamage(45, Pawn(Owner), HitLocation, 0.1 * Velocity, class'FragRifleDamage');
        }
    }
    if(Role > ROLE_SimulatedProxy)
    {
        AttackComplete(Other, HitLocation, HitNormal);
    }
}

function AttackComplete(Actor Other, Vector HitLocation, Vector HitNormal)
{
    Destroy(); // derivative will do something more interesting
}

simulated function Destroyed()
{
    Trail.Destroy();
	Super.Destroyed();
}

defaultproperties
{
     LifeSpan=10.000000
     DrawScale=0.500000
     Mass=0.000000
     StaticMesh=StaticMesh'PariahWeaponEffectsMeshes.Grenade.MChunkA'
     DrawType=DT_StaticMesh
     AmbientGlow=120
     bFixedRotationDir=True
}
