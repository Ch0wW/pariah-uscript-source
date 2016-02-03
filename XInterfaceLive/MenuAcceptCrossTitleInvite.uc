class MenuAcceptCrossTitleInvite extends MenuQuestionYesNo;

var() String Inviter, Invited;
var() bool Invitation;

var() localized String InviteTitle, JoinTitle;
var() localized String InviteQuestion, JoinQuestion;

simulated function Init( String Args )
{
    local String S;
    
    Super.Init( Args );
    
    S = ConsoleCommand( "XLIVE GET_CROSS_TITLE_INVITE_INFO" );

    Inviter = ParseToken( S );
    Invited = ParseToken( S );
    Invitation = bool(ParseToken( S ));
    
    if( Invitation )
    {
        MenuTitle.Text = InviteTitle;
        Question.Text = InviteQuestion;
    }
    else
    {
        MenuTitle.Text = JoinTitle;
        Question.Text = JoinQuestion;
    }

    Question.Text = ReplaceSubString( Question.Text, "<INVITED>", Invited );
    Question.Text = ReplaceSubString( Question.Text, "<INVITER>", Inviter );
}

simulated function OnYes()
{
	GotoMenuClass( "XInterfaceLive.MenuLivePasscode", MakeQuotedString(Invited) @ "CROSS_TITLE_JOIN" );
}

simulated function OnNo()
{
    if( "SUCCESS" != ConsoleCommand( "XLIVE REJECT_CROSS_TITLE_INVITE" ) )
        OverlayErrorMessageBox( "REJECT_CROSS_TITLE_INVITE_FAILED" );
    else
    {
        // Because we're now jumping straight to main, we'd better fire off the silent-login
        // as if we'd gone manually from the Start menu.
        ConsoleCommand("XLIVE SILENT_LOGON");
        CloseMenu();
    }
}

defaultproperties
{
     InviteTitle="Pending game invitation"
     JoinTitle="Pending game join"
     InviteQuestion="<INVITED> has a pending game invitation from <inviter>. Accept invitation?"
     JoinQuestion="<INVITED> wants to join <INVITER>'s game. Join session?"
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
