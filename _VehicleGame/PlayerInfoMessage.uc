class PlayerInfoMessage extends LocalMessage;


// PlayerInfoMessages
//
// Switch 0: No Vehicle Available!
//
// Switch 1: No Teleport Available!
//
// Switch 2: You are on the Red Team
//
// Switch 3: You are on the Blue Team
// 
// Switch 4: Vehicle moving too fast to ride.
//
// Switch 5: Weapon has gone up a level
//
// Switch 6: Weapon Maxed out
//
// Switch 7: No Valid WEC
//
// Switch 8: Applied WEC to Weapon

var localized string NoVehicleAvailable;
var localized string NoTeleportAvailable;

var localized string YouAreOnTeam, BlueTeam, RedTeam;

var localized string VehicleMovingTooFast;

var localized string WeaponLevelUp;
var localized string WeaponLevelMaxed;
var localized string WeaponNoWEC;
var localized string WeaponAddedWEC;

var(Message) color RedColor, BlueColor, YellowColor;

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	switch(Switch)
	{
	case 1: return Default.YellowColor;
	case 2:	return Default.RedColor;
	case 3: return Default.BlueColor;
	default: return Default.YellowColor;
	}
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
	case 0: return Default.NoVehicleAvailable;
	case 1:	return Default.NoTeleportAvailable;
	case 2:	return Default.YouAreOnTeam@Default.RedTeam;
	case 3:	return Default.YouAreOnTeam@Default.BlueTeam;
	case 4:	return Default.VehicleMovingTooFast;
	case 5:	return Default.WeaponLevelUp;
	case 6: return Default.WeaponLevelMaxed;
	case 7: return Default.WeaponNoWEC;
	case 8: return Default.WeaponAddedWEC;
	}
}

defaultproperties
{
     RedColor=(B=23,G=23,R=166,A=255)
     BlueColor=(B=255,A=255)
     YellowColor=(G=255,R=255,A=255)
     NoVehicleAvailable="There are no vehicles available"
     NoTeleportAvailable="No teleport available"
     YouAreOnTeam="You are on the"
     BlueTeam="Blue Team"
     RedTeam="Red Team"
     VehicleMovingTooFast="Vehicle is moving too fast to get on."
     WeaponLevelUp="Weapon has gone up a level"
     WeaponLevelMaxed="Weapon already at full power"
     WeaponNoWEC="No WEC available"
     WeaponAddedWEC="WEC applied to weapon"
     FontSize=1
     Lifetime=2.000000
     PosX=0.980000
     PosY=0.120000
     DrawColor=(B=255,G=128,R=0)
     DrawPivot=DP_UpperRight
     StackMode=SM_Down
     bIsPartiallyUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
}
