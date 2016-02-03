class DeployableCoverPart extends Actor;


var DeployableCover Cover;

var Vector HitParam, MomentumParam;
var class<DamageType> DamageParam;


var int hack;

function InitCover(DeployableCover C, int position)
{
	SetStaticMesh(C.PartMeshes[position]);
	Cover = C;
}

state Deployed
{

	function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
		Cover.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);
	}

}

function SetDetachParams(vector Hitlocation, vector Momentum, class<DamageType> Damage)
{
	HitParam = HitLocation;
	MomentumParam = Momentum;
	DamageParam = Damage;
}

state Detached
{
	function BeginState()
	{
		bMovable=true;

		if(Physics != PHYS_Havok)
			SetPhysics(PHYS_Havok);

		hack = 1;

	}

	function Tick(float dt)
	{
		local vector impulse;
		hack--;
		if(hack<=0)
		{
			if( DamageParam.static.GetHavokHitImpulse( MomentumParam, impulse ) )
			{
				HAddImpulse(impulse*256, HitParam);
			}
			Disable('Tick');
		}
	}

	function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
		local vector impulse;

		if( damageType.static.GetHavokHitImpulse( momentum, impulse ) )
		{
			HAddImpulse(impulse*256, hitlocation);
		}

	}
}

	

defaultproperties
{
     Begin Object Class=HavokParams Name=DeployableCoverPartHParams
         Mass=10000.000000
         bWantContactEvent=True
     End Object
     HParams=HavokParams'VehicleGame.DeployableCoverPartHParams'
     DrawType=DT_StaticMesh
     SurfaceType=EST_Metal
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bBlockKarma=True
}
