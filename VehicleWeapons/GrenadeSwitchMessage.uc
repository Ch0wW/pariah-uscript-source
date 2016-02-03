class GrenadeSwitchMessage extends PlayerInfoMessage;

var localized string GrenadeModeZero;	// flash grenade message
var localized string GrenadeModeOne;	// gas grenade message
var localized string GrenadeModeTwo;	// mag grenade message
var localized string GrenadeModeThree;	// proximity grenade message
var localized string GrenadeModeUnknown;

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
	case 0: return Default.GrenadeModeZero;
	case 1:	return Default.GrenadeModeOne;
	case 2:	return Default.GrenadeModeTwo;
	case 3:	return Default.GrenadeModeThree;
	default: return Default.GrenadeModeUnknown;
	}
}

defaultproperties
{
     GrenadeModeZero="Concussion Grenade Selected"
     GrenadeModeOne="Gas Grenade Selected"
     GrenadeModeTwo="Sticky Grenade Selected"
     GrenadeModeThree="MAG Grenade Selected"
     GrenadeModeUnknown="Unknown Grenade Type"
}
