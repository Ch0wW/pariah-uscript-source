class GameMessage extends LocalMessage;

var(Message) localized string SwitchLevelMessage;
var(Message) localized string LeftMessage;
var(Message) localized string FailedTeamMessage;
var(Message) localized string FailedPlaceMessage;
var(Message) localized string FailedSpawnMessage;
var(Message) localized string EnteredMessage;
var(Message) localized string MaxedOutMessage;
var(Message) localized string OvertimeMessage;
var(Message) localized string GlobalNameChange;
var(Message) localized string NewTeamMessage;
var(Message) localized string NewTeamMessageTrailer;
var(Message) localized string NoNameChange;
var(Message) localized string VoteStarted;
var(Message) localized string VotePassed;

//
// Messages common to GameInfo derivatives.
//
static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    local String S;
    local String X;

    switch (Switch)
    {
        case 0:
            return "";// AsP --- Removeing redundant info
            break;
        case 1:
            if (RelatedPRI_1 == None)
                return "";
            
            S = RelatedPRI_1.RetrivePlayerName();
            
            if( S == "" )
                return "";

            return S $ Default.EnteredMessage;
            break;
        case 2:
            if (RelatedPRI_1 == None)
                return "";

            return RelatedPRI_1.OldName@Default.GlobalNameChange@RelatedPRI_1.RetrivePlayerName();
            break;
        case 3:
            if (RelatedPRI_1 == None)
                return "";
                
            if (OptionalObject == None)
                return "";

            S = RelatedPRI_1.RetrivePlayerName();
            X = TeamInfo(OptionalObject).RetrivePlayerName();
            
            if( (S == "") || (X == "") )
                return "";
                

            return S @ Default.NewTeamMessage @ X @ Default.NewTeamMessageTrailer; // gam
            break;
        case 4:
            if (RelatedPRI_1 == None)
                return "";
            
            S = RelatedPRI_1.RetrivePlayerName();
            
            if( S == "" )
                return "";
                
            return S $ Default.LeftMessage;
            break;
        case 5:
            return Default.SwitchLevelMessage;
            break;
        case 6:
            return Default.FailedTeamMessage;
            break;
        case 7:
            return Default.MaxedOutMessage;
            break;
        case 8:
            return Default.NoNameChange;
            break;
        case 9:
            return RelatedPRI_1.RetrivePlayerName()@Default.VoteStarted;
            break;
        case 10:
            return Default.VotePassed;
            break;
    }
    return "";
}

defaultproperties
{
     SwitchLevelMessage="Switching Levels"
     LeftMessage=" left the game."
     FailedTeamMessage="Could not find team for player"
     FailedPlaceMessage="Could not find a starting spot"
     FailedSpawnMessage="Could not spawn player"
     EnteredMessage=" entered the game."
     MaxedOutMessage="Server is already at capacity."
     OvertimeMessage="Scores are tied."
     GlobalNameChange="changed name to"
     NewTeamMessage="is now on the"
     NewTeamMessageTrailer="team."
     NoNameChange="Name is already in use."
     VoteStarted="started a vote."
     VotePassed="Vote passed."
     FontSize=1
     Lifetime=6.000000
     PosX=0.980000
     PosY=0.120000
     DrawColor=(B=255,G=255,R=255)
     DrawPivot=DP_UpperRight
     StackMode=SM_Down
     bFadeMessage=True
}
