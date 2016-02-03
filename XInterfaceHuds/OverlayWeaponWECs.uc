class OverlayWeaponWECs extends MenuTemplate;

var() MenuSprite Border;

var() MenuText LevelDescriptions[3];
var() int bLevelActivated[3];
var() int LevelCosts[3];

var() float BorderMargin;
var() float SpaceBetweenDescriptions;

var() Color ColorOn;
var() Color ColorOff;

var() MenuSprite WecDots[7];
var() int WecDotsUsed;
var() IntBox WecDotOff;
var() IntBox WecDotOn;
var() bool CanBeUpgraded;

var() float LabelOffsetX;
var() float LabelOffsetY;

var() MenuText ApplyText;

struct DotLayout
{
    var() Array<Vector> Positions;
};

var() Array<DotLayout> DotLayouts;

var() localized String StringLeftMouse;

simulated function Init( String Args )
{   
    local String IconString;
    local PlayerController PC;
    Super.Init( Args );
    
    PC = PlayerController(Owner);    
    
    if( IsOnConsole() )
    {
        IconString = class'Fonts_rc'.static.DescribeBinding( "Joy7", PC );
    }
    else
    {
        IconString = StringLeftMouse;
    }

    ApplyText.Text = ReplaceSubstring( ApplyText.Text, "<KEY>", IconString );
    
    if( Caps(Left(ApplyText.Text, 1)) != Left(ApplyText.Text, 1) )
    {
        ApplyText.Text = Caps(Left(ApplyText.Text, 1)) $ Right( ApplyText.Text, Len(ApplyText.Text) - 1 );
    }
}

simulated function ShowWeaponInfo( VGWeapon Weapon )
{
    local int i;
    local VehiclePlayer pc;

    PC = VehiclePlayer(Owner);
    
    CanBeUpgraded = false;
    
    for( i = 0; i < Min( Weapon.WECMaxLevel, ArrayCount(LevelCosts)); ++i )
    {
        LevelDescriptions[i].Text = Weapon.WeaponMessageClass.static.GetString(i + 1);
        LevelDescriptions[i].bHidden = 0;
        
        if( Weapon.WECLevel <= i )
        {
            bLevelActivated[i] = 0;
        }
        else
        {
            bLevelActivated[i] = 1;
        }
        
        LevelCosts[i] = Weapon.WECPerLevel[i];
        
        if( (Weapon.WECLevel < Weapon.WECMaxLevel) && (Weapon.WECLevel == i) && ( PC.WecCount >= Weapon.WECPerLevel[i]) )
        {
            CanBeUpgraded = true;
        }
    }
    
    for( i = i; i < ArrayCount(LevelCosts); ++i )
    {
        LevelDescriptions[i].bHidden = 1;
        LevelCosts[i] = 0;
    }
    
    bDynamicLayoutDirty = true;
}

simulated function LayoutWecDots( float PosX, float PosY, int Count, bool Active )
{
    local int LocalDotIndex;
    local DotLayout Layout;
    
    if( Count == 0 )
    {
        return;
    }
    
    Assert( (Count - 1) < DotLayouts.Length );
    Layout = DotLayouts[Count - 1];
    
    LocalDotIndex = 0;
    
    for( LocalDotIndex = 0; LocalDotIndex < Count; ++LocalDotIndex )
    {
        Assert( WecDotsUsed < ArrayCount(WecDots) );
        
        WecDots[WecDotsUsed].bHidden = 0;
        
        WecDots[WecDotsUsed].PosX = PosX + Layout.Positions[LocalDotIndex].X;
        WecDots[WecDotsUsed].PosY = PosY + Layout.Positions[LocalDotIndex].Y;
    
        if( Active )
        {
            WecDots[WecDotsUsed].TextureCoords = WecDotOn;
        }
        else
        {
            WecDots[WecDotsUsed].TextureCoords = WecDotOff;
        }
        
        ++WecDotsUsed;
    }
}

