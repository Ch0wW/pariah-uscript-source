class CoopInfo extends ReplicationInfo
    native
    abstract;

function Initialize(PlayerController captain);
function bool IsCaptainReady();
function bool RemoveBotQuery(Controller botToRemove);
function AdjustPlayerCount(optional bool bInit);

defaultproperties
{
     bGameRelevant=True
}
