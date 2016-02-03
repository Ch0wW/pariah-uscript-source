class MenuProfileEditDifficulty extends MenuTemplateTitledBA;

var() MenuButtonText    Options[10];
var() config int        Position;
var ProfileData         mProfileData;


simulated function Init( String Args )
{
    local int d;

    mProfileData = GetProfileData();
    assert(mProfileData != None);

    Super.Init( Args );
    UpdateOptions();

    d = mProfileData.Difficulty();
    if( d < 0 )
    {
        d = 0;
    }

    if( Options[d].bHidden == 0 )
    {
        FocusOnWidget( Options[d] );
    }
    else
    {
        Position = Clamp( Position, 0, ArrayCount(Options) - 1 );

        if( Options[Position].bHidden != 0 )
        {
            for( Position = 0; Options[Position].bHidden != 0; Position++ )
                continue;
        }
        
        FocusOnWidget( Options[Position] );
    }
}

simulated function UpdateOptions()
{
    local int i;
    
    for( i = 0; i < class'GameInfo'.static.GetNumDifficultyLevels(); ++i )
    {
        Assert( i < ArrayCount(Options) );

        Options[i].ContextID = i;
        Options[i].Blurred.Text = class'GameInfo'.static.GetDifficultyName(i);
        Options[i].Focused.Text = Options[i].Blurred.Text;
        Options[i].bHidden = 0;
    }

    while( i < ArrayCount( Options ) )
    {
        Options[i].bHidden = 1;
        ++i;
    }

    LayoutArray( Options[0], 'TitledOptionLayout' );
}

simulated event PostEditChange()
{
    UpdateOptions();
}

simulated function OnSelect( int contextId )
{
    mProfileData.Difficulty(string(contextId));
    CallMenuClass("XInterfaceCommon.MenuProfileSaving");    
}

defaultproperties
{
     Options(0)=(OnSelect="OnSelect",Style="TitledTextOption")
     MenuTitle=(Text="Difficulty")
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
