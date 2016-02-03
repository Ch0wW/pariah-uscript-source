class MenuHostAdmin extends MenuTemplateTitledB;

var MenuHostMain HostMain;

var() MenuText      ServerNameLabel;
var() MenuText      GamePasswordLabel;
var() MenuText      AdminNameLabel;
var() MenuText      AdminEmailLabel;
var() MenuText      AdminPasswordLabel;

var() MenuEditBox   ServerNameBox;
var() MenuEditBox   GamePasswordBox;
var() MenuEditBox   AdminNameBox;
var() MenuEditBox   AdminEmailBox;
var() MenuEditBox   AdminPasswordBox;

var() WidgetLayout  OptionLayout;
var() WidgetLayout  ValueLayout;

simulated function Init( String Args )
{
    Super.Init( Args );
    
    HostMain = MenuHostMain(PreviousMenu);
    Assert( HostMain != None );
    
    ServerNameBox.Blurred.Text = class'GameReplicationInfo'.default.ServerName;
    ServerNameBox.Focused.Text = ServerNameBox.Blurred.Text;

    GamePasswordBox.Blurred.Text = HostMain.ServerSettings.GamePassword;
    GamePasswordBox.Focused.Text = GamePasswordBox.Blurred.Text;

    AdminNameBox.Blurred.Text = class'GameReplicationInfo'.default.AdminName;
    AdminNameBox.Focused.Text = AdminNameBox.Blurred.Text;

    AdminEmailBox.Blurred.Text = class'GameReplicationInfo'.default.AdminEmail;
    AdminEmailBox.Focused.Text = AdminEmailBox.Blurred.Text;
    
    AdminPasswordBox.Blurred.Text = HostMain.ServerSettings.AdminPassword;
    AdminPasswordBox.Focused.Text = AdminPasswordBox.Blurred.Text;
}

simulated function HandleInputBack()
{
    class'GameReplicationInfo'.default.ServerName = ServerNameBox.Focused.Text;
    HostMain.ServerSettings.GamePassword = GamePasswordBox.Focused.Text;
    class'GameReplicationInfo'.default.AdminName = AdminNameBox.Focused.Text;
    class'GameReplicationInfo'.default.AdminEmail = AdminEmailBox.Focused.Text;
    HostMain.ServerSettings.AdminPassword = AdminPasswordBox.Focused.Text;

    class'GameReplicationInfo'.static.StaticSaveConfig();

    HostMain.Refresh();
    CloseMenu();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout(C);
    
    LayoutWidgets( ServerNameLabel, AdminPasswordLabel, 'OptionLayout' );
    LayoutWidgets( ServerNameBox, AdminPasswordBox, 'ValueLayout' );
}

defaultproperties
{
     ServerNameLabel=(Text="Server Name:",Style="NormalLabel")
     GamePasswordLabel=(Text="Game Password:",Style="NormalLabel")
     AdminNameLabel=(Text="Admin Name:",Style="NormalLabel")
     AdminEmailLabel=(Text="Admin Email:",Style="NormalLabel")
     AdminPasswordLabel=(Text="Admin Password:",Style="NormalLabel")
     ServerNameBox=(FilterMode=FM_None,MaxLength=40,MinLength=6,Blurred=(MaxSizeX=0.370000),BackgroundBlurred=(ScaleX=0.400000),Style="NormalEditBox")
     GamePasswordBox=(bNoSpaces=1,FilterMode=FM_AlphaNumeric,MaxLength=15,Blurred=(MaxSizeX=0.370000),BackgroundBlurred=(ScaleX=0.400000),Style="NormalEditBox")
     AdminNameBox=(FilterMode=FM_None,MaxLength=20,Blurred=(MaxSizeX=0.370000),BackgroundBlurred=(ScaleX=0.400000),Style="NormalEditBox")
     AdminEmailBox=(bNoSpaces=1,FilterMode=FM_None,MaxLength=50,Blurred=(MaxSizeX=0.370000),BackgroundBlurred=(ScaleX=0.400000),Style="NormalEditBox")
     AdminPasswordBox=(bNoSpaces=1,FilterMode=FM_AlphaNumeric,MaxLength=15,Blurred=(MaxSizeX=0.370000),BackgroundBlurred=(ScaleX=0.400000),Style="NormalEditBox")
     OptionLayout=(PosX=0.100000,PosY=0.300000,SpacingY=0.070000,BorderScaleX=0.400000)
     ValueLayout=(PosX=0.500000,PosY=0.300000,SpacingY=0.070000,BorderScaleX=0.400000)
     MenuTitle=(Text="Admin Settings")
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
