class VGHitEffectBase extends Object
    abstract;

var(HitEffect) class<Actor> HitEffectDefault;
var(HitEffect) class<Actor> HitEffectRock;
var(HitEffect) class<Actor> HitEffectDirt;
var(HitEffect) class<Actor> HitEffectMetal;
var(HitEffect) class<Actor> HitEffectWood;
var(HitEffect) class<Actor> HitEffectPlant;
var(HitEffect) class<Actor> HitEffectFlesh;
var(HitEffect) class<Actor> HitEffectIce;
var(HitEffect) class<Actor> HitEffectSnow;
var(HitEffect) class<Actor> HitEffectWater;
var(HitEffect) class<Actor> HitEffectGlass;
var(HitEffect) class<Actor> HitEffectWet;
var(HitEffect) class<Actor> HitEffectStone;
var(HitEffect) class<Actor> HitEffectSand;


var(HitEffect) class<Actor> BounceEffectDefault;
var(HitEffect) class<Actor> BounceEffectRock;
var(HitEffect) class<Actor> BounceEffectDirt;
var(HitEffect) class<Actor> BounceEffectMetal;
var(HitEffect) class<Actor> BounceEffectWood;
var(HitEffect) class<Actor> BounceEffectPlant;
var(HitEffect) class<Actor> BounceEffectFlesh;
var(HitEffect) class<Actor> BounceEffectIce;
var(HitEffect) class<Actor> BounceEffectSnow;
var(HitEffect) class<Actor> BounceEffectWater;
var(HitEffect) class<Actor> BounceEffectGlass;
var(HitEffect) class<Actor> BounceEffectWet;
var(HitEffect) class<Actor> BounceEffectStone;
var(HitEffect) class<Actor> BounceEffectSand;

