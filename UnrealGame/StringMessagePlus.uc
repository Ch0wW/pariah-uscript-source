class StringMessagePlus extends LocalMessage;

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	return MessageString;
}

defaultproperties
{
     DrawColor=(B=255,G=255,R=255)
     bIsSpecial=False
}
