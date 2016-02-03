class Cigar extends Actor;

var() class<Emitter> CigarSmokeClass;
var	Emitter		   CigarSmoke;

event Reset()
{
    SetTimer(0,false);
    bHidden=false;
	if (CigarSmoke==None) 
	{
		CigarSmoke=spawn(CigarSmokeClass,self,,Location, Rotation);
	}
}

simulated function Tick(float DeltaTime)
{
	if (CigarSmoke!=None && !bHidden)
	{
		CigarSmoke.SetLocation(Location);
		CigarSmoke.SetRotation(Rotation);
	}
}

function Timer()
{
    SetCollision(false,false,false);
	bCollideWorld=false;
    bHidden=true;
    SetPhysics(PHYS_None); //FIXME Karma?
	if (CigarSmoke!=None)
		CigarSmoke.Destroy();
}

event TornOff()
{
	Velocity = vect(0,0,-300) ;
	if ( Base != None )
	{
		Velocity = 1.2 * Base.Velocity + Velocity;
		if( bUseLightingFromBase )
		{
			bUnlit = Base.bUnlit;
			AmbientGlow = Base.AmbientGlow;
		}
	}
	//LifeSpan = 10;
	// FIXME - set location to bone location to be safe?
	SetBase(None);
	SetPhysics(PHYS_Falling); //FIXME Karma?
	bCollideWorld = true;
	SetCollision(true,false,false);
	bProjTarget = true;
	bHidden = false;
	RotationRate = rot(65535,65535,65535) * (0.3 + 0.7 * FRand());
	DesiredRotation = RotRand(true);
	//bTearOff = true;


    SetTimer(5.0, false);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	local float speed;
	
	Velocity = 0.5 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	Velocity.Z = FMin(Velocity.Z * 0.8, 700);
	speed = VSize(Velocity);
	if ( speed < 120 )
	{
		bBounce = false;
		Disable('HitWall');
	}
	// PlaySound(HitSounds[Rand(2)]); //FIXME need sound
	RotationRate = rot(65535,65535,65535) * (0.3 + 0.7 * FRand());
	DesiredRotation = RotRand(true);

}

simulated event Landed(vector HitNormal)
{
	// PlaySound(HitSounds[Rand(2)]); //FIXME need sound
	RotationRate = rot(65535,65535,65535);
	SetPhysics(PHYS_Rotating);
	bFixedRotationDir = false;
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
}

simulated event EndedRotation()
{
	if ( Physics == PHYS_Rotating )
		SetPhysics(PHYS_None);
}

defaultproperties
{
     CigarSmokeClass=Class'VehicleEffects.CigarSmoke'
     DrawScale=2.500000
     CollisionRadius=11.000000
     CollisionHeight=11.000000
     StaticMesh=StaticMesh'MannyPrefabs.cigar.cigar_mesh'
     DrawType=DT_StaticMesh
     bHidden=True
     bOrientOnSlope=True
     bBounce=True
     bFixedRotationDir=True
     bRotateToDesired=True
}