simulated function DoDynamicLayout( Canvas C )
{
    local float OffsetY;
    local float OffsetX;
    local float LineDY;
    local float X;
    local float Y;
    local int i;
    
    Super.DoDynamicLayout( C );
    
    WecDotsUsed = 0;
    
    for( i = 0; i < ArrayCount(LevelDescriptions); ++i )
    {
        if( LevelDescriptions[i].bHidden != 0 )
        {
            break;
        }
        
        X = default.LevelDescriptions[0].PosX + OffsetX;
        Y = default.LevelDescriptions[0].PosY + OffsetY;

        LevelDescriptions[i].DrawPivot = DP_UpperLeft; // Style is trouncing this!
        LevelDescriptions[i].PosX = X + LabelOffsetX;
        LevelDescriptions[i].PosY = Y + LabelOffsetY;
        LevelDescriptions[i].MaxSizeX = default.LevelDescriptions[0].MaxSizeX - OffsetX;

        if( bool(BLevelActivated[i]) )
        {
            LevelDescriptions[i].DrawColor = ColorOn;
        }
        else
        {
            LevelDescriptions[i].DrawColor = ColorOff;
        }

        LineDY = GetWrappedTextHeight( C, LevelDescriptions[i] ) + SpaceBetweenDescriptions;

        LayoutWecDots( X, Y + (LineDY * 0.5), LevelCosts[i], bool(bLevelActivated[i]) );

        OffsetY += LineDY;
    }

    for( i = WecDotsUsed; i < ArrayCount(WecDots); ++i )
    {
        WecDots[i].bHidden = 1;
    }

    Border.PosX = LevelDescriptions[0].PosX - BorderMargin - LabelOffsetX;
    Border.PosY = LevelDescriptions[0].PosY - BorderMargin - LabelOffsetY;

    Border.ScaleY = (OffsetY - SpaceBetweenDescriptions) + (2.0 * BorderMargin);

    if( !CanBeUpgraded )
    {
        Border.ScaleX = (LevelDescriptions[0].MaxSizeX - LabelOffsetX) + (2.0 * BorderMargin);
        ApplyText.bHidden = 1;
    }
    else
    {
        Border.ScaleX = 1.f - (2.0 * Border.PosX);
        ApplyText.bHidden = 0;
        
        ApplyText.PosX = LevelDescriptions[0].PosX + LevelDescriptions[0].MaxSizeX + BorderMargin;
        ApplyText.PosY = LevelDescriptions[0].PosY;
        
        ApplyText.DrawPivot = DP_UpperLeft; // Style is trouncing this!
        ApplyText.MaxSizeX = (Border.PosX + Border.ScaleX) - (ApplyText.PosX);
    }
}

defaultproperties
{
     Border=(DrawColor=(A=255),Style="Border")
     LevelDescriptions(0)=(PosX=0.150000,PosY=0.150000,ScaleX=0.700000,ScaleY=0.700000,MaxSizeX=0.380000,bWordWrap=1,Style="NormalLabel")
     BorderMargin=0.030000
     SpaceBetweenDescriptions=0.002000
     ColorOn=(G=150,R=255,A=255)
     ColorOff=(B=255,G=255,R=255,A=255)
     WecDots(0)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',DrawPivot=DP_MiddleMiddle,ScaleX=0.600000,ScaleY=0.600000,Pass=5,bHidden=1)
     WecDotOff=(X1=154,Y1=16,X2=169,Y2=31)
     WecDotOn=(X1=154,X2=169,Y2=15)
     LabelOffsetX=0.025000
     ApplyText=(Text="<KEY> to apply upgrades.",ScaleX=0.700000,ScaleY=0.700000,bWordWrap=1,Style="NormalLabel")
     DotLayouts(0)=(Positions=())
     DotLayouts(1)=(Positions=((Y=-0.011000),(Y=0.011000)))
     DotLayouts(2)=(Positions=((Y=-0.011000),(X=0.009400,Y=0.005500),(X=-0.009400,Y=0.005500)))
     StringLeftMouse="Left mouse button"
     CrossFadeRate=4.000000
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
}
