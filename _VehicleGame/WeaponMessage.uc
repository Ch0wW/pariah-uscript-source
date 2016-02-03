class WeaponMessage extends PlayerInfoMessage;

var localized string WeaponLevelZero;
var localized string WeaponLevelOne;
var localized string WeaponLevelTwo;
var localized string WeaponLevelThree;
var localized string WeaponLevelFour;
var localized string WeaponLevelFive;

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
	case 0: return Default.WeaponLevelZero;
	case 1:	return Default.WeaponLevelOne;
	case 2:	return Default.WeaponLevelTwo;
	case 3:	return Default.WeaponLevelThree;
	case 4:	return Default.WeaponLevelFour;
	case 4:	return Default.WeaponLevelFive;
	}
}

defaultproperties
{
     WeaponLevelZero="Weapon Level 0"
     WeaponLevelOne="Weapon Level 1"
     WeaponLevelTwo="Weapon Level 2"
     WeaponLevelThree="Weapon Level 3"
     WeaponLevelFour="Weapon Level 4"
     WeaponLevelFive="Weapon Level 5"
}
