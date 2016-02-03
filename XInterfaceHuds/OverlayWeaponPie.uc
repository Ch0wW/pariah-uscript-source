class OverlayWeaponPie extends MenuTemplate;

const SLICE_COUNT = 8;
const WEC_DOTS_PER_SLICE = 3;
const WEC_DOT_COUNT = 24;

const RADIANS_PER_SLICE = 0.785;

var() float PivotX;
var() float PivotY;

var() float FullScreenPivotX;
var() float FullScreenPivotY;

var() float SplitPivotX[2];
var() float SplitPivotY[2];

var() float WindingDirection; // -1 or 1
var() float RotationOffset; // Degrees
var() float WecDotArc; // Degrees

var() float IconRadius;
var() float WecRadius;
var() float MouseDotRadius;

var() MenuButtonSprite Icons[SLICE_COUNT];
var() MenuSprite WecDots[WEC_DOT_COUNT];
var() MenuText WeaponName;

var() MenuSprite MouseDot;

var() IntBox WecDotOff;
var() IntBox WecDotOn;
 
var() MenuSprite BackgroundDisc[4];
var() MenuSprite InfoDisc[4];

var() MenuLayer WecLayerWidget;
var() OverlayWeaponWECs WecLayer;

var() float SelectionOffsetX;
var() float SelectionOffsetY;

var() Material EmptyIcon;
var() IntBox EmptyIconCoords;

var() VGWeapon Weapons[SLICE_COUNT];

var() float JoyX;
var() float JoyY;
var() float JoyU;
var() float JoyV;

var() float JoyDeadZone;
var() float MouseDeadZone;

var() int CurrentSlice;

var() Interactions.EInputKey HoldKey;

var() float InfoDelayTime;

var() float MouseAxisMagnitude;

var() float MousePosX;
var() float MousePosY;

var() float NormMousePosX;
var() float NormMousePosY;

var() float RotScaleX;
var() float RotScaleY;

var() localized String NoAmmo;

simulated function Init( String Args )
{
    local int i;
    local VehiclePlayer PC;
    
    local Interactions.EInputAction Action;
    local float Delta;

    Assert( SLICE_COUNT * WEC_DOTS_PER_SLICE == WEC_DOT_COUNT );

    PC = VehiclePlayer(Owner);
    Assert( PC != None );

    PC.GetInputAction( Action, HoldKey, Delta );

    Assert( Action == IST_Press );
    Assert( HoldKey != IK_None );
    
    Super.Init( Args );
    
    for( i = 0; i < SLICE_COUNT; ++i )
    {
        Icons[i].ContextId = i;
    }
    
    SetTimer( 0.15, true );
    
    WecLayer = Spawn( class'XInterfaceHuds.OverlayWeaponWECs', Owner );
    WecLayer.Init("");
    WecLayerWidget.Layer = WecLayer;
    
    ConsoleCommand("HideObjectives");
    
    InfoDelayTime += Level.TimeSeconds;
    
    GetWeapons();
}

simulated function bool IsSplit()
{
    return( (CanvasSizeX / CanvasSizeY) > 1.5f );
}

simulated function Timer()
{
    if( (Level.TimeSeconds > InfoDelayTime) && (WecLayer.CrossFadeLevel <= 0.f) )
    {
        //log("TOEKNEEEEE");
        HudADeathMatch(VehiclePlayer(Owner).myHUD).bFromWECMenu = true;
        WecLayer.CrossFadeDir = TD_In;
    }

    GetWeapons();
}

simulated function float ToRadians( float Degrees )
{
    return( Degrees * (Pi / 180.0) );
}

simulated function float ToDegrees( float Radians )
{
    return( 180.0 * (Radians / Pi) );
}

simulated function float GetTheta( int SliceIndex )
{
    // Return the radian angle for the given slice:
    return( ToRadians(RotationOffset) + ( WindingDirection * 2.0 * Pi * ( float(SliceIndex) / float(SLICE_COUNT) ) ) );
}

