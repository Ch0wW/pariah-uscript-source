class MultiPieceHavokDestroyableMesh extends SimpleHavokDestroyableMesh
	placeable;

struct DestroyableMeshHavokPiece
{
	var() StaticMesh		Mesh;
	var() name				AttachPoint;
	var vector				Loc;	// attach point is cached here
	var rotator				Rot;
	var() float				Mass;
};

var(HavokProps) array<DestroyableMeshHavokPiece>	 Pieces;
var(HavokProps) float								 PieceLifeSpan;
var(HavokProps) bool bFuckPaths;

var(SkelMesh) array<Name>	AnimsToPlay;
var transient int			AnimIndex;
var(SkelMesh) float			Rate;
var(SkelMesh) bool			bRandom;
var() bool bDisablePartCollision;

event PostBeginPlay()
{
	local int p;
	local vector v;
	local rotator r;

	Super.PostBeginPlay();

	// cache attach points
	//
	for ( p = 0; p < Pieces.Length; p++ )
	{
		if ( GetAttachPoint( Pieces[p].AttachPoint, v, r ) )
		{
			Pieces[p].Loc = v;
			Pieces[p].Rot = r;
		}
	}

	if ( Mesh != None && AnimsToPlay.Length > 0 )
	{
		SetDrawType( DT_Mesh );

		if(Rate==0.0) Rate=1.0;

		AnimIndex=0;
		if ( AnimsToPlay.Length > 1 )
		{
			if( bRandom )
			{
				PlayAnim(AnimsToPlay[Rand(AnimsToPlay.Length)], Rate);
			}
			else
			{
				PlayAnim(AnimsToPlay[0], Rate);
			}
		}
		else
		{
			LoopAnim(AnimsToPlay[0], Rate);
		}
	}
}

event AnimEnd(int channel)
{
	local int next;
	if(DrawType == DT_Mesh && AnimsToPlay.Length > 1)
	{
		if(bRandom)
			next = Rand(AnimsToPlay.Length);
		else
		{
			next = AnimIndex + 1;
			if(next >= AnimsToPlay.Length)
				next = 0;
		}

		PlayAnim(AnimsToPlay[next], Rate);
		AnimIndex = next;
	}
}

function GetBent(Pawn instigator,optional Controller ProjOwner)
{
	local int			p;
	local vector		worldLoc;
	local rotator		worldRot;
	local RuntimeHavokActor	piece;
	local vector RandVel, RandAng;

	// spawn havok pieces
	//
	for ( p = 0; p < Pieces.Length; p++ )
	{
		// attach points were cached at startup
		//
		worldLoc = Location + (Pieces[p].Loc >> Rotation);
		worldRot = Rotation + Pieces[p].Rot;

		piece = spawn( class'RuntimeHavokActor', self, , worldLoc, worldRot );
		`log( "RJ: spawning RuntimeHavokActor"@piece@"at l="@worldLoc@",r="@worldRot );

		piece.bDisableKarmaEncroacher = bDisableKarmaEncroacher;
		piece.bFuckPaths = bFuckPaths;
		piece.LifeSpan = PieceLifeSpan + FRand() * PieceLifeSpan * 0.4;
		if(bDisablePartCollision)
			piece.SetCollision(false,false,false);
		piece.SetStaticMesh( Pieces[p].Mesh );
		if ( Pieces[p].Mass > 0 )
		{
			piece.bCanCrushPawns = bCanCrushPawns;
			piece.CrushSpeed = CrushSpeed;
			piece.HSetMass( Pieces[p].Mass );

			// currently all these piece properties are the same as this actor
			//
			piece.HSetFriction( HFriction );
			piece.HSetRestitution( HRestitution );
			piece.HSetDampingProps( HLinearDamping, HAngularDamping );

			RandVel = HStartLinVel + VRand()*80.0;
			RandAng = HStartAngVel + VRand()*1000.0;

			piece.HSetRBVel( RandVel >> Rotation, RandAng >> Rotation );
			piece.AmbientGlow = AmbientGlow;

			HavokParams(piece.HParams).GravScale = HGravScale;
			HavokParams(piece.HParams).Buoyancy = HBuoyancy;
			if ( HImpactThreshold > 0 )
			{
				HavokParams(piece.HParams).ImpactThreshold = HImpactThreshold;
				piece.ImpactSound = ImpactSound;
				piece.ImpactSoundVolScale = ImpactSoundVolScale;
			}

			piece.HWake();
		}
		else
		{
			piece.SetPhysics( PHYS_None );
		}
	}
	
	Super.GetBent(instigator,ProjOwner); // call super last, may destroy this actor
}

defaultproperties
{
}
