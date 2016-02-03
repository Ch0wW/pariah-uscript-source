class MenuInternetManageBuddies extends MenuTemplateTitledBA;

// I apologize in advance for the lack of elegance found here. Should functionality like this be
// required in general it would be better to implement a widget like a MenuStringList that
// handles all of this, to the max.

const MAX_BUDDIES = 9;

var() config Array<String> Buddies;

var() MenuEditBox EditBoxes[MAX_BUDDIES];
var localized String StringAddNew;
var localized String StringNoBuddies;

simulated function Init( String Args )
{
    local int i;

    CleanList(Buddies);

    for( i = 0; i < Buddies.Length; ++i )
    {
        EditBoxes[i].Blurred.Text = Buddies[i];
        EditBoxes[i].Focused.Text = Buddies[i];
        EditBoxes[i].OnDeactivate = 'OnDeactivate';
        EditBoxes[i].OnSelect = 'OnDeactivate';
        EditBoxes[i].ContextID = i;
    }
    
    if( i < MAX_BUDDIES )
    {
        EditBoxes[i].Blurred.Text = StringAddNew;
        EditBoxes[i].Focused.Text = StringAddNew;
        EditBoxes[i].OnActivate = 'ClearAddNewBuddy';
        EditBoxes[i].ContextID = i;
        ++i;
    }
    
    while( i < MAX_BUDDIES )
    {
        EditBoxes[i].ContextID = i;
        ++i;
    }
}

static simulated function CleanList( out Array<String> List )
{
    local int i;

    for( i = 0; i < List.Length; ++i )
    {
        if( List[i] == "" )
        {
            List.Remove( i, 1 );
            --i;
        }
    }
    
    if( List.Length > MAX_BUDDIES )
    {
        List.Remove( MAX_BUDDIES, List.Length - MAX_BUDDIES );
    }
}

simulated function HandleInputBack()
{
    SaveBuddies();
    GotoMenuClass("XInterfaceMP.MenuInternetMain");
}

simulated function OnAButton()
{
    local MenuMessageBox MessageBox;

    SaveBuddies();
    
    if( Buddies.Length == 0 )
    {
        MessageBox = Spawn( class'XInterfaceCommon.MenuMessageBox', Owner );
        MessageBox.SetText( StringNoBuddies );
        CallMenu( MessageBox );
        return;
    }
    else
    {
        StartQuery(self);
    }
}

simulated function SaveBuddies()
{
    local int i;
    
    Buddies.Remove( 0, Buddies.Length );
    
    for( i = 0; i < MAX_BUDDIES; ++i )
    {
        if( EditBoxes[i].OnActivate == 'ClearAddNewBuddy' )
        {
            break;
        }

        if( bool(EditBoxes[i].bDisabled) )
        {
            break;
        }
    
        Buddies[Buddies.Length] = EditBoxes[i].Blurred.Text;
    }
    
    SaveConfig();
}

static simulated function StartQuery( MenuBase PrevMenu )
{
    local MenuInternetServerList M;
    local int i;
 
    CleanList(default.Buddies);
 
    if( default.Buddies.Length == 0 )
    {
        PrevMenu.GotoMenuClass(String(default.class));
        return;
    }
 
    M = PrevMenu.Spawn( class'MenuInternetServerList', PrevMenu.Owner );
    M.ListMode = SLM_Buddies;
    
    for( i = 0; i < default.Buddies.Length; ++i )
    {
        M.AddQueryTerm( "buddy", QT_Equals, default.Buddies[i] );
    }
    
    PrevMenu.GotoMenu( M );
}

simulated function DoDynamicLayout( Canvas C )
{
    local int i;
    local int bDisabled;

    Super.DoDynamicLayout( C );

    for( i = 0; i < MAX_BUDDIES; ++i )
    {
        EditBoxes[i].bDisabled = 0;
    }
    
    LayoutArray( EditBoxes[0], 'TitledOptionLayout' );
    
    for( i = 0; i < MAX_BUDDIES; ++i )
    {
        if( EditBoxes[i].OnActivate == 'ClearAddNewBuddy' )
        {
            bDisabled = 1;
        }
        else
        {
            EditBoxes[i].bDisabled = bDisabled;
        }
    }
}

simulated function ClearAddNewBuddy( int i )
{
    EditBoxes[i].Blurred.Text = "";
    EditBoxes[i].Focused.Text = "";
    EditBoxes[i].OnSelect = 'ValidateNewBuddySelect';
    EditBoxes[i].OnDeactivate = 'ValidateNewBuddyDeactivate';
}

simulated function ValidateNewBuddySelect( int i )
{
    ValidateNewBuddy(i, true);
}

simulated function ValidateNewBuddyDeactivate( int i )
{
    ValidateNewBuddy(i, false);
}

simulated function ValidateNewBuddy( int i, bool FocusOnNext )
{
    EditBoxes[i].OnActivate = '';
    EditBoxes[i].OnSelect = 'OnDeactivate';
    EditBoxes[i].OnDeactivate = 'OnDeactivate';

    if( EditBoxes[i].Blurred.Text == "" )
    {
        EditBoxes[i].Blurred.Text = StringAddNew;
        EditBoxes[i].Focused.Text = StringAddNew;
        EditBoxes[i].OnActivate = 'ClearAddNewBuddy';
        return;
    }
    
    ++i;
    
    if( i < MAX_BUDDIES )
    {
        EditBoxes[i].Blurred.Text = StringAddNew;
        EditBoxes[i].Focused.Text = StringAddNew;
        EditBoxes[i].OnActivate = 'ClearAddNewBuddy';
        EditBoxes[i].bDisabled = 0;
    }
    else
    {
        i = 0;
    }
    
    if( FocusOnNext )
    {
        FocusOnWidget( EditBoxes[i] );
        SelectWidget( EditBoxes[i] );
    }
}

simulated function OnDeactivate( int i )
{
    local int refocus;
    
    if( EditBoxes[i].Blurred.Text != "" )
    {
        return;
    }
    
    refocus = i;
    
    while( i < MAX_BUDDIES )
    {
        if( EditBoxes[i].OnActivate == 'ClearAddNewBuddy' )
        {
            EditBoxes[i].OnActivate = '';
            EditBoxes[i].Blurred.Text = "";
            EditBoxes[i].Focused.Text = "";
            EditBoxes[i].bDisabled = 1;
            break;
        }

        if( bool(EditBoxes[i].bDisabled) || (i == (MAX_BUDDIES - 1) ) )
        {
            EditBoxes[i].Blurred.Text = StringAddNew;
            EditBoxes[i].Focused.Text = StringAddNew;
            EditBoxes[i].OnActivate = 'ClearAddNewBuddy';
            EditBoxes[i].bDisabled = 0;
            break;
        }
    
        EditBoxes[i].Blurred.Text = EditBoxes[i + 1].Blurred.Text;
        EditBoxes[i].Focused.Text = EditBoxes[i + 1].Blurred.Text;
        EditBoxes[i].OnActivate = EditBoxes[i + 1].OnActivate;
        EditBoxes[i].OnDeactivate = EditBoxes[i + 1].OnDeactivate;
        EditBoxes[i].bDisabled = EditBoxes[i + 1].bDisabled;
        ++i;
    }
}

defaultproperties
{
     EditBoxes(0)=(MaxLength=15,OnDeactivate="OnDeactivate",Style="EditListBox")
     StringAddNew="Add New Buddy"
     StringNoBuddies="Your buddy list is empty!"
     ALabel=(Text="Find Online")
     APlatform=MWP_All
     MenuTitle=(Text="Manage Buddies")
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
