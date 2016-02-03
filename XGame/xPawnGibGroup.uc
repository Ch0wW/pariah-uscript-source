class xPawnGibGroup extends Object
    abstract;

var(Gib) array< class<Gib> > Gibs;
var(Gib) array< class<Gib> > LowGoreGibs;
var(Gib) float GibScale;

var class<xEmitter> BloodHitClass;
var class<xEmitter> BloodGibClass;

var class<xEmitter> LowGoreBloodHitClass;
var class<xEmitter> LowGoreBloodGibClass;

Enum EGibType
{
    EGT_Calf,
    EGT_Forearm,
    EGT_Hand,
    EGT_Head,
    EGT_Torso,
    EGT_Upperarm,
};

static function class<Gib> GetGibClass(EGibType gibType)
{
	//return none;
    if ( class'GameInfo'.default.bGreenGore )
        return default.LowGoreGibs[int(gibType)];
    else
        return default.Gibs[int(gibType)];
}

static simulated function StaticPreLoadData()
{
    local int i;

    for( i=0; i<default.Gibs.Length; i++ )
    {
        PreLoad(default.Gibs[i]);
        PreLoad(default.Gibs[i].default.TrailClass);
    }
    for( i=0; i<default.LowGoreGibs.Length; i++ )
    {
        PreLoad(default.LowGoreGibs[i]);
        PreLoad(default.LowGoreGibs[i].default.TrailClass);
    }
    PreLoad(default.BloodHitClass);
    PreLoad(default.BloodGibClass);
    PreLoad(default.LowGoreBloodHitClass);
    PreLoad(default.LowGoreBloodGibClass);
}

defaultproperties
{
}
