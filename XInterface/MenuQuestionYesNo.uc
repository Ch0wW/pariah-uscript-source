class MenuQuestionYesNo extends MenuTemplateTitledBA;

var() MenuText Question;
var() bool bSelectedYes;

simulated function Init( String Args )
{
    local MenuTemplateTitled SubMenu;
    local String QuestionText, TitleText;

    Super.Init( Args );

    SubMenu = MenuTemplateTitled( PreviousMenu );
    
    if( SubMenu != None )
        Background = SubMenu.Background;
    
    if( ( Question.Text == "" ) && ( Args != "" ) )
    {
        QuestionText = ParseToken( Args );
        TitleText = ParseToken( Args );
        SetText( QuestionText, TitleText );
    }

	ALabel.Text = StringYes;
	BLabel.Text = StringNo;
}

simulated event SetText( String QuestionText, optional String TitleText )
{
    local int i;

    if( TitleText != "" )
        MenuTitle.Text = TitleText;
        
    i = CountOccurances( QuestionText, "\\n\\n" );
    
    if( i > 1 )
    {
        Question = class'MenuDefaults'.default.LongMessageText;
        Question.Text = QuestionText;
    }
    else if( i == 1 )
    {
        Question = class'MenuDefaults'.default.MedMessageText;
        Question.Text = QuestionText;
    }
    else
    {
        Question.Text = QuestionText;
    }
}

simulated function String GetText()
{
    return( Question.Text );
}

simulated function OnYes()
{
    bSelectedYes = true;
    CloseMenu();
}

simulated function OnNo()
{
    CloseMenu();
}

simulated function HandleInputStart()
{
}

simulated function OnAButton()
{
    OnYes();
}

simulated function HandleInputBack()
{
    OnBButton();
}

simulated function OnBButton()
{
    OnNo();
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName == "A" )
    {
        OnAButton();
        return( true );
    }

    if( ButtonName == "B" )
    {
        OnBButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     Question=(Style="MessageText")
     APlatform=MWP_All
     MenuTitle=(Text="Please Confirm")
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
