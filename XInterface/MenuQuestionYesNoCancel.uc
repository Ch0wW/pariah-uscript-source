class MenuQuestionYesNoCancel extends MenuTemplateTitledBXA;

var() MenuText Question;

simulated function OnYes()
{
}

simulated function OnNo()
{
}

simulated function OnCancel()
{
}

simulated function OnAButton()
{
    OnYes();
}

simulated function HandleInputBack()
{
    OnCancel();
}

simulated function OnXButton()
{
    OnNo();
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "A" )
    {
        OnAButton();
        return( true );
    }
    if( ButtonName ~= "X" )
    {
        OnXButton();
        return( true );
    }    
    if( ButtonName ~= "B" )
    {
        OnBButton();
        return( true );
    }
    return( Super.HandleInputGamePad( ButtonName ) );
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

defaultproperties
{
     Question=(Style="MessageText")
     ALabel=(Text="Yes")
     APlatform=MWP_All
     XLabel=(Text="No")
     BLabel=(Text="Cancel")
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
