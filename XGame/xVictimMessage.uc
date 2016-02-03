class xVictimMessage extends LocalMessage;

var(Message) localized string YouWereKilledBy, KilledByTrailer;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    local String Name;
    
	if (RelatedPRI_1 == None)
	{
	    return("");
	}

    Name = RelatedPRI_1.RetrivePlayerName();
    
	if( Name == "" )
	{
	    return("");
	}
    
    return(Default.YouWereKilledBy @ Name $ Default.KilledByTrailer);
}

defaultproperties
{
     YouWereKilledBy="You were killed by"
     KilledByTrailer="!"
     FontSize=1
     Lifetime=8.000000
     PosX=0.980000
     PosY=0.120000
     DrawColor=(B=0,G=0,R=255)
     DrawPivot=DP_UpperRight
     StackMode=SM_Down
     bIsUnique=True
     bFadeMessage=True
}
