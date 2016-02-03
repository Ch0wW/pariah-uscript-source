class MenuObjectives extends MenuTemplate;

// These are for other menus to query if need be:
var() String PrimaryObjective;
var() String SubObjective;

var() MenuText Objectives[2];
var() MenuSprite Border;

var() float SubIndent;
var() float SpaceBetweenObjectives;

var() float BorderMargin;

var() float MinHoldTime;
var() float HoldTimePerCharacter;
var() float FadeOutTime;

var() float HoldTime;

var() bool ForceVisbile;

const ONLY_SHOW_ONE = true;

simulated function Init( String msg )
{
    Super.Init( Args );
    CrossFadeRate = 1.f / FadeOutTime;
}

simulated function ShowObjectives( String PrimaryObjText, String SubObjText, bool AutoHide )
{
    local PlayerController PC;
    
    if( ONLY_SHOW_ONE )
    {
        if( SubObjText != "" )
        {
            Objectives[0].Text = SubObjText;
        }
        else
        {
            Objectives[0].Text = PrimaryObjText;
        }
        
        Objectives[1].Text = "";
    }
    else
    {
        Objectives[0].Text = PrimaryObjText;
        Objectives[1].Text = SubObjText;
    }
    
    PrimaryObjective = PrimaryObjText;
    SubObjective = SubObjText;

    bDynamicLayoutDirty = true;
    
    PC = PlayerController(Owner);
    Assert( PC != None );
    Assert( PC.MyHud.ObjectivesMenu == self );
    
    HoldTime = Max( MinHoldTime, HoldTimePerCharacter * float( Len(Objectives[0].Text) + Len(Objectives[1].Text) ) );

    if( AutoHide )
    {
        if( !ForceVisbile )
        {
            CrossFadeLevel = 1.f;
            CrossFadeDir = TD_None;

            SetTimer( HoldTime, false );
        }
    }
    else
    {
        if( ForceVisbile )
        {
            ForceVisbile = false;
            CrossFadeDir = TD_Out;
        }
        else
        {
            ForceVisbile = true;
            CrossFadeLevel = 1.f;
        }
    }
}

simulated function Timer()
{
    if( !ForceVisbile )
    {
        CrossFadeDir = TD_Out;
    }
}

simulated function DoDynamicLayout( Canvas C )
{
    local float OffsetY;
    local float OffsetX;
    local int i;
    
    Super.DoDynamicLayout( C );
    
    for( i = 0; i < ArrayCount(Objectives); ++i )
    {
        Objectives[i].DrawPivot = DP_UpperLeft; // Style is trouncing this!
        Objectives[i].PosX = default.Objectives[0].PosX + OffsetX;
        Objectives[i].PosY = default.Objectives[0].PosY + OffsetY;
        Objectives[i].MaxSizeX = default.Objectives[0].MaxSizeX - OffsetX;
        
        OffsetY += GetWrappedTextHeight( C, Objectives[i] ) + SpaceBetweenObjectives;
        OffsetX += SubIndent;
    }
    
    Border.PosX = Objectives[0].PosX - BorderMargin;
    Border.PosY = Objectives[0].PosY - BorderMargin;

    Border.ScaleX = Objectives[0].MaxSizeX + (2.0 * BorderMargin);
    Border.ScaleY = (OffsetY - SpaceBetweenObjectives) + (2.0 * BorderMargin);
}

defaultproperties
{
     Objectives(0)=(DrawColor=(B=255,G=255,R=255,A=255),PosX=0.080000,PosY=0.190000,MaxSizeX=0.500000,bWordWrap=1,Style="NormalLabel")
     Border=(DrawColor=(A=128),Style="Border")
     SubIndent=0.030000
     SpaceBetweenObjectives=0.005000
     BorderMargin=0.030000
     MinHoldTime=3.000000
     HoldTimePerCharacter=0.100000
     FadeOutTime=0.750000
     CrossFadeLevel=0.000000
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
     bRenderLevel=True
     bIgnoresInput=True
     bShowMouseCursor=False
}
