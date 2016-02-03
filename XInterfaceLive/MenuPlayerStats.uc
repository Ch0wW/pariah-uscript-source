class MenuPlayerStats extends MenuTemplateTitledB;
// Args == "<GAMER TAG>"

var() MenuText NameLabel;
var() MenuText PointsLabel;
var() MenuText KillsLabel;
var() MenuText DeathsLabel;
var() MenuText GamesPlayedLabel;
var() MenuText SpecialsLabel;
var() MenuText EfficiencyLabel;

var() MenuText NameValue;
var() MenuText PointsValue;
var() MenuText KillsValue;
var() MenuText DeathsValue;
var() MenuText GamesPlayedValue;
var() MenuText SpecialsValue;
var() MenuText EfficiencyValue;

var() string Gamertag;

simulated function Init( String Args )
{
    Gamertag = Args;
    
    NameValue.Text = ParseToken(Args);

    GetResults();
    Super.Init(Args);
}

simulated function GetResults()
{
    local string Results;
    Results = ConsoleCommand("XLIVE STAT_GAMER_LEADERBOARD_DETAILS"@Gamertag);

    log("Gamer details: "$Results);

    PointsValue.Text = ParseToken(Results);
    KillsValue.Text = ParseToken(Results);
    DeathsValue.Text = ParseToken(Results);
    GamesPlayedValue.Text = ParseToken(Results);
    SpecialsValue.Text = ParseToken(Results);
    EfficiencyValue.Text = ParseToken(Results);
}

simulated exec function Pork()
{
    NameValue.Text = "Bob";
    PointsValue.Text = "1000";
    KillsValue.Text = "1032";
    DeathsValue.Text = "5054";
    GamesPlayedValue.Text = "12303";
    SpecialsValue.Text = "3434";
    EfficiencyValue.Text = "40.5";
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    
    LayoutWidgets( NameLabel, EfficiencyLabel, 'DetailLabelsLayout' );
    LayoutWidgets( NameValue, EfficiencyValue, 'DetailValuesLayout' );
}

defaultproperties
{
     NameLabel=(Text="Name:",Style="DetailLabel")
     PointsLabel=(Text="Points:",Style="DetailLabel")
     KillsLabel=(Text="Kills:",Style="DetailLabel")
     DeathsLabel=(Text="Deaths:",Style="DetailLabel")
     GamesPlayedLabel=(Text="Games Played:",Style="DetailLabel")
     SpecialsLabel=(Text="Specials:",Style="DetailLabel")
     EfficiencyLabel=(Text="Efficiency:",Style="DetailLabel")
     NameValue=(Style="DetailValue")
     PointsValue=(Style="DetailValue")
     KillsValue=(Style="DetailValue")
     DeathsValue=(Style="DetailValue")
     GamesPlayedValue=(Style="DetailValue")
     SpecialsValue=(Style="DetailValue")
     EfficiencyValue=(Style="DetailValue")
     MenuTitle=(Text="Player Statistics")
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