simulated function GetWeapons()
{
    local VehiclePlayer pc;
    local Inventory inv;
    local VGWeapon weap;
    local VGWeapon activeWeap;
    local int i;
    local VGWeapon NewWeapons[SLICE_COUNT];

    PC = VehiclePlayer(Owner);
    
    if( (PC != None) && (PC.Pawn != None) )
    {
        inv = PC.Pawn.Inventory;
    }

    while( inv != None )
    {
        weap = VGWeapon(inv);
        inv = inv.inventory;
        
        if( weap == None )
        {
            continue;
        }
        
        if( weap.IconMaterial == None )
        {
            continue;
        }

        i = weap.InventoryGroup - 1;
        
        if( i > SLICE_COUNT )
        {
            continue;
        }

        if( NewWeapons[i] != None )
        {
            continue;
        }

        NewWeapons[i] = weap;
    }
    
    for( i = 0; i < SLICE_COUNT; ++i )
    {
        if( Weapons[i] != NewWeapons[i] )
        {
            Weapons[i] = NewWeapons[i];
            bDynamicLayoutDirty = true;
        }
    }

    activeWeap = VGWeapon(PC.Pawn.Weapon);
        
    // Select current:
    if( activeWeap != None && CurrentSlice == -1)
    {
        for( i = 0; i < SLICE_COUNT; ++i )
        {
            if( Weapons[i] == activeWeap )
            {
                CurrentSlice = i;
                break;
            }
        }
    }
}

simulated event DoDynamicLayout( Canvas C )
{
    local int i, j, wi;
    local float t, wt;
    local float x, y;
    local float arc;
    local float halfArc;
    local float arcStep;
    local PlayerController PC;

    Super.DoDynamicLayout( C );

    RotScaleX = 1.f;
    RotScaleY = (CanvasSizeX / CanvasSizeY);

    PC = PlayerController(Owner);

    if( IsSplit() )
    {
        i = 0;
        
        if( ( PC.Player != None ) && ( PC.Player.SplitIndex > 0 ) )
            i = PC.Player.SplitIndex;
        
        i = Clamp( i, 0, ArrayCount(SplitPivotX) - 1 );
        
        PivotX = SplitPivotX[i];
        PivotY = SplitPivotY[i];

        // Owe my anus!
        RotScaleX *= ResScaleX;
        RotScaleY *= ResScaleX;
    }
    else
    {
        PivotX = FullScreenPivotX;
        PivotY = FullScreenPivotY;
    }

    for( i = 0; i < ArrayCount(BackgroundDisc); ++i )
    {
        BackgroundDisc[i].PosX = PivotX;
        BackgroundDisc[i].PosY = PivotY;
        InfoDisc[i].PosX = PivotX;
        InfoDisc[i].PosY = PivotY;
    }

    arc = ToRadians( WecDotArc );
    halfArc = arc * 0.5;
    arcStep = arc / float(WEC_DOTS_PER_SLICE - 1);

    for( i = 0; i < SLICE_COUNT; ++i )
    {
        // This calculates the pivot for the icon:
        t = GetTheta(i);
        x = PivotX + ( Cos(t) * IconRadius * RotScaleX );
        y = PivotY + ( Sin(t) * IconRadius * RotScaleY );

        Icons[i].Blurred.PosX = x;
        Icons[i].Blurred.PosY = y;

        Icons[i].Focused.PosX = x;
        Icons[i].Focused.PosY = y;

        if( Weapons[i] != None )
        {
            Icons[i].Blurred.WidgetTexture = Weapons[i].IconMaterial;
            Icons[i].Blurred.TextureCoords = Weapons[i].IconCoords;
            Icons[i].Focused.WidgetTexture = Weapons[i].IconMaterial;
            Icons[i].Focused.TextureCoords = Weapons[i].IconCoords;
        }
        else
        {
            Icons[i].Blurred.WidgetTexture = EmptyIcon;
            Icons[i].Blurred.TextureCoords = EmptyIconCoords;
            Icons[i].Focused.WidgetTexture = EmptyIcon;
            Icons[i].Focused.TextureCoords = EmptyIconCoords;

        }

        // Put the WEC dots on the same angle across the arc:
        for( j = 0; j < WEC_DOTS_PER_SLICE; ++j )
        {
            if( (Weapons[i] != None) && (j < Weapons[i].WecLevel) )
            {
                WecDots[wi].TextureCoords = WecDotOn;
                
                if( Weapons[i].IsA('TitansFist') )
                {
                    WecDots[wi].WidgetTexture = EmptyIcon;
                    WecDots[wi].TextureCoords = EmptyIconCoords;
                }
            }
            else if(Weapons[i] != None) 
            {
                WecDots[wi].TextureCoords = WecDotOff;
                
                if( Weapons[i].IsA('TitansFist') )
                {
                    WecDots[wi].WidgetTexture = EmptyIcon;
                    WecDots[wi].TextureCoords = EmptyIconCoords;
                }            
            }
            else 
            {
                WecDots[wi].WidgetTexture = EmptyIcon;
                WecDots[wi].TextureCoords = EmptyIconCoords;
            }
        
            wt = (t - halfArc) + (float(j) * arcStep);

            x = PivotX + ( Cos(wt) * WecRadius * RotScaleX );
            y = PivotY + ( Sin(wt) * WecRadius * RotScaleY );

            WecDots[wi].PosX = x;
            WecDots[wi].PosY = y;

            ++wi;
        }
    }
    
    for( i = 0; i < SLICE_COUNT; ++i )
    {
        t = ToDegrees( RADIANS_PER_SLICE * float(i) );

        // Position all of the slice backgrounds to be at the slice-0 position, then we rotate around using
        // the sprite rotation:

        Icons[i].bRelativeBackgroundCoords = 0;

        Icons[i].BackgroundBlurred.PosX = Icons[0].Blurred.PosX + SelectionOffsetX;
        Icons[i].BackgroundBlurred.PosY = Icons[0].Blurred.PosY + SelectionOffsetY;

        Icons[i].BackgroundBlurred.RotPivotX = PivotX;
        Icons[i].BackgroundBlurred.RotPivotY = PivotY;
        Icons[i].BackgroundBlurred.RotAngle = t;

        Icons[i].BackgroundFocused.PosX = Icons[0].Blurred.PosX;
        Icons[i].BackgroundFocused.PosY = Icons[0].Blurred.PosY;

        Icons[i].BackgroundFocused.RotPivotX = PivotX;
        Icons[i].BackgroundFocused.RotPivotY = PivotY;
        Icons[i].BackgroundFocused.RotAngle = t;
    }

    if( IsOnConsole() )
    {
        WeaponName.MaxSizeX = default.WeaponName.MaxSizeX * FMin( ResScaleX,  ResScaleY );
    }

    WeaponName.PosX = PivotX + 0.005 - (WeaponName.MaxSizeX * 0.5);
    WeaponName.PosY = PivotY - 0.01;
    
    if( CurrentSlice >= 0 )
    {
        FocusOnWidget( Icons[CurrentSlice] );
        SnapMouseToFocus();
        ShowWeaponInfo( CurrentSlice );
    }
    else
    {
        FocusOnNothing();
        ShowWeaponInfo( -1 );
    }
}

