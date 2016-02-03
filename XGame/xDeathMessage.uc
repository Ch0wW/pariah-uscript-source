//
// A Death Message.
//
// Switch 0: Kill
//	RelatedPRI_1 is the Killer.
//	RelatedPRI_2 is the Victim.
//	OptionalObject is the DamageType Class.
//

class xDeathMessage extends LocalMessage;

var(Message) localized string KilledString, SomeoneString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	local string KillerName, VictimName;
	local Class<DamageType> DamType;
	
	DamType = Class<DamageType>(OptionalObject);

	if(DamType == None)
	{
	    log("xDeathMessage: No damage type");
		return "";
    }

	if (RelatedPRI_2 == None)
		VictimName = Default.SomeoneString;
	else
		VictimName = RelatedPRI_2.RetrivePlayerName();

	if ( Switch == 1 )
	{
		// suicide
		return class'GameInfo'.Static.ParseKillMessage(
			KillerName, 
			VictimName,
			DamType.Static.SuicideMessage(RelatedPRI_2) );
	}

	if (RelatedPRI_1 == None)
		KillerName = Default.SomeoneString;
	else
		KillerName = RelatedPRI_1.RetrivePlayerName();

	return class'GameInfo'.Static.ParseKillMessage(
		KillerName, 
		VictimName,
		DamType.Static.DeathMessage(RelatedPRI_1, RelatedPRI_2) );
}


static function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_1 == P.PlayerReplicationInfo)
	{
	    // If we were the killer, show the child message instead (you killed bob)
		P.myHUD.LocalizedMessage( Default.ChildMessage, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	}
	else if (RelatedPRI_2 == P.PlayerReplicationInfo)
	{
	    // If we were the victem, show the victem message ("you were killed by bob")
		P.myHUD.LocalizedMessage( class'xVictimMessage', Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	}
	
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
     KilledString="was killed by"
     SomeoneString="someone"
     ChildMessage=Class'XGame.xKillerMessagePlus'
     DrawColor=(B=0,G=0,R=255)
     bIsSpecial=False
}
