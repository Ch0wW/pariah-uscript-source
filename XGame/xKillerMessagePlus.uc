class xKillerMessagePlus extends LocalMessage;

var(Message) localized string YouKilledMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    local string outString;

	if (RelatedPRI_1 == None)
		return "";
	if (RelatedPRI_2 == None)
		return "";

	if (RelatedPRI_2.RetrivePlayerName() == "")
        return "";

    outString = default.YouKilledMessage;
    UpdateTextField(outString, "%name",  RelatedPRI_2.RetrivePlayerName() );
    return outString;
}

defaultproperties
{
     YouKilledMessage="You killed %name."
     FontSize=1
     Lifetime=3.000000
     PosX=0.980000
     PosY=0.120000
     DrawColor=(B=255,G=200,R=0)
     DrawPivot=DP_UpperRight
     StackMode=SM_Down
     bFadeMessage=True
}