static function Actor SpawnHitEffect( Actor Victim, Vector HitLocation, Vector HitNormal, optional Actor Owner, optional Material HitMaterial )
{
    local class<Actor> HitEffect;
    local class<Actor> BounceEffect;

	//XJ tell it what material we just hit, useful when hitting BSP
	if(HitMaterial != none)
	{
        switch (HitMaterial.SurfaceType)
        {
            case EST_Rock:
			case EST_ThinRock:
                HitEffect = Default.HitEffectRock;
                BounceEffect = Default.BounceEffectRock;
                break;
            case EST_Dirt:
			case EST_ThinDirt:
                HitEffect = Default.HitEffectDirt;
                BounceEffect = Default.BounceEffectDirt;
                break;
            case EST_Metal:
            case EST_ThinMetal:
                HitEffect = Default.HitEffectMetal;
                BounceEffect = Default.BounceEffectMetal;
                break;
            case EST_Wood:
            case EST_ThinWood:
                HitEffect = Default.HitEffectWood;
                BounceEffect = Default.BounceEffectWood;
                break;
            case EST_Plant:
            case EST_ThinPlant:
                HitEffect = Default.HitEffectPlant;
                BounceEffect = Default.BounceEffectPlant;
                break;
            case EST_Flesh:
            case EST_ThinFlesh:
                HitEffect = Default.HitEffectFlesh;
                BounceEffect = Default.BounceEffectFlesh;
                break;
            case EST_Ice:
            case EST_ThinIce:
                HitEffect = Default.HitEffectIce;
                BounceEffect = Default.BounceEffectIce;
                break;
            case EST_Snow:
            case EST_ThinSnow:
                HitEffect = Default.HitEffectSnow;
                BounceEffect = Default.BounceEffectSnow;
                break;
            case EST_Water:
            case EST_ThinWater:
                HitEffect = Default.HitEffectWater;
                BounceEffect = Default.BounceEffectWater;
                break;
            case EST_Glass:
            case EST_ThinGlass:
                HitEffect = Default.HitEffectGlass;
                BounceEffect = Default.BounceEffectGlass;
                break;
            case EST_Wet:
            case EST_ThinWet:
                HitEffect = Default.HitEffectWet;
                BounceEffect = Default.BounceEffectWet;
                break;
            case EST_Stone:
            case EST_ThinStone:
                HitEffect = Default.HitEffectStone;
                BounceEffect = Default.BounceEffectStone;
                break;
            case EST_Sand:
            case EST_ThinSand:
                HitEffect = Default.HitEffectSand;
                BounceEffect = Default.BounceEffectSand;
                break;
            default:
                HitEffect = Default.HitEffectDefault;
                BounceEffect = Default.BounceEffectDefault;
                break;
		}
	}
    else if( Victim != None)
    {
        switch (Victim.Texture.SurfaceType)	//XJ used to be Victim.SurfaceType
        {
            case EST_Rock:
            case EST_ThinRock:
                HitEffect = Default.HitEffectRock;
                BounceEffect = Default.BounceEffectRock;
                break;
            case EST_Dirt:
            case EST_ThinDirt:
                HitEffect = Default.HitEffectDirt;
                BounceEffect = Default.BounceEffectDirt;
                break;
            case EST_Metal:
            case EST_ThinMetal:
                HitEffect = Default.HitEffectMetal;
                BounceEffect = Default.BounceEffectMetal;
                break;
            case EST_Wood:
            case EST_ThinWood:
                HitEffect = Default.HitEffectWood;
                BounceEffect = Default.BounceEffectWood;
                break;
            case EST_Plant:
            case EST_ThinPlant:
                HitEffect = Default.HitEffectPlant;
                BounceEffect = Default.BounceEffectPlant;
                break;
            case EST_Flesh:
            case EST_ThinFlesh:
                HitEffect = Default.HitEffectFlesh;
                BounceEffect = Default.BounceEffectFlesh;
                break;
            case EST_Ice:
            case EST_ThinIce:
                HitEffect = Default.HitEffectIce;
                BounceEffect = Default.BounceEffectIce;
                break;
            case EST_Snow:
            case EST_ThinSnow:
                HitEffect = Default.HitEffectSnow;
                BounceEffect = Default.BounceEffectSnow;
                break;
            case EST_Water:
            case EST_ThinWater:
                HitEffect = Default.HitEffectWater;
                BounceEffect = Default.BounceEffectWater;
                break;
            case EST_Glass:
            case EST_ThinGlass:
                HitEffect = Default.HitEffectGlass;
                BounceEffect = Default.BounceEffectGlass;
                break;
			case EST_Wet:
            case EST_ThinWet:
                HitEffect = Default.HitEffectWet;
                BounceEffect = Default.BounceEffectWet;
                break;
            case EST_Stone:
            case EST_ThinStone:
                HitEffect = Default.HitEffectStone;
                BounceEffect = Default.BounceEffectStone;
                break;
            case EST_Sand:
            case EST_ThinSand:
                HitEffect = Default.HitEffectSand;
                BounceEffect = Default.BounceEffectSand;
                break;
            default:
                HitEffect = Default.HitEffectDefault;
                BounceEffect = Default.BounceEffectDefault;
                break;
        }
    }
	else
    {
        HitEffect = Default.HitEffectDefault;
        BounceEffect = Default.BounceEffectDefault;
    }


//    Log("surface: "@Victim@Victim.SurfaceType@HitEffect);

    if(BounceEffect != none && Owner != none)
    {
        Owner.Spawn(BounceEffect, none,, HitLocation, Rotator(HitNormal) );
    }
	else if(BounceEffect != none &&  Victim != none)
	{
		Victim.Spawn(BounceEffect, none,, HitLocation, Rotator(HitNormal) );
	}

	if(HitEffect != none && Owner != none)
    {
        return Owner.Spawn(HitEffect, none,, HitLocation, Rotator(HitNormal));
    }
	if(HitEffect != none &&  Victim != none)
	{
		return Victim.Spawn(HitEffect, none,, HitLocation, Rotator(HitNormal));
	}
	return none;
}

defaultproperties
{
}
