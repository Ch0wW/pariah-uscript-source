class xPlayerReplicationInfo extends TeamPlayerReplicationInfo;

simulated function LoadPlayer()
{
    local xPawn p;
    local xUtil.PlayerRecord rec;

    rec = class'xUtil'.static.FindPlayerRecord(CharacterName);
    class'xUtil'.static.LoadPlayerRecordResources(rec.RecordIndex, Level.NetMode != NM_Standalone || !Level.Game.bSinglePlayer );

    //log(self$" - LoadPlayer: "$rec.DefaultName$" for "$PlayerName, 'LOADING');

    foreach DynamicActors(class'xPawn', p)
    {
        if ((p.PlayerReplicationInfo == self))
        {
            p.SetupPlayerRecord(rec);
            break;
        }
    }
}

simulated function Destroyed()
{
    Level.RemoveDelayedPlayer(self);
    Super.Destroyed();
}

// amb ---
function int GetPlayerRecordIndex()
{
    local xUtil.PlayerRecord rec;
    rec = class'xUtil'.static.FindPlayerRecord(CharacterName);
    return rec.RecordIndex;
}
// --- amb

defaultproperties
{
}
