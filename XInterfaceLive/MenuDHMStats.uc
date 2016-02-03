class MenuDHMStats extends MenuTemplateTitledB NoPropertySort;

var() MenuText NameLabel;
var() MenuText AveragePlayersLabel;
var() MenuText UpTimeLabel;
var() MenuText TotalSessionsLabel;
var() MenuText DMSessionsLabel;
var() MenuText CTFSessionsLabel;
var() MenuText TDMSessionsLabel;
var() MenuText ASSessionsLabel;

var() MenuText NameValue;
var() MenuText AveragePlayersValue;
var() MenuText UpTimeValue;
var() MenuText TotalSessionsValue;
var() MenuText DMSessionsValue;
var() MenuText CTFSessionsValue;
var() MenuText TDMSessionsValue;
var() MenuText ASSessionsValue;

var() string Gamertag;

simulated function Init( String Args ) // args == "GAMER TAG"
{
    local string Results;

    Super.Init(Args);

    Gamertag = Args;
    NameValue.Text = ParseToken(Args);
    
    Results = ConsoleCommand("XLIVE STAT_GAMER_LEADERBOARD_DETAILS"@Gamertag);

    log("Gamer details: "$Results);

    AveragePlayersValue.Text = ParseToken(Results);
    UpTimeValue.Text = ParseToken(Results);
    TotalSessionsValue.Text = ParseToken(Results);
    DMSessionsValue.Text = ParseToken(Results);
    CTFSessionsValue.Text = ParseToken(Results);
    ASSessionsValue.Text = ParseToken(Results);
    TDMSessionsValue.Text = ParseToken(Results);
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    
    LayoutWidgets( NameLabel, ASSessionsLabel, 'DetailLabelsLayout' );
    LayoutWidgets( NameValue, ASSessionsValue, 'DetailValuesLayout' );
}

defaultproperties
{
     NameLabel=(Text="Name:",Style="DetailLabel")
     AveragePlayersLabel=(Text="Average Players:",Style="DetailLabel")
     UpTimeLabel=(Text="Up Time:",Style="DetailLabel")
     TotalSessionsLabel=(Text="Total Sessions:",Style="DetailLabel")
     DMSessionsLabel=(Text="Deathmatch:",Style="DetailLabel")
     CTFSessionsLabel=(Text="Capture the Flag:",Style="DetailLabel")
     TDMSessionsLabel=(Text="Team Deathmatch:",Style="DetailLabel")
     ASSessionsLabel=(Text="Assault:",Style="DetailLabel")
     NameValue=(Style="DetailValue")
     AveragePlayersValue=(Style="DetailValue")
     UpTimeValue=(Style="DetailValue")
     TotalSessionsValue=(Style="DetailValue")
     DMSessionsValue=(Style="DetailValue")
     CTFSessionsValue=(Style="DetailValue")
     TDMSessionsValue=(Style="DetailValue")
     ASSessionsValue=(Style="DetailValue")
     MenuTitle=(Text="Dedicated Host Statistics")
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
