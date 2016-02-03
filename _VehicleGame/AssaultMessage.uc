class AssaultMessage extends CriticalEventPlus;

// Switch 0: Point advanced message
//	RelatedPRI_1 is the scorer.
//
// Switch 1: objective destroyed
//	RelatedPRI_1 is the scorer.
//
// Switch 2: all objectives destroyed
//	RelatedPRI_1 is the scorer.
//
// Switch 3: new round
//

var localized string WhiteTeamAdvancing, BlackTeamAdvancing;
var localized string WhiteObjectiveDestroyed, BlackObjectiveDestroyed;
var localized string AllWhiteDestroyed, AllBlackDestroyed;
var localized string NewRoundStarting;
var localized string DefendWhiteBase,DefendBlackBase;
var localized string WhiteBaseReverted,BlackBaseReverted;



static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{

	local TeamInfo Team;
	Team = TeamInfo(OptionalObject);
	switch (Switch)
	{
		// frontline advanced
		case 0:
			if (Team == None)
				return "";
			
			if ( Team.TeamIndex == 0 ) 
				return Default.WhiteTeamAdvancing;
			else
				return Default.BlackTeamAdvancing;
			break;
		case 1:
			if (RelatedPRI_1 == None)
				return "";
			if ( RelatedPRI_1.Team.TeamIndex == 1 ) 
				return Default.WhiteObjectiveDestroyed;
			else
				return Default.BlackObjectiveDestroyed;
			break;
		case 2:
			if (RelatedPRI_1 == None)
				return "";
			if ( RelatedPRI_1.Team.TeamIndex == 1 ) 
				return Default.AllWhiteDestroyed;
			else
				return Default.AllBlackDestroyed;
			break;
		case 3:
			return Default.NewRoundStarting;
			break;
		case 4:
			if(AssaultSpawn(OptionalObject) == None)
				return "";

			if(AssaultSpawn(OptionalObject).OrderIndex==0)
				return Default.WhiteBaseReverted;
			else
				return Default.BlackBaseReverted;
			break;
		case 5:
			if(AssaultSpawn(OptionalObject) == None)
				return "";

			if(AssaultSpawn(OptionalObject).OrderIndex==0)
				return Default.DefendWhiteBase;
			else
				return Default.DefendBlackBase;
			break;
	}
}

defaultproperties
{
     WhiteTeamAdvancing="The red team is pushing forward!"
     BlackTeamAdvancing="The blue team is pushing forward!"
     WhiteObjectiveDestroyed="A red objective has been destroyed!"
     BlackObjectiveDestroyed="A blue objective has been destroyed!"
     AllWhiteDestroyed="ALL the red objectives have been destroyed!"
     AllBlackDestroyed="ALL the blue objectives have been destroyed!"
     NewRoundStarting="Round is restarting"
     DefendWhiteBase="The Red Base is vulnerable!"
     DefendBlackBase="The Blue Base is vulnerable!"
     WhiteBaseReverted="The Red Base has been defended!"
     BlackBaseReverted="The Blue Base has been defended!"
     FontSize=0
     Lifetime=3.000000
     PosY=0.800000
     DrawPivot=DP_UpperMiddle
     StackMode=SM_Up
     bIsUnique=False
}
