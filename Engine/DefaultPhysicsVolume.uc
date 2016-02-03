//=============================================================================
// DefaultPhysicsVolume:  the default physics volume for areas of the level with 
// no physics volume specified
//=============================================================================
class DefaultPhysicsVolume extends PhysicsVolume
	native
	notplaceable;

function Destroyed()
{
	if ( bNoDelete )
	{
		log(self$" destroyed!");
		assert(false);
	}
}

defaultproperties
{
     RemoteRole=ROLE_None
     bStatic=False
     bNoDelete=False
     bAlwaysRelevant=False
}
