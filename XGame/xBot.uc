class xBot extends Bot
    DependsOn(xUtil)
	native;

var() xUtil.PlayerRecord PawnSetupRecord;

// Main skills/traits
var() float         StyleScale;     // 0.f to 1.f
var() float         AccuracySkill;  // 0.f to 1.f
var() float         AgilitySkill;   // 0.f to 1.f
var() float         TacticsSkill;   // 0.f to 1.f
var() float         SkillsRange[2];

// Style
var() float         CombatStyleRange[2];
var() float         BaseAggressivenessRange[2];
var() float         JumpyThreshold;

// Accuracy
var() float         AccuracyRange[2];

// Tactics
var() float         SkillRange[2];
var() float         BaseAlertnessRange[2];
var() float         StrafingAbilityRange[2];


function InitAttribs()
{
    if (GetCurrentGameProfile() == None)
        return;

    // General
    ScaleAttrib(AccuracySkill, SkillsRange, AccuracySkill);
    ScaleAttrib(AgilitySkill,  SkillsRange, AgilitySkill);
    ScaleAttrib(TacticsSkill,  SkillsRange, TacticsSkill);

    // Style
    ScaleAttrib(CombatStyle, CombatStyleRange, StyleScale);
    ScaleAttrib(BaseAggressiveness, BaseAggressivenessRange, StyleScale);
    bJumpy = SetAttrib(JumpyThreshold, StyleScale);		// FIXME - this is really separate/different from other style elements

    // Accuracy
    ScaleAttrib(Accuracy, AccuracyRange, AccuracySkill);

    // Tactics
    ScaleAttrib(Tactics, SkillRange, TacticsSkill); // FIXME - help - this used to range from 0 to 7, modifying skill.  
													// I think it makes more sense to modify Tactics, rather than skill (which affects all abilities)
													// however, I'm not sure about the range.  I don't think bots in any one game should be more
													// than +/- 1 skill level from the base, which is why I changed the skill range below.
													// however, I'm not sure if this is being used for overall difficulty progression in singleplayer
																
    ScaleAttrib(BaseAlertness, BaseAlertnessRange, TacticsSkill);
    
    // Agility
    ScaleAttrib(StrafingAbility, StrafingAbilityRange, AgilitySkill);
}

// attrib = min + scale*(max-min)
function ScaleAttrib(out float attrib, float attribRange[2], float scaleFactor)
{
    attrib = Lerp(scaleFactor, attribRange[0], attribRange[1], true); //Clamped to {min,max} range
}

function bool SetAttrib(float threshold, float skillLevel)
{
    if (threshold > skillLevel)
        return true;
    else
        return false;
}

function SetPawnClass(string inClass, string inCharacter, optional string DefaultClass)
{
    local class<xPawn> pClass;
    
	if ( inClass != "" )
		pClass = class<xPawn>(DynamicLoadObject(inClass, class'Class'));
    if (pClass != None)
        PawnClass = pClass;

    PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
    PlayerReplicationInfo.SetCharacterName(PawnSetupRecord.DefaultName);
}

function Possess( Pawn aPawn )
{
    local xPawn xp;

    if(aPawn.IsA('xPawn'))
	{
		xp = xPawn(aPawn);
		xp.PlayerReplicationInfo = PlayerReplicationInfo;
		xp.SetupPlayerRecord(PawnSetupRecord);
	}
	else
	{
		aPawn.PlayerReplicationInfo = PlayerReplicationInfo;
	}

    Super.Possess( aPawn );
}

defaultproperties
{
     SkillsRange(1)=1.000000
     CombatStyleRange(1)=1.000000
     BaseAggressivenessRange(1)=1.000000
     JumpyThreshold=0.800000
     AccuracyRange(0)=-1.000000
     AccuracyRange(1)=1.000000
     SkillRange(0)=-1.000000
     SkillRange(1)=1.000000
     StrafingAbilityRange(0)=-1.000000
     StrafingAbilityRange(1)=1.000000
     PlayerReplicationInfoClass=Class'XGame.xPlayerReplicationInfo'
}
