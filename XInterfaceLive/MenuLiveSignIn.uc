class MenuLiveSignIn extends MenuTemplateTitledBA;

// Args: <LIVE_MAIN | MINIED_PROMPT | MINIED_LIVE>

var() MenuStringList	AccountList;
var() MenuScrollArea	ScrollArea;
var() MenuScrollBar		ScrollBar;
var() MenuButtonSprite	ScrollBarArrowUp, ScrollBarArrowDown;
var() MenuActiveWidget	PageUpArea, PageDownArea;

var() int               NewAccountIndex;
var() transient String  LastAccounts;
var() localized string  NewAccountText;
var() localized string  GuestText;

simulated function Init( String Args )
{
    Super.Init( Args );
    
    LastAccounts = "-";
    UpdateAccounts();
    FocusOnAccount(0);
    SetTimer(0.5,true);
}

simulated function Timer()
{
    UpdateAccounts();
}

simulated function FocusOnAccount( int i )
{
    local int NewPosition;

    if( AccountList.Items[i].bHidden != 0 )
    {
        NewPosition = Min( i, Max( 0, AccountList.Items.Length - AccountList.DisplayCount ) );

        AccountList.Position = NewPosition;

        LayoutMenuStringList( AccountList );
	    UpdateScrollBar();
	
	    Assert( AccountList.Items[i].bHidden == 0 );
    }

    FocusOnWidget( AccountList.Items[i] );
}

simulated function ParseAccountList( String Accounts )
{
    local string name;
    local int i;
    local string nameInFocus;

    for( i = 0; i < AccountList.Items.Length; i++ )
    {
        if( AccountList.Items[i].bHasFocus != 0 )
        {
            nameInFocus = AccountList.Items[i].Blurred.Text;
            FocusOnNothing();
        }
    }

    i = 0;

    AccountList.Items.Length = 0;
        
    LastAccounts = accounts;
    
    name = ParseToken(accounts);
    while( name != "" )
    {
        AccountList.Items[i].ContextID = i;
        AccountList.Items[i].Focused.Text = name;
        AccountList.Items[i].Blurred.Text = AccountList.Items[i].Focused.Text;
        i++;
        name = ParseToken(accounts);
    }

    // dashboard
    AccountList.Items[i].ContextID = i;
    AccountList.Items[i].Focused.Text = NewAccountText;
    AccountList.Items[i].Blurred.Text = AccountList.Items[i].Focused.Text;
    NewAccountIndex = i;
    i++;

    LayoutMenuStringList( AccountList );
	UpdateScrollBar();
	
    if( nameInFocus != "" )
    {
        for( i = 0; i < AccountList.Items.Length; i++ )
        {
            if( AccountList.Items[i].Blurred.Text == nameInFocus )
            {
                FocusOnAccount( i );
                return;
            }
        }

        FocusOnAccount( 0 );
    }
}

simulated function UpdateAccounts()
{
    local string Accounts;

    Accounts = ConsoleCommand("XLIVE GETACCOUNTS");
    
    if( accounts == LastAccounts )
        return;

    ParseAccountList( Accounts );
}

simulated function UpdateScrollBar()
{
    if( AccountList.Items.Length <= AccountList.DisplayCount )
    {
        ScrollBar.bHidden = 1;
        ScrollBarArrowUp.bHidden = 1;
        ScrollBarArrowDown.bHidden = 1;
        PageUpArea.bHidden = 1;
        PageDownArea.bHidden = 1;
    }
    else
    {
        ScrollBar.bHidden = 0;
        ScrollBarArrowUp.bHidden = 0;
        ScrollBarArrowDown.bHidden = 0;
        PageUpArea.bHidden = 0;
        PageDownArea.bHidden = 0;

        ScrollBar.Position = AccountList.Position;
        ScrollBar.Length = AccountList.Items.Length;
        ScrollBar.DisplayCount = AccountList.DisplayCount;
        LayoutMenuScrollBarEx( ScrollBar, PageUpArea, PageDownArea );
    }
}

simulated function OnListScroll()
{
    AccountList.Position = ScrollBar.Position;
    LayoutMenuStringList( AccountList );
}

