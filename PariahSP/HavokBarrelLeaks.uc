class HavokBarrelLeaks extends HavokBarrelExplosive;

var bool bPunctured;

var FuelBarrelLeakSpot First, Last;

var BarrelLeak MyLeak;
var BarrelLeakWhite MyLeakb;
var vector OldLoc;

var Material DampTexture;

var Sound LeakSound;

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
{
	local Rotator r;
	local vector dir;
	Super.TakeDamage(0, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);

	if(!bPunctured)
	{
		dir = HitLocation - Location;
		//dir.z = 0;

		r = Rotator(Normal(dir));

		MyLeak = spawn(class'BarrelLeak',,,HitLocation, r);
		MyLeak.SetBase(self);
		MyLeakb = spawn(class'BarrelLeakWhite',,,HitLocation, r);
		MyLeakb.SetBase(self);
		GotoState('Punctured');
	}
}


state Punctured
{
	function BeginState()
	{
		bPunctured = true;
		//spawn first leak

		OldLoc = Location;
		First = None;

		MakeDecal();

		SetMultiTimer(0, 0.2, true);
		SetMultiTimer(1, 30, false);

		AmbientSound=LeakSound;
	}

	function MultiTimer(int slot)
	{
		switch(slot)
		{
		case 0:
			if (VSize(OldLoc - Location) > 50)
			{
				MakeDecal();
				OldLoc = Location;
			}
			break;
		case 1:
			GotoState('Empty');
			break;
		}
	}

}

// Trace down to ground and put a wet spot
//
function MakeDecal()
{
	local Vector LeakHit;
    local Vector End, HitLocation, HitNormal;
    local Actor Other;
	local Material HitMat;
	local Material.ESurfaceTypes HitSurfaceType;

	local FuelBarrelLeakSpot s;

	If (MyLeak != None)
	{

		LeakHit = MyLeak.Location + vector(MyLeak.Rotation) * 110;   //Put leak spot right where gas falls to ground.
		LeakHit = LeakHit + Vect(0,0,60);

		End = LeakHit + Vect(0,0,-300);

	    Other = Trace(HitLocation, HitNormal, End, LeakHit, true,,HitMat);

	    if ( Other != None && Other.bStatic && Other != self )
	    {
				s = Spawn(class'FuelBarrelLeakSpot',Self,, HitLocation + HitNormal * 20.0);
				if (s!=none)
				{
					if (First!=none)
					{
						if (Last!=None) Last.Next = s;
						s.Prev = Last;
						Last = s;
						s.MyLeakyBarrel = Self;
					}
					else
					{
						First = s;
						Last = First;
						First.bFirstSpot = true;
						First.MyLeakyBarrel = self;
					}
				}

				HitSurfaceType = EST_Default;
                // jim: New fuel decals
                Level.FuelDecal( HitLocation + HitNormal, HitNormal, 125.0f, 30.0f, Other, class'ExplosionMark'.default.ProjTexture );
				//Level.QuickDecal(HitLocation + HitNormal*2.0f, HitNormal, Other, 190.0f, 30.0f,class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
		}
	}
}


function bool IsEmpty()
{
	return False;
}

state Empty
{
	function bool IsEmpty()
	{
		return True;
	}

	function BeginState()
	{
		local Vector groundspot, groundnormal;

        if ( MyLeak != None )
        {
            MyLeak.Kill();
            MyLeak=None;
        }
        if ( MyLeakb != None )
        {
            MyLeakb.Kill();
            MyLeakb=None;
        }

		Trace(groundspot,groundnormal,Location - Vect(0,0,150),,false);

		Last.TrailEnd = groundspot;


		AmbientSound=None;
	}

	function GetBent(Pawn instigator,optional Controller ProjOwner)
	{

	}

}

function GetBent(Pawn instigator,optional Controller ProjOwner)
{
	AmbientSound=None;
    if ( MyLeak != None )
    {
        MyLeak.Kill();
        MyLeak=None;
    }
    if ( MyLeakb != None )
    {
        MyLeakb.Kill();
        MyLeakb=None;
    }
    Super.GetBent(instigator, ProjOwner);
}

function Destroyed()
{
    if ( MyLeak != None )
    {
        MyLeak.Kill();
        MyLeak=None;
    }
    if ( MyLeakb != None )
    {
        MyLeakb.Kill();
        MyLeakb=None;
    }
}

defaultproperties
{
     DampTexture=Texture'PariahWeaponEffectsTextures.Decals.LeakSpot'
     LeakSound=Sound'PariahGameSounds.FuelBarrel.GasPouringOutC'
     Pieces(0)=(Mesh=StaticMesh'HavokObjectsPrefabs.Barrels.BarrelExplTop',AttachPoint="PointTop",Mass=10.000000)
     Pieces(1)=(Mesh=StaticMesh'HavokObjectsPrefabs.Barrels.BarrelExplBottom',AttachPoint="PointBottom",Mass=10.000000)
     DestroyEmitters(1)=(AttachPoint="PointBottom",EmitterClass=Class'VehicleEffects.BarrelShardBurst')
     bWorldGeometry=False
}
