class MenuSelectStats extends MenuSelectGameType;

var() localized String StringOverallGameName;
var() String OverallScreenshotName;
var() String OverallDecoTextName;

var() localized String StringDedicateHostGameName;
var() String DedicateHostScreenshotName;
var() String DedicateHostDecoTextName;

simulated function LoadGameTypes()
{
    local int i;

    Super.LoadGameTypes();

    i = GameTypeRecords.Length;
    GameTypeRecords.Insert(i,1);
    GameTypeRecords[i].GameName = StringDedicateHostGameName;
    GameTypeRecords[i].ScreenshotName = DedicateHostScreenshotName;
    GameTypeRecords[i].Screenshot = Material(DynamicLoadObject(DedicateHostScreenshotName, class'Material'));
    GameTypeRecords[i].DecoTextName = DedicateHostDecoTextName;
    GameTypeRecords[i].ClassName = "DEDICATED";

    for( i = 0; i < GameTypeRecords.Length; ++i )
    {
        if( bool(GameTypeRecords[i].bCustomMaps) )
        {
            GameTypeRecords.Remove(i, 1);
            --i;
        }
    }
}

simulated function HandleInputBack()
{
    Super.HandleInputBack();
    CloseMenu();
}

simulated function GotoNextMenu()
{
    local int i;
    
    for( i = 0; i < GameTypeRecords.Length; ++i )
    {
    	if( GameTypeName == GameTypeRecords[i].ClassName )
    	{
    	    break;
    	}
    }
    
    Assert( i < GameTypeRecords.Length );

    CallMenuClass( "XInterfaceLive.MenuLeaderBoard", GameTypeName @ MakeQuotedString( GameTypeRecords[i].GameName ) );
}

defaultproperties
{
     StringOverallGameName="Overall"
     OverallScreenshotName="PariahMapThumbnails.ShotAllGameTypes"
     OverallDecoTextName="XGame.AllGameTypes"
     StringDedicateHostGameName="Dedicated Host Mode"
     DedicateHostScreenshotName="PariahMapThumbnails.ShotAllGameTypes"
     DedicateHostDecoTextName="XGame.AllGameTypes"
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
