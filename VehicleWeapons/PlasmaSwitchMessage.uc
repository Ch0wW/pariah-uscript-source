class PlasmaSwitchMessage extends PlayerInfoMessage;

var localized string PlasmaModeZero;	// normal mode message
var localized string PlasmaModeOne;		// repair mode message
var localized string PlasmaModeUnknown;

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.YellowColor;
}


static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch(Switch)
	{
	case 0: return Default.PlasmaModeZero;
	case 1:	return Default.PlasmaModeOne;
	default: return Default.PlasmaModeUnknown;
	}
}

defaultproperties
{
     PlasmaModeZero="EMP Mode"
     PlasmaModeOne="Repair Mode"
     PlasmaModeUnknown="Unknown Plasma Mode"
}