simulated function ShowWeaponInfo( int ContextId )
{
    local VGWeapon W;

    if( (ContextId < 0) || (Weapons[ContextId] == None) )
    {
        WecLayerWidget.bHidden = 1;
        WeaponName.bHidden = 1;
        return;
    }
    
    W = Weapons[ContextId];

    // sjs - could IsOnConsole() here, but let's see...
    if( W != VGWeapon(PlayerController(Owner).Pawn.Weapon) )
    {
        PlayerController(Owner).SwitchWeapon(W.InventoryGroup);
    }
    
    if( !IsSplit() )
    {
        WecLayer.ShowWeaponInfo( W );
        WecLayerWidget.bHidden = 0;
    }
     
    WeaponName.bHidden = 0;
        
    if( W.HasAmmo() )
    {
        WeaponName.Text = W.ItemName;
        if(WeaponName.Text == "Lance-grenades")
        {
            WeaponName.Text = "Lance\\nGrenades"; // brutal french localization hack bt192, to avoid breaking the itemname usage globally
        }
    }
    else
    {
        WeaponName.Text = NoAmmo;
    }
}

simulated function FocusOn( int Slice )
{
    if( Slice == CurrentSlice )
    {
        return;
    }
    
     CurrentSlice = Slice;
    
    if( CurrentSlice < 0 )
    {
        FocusOnNothing();
    }
    else
    {
        FocusOnWidget( Icons[CurrentSlice] );
    }
}

simulated function WheelWeapon( int Delta )
{
    local int NewSlice;
    
    if( CurrentSlice < 0 )
    {
        return;
    }
    
    NewSlice = CurrentSlice;

    do
    {
        NewSlice += Delta;
        
        if( NewSlice < 0 )
        {
            NewSlice = SLICE_COUNT - 1;
        }
        else
        {
            NewSlice = NewSlice % SLICE_COUNT;
        }
        
        if( NewSlice == CurrentSlice )
        {
            return;
        }
        
    } until(Weapons[NewSlice] != None)
    
    FocusOn( NewSlice );
    SnapMouseToFocus();
}

simulated function SnapMouseToFocus()
{
    local float NormMousePosX;
    local float NormMousePosY;
    
    if( CurrentSlice < 0 )
    {
        return;
    }

    MouseDot.PosX = Icons[CurrentSlice].Focused.PosX;
    MouseDot.PosY = Icons[CurrentSlice].Focused.PosY;

    NormMousePosX = (MouseDot.PosX - PivotX) / (MouseDotRadius * RotScaleX);
    NormMousePosY = - (MouseDot.PosY - PivotY) / (MouseDotRadius * RotScaleY);

    MousePosX = NormMousePosX * MouseAxisMagnitude;
    MousePosY = NormMousePosY * MouseAxisMagnitude;

    SetMousePos( MouseDot.PosX, MouseDot.PosY );
}

