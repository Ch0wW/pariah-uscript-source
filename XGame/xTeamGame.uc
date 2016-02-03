//=============================================================================
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
//=============================================================================
class xTeamGame extends TeamGame;

function PostBeginPlay()
{
    local xUtil.PlayerRecord PlayerRecord;
    local Array <xUtil.WeaponRecord> WeaponRecords;
    
    Super.PostBeginPlay();
    
	log( "Precaching MP resources..." );

    PlayerRecord = class'xUtil'.static.FindPlayerRecord("TeamPlayerA");
    log("Precached:" @ DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );

    PlayerRecord = class'xUtil'.static.FindPlayerRecord("TeamPlayerB");
    log("Precached:" @ DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );
        	
	class'xUtil'.static.GetWeaponList( WeaponRecords );
}

function PreLoadData()
{
    class'xDeathmatch'.static.PreLoadGameTypeData();
}

function ScoreKill(Controller Killer, Controller Other)
{
	if (xPlayer(Killer)!=None)
	  xPlayer(Killer).LogMultiKills();

    Super.ScoreKill( Killer, Other );
}

function StartMatch()
{
    Super.StartMatch();
    EvaluateHint('TDMStart', None);
}

defaultproperties
{
     EndGameSound(0)=Sound'PariahAnnouncer.red_team_wins'
     EndGameSound(1)=Sound'PariahAnnouncer.blue_team_wins'
     AltEndGameSound(0)=Sound'PariahAnnouncer.you_have_won_the_game'
     AltEndGameSound(1)=Sound'PariahAnnouncer.you_have_lost_the_game'
     LevelRulesClass=Class'XGame.xLevelGameRules'
     BotNames(0)="Stubbs"
     BotNames(1)="Stockton"
     BotNames(2)="Raphael"
     BotNames(3)="Jahal"
     BotNames(4)="Noah"
     BotNames(5)="Greo"
     BotNames(6)="Mick"
     BotNames(7)="Howie"
     BotNames(8)="Tonklin"
     BotNames(9)="Jones"
     BotNames(10)="Eddy"
     BotNames(11)="Garren"
     BotNames(12)="Mitchel"
     BotNames(13)="Jayton"
     BotNames(14)="Jared"
     BotNames(15)="Aaron"
     BotNames(16)="Lance"
     BotNames(17)="Morgan"
     MinGoalScore=10
     MaxLives=0
     ListPriority=9
     DeathMessageClass=Class'XGame.xDeathMessage'
     ScoreBoardType="XInterfaceHuds.ScoreBoardTeamDeathMatch"
     HUDType="XInterfaceHuds.HudATeamDeathMatch"
     MapListType="XInterfaceMP.MapListTeamGame"
     ScreenshotName="PariahMapThumbNails.GameTypes.TeamDeathMatch"
     DecoTextName="XGame.TeamGame"
     Acronym="TDM"
     bNeedPreLoad=True
}
