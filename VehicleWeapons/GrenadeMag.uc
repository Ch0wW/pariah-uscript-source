class GrenadeMag extends DetonatedGrenadeProjectile;

var	float			NextItemTime;
var	float			NextItemCount;
var float			MinMagPieceSpawnRate;
var float			MaxMagPieceSpawnRate;
var	Array<MagPiece>	Pieces;

var Emitter				DebrisTrail;
var	() class<Emitter>	DebrisEmitterClass;

const MAX_MAG_PIECES = 12;
const MAX_MAG_FRAGS = 12;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer ) 
	{
		if (DebrisEmitterClass!=None)			
			DebrisTrail=Spawn(DebrisEmitterClass,Self);
	}
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	Super.HitWall(HitNormal, Wall);

	if (DebrisTrail != None) 
		DebrisTrail.Kill();
}

simulated function Tick(float dt)
{
	local MagPiece MP;
	Super.Tick(dt);
	if( Level.NetMode != NM_DedicatedServer)
	{
		NextItemCount += dt;
		if(NextItemCount > NextItemTime && Pieces.Length < MAX_MAG_PIECES && Vsize(Velocity) > 300.0)
		{
			NextItemCount = 0.0;
			NextItemTime = RandRange(MinMagPieceSpawnRate, MaxMagPieceSpawnRate);

            MP = SpawnPiece();
			if(MP != none)
			{
				Pieces[Pieces.Length] = MP;
            }
		}
	}
} 

simulated function MagPiece SpawnPiece()
{
	local vector HitLocation, HitNormal, TraceEnd, SideVect;

	TraceEnd = Location;
	TraceEnd.Z += RandRange(-4000,-4000);	//need to do something better than this really.
	TraceEnd.X += RandRange(-200, 200);
	TraceEnd.Y += RandRange(-200, 200);

	SideVect = Normal(Velocity cross vect(0,0,1)) * RandRange(200, 1000);
	if (FRand() < 0.5)
	{
	    SideVect = -SideVect;
    }
	SideVect = SideVect + Location;

	if(Trace(HitLocation, HitNormal, TraceEnd, SideVect) == none)
		Return None;

	return Spawn(class'MagPiece',self,,HitLocation);
}

function SpawnFrags()
{
	local int frags;
    local VGPawn Target;
    local Vector Loc, FragLoc;
    local Rotator FragRot;

    if(Physics == PHYS_None && Owner != None)
        Loc = Owner.Location;
    else
        Loc = Location;

    frags = 0;
	foreach RadiusActors(class'VGPawn', Target, 1200)
	{
        if(Target == Instigator)
            continue;

        FragRot = Rotator(Target.Location - Loc);
        FragLoc = Loc + Vector(FragRot) * 100;

    	Spawn(class'MagFrag', self,, FragLoc, FragRot);

        frags++;
        if(frags == MAX_MAG_FRAGS)
            break;
	}

    while(frags < MAX_MAG_FRAGS)
    {
    	Spawn(class'MagFrag', self,, Loc, RotRand());
        frags++;
    }
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (DebrisTrail!=None)
	{
		DebrisTrail.Kill();
    }

    SetCollision(false, false, false);
    SpawnFrags();

	Super.Explode(HitLocation, HitNormal);
}

simulated function Destroyed()
{
    local int i;
	for(i = 0; i < Pieces.Length; i++)
	{
        if(Pieces[i] != None)
		    Pieces[i].Destroy();
    }
	Pieces.Remove(0, Pieces.Length);

    Super.Destroyed();
}

defaultproperties
{
     MinMagPieceSpawnRate=0.100000
     MaxMagPieceSpawnRate=0.150000
     DebrisEmitterClass=Class'VehicleEffects.MagDebris'
     explodeTime=7.000000
     DamageRadius=700.000000
}