simulated function bool HandleInputKeyRaw(Interactions.EInputKey Key, Interactions.EInputAction Action)
{
    local VGWeapon W;
    local VehiclePlayer PC;

	// cmr -- allow release to pass through menu, this fixes stuck in crouch bug. 
	if(Action == IST_Release && !(Key == HoldKey))
	{
		return false;
	}
	
    if( (Action == IST_Release) && (Key == HoldKey ) )
    {
        CloseMenu();
        return(true);
    }
    
    if( Key == IK_MouseWheelUp )
    {
        WheelWeapon( 1 );
    }
    
    if( Key == IK_MouseWheelDown )
    {
        WheelWeapon( -1 );
    }
    
    if( (Action == IST_Press) && (( Key == IK_Joy7 ) || ( Key == IK_LeftMouse )) )
    {
        if( CurrentSlice < 0 )
        {
            log( "Can't upgrade null weapon.", 'Log' );
            return(true);
        }
    
        W = Weapons[CurrentSlice];
        PC = VehiclePlayer(Owner);
        
        if( W == None )
        {
            log( "Can't upgrade null weapon.", 'Log' );
            PlayerController(Owner).PlayBeepSound();
            return(true);
        }
        
        if( W.WECLevel >= W.WECMaxLevel )
        {
            log( "Can't apply any more upgrades to this weapon.", 'Log' );
            PlayerController(Owner).PlayBeepSound();
            return(true);
        }
        
        if( PC.WecCount < W.WECPerLevel[W.WECLevel] ) 
        {
            log( "Can't upgrade" @ W @ "without more WECs", 'Log' );
            PlayerController(Owner).PlayBeepSound();
            return(true);
        }
        
        PC.ClientWECLevelUp(W);
        
        bDynamicLayoutDirty = true;
        return(true);
    }


    return(true);
}

simulated function CloseMenu()
{
    local VehiclePlayer PC;
    
    PC = VehiclePlayer(Owner);
	SetTimer(0, false);
    HudADeathMatch(PC.myHUD).bFromWECMenu = false;

    PC.Player.Console.MenuClose();
    PC.ConsoleCommand("RETRIGGER_INPUT"); // resend any IST_Press events that were swallowed by the menu.
}

simulated function bool HandleInputAxis( Interactions.EInputKey Key, float Delta )
{
    local float R;
    local int S;
    local float PosX;
    local float PosY;
    
    local float LeftStickR;
    local float RightStickR;
    local float MouseR;
    
    local bool MoveMouse;
    
    MoveMouse = true;
    
    if( Key == IK_JoyX )
    {
        JoyX = Delta;
    }
    else if( Key == IK_JoyY )
    {
        JoyY = Delta;
    }
    else if( Key == IK_JoyU )
    {
        JoyU = Delta;
    }
    else if( Key == IK_JoyV )
    {
        JoyV = Delta;
    }
    else if( Key == IK_MouseX )
    {
        MousePosX = Clamp( MousePosX + Delta, -MouseAxisMagnitude, MouseAxisMagnitude );
    }
    else if( Key == IK_MouseY )
    {
        MousePosY = Clamp( MousePosY + Delta, -MouseAxisMagnitude, MouseAxisMagnitude );
    }
    else
    {
        return(true);
    }

    // Clamp the mouse to the disk and move the mouse dot:
    
    if( ( Key == IK_MouseX ) || ( Key == IK_MouseY ) )
    {
        NormMousePosX = MousePosX / MouseAxisMagnitude;
        NormMousePosY = MousePosY / MouseAxisMagnitude;
    
        if( Sqrt( (NormMousePosX * NormMousePosX) + (NormMousePosY * NormMousePosY) ) > 1.f )
        {
            R = Atan(NormMousePosY, NormMousePosX);
    
            NormMousePosX = Cos(R);
            NormMousePosY = Sin(R);
        }

        MouseDot.PosX = PivotX + (NormMousePosX * MouseDotRadius * RotScaleX);
        MouseDot.PosY = PivotY - (NormMousePosY * MouseDotRadius * RotScaleY);
        
        SetMousePos( MouseDot.PosX, MouseDot.PosY );

        MoveMouse = false;
    }
    
    // Pick dominant axis:
    
    LeftStickR = Sqrt((JoyX * JoyX) + (JoyY * JoyY));
    RightStickR = Sqrt((JoyU * JoyU) + (JoyV * JoyV));
    MouseR = Sqrt((NormMousePosX * NormMousePosX) + (NormMousePosY * NormMousePosY));
    
    if( (LeftStickR > JoyDeadZone) && (LeftStickR > RightStickR) && (LeftStickR > MouseR) )
    {
        PosX = JoyX;
        PosY = JoyY;
    }
    else if( (RightStickR > JoyDeadZone) && (RightStickR > LeftStickR) && (RightStickR > MouseR) )
    {
        PosX = JoyU;
        PosY = JoyV;
    }
    else if( MouseR > MouseDeadZone)
    {
        PosX = NormMousePosX;
        PosY = NormMousePosY;
    } 
    else
    {
        return(true);
    }
    
    R = - (WindingDirection * Atan(PosY, PosX)) - ToRadians(RotationOffset);
    
    while(R < 0.f)
    {
        R += Pi2;
    }
    
    while(R > Pi2)
    {
        R -= Pi2;
    }

    S = int(Round(R / RADIANS_PER_SLICE)) % SLICE_COUNT;
    
    FocusOn(S);
    
    if( MoveMouse )
    {
        SnapMouseToFocus();
    }
    
    return(true);
}

