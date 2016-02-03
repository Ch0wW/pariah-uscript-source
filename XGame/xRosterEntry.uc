class xRosterEntry extends RosterEntry;

static function xRosterEntry CreateRosterEntry(int prIdx, xRosterEntry xre)  // sjs[sg]
{
    local xUtil.PlayerRecord pr;

    pr = class'xUtil'.static.GetPlayerRecord(prIdx);

    xre.PlayerName = pr.DefaultName;
    xre.PawnClassName = pr.ClassName;
    xre.Init();

    //log("CreateRosterEntry() Created xre.PlayerName="$xre.PlayerName$" prIdx="$prIdx);

    return xre;
}

function InitBot(Bot B, optional string Character)
{
	local XBot X;
    local xUtil.PlayerRecord recLoaded;

	Super.InitBot(B);

	if(Character=="")
		B.SetPawnClass(PawnClassName, PlayerName);
	else
		B.SetPawnClass(PawnClassName, Character);

	X = XBot(B);
	if ( X == None )
		return;

    //log("init bot!!!!! bot name is "$playername);

    recLoaded = class'xUtil'.static.CheckLoadLimits(B.Level, X.PawnSetupRecord.RecordIndex);
    if (recLoaded.RecordIndex != X.PawnSetupRecord.RecordIndex)
        X.PawnSetupRecord = recLoaded;
    class'xUtil'.static.LoadPlayerRecordResources(X.PawnSetupRecord.RecordIndex, B.Level.NetMode != NM_Standalone || !B.Level.Game.bSinglePlayer);

	X.SetVehicleClass(recLoaded.FavVehicle);
}

defaultproperties
{
}
