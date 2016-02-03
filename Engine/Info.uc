//=============================================================================
// Info, the root of all information holding classes.
//=============================================================================
class Info extends Actor
	abstract
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force,Havok)
	native;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	PlayInfo.AddClass(default.Class);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	return true;
}

defaultproperties
{
     NetUpdateFrequency=10.000000
     RemoteRole=ROLE_None
     bHidden=True
     bSkipActorPropertyReplication=True
     bOnlyDirtyReplication=True
}