simulated function ScrollListTo( int NewPosition )
{
    if( ScrollBar.Length == 0 )
        return;

    NewPosition = Clamp( NewPosition, 0, Max( 0, ScrollBar.Length - ScrollBar.DisplayCount ) );

    if( ScrollBar.Position == NewPosition )
        return;

    ScrollBar.Position = NewPosition;

    LayoutMenuScrollBar( ScrollBar );
}

simulated function OnListScrollUp()
{
    ScrollListTo( ScrollBar.Position - 1 );
}

simulated function OnListScrollDown()
{
    ScrollListTo( ScrollBar.Position + 1 );
}

simulated function OnListPageUp()
{
    ScrollListTo( ScrollBar.Position - ScrollBar.DisplayCount );
}

simulated function OnListPageDown()
{
    ScrollListTo( ScrollBar.Position + ScrollBar.DisplayCount );
}

simulated function OnListScrollLinesUp( int Lines )
{
    ScrollListTo( ScrollBar.Position - Lines );
}

simulated function OnListScrollLinesDown( int Lines )
{
    ScrollListTo( ScrollBar.Position + Lines );
}

simulated function OnSelect(int ContextID)
{
    if( ContextID == NewAccountIndex )
    {
        SetTimer( 0, false );
        CallMenuClass( "XInterfaceLive.MenuDashboardConfirm", "XLD_LAUNCH_DASHBOARD_NEW_ACCOUNT_SIGNUP 1" );
        return;
    }
    else
    {	
        SetTimer( 0, false );
	    GotoMenuClass( "XInterfaceLive.MenuLivePasscode", MakeQuotedString(AccountList.Items[ContextID].Blurred.Text) @ Args );
	}
}

simulated function OnFocus(int ContextID)
{
    PlayerController(Owner).Gamertag = AccountList.Items[ContextID].Blurred.Text;
}

simulated exec function Hump()
{
    local String Accounts;
    local int i;
    
    SetTimer( 0, false );
    
    Accounts = "\"WWWWWWWWWWWWWWW\"";
    
    for( i = 0; i < 100; ++i)
    {
        Accounts = Accounts @ "\"Bob" @ Rand(100) $"\"";
    }
    
    ParseAccountList( Accounts );
}

simulated exec function Pork()
{
    SetTimer( 0, false );
	GotoMenuClass( "XInterfaceLive.MenuLivePasscode", "Pork" @ Args );
}

simulated function bool MenuClosed( Menu ClosingMenu )
{
    if( ClosingMenu.IsA('MenuDashboardConfirm') )
    {
        SetTimer(0.5,true);
        return true;
    }
}

simulated function HandleInputBack()
{
    SetTimer( 0, false );

    if( Args == "LIVE_MAIN" )
    {
        GotoMenuClass("XInterfaceMP.MenuMultiplayerMain");
    }
    else if( Args == "MINIED_PROMPT" )
    {
        CloseMenu();
    }
    else if( Args == "MINIED_LIVE" )
    {
        GotoMenuClass("MiniEd.MenuMiniEdMain");
    }
    else
    {
        log("Can't go back from unknown args:" @ Args, 'Error');
    }
}

simulated function bool FindNetMenu(Menu M)
{
    return(false);
}

simulated function bool IsNetMenu()
{
    return(false);
}

simulated function bool FindLiveMenu(Menu M)
{
    return(false);
}

simulated function bool IsLiveMenu()
{
    return(false);
}

defaultproperties
{
     AccountList=(Template=(OnFocus="OnFocus",OnSelect="OnSelect"),OnScroll="UpdateScrollBar",Style="TitledStringList")
     ScrollArea=(OnScrollPageUp="OnListPageUp",OnScrollLinesUp="OnListScrollLinesUp",OnScrollLinesDown="OnListScrollLinesDown",OnScrollPageDown="OnListPageDown",Style="TitledStringListScrollArea")
     ScrollBar=(OnScroll="OnListScroll",Style="TitledStringListScrollBar")
     ScrollBarArrowUp=(OnSelect="OnListScrollUp",Style="TitledStringListArrowUp")
     ScrollBarArrowDown=(OnSelect="OnListScrollDown",Style="TitledStringListArrowDown")
     PageUpArea=(OnSelect="OnListPageUp",Style="TitledStringListPageScrollArea")
     PageDownArea=(OnSelect="OnListPageDown",Style="TitledStringListPageScrollArea")
     NewAccountText="New account"
     GuestText="Guest"
     MenuTitle=(Text="Sign In")
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