defaultproperties
{
     FullScreenPivotX=0.300000
     FullScreenPivotY=0.610000
     SplitPivotX(0)=0.230000
     SplitPivotX(1)=0.230000
     SplitPivotY(0)=0.550000
     SplitPivotY(1)=0.580000
     WindingDirection=1.000000
     RotationOffset=-90.000000
     WecDotArc=14.000000
     IconRadius=0.122000
     WecRadius=0.170000
     MouseDotRadius=0.170000
     Icons(0)=(Blurred=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(B=180,G=180,R=180,A=255),DrawPivot=DP_MiddleMiddle,ScaleX=0.600000,ScaleY=0.600000),Focused=(DrawColor=(G=150,R=255,A=255),ScaleX=0.850000,ScaleY=0.850000),OnFocus="ShowWeaponInfo",Pass=1)
     WecDots(0)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',DrawPivot=DP_MiddleMiddle,ScaleX=1.000000,ScaleY=1.000000,Pass=4)
     WeaponName=(DrawPivot=DP_MiddleLeft,ScaleX=0.600000,ScaleY=0.600000,MaxSizeX=0.170000,bWordWrap=1,TextAlign=TA_Center,Pass=2,Style="NormalLabel")
     MouseDot=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.Cursor',DrawPivot=DP_MiddleMiddle,PosX=0.300000,PosY=0.610000,ScaleX=1.000000,ScaleY=1.000000,Pass=4,Platform=MWP_PC)
     WecDotOff=(X1=154,Y1=16,X2=169,Y2=31)
     WecDotOn=(X1=154,X2=169,Y2=15)
     BackgroundDisc(0)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',TextureCoords=(X1=384,X2=511,Y2=126),DrawColor=(A=80),DrawPivot=DP_LowerRight,PosX=0.300000,PosY=0.770000,ScaleX=1.000000,ScaleY=1.000000)
     BackgroundDisc(1)=(ScaleX=-1.000000,ScaleY=1.000000)
     BackgroundDisc(2)=(ScaleX=1.000000,ScaleY=-1.000000)
     BackgroundDisc(3)=(ScaleX=-1.000000,ScaleY=-1.000000)
     InfoDisc(0)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',TextureCoords=(X1=272,X2=334,Y2=63),DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_LowerRight,PosX=0.300000,PosY=0.770000,ScaleX=1.000000,ScaleY=1.000000)
     InfoDisc(1)=(TextureCoords=(X1=272,X2=333,Y2=63),DrawPivot=DP_LowerRight,ScaleX=-1.000000,ScaleY=1.000000)
     InfoDisc(2)=(TextureCoords=(X1=272,Y1=64,X2=334,Y2=127),DrawPivot=DP_UpperRight,ScaleX=1.000000,ScaleY=1.000000)
     InfoDisc(3)=(TextureCoords=(X1=272,Y1=64,X2=333,Y2=127),DrawPivot=DP_UpperRight,ScaleX=-1.000000,ScaleY=1.000000)
     JoyDeadZone=0.950000
     MouseDeadZone=0.500000
     CurrentSlice=-1
     MouseAxisMagnitude=100.000000
     RotScaleX=1.000000
     RotScaleY=1.000000
     NoAmmo="No\nAmmo!"
     CrossFadeDir=TD_In
     CrossFadeRate=50.000000
     CrossFadeLevel=0.000000
     SoundTweenOut=None
     SoundOnFocus=None
     SoundOnSelect=None
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
     bShowMouseCursor=False
}
