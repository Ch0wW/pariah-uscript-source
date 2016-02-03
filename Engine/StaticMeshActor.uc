//=============================================================================
// StaticMeshActor.
// An actor that is drawn using a static mesh(a mesh that never changes, and
// can be cached in video memory, resulting in a speed boost).
//=============================================================================

class StaticMeshActor extends Actor
	native
	placeable;

var() bool bExactProjectileCollision;		// nonzero extent projectiles should shrink to zero when hitting this actor
var() bool bBlocksCamera;

var( MiniEd ) bool bSelectable; //Whether or not the user can select it

simulated event CreateColorModifier()
{
	CreateStyle(class'ColorModifier');
}


simulated event ChangeColor( int R, int G, int B, int A )
{
	local int i;
	for( i=0; i<StyleModifier.Length; i++ )
	{
		ColorModifier(StyleModifier[i]).Color.R = R;
		ColorModifier(StyleModifier[i]).Color.G = G;
		ColorModifier(StyleModifier[i]).Color.B = B;
		ColorModifier(StyleModifier[i]).Color.A = A;
	}
}

// Visually show to the user that the mesh is not placeable at that location
simulated event ChangeAlpha( int A )
{
	local int i;
	for( i=0; i<StyleModifier.Length; i++ )
	{
		ColorModifier(StyleModifier[i]).Color.A = A;
	}
}

defaultproperties
{
     bExactProjectileCollision=True
     bBlocksCamera=True
     bSelectable=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     DrawType=DT_StaticMesh
     bStatic=True
     bWorldGeometry=True
     bShadowCast=True
     bStaticLighting=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bBlockKarma=True
     bEdShouldSnap=True
}
