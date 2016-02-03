class PlayerPlasmaBall extends VGProjectile;

var() class<xEmitter> TrailClass;
var xEmitter Trail;

var() class<Actor> CoronaClass;
var	Actor Corona;

var Actor GodRays[2];

var int WECLevel;

var() float ChainRange;
var() int ChainDamage;
var() float StickDuration;

var VGPawn LastChainTarget;
var VGPawn ClientChainTarget;

var float StuckTime;


replication
{
    unreliable if(Role == ROLE_Authority && bNetInitial) WECLevel;
    unreliable if(Role == ROLE_Authority) ClientChainTarget;
}

simulated function PostBeginPlay()
{
    local int i;
    Super.PostBeginPlay();
    if(Level.NetMode != NM_DedicatedServer)
    {
        for(i = 0; i < ArrayCount(GodRays); ++i)
        {
            GodRays[i] = Spawn(class'VehicleEffects.PlasmaGodRays',self);
        }
    }

    if(Role == ROLE_Authority)
        SetTimer(0.4, true);
}

simulated function Tick(float dt)
{
    if(StuckTime > 0.0)
    {
        StuckTime -= dt;
        if(StuckTime <= 0.0)
        {
            BlowUp(Location);
            Explode(Location, Vect(0,0,1));
        }
    }
}

simulated function SpawnTrail()
{
    if(Trail == None && TrailClass != None)
    {
        Trail = Spawn(TrailClass, self);
    }
    if(Corona != None && CoronaClass != None)
    {
	    //Corona = Spawn(CoronaClass, self);
    }
}

simulated function Destroyed()
{
    local int i;
    for(i = 0; i < ArrayCount(GodRays); ++i)
    {
        if(GodRays[i] != None)
            GodRays[i].Destroy();
    }
    if(Trail != None)
        Trail.mRegen = false;
    if(Corona != None)
        Corona.Destroy();
    Super.Destroyed();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local VGPawn Victim;
    local Vector Momentum;
    local Vector TestLoc;
    local int MaxTargets;

    Super.Explode(HitLocation, HitNormal);

    if(Level.NetMode != NM_DedicatedServer)
    {
        if(WECLevel == 3)
        {
            Spawn(class'PlayerPlasmaBlastBig',,, HitLocation);
        }
        else
        {
            Spawn(class'PlayerPlasmaBlast',,, HitLocation);
        }
    }

    // wec level 3 - zap every target in range one last time
    if(WECLevel == 3)
    {
        TestLoc = Location + Velocity * 1.0f; // chains aim 1 second forward
        MaxTargets = 8;
        foreach VisibleCollidingActors(class'VGPawn', Victim, ChainRange, TestLoc) 
        {
            if(ValidChainTarget(Victim))
            {
                if(Role == ROLE_Authority)
                {
                    Momentum = Normal(Victim.Location - Location) * 2000;
                    Victim.TakeDamage(ChainDamage, Instigator, Location, Momentum, MyDamageType, ProjOwner);
                    //Victim.Controller.CalcBlinded(Instigator, Victim.Location, 100.0, 0.5, 'Laser');
                }
                if(Level.NetMode != NM_DedicatedServer)
                    SpawnChain(Victim, Victim.Location);
            }
            if(--MaxTargets <= 0)
                break;
        }
    }
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    if(Other == Instigator)
    {
        Super.ProcessTouch(Other, HitLocation);
        return;
    }

    Super.ProcessTouch(Other, HitLocation);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
    // wec level 2+, stick to wall for a few seconds before exploding
	if(WECLevel >= 2 && Wall.bStatic)
	{
        SetPhysics(PHYS_None);
        SetLocation(Location + HitNormal*10);
        StuckTime = StickDuration;

		if ( Trail != None )
		{
			// do some kind of effect for being stuck
			Trail.mPosDev = Vect(2,2,2);
			Trail.mSpeedRange[0] = 40;
			Trail.mSpeedRange[1] = 40;
			Trail.mLifeRange[0] = 0.7;
			Trail.mLifeRange[1] = 1.1;
			Trail.mSizeRange[0] = 13.0;
			Trail.mSizeRange[1] = 17.0;
			Trail.mGrowthRate = -10.0;
			Trail.mAirResistance = 0.5;
		}
    }
    else
    {
        Super.HitWall(HitNormal, Wall);
    }
}

simulated function bool ValidChainTarget(VGPawn P)
{
    if(P == Instigator)
        return false;

    if(P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team != None && P.PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team)
        return false;

    return true;
}

simulated function SpawnChain(Pawn Victim, Vector VictimLoc)
{
    local PlayerPlasmaChainEffect ChainEffect;
    local Emitter BlastEffect;

    BlastEffect = Spawn(class'PlayerPlasmaBlast',,, VictimLoc);
    BlastEffect.Tag = 'Lightning';

    ChainEffect = Spawn(class'PlayerPlasmaChainEffect', self,, Location);
    ChainEffect.ZapTarget = Victim;
    ChainEffect.SetChainEnd(VictimLoc);
}

function Timer()
{
    local VGPawn Victim;
    local Vector Momentum;
    local Vector TestLoc;
    local bool bFoundVictim;

    TestLoc = Location + Velocity * 1.0f; // chains aim 1 second forward

    foreach VisibleCollidingActors(class'VGPawn', Victim, ChainRange, TestLoc) 
    {
        if(ValidChainTarget(Victim) && Victim != LastChainTarget && Victim.Health > 0)
        {
            Momentum = Normal(Victim.Location - Location) * 2000;
            Victim.TakeDamage(ChainDamage, Instigator, Location, Momentum, MyDamageType, ProjOwner);
            //Victim.Controller.CalcBlinded(Instigator, Victim.Location, 100.0, 0.5, 'Laser');
            if(Level.NetMode != NM_DedicatedServer)
                SpawnChain(Victim, Victim.Location);
            bFoundVictim = true;
            break;
        }
    }

    LastChainTarget = Victim;
    ClientChainTarget = Victim;
}

simulated function PostNetReceive()
{
    if(ClientChainTarget != LastChainTarget)
    {
        LastChainTarget = ClientChainTarget;
        if(ClientChainTarget != None)
        {
            SpawnChain(ClientChainTarget, ClientChainTarget.Location);
        }
    }
}

function SetWECLevel(int w)
{
    WECLevel = w;
    if(WECLevel == 3)
    {
        // wec level 3 adds range, speed, and zap frequency
        Speed = 1200;
	    Velocity = Speed * Vector(Rotation);

        ChainRange = 1000;
        SetTimer(0.25, true);
    }
}

defaultproperties
{
     ChainDamage=20
     ChainRange=650.000000
     StickDuration=8.000000
     TrailClass=Class'VehicleEffects.PlasmaGlobules'
     CoronaClass=Class'VehicleEffects.PRocketCoronaEffect'
     VehicleDamage=50
     PersonDamage=40
     SplashDamage=90.000000
     Speed=1000.000000
     DamageRadius=440.000000
     MomentumTransfer=2000.000000
     LightBrightness=255.000000
     LifeSpan=20.000000
     DrawScale=4.000000
     AmbientSound=Sound'PariahWeaponSounds.hit.PlasmaRifleEnergyBall'
     LightHue=28
     LightSaturation=255
     SoundVolume=255
     bNetTemporary=False
     bNetNotify=True
}
