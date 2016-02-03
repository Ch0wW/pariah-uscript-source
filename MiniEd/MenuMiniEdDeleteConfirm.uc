class MenuMiniEdDeleteConfirm extends MenuQuestionYesNo;

// Args: <CustomMapName> <TRUE|FALSE>

var() String CustomMapName;
var() bool Damaged;

simulated function Init( String Args )
{
    local String S;
    
    CustomMapName = ParseToken( Args );
    Assert( CustomMapName != "" );

    Damaged = bool(ParseToken( Args ));

    if( Damaged )
        S = class'MenuCustomMaps'.default.StringConfirmDeleteDamaged;
    else
        S = class'MenuCustomMaps'.default.StringConfirmDelete;
    
    S = ReplaceSubstring( S, "<MAPNAME>", CustomMapName );

    Super.Init(MakeQuotedString(S));
}

simulated function OnYes()
{
    class'xUtil'.static.DeleteCustomMap( true, CustomMapName );
    GotoMenuClass("MiniEd.MenuMiniEdLoad");
}

simulated function OnNo()
{
    GotoMenuClass("MiniEd.MenuMiniEdLoad");
}

defaultproperties
{
     ReservedNames(1)="Default"
     ReservedNames(2)="New"
     ReservedNames(3)="Player"
     ReservedNames(4)="Pariah"
     ReservedNames(5)="Build"
     ReservedNames(6)="Default"
     ReservedNames(7)="DefPariahEd"
     ReservedNames(8)="DefUser"
     ReservedNames(9)="Manifest"
     ReservedNames(10)="MiniEdLaunch"
     ReservedNames(11)="MiniEdUser"
     ReservedNames(12)="PariahEd"
     ReservedNames(13)="PariahEdTips"
     ReservedNames(14)="Running"
     ReservedNames(15)="TEMP"
     ReservedNames(16)="User"
}
