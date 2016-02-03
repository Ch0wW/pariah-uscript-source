class MenuMatchMakingOptiMatchGameType extends MenuSelectGameType;

var() localized String StringAllGameName;        
var() String AllScreenshotName;
var() String AllDecoTextName;

simulated function Init( String Args )
{
    local int i;

    Super.Init( Args );
    
    for( i = 0; i < GameTypeRecords.Length; ++i )
    {
        if( GameTypeRecords[i].ClassName == class'MenuMatchMakingOptiMatchOptions'.default.GameTypeName )
        {
	        ShowGameTypeDetails(i);
            FocusOnGameType(i);
            break;
        }
    }
}

simulated function LoadGameTypes()
{
    local int i;
    
    Super.LoadGameTypes();

    GameTypeRecords.Insert(0,1);
    GameTypeRecords[0].GameName = StringAllGameName;
    GameTypeRecords[0].ScreenshotName = AllScreenshotName;
    GameTypeRecords[0].Screenshot = Material(DynamicLoadObject(AllScreenshotName, class'Material'));
    GameTypeRecords[0].DecoTextName = AllDecoTextName;
    GameTypeRecords[0].ClassName = "All";

    if( class'MenuMatchMakingOptiMatchOptions'.default.MapClassFilter == MCF_CustomOnly )
    {
        GameTypeRecords[0].bCustomMaps = 1;

        for( i = 0; i < GameTypeRecords.Length; ++i )
        {
            if( !bool(GameTypeRecords[i].bCustomMaps) )
            {
                GameTypeRecords.Remove(i, 1);
                --i;
            }
        }
    }
    else
    {
        GameTypeRecords[0].bCustomMaps = 0;

        for( i = 0; i < GameTypeRecords.Length; ++i )
        {
            if( bool(GameTypeRecords[i].bCustomMaps) )
            {
                GameTypeRecords.Remove(i, 1);
                --i;
            }
        }
    }
}

simulated function HandleInputBack()
{
    Super.HandleInputBack();
    GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatch");
}

simulated function GotoNextMenu()
{
    class'MenuMatchMakingOptiMatchOptions'.default.GameTypeName = GameTypeName;;
    class'MenuMatchMakingOptiMatchOptions'.static.StaticSaveConfig();
 
    GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatchOptions", "");
}

defaultproperties
{
     StringAllGameName="All Game Types"
     AllScreenshotName="PariahMapThumbnails.ShotAllGameTypes"
     AllDecoTextName="XGame.AllGameTypes"
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
