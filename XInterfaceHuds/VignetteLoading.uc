class VignetteLoading extends MenuTemplateTitled
    config;

var() MenuSprite Logo;
var() MenuText LoadingMapName;

simulated function Init( String Args )
{
    Super.Init( Args );

    if( !IsOnConsole() )
    {
        RollBink();
    }
}

simulated function RollBink()
{
    local String MapBink;

    if( !IsOnConsole() )
    {
        ShowVignetteImage();
        return;
    }

    Background.WidgetTexture = class'MenuTemplateTitled'.default.Background.WidgetTexture;
    MapBink = GetMap() $ "Loop.bik";
    
    log( "MapBink:" @ MapBink );
    SetBackgroundVideo( MapBink );
}

simulated function ShowVignetteImage()
{
    local Material Tex;
    local String MapName;

    MapName = GetMap();

    if( MapName != "" )
    {
        Tex = class'xUtil'.static.GetMapVignette( MapName );
    }
    
    if( Tex != None )
    {
        Background.WidgetTexture = Tex;
        Background.PosX = 0.f;
        Background.PosY = 0.f;
        Background.ScaleX = 1.f;
        Background.ScaleY = 1.f;
    }
    else
    {
        Background.WidgetTexture = default.Background.WidgetTexture;
    }
}

simulated function String GetMap()
{
    local int i;
    local String MapName;

    i = InStr( Args, "?" );

    if( i <= 0 )
        MapName = Args;
    else
        MapName = Left( Args, i );
    
    i = InStr( MapName, "/" );

    if( i >= 0 )
        MapName = Right( MapName, Len(MapName) - i -  1 );

    if( MapName != "" )
        return(MapName);
    else
        return(GetURLMap());
}

defaultproperties
{
     Logo=(WidgetTexture=FinalBlend'InterfaceContent.Logos.Logo',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleX=1.000000,ScaleY=1.000000,Pass=1,bHidden=1)
     LoadingMapName=(PosX=0.080000,PosY=0.800000,ScaleX=1.250000,ScaleY=1.250000,Kerning=-2,Pass=2,Style="NormalLabel")
     MenuTitle=(Text="Loading")
     Background=(WidgetTexture=Texture'LoadingScreens.Vignette_00',DrawColor=(A=255))
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
     bVignette=True
}
