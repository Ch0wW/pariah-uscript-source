class HudADeathMatch extends HudBase;

#exec LOAD FILE="PariahInterface.utx"

var() SpriteWidget  VehicleHealthBarBG;
var() SpriteWidget  VehicleHealthBar;

var() DigitSet DigitsBigPulse;

var() SpriteWidget  RocketReticle;

var() NumericWidget WeaponLevel;
var() SpriteWidget	WECIcon;
var() NumericWidget WECCount;
var() NumericWidget WeaponNextLevelCount;

var() SpriteWidget	ColonSprite;
var() SpriteWidget	BackslashSprite;

var() Color ConsoleMessageTints[2];

var() SpriteWidget	HealthBubble[6];
var() SpriteWidget	HealthBubbleTint[6];
var() SpriteWidget	HealthBubbleBackground[6];

var() SpriteWidget	AmmoBackground;
var() SpriteWidget	AmmoCapacityFill;
var() SpriteWidget	AmmoCapacityTint;
var() SpriteWidget	CurWeaponIcon;
var() NumericWidget	AmmoDigits;
var() SpriteWidget	Bullet;
var() int ClipOffsetX;
var() int ClipOffsetY;
var() bool ClipEmptyFromTop;

// --- Hud Animations 
var() int bFlashDigits;
var() int bFlashHealthIcon;
var() float DigitsScaleSize;
var() float HealthIconScaleSize;
// ---

const WEAPON_BAR_DISPLAY_TIME = 2.5;
const WEAPON_BAR_FADE_TIME = 0.5;
const WEAPON_BAR_SHIFT_SPEED = 0.1;
const WEAPON_BAR_ICON_SPACING = 0.19;
const WEAPON_BAR_MAX_ALPHA = 255;
const WEAPON_BAR_SELECTION_MAX_ALPHA = 100;
const WEAPON_BAR_SHRINKAGE = 0.12;
const HIDE_HEALTH_THRESHOLD = 25;

var transient float LastHealth, CurShield, LastShield, CurEnergy, CurAmmoPrimary, CurAmmoSecondary, CurClips, LastWECCount;
var transient float MaxHealth, MaxShield, LastEnergy, MaxEnergy, MaxAmmoPrimary, MaxAmmoSecondary, UdamageCount;

var bool bShowSniperScope;
var bool bShowingWECCount, bShowingFromWECPie, bWECMenuFadeIN, bFromWECMenu;
var float ShowWecTimer, WECMenuOpen;
var() int TMPPosX, TMPPosY;

var() bool bShowVehicleHealth;

// cmr-
var transient Pawn LastPawnOwner;
// -cmr

var transient int CurScore, CurRank, ScoreDiff;

var() transient Weapon ActiveWeapon;

var int OldRemainingTime;
var sound LongCount[6];
var sound CountDown[5];

var transient float LetsNotDoThisQuiteSoOften;

var GuiHideData HealthHideData;

var Vector BlindedTime;
var Vector CurBlinded;
var float BloomLevel;
var float BaseCrosshair;
var float DesiredCrosshair;

var bool bShowPawnInfo;

simulated function Tick(float d)
{
    Super.Tick(d);
    BlindedTime.X = FClamp(BlindedTime.X - d, 0, 10);
    BlindedTime.Y = FClamp(BlindedTime.Y - d, 0, 10);
    BlindedTime.Z = FClamp(BlindedTime.Z - d, 0, 10);
    CurBlinded = CurBlinded + ((d*4) * (BlindedTime - CurBlinded));
    
    BaseCrosshair = BaseCrosshair - ((d * 5) * (BaseCrosshair - DesiredCrosshair));
}

simulated function Blinded(float time, Name BlindedType)
{
    if(PawnOwner != None && PawnOwner.Weapon != None && PawnOwner.Weapon.FilterBlindness( BlindedType ))
    {
        return;
    }
    
    if(BlindedType == 'Plasma')
    {
        BlindedTime.X = Max(BlindedTime.X, time);
        BlindedTime.Y = Max(BlindedTime.Y, time);
        BlindedTime.Z = Max(BlindedTime.Z, time);
    }
    else if(BlindedType == 'Laser')
    {
        BlindedTime.X = Max(BlindedTime.X, time * 0.1);
        BlindedTime.Y = Max(BlindedTime.Y, time * 0.1);
        BlindedTime.Z = Max(BlindedTime.Z, time);
    }
}

simulated function DrawBlinded(Canvas C)
{
	local vector fade;
	local vector fog;
	
	if(CurBlinded.X <= 0 && CurBlinded.Y <= 0 && CurBlinded.Z <= 0)
	{
	    return;
	}
	
    fade.X = FClamp(1.0 - VSize(CurBlinded), 0.25, 1);
	fade.Y = 1;
	fade.Z = 1;
	fog.X = FClamp(CurBlinded.X * 255, 0, 255);
	fog.Y = FClamp(CurBlinded.Y * 255, 0, 255);
	fog.Z = FClamp(CurBlinded.Z * 255, 0, 255);
    DrawScreenFlash(C, fade, fog);
}

simulated function DrawScopeOverlay( Canvas C )
{
    local int CurrentDrawScaleX, CurrentDrawScaleY, MidX, MidY, BarPosX;
    
    if(PawnOwner.Weapon != None && PawnOwner.Weapon.IsA('SniperRifle') && VehiclePlayer(Owner).bZoomed)
    {
        if(PawnOwner.Weapon.IsInState('Reload'))
            return;

        CurrentDrawScaleX = C.SizeX/640;
        CurrentDrawScaleY = C.SizeY/480;
        MidX = C.SizeX*0.5;
        MidY = C.SizeY*0.5;
        
        C.Style = ERenderStyle.STY_Modulated;
     
        C.SetPos(0,0);
        C.SetDrawColor( 255, 255, 255);
        C.DrawTile( TexPanner'PariahInterface.HUD.PaningNoise', C.SizeX, C.SizeY, 0.0, 0.0, C.SizeX *2, C.SizeY *2);
        
        C.SetPos(0,0); // Overlay Color
        
        if( PersonalWeapon(PawnOwner.Weapon).WECLevel < 1 )
            C.SetDrawColor( 51, 180, 246 );
            
        C.DrawTile( Texture'Engine.PariahWhiteTexture', C.SizeX, C.SizeY, 0.0, 0.0, 8, 8 );
     
     
        C.SetDrawColor( 255, 255, 255, 40);// Center Rings
        CreateRing( C, MidX, MidY, Material'PariahInterface.HUD.SniperPartB', CurrentDrawScaleX*185, CurrentDrawScaleY*185, 0, 0, 127, 127 );
        CreateRing( C, MidX, MidY, Material'PariahInterface.HUD.SniperPartC', CurrentDrawScaleX*292, CurrentDrawScaleY*292, 0, 0, 127, 127 );
     
        CreateRing( C, MidX, MidY, Material'PariahInterface.HUD.SniperPartB', CurrentDrawScaleX*185, CurrentDrawScaleY*185, 0, 0, 127, 127 );
        CreateRing( C, MidX, MidY, Material'PariahInterface.HUD.SniperPartC', CurrentDrawScaleX*292, CurrentDrawScaleY*292, 0, 0, 127, 127 );
        CreateRing( C, MidX, MidY, Material'PariahInterface.HUD.SniperPartB', CurrentDrawScaleX*185, CurrentDrawScaleY*185, 0, 0, 127, 127 );
        CreateRing( C, MidX, MidY, Material'PariahInterface.HUD.SniperPartC', CurrentDrawScaleX*292, CurrentDrawScaleY*292, 0, 0, 127, 127 );
        
        C.SetDrawColor( 200, 200, 200);
        BarPosX = C.SizeX*0.0625;
        CreateSideBars( C, 6, CurrentDrawScaleX*10, true, BarPosX, MidY-(CurrentDrawScaleY*20), Texture'Engine.PariahWhiteTexture', CurrentDrawScaleX*8, CurrentDrawScaleY*8, 0, 0, 8, 8 );
        CreateSideBars( C, 6, CurrentDrawScaleX*10, true, BarPosX, MidY+(CurrentDrawScaleY*12), Texture'Engine.PariahWhiteTexture', CurrentDrawScaleX*8, CurrentDrawScaleY*8, 0, 0, 8, 8 );
        CreateSideBars( C, 6, CurrentDrawScaleX*10, true, BarPosX, MidY-3, Texture'Engine.PariahWhiteTexture', CurrentDrawScaleX*8, CurrentDrawScaleY*4, 0, 0, 8, 8 );
        
        C.SetPos( (CurrentDrawScaleX*110)+(6*CurrentDrawScaleX), MidY-10 );   
        C.DrawTile( Texture'Engine.PariahWhiteTexture', 6, 20, 0.0, 0.0, 8, 8 );
        
        //Right Side
        BarPosX = C.SizeX*0.9375;
        CreateSideBars( C, 6, CurrentDrawScaleX*10, false, BarPosX, MidY-(CurrentDrawScaleY*20), Texture'Engine.PariahWhiteTexture', CurrentDrawScaleX*8, CurrentDrawScaleY*8, 0, 0, 8, 8 );
        CreateSideBars( C, 6, CurrentDrawScaleX*10, false, BarPosX, MidY+(CurrentDrawScaleY*12), Texture'Engine.PariahWhiteTexture', CurrentDrawScaleX*8, CurrentDrawScaleY*8, 0, 0, 8, 8 );
        CreateSideBars( C, 6, CurrentDrawScaleX*10, false, BarPosX, MidY-3, Texture'Engine.PariahWhiteTexture', CurrentDrawScaleX*6, CurrentDrawScaleY*4, 0, 0, 8, 8 );
        
        C.SetPos( C.SizeX-((CurrentDrawScaleX*116)+(6*CurrentDrawScaleX)), MidY-10 );   
        C.DrawTile( Texture'Engine.PariahWhiteTexture', 6, 20, 0.0, 0.0, 8, 8 );
        
        C.Style = ERenderStyle.STY_Alpha;
        C.SetDrawColor( 135, 192, 220,128);
        C.SetPos( MidX, MidY - 20 );   
        C.DrawTile( Texture'Engine.PariahWhiteTexture', 1, -140, 0.0, 0.0, 8, 8 );
        C.SetPos( MidX + 20 , MidY );   
        C.DrawTile( Texture'Engine.PariahWhiteTexture', 140, 1, 0.0, 0.0, 8, 8 );
        C.SetPos( MidX, MidY + 20 );   
        C.DrawTile( Texture'Engine.PariahWhiteTexture', 1, 140, 0.0, 0.0, 8, 8 );
        C.SetPos( MidX -  20, MidY );   
        C.DrawTile( Texture'Engine.PariahWhiteTexture', -140, 1, 0.0, 0.0, 8, 8 );

        C.Style = ERenderStyle.STY_Modulated;
        C.SetDrawColor( 180, 180, 180,255);
        C.SetPos( MidX, MidY - 20 );   
        C.DrawTile( Texture'Engine.PariahWhiteTexture', 1, -140, 0.0, 0.0, 8, 8 );
        C.SetPos( MidX + 20 , MidY );   
        C.DrawTile( Texture'Engine.PariahWhiteTexture', 140, 1, 0.0, 0.0, 8, 8 );
        C.SetPos( MidX, MidY + 20 );   
        C.DrawTile( Texture'Engine.PariahWhiteTexture', 1, 140, 0.0, 0.0, 8, 8 );
        C.SetPos( MidX -  20, MidY );   
        C.DrawTile( Texture'Engine.PariahWhiteTexture', -140, 1, 0.0, 0.0, 8, 8 );

    }
}

simulated function CreateSideBars( Canvas C, int BarCount, int Spacer , bool bFromLeftSide, int PosX, int PosY, Material TX, int ScaleX, int ScaleY, int X1, int Y1,int X2,int Y2 )
{
    local int i;

    for( i=0; i < BarCount ; ++i )
    {
        C.SetPos( PosX + (i*Spacer), PosY);
     
        if(!bFromLeftSide)
            C.SetPos( PosX - (i*Spacer), PosY);            
        
        C.DrawTile( TX, ScaleX, ScaleY, X1, Y1, -X2, -Y2);
    }
}

simulated function CreateRing( Canvas C, int PosX, int PosY, Material TX, int ScaleX, int ScaleY, int X1, int Y1,int X2,int Y2 )
{
    C.SetPos( PosX-ScaleX, PosY-ScaleY ); // UpperLeft
    C.DrawTile( TX, ScaleX, ScaleY, X1, Y1, X2, Y2);

    C.SetPos( PosX, PosY-ScaleY ); // UpperRight
    C.DrawTile( TX, ScaleX, ScaleY, X1, Y1, -X2, Y2);

    C.SetPos( PosX-ScaleX, PosY ); // LowerLeft
    C.DrawTile( TX, ScaleX, ScaleY, X1, Y1, X2, -Y2);

    C.SetPos( PosX, PosY ); // LowerRight
    C.DrawTile( TX, ScaleX, ScaleY, X1, Y1, -X2, -Y2);
}


simulated function ShowHideHealth()
{
	UpdateHideData(HealthHideData);
	ApplyHideDataS(HealthHideData, LHud[1], True);
	ApplyHideDataS(HealthHideData, LHud[0], True);
	ApplyHideDataS(HealthHideData, HealthIcon, True);
	ApplyHideDataN(HealthHideData, HealthCount, True);
}

simulated function SpawnOverlays() // create vote/speech/voicechannel menus here
{
	Super.SpawnOverlays();

    if( VoiceMenuClass != None )
        VoiceMenu = Spawn(VoiceMenuClass,self);
    if( HudXboxSpeechOverlay(VoiceMenu) != None )
        HudXboxSpeechOverlay(VoiceMenu).SetPlayer(PlayerOwner);
    
    if( VoiceChannelMenuClass != None )
        VoiceChannelMenu = Spawn(VoiceChannelMenuClass,self);
    if( HudXboxVoiceChannelOverlay(VoiceChannelMenu) != None )
        HudXboxVoiceChannelOverlay(VoiceChannelMenu).SetPlayer(PlayerOwner);

}

simulated function bool IsOnlySpectator( PlayerReplicationInfo P )
{
	return P.bOnlySpectator;
}

simulated function bool PRI_InOrder( PlayerReplicationInfo P1, PlayerReplicationInfo P2 )
{
    local bool S1, S2;
    
    S1 = IsOnlySpectator( P1 );
    S2 = IsOnlySpectator( P2 );
    
    if( S1 )
    {
        if( S2 )
            return( true );
        else
            return( false );
    }

    if( P1.Score < P2.Score )
        return( false );
    
    return( true );
}

simulated function SortPRIArray()
{
    local int i, j;
    local PlayerReplicationInfo tmp;
    

    for (i=0; i<PlayerOwner.GameReplicationInfo.PRIArray.Length-1; i++)
    {
        for (j=i+1; j<PlayerOwner.GameReplicationInfo.PRIArray.Length; j++)
        {
           if( !PRI_InOrder( PlayerOwner.GameReplicationInfo.PRIArray[i], PlayerOwner.GameReplicationInfo.PRIArray[j] ) )
            {
                tmp = PlayerOwner.GameReplicationInfo.PRIArray[i];
                PlayerOwner.GameReplicationInfo.PRIArray[i] = PlayerOwner.GameReplicationInfo.PRIArray[j];
                PlayerOwner.GameReplicationInfo.PRIArray[j] = tmp;
            }
        }
    }
}

function CheckCountdown(GameReplicationInfo GRI)
{
	if ( (GRI == None) || (GRI.RemainingTime == 0) || (GRI.RemainingTime == OldRemainingTime) || (GRI.Winner != None) )
		return;
	
	OldRemainingTime = GRI.RemainingTime;

	if ( OldRemainingTime == 120 )
		PlayerOwner.PlayAnnouncement(LongCount[2],1,true);
	else if ( OldRemainingTime == 60 )
		PlayerOwner.PlayAnnouncement(LongCount[3],1,true);
	else if ( OldRemainingTime == 30 )
		PlayerOwner.PlayAnnouncement(LongCount[4],1,true);
	else if ( (OldRemainingTime <= 5) && (OldRemainingTime > 0) )
		PlayerOwner.PlayAnnouncement(CountDown[OldRemainingTime - 1],1,true);
}

simulated function CalculateHealth()
{
    // cmr-
	if(LastPawnOwner != PawnOwner) //changed pawns, init LastHealth
	{
		ToggleHideData(HealthHideData, False);
		LastHealth = PawnOwner.Health;
		LastPawnOwner=PawnOwner;
	}
	else if(CurHealth <= HIDE_HEALTH_THRESHOLD)
	{
	    ToggleHideData(HealthHideData, False);
	    LastHealth = CurHealth;
	}
	else
	{
		ToggleHideData(HealthHideData, LastHealth==CurHealth);
		LastHealth = CurHealth;
	}

	ToggleHideData(HealthHideData, true); // sjs - TEMP!

    // -cmr
    MaxHealth = PawnOwner.HealthMax;
    CurHealth = PawnOwner.Health;
    
   
    // AsP --- HoeLeeChow, Just trying to get the VehicleHealthInformation
    bShowVehicleHealth = false;
   
    if(PawnOwner.IsA('VGVehicle'))
    {
        if(VGVehicle(PawnOwner).bIsDriven)
            bShowVehicleHealth = true;  

        VehicleHealthBar.Scale = (float(PawnOwner.Health) / PawnOwner.HealthMax) ;

        MaxHealth = VGVehicle(PawnOwner).Driver.HealthMax;
        CurHealth = VGVehicle(PawnOwner).Driver.Health;

        return;
    }

    if( VGPawn(PawnOwner).RiddenVehicle != None )
    {
        VehicleHealthBar.Scale = (float(VGPawn(PawnOwner).RiddenVehicle.Health) / VGPawn(PawnOwner).RiddenVehicle.HealthMax) ;
        bShowVehicleHealth = true;
    }
    // --- AsP
}

simulated function CalculateUdamage()
{
    //CMR
	if(PawnOwner.IsA('xPawn')==false) return;

	UdamageCount = FClamp( XPawn(PawnOwner).UDamageTime - Level.TimeSeconds, 0.f, XPawn(PawnOwner).RemainingUDamageMax);
}
simulated function CalculateShield()
{
    LastShield = CurShield;
    if( PawnOwner.IsA ('XPawn') )
    {
        MaxShield = XPawn(PawnOwner).ShieldStrengthMax;
        CurShield = Clamp (XPawn(PawnOwner).ShieldStrength, 0, MaxShield);
    }
    else
    {
        MaxShield = 100;
        CurShield = 0;
    }
}

simulated function CalculateAmmo()
{
	local Weapon wep;
	local AmmoClip clip;

    MaxAmmoPrimary = 1;
    CurAmmoPrimary = 1;
    MaxAmmoSecondary = 1;
    CurAmmoSecondary = 1;

    if(PawnOwner.Weapon != none)
    {
        Wep = PawnOwner.Weapon;

        if (Wep.Ammo[0] != none)
        {
            
			if(Wep.Ammo[0].IsA('AmmoClip') )
			{
                clip = AmmoClip(Wep.Ammo[0]);
			    MaxAmmoPrimary = clip.MagAmount;
                CurAmmoPrimary = clip.RemainingMagAmmo;
				CurClips = clip.AmmoAmount;
            }
            else
            {
                MaxAmmoPrimary = Max (Wep.Ammo[0].MaxAmmo, Wep.Ammo[0].AmmoAmount);
                CurAmmoPrimary = Wep.Ammo[0].AmmoAmount;
            }
        }
        
		//if(Wep.Ammo[0] != none && Wep.Ammo[0].IsA('VGAmmoPool') && PawnOwner.AmmoPool != none) 
		//{
		//	MaxAmmoPrimary = PawnOwner.MaxAmmoAmount;
		//	CurAmmoPrimary = PawnOwner.AmmoAmount;
		//}
    }
   // RHud[2].Scale = CurAmmoPrimary / MaxAmmoPrimary;       
}

simulated function ReticleReloadingBar(out float RechargeTime)
{
    if(RechargeTime >1)
    {
        RechargeTime=1;
    }
}

// AsP --- OMFG U HAX
simulated function DrawWECCount( Canvas C )
{
    local float ShowRatio, ShowWecTime, FadeInRatio, FadeInTime, FadeOutTime, FadeOutRatio, FadeRatio;
    
    ShowWecTime = 4.0;
    FadeInTime = 0.25;
    FadeOutTime = 0.25;

    if(PlayerOwner != None)
    {
        WECCount.Value = VehiclePlayer(PlayerOwner).WECCount;
          
        if( bFromWECMenu && !bWECMenuFadeIN )
        {
            ShowWecTimer = Level.TimeSeconds+ShowWecTime;
            bWECMenuFadeIN=true;
        }

        if( WECCount.Value > LastWECCount && !bWECMenuFadeIN && !bFromWECMenu )
            ShowWecTimer = Level.TimeSeconds+ShowWecTime;
       
        if( ShowWecTimer > Level.TimeSeconds || bWECMenuFadeIN )
        {
            ShowRatio    = ( ShowWecTime -( ShowWecTimer - Level.TimeSeconds )) /ShowWecTime;
            FadeInRatio  = FadeInTime / ShowWecTime;
            FadeOutRatio = (FadeOutTime / ShowWecTime);
            
            if( ShowRatio < FadeInRatio && !bShowingWECCount)
            {
                FadeRatio = FClamp( ShowRatio/FadeInRatio, 0.0, 1.0 );
            }
            else
            {
                bShowingWECCount=true;
                FadeRatio = Lerp( (FadeOutRatio-(1.0-ShowRatio))/FadeOutRatio, 1.0, 0.0, true);

                if( bWECMenuFadeIN )
                    FadeRatio = 1.0;

            }

            WECIcon.PosX = default.WECCount.PosX *FadeRatio;
            WECCount.PosX = WECIcon.PosX;
            WECIcon.Tints[TeamIndex].A = 200 *FadeRatio;
            WECCount.Tints[TeamIndex].A = 255 *FadeRatio;

            WECCount.TextureScale = default.WECCount.TextureScale *FadeRatio;

            DrawSpriteWidget( C, WECIcon ); 
            DrawNumericWidget(C, WECCount, DigitsBig);       
        }
        else
            bShowingWECCount=false;

        if( !bFromWECMenu )
            bWECMenuFadeIN=false;

        LastWECCount = WECCount.Value;
    }
}


simulated function DrawHudPassB (Canvas C)
{
	Super.DrawHudPassB(C);
	DrawBlinded(C);
}


simulated function DrawDamageIndicators(Canvas C)
{
    local float Thickness;

    Thickness = 0.1;

    C.Style = ERenderStyle.STY_Additive;
    C.DrawColor.A = 255;
    
    // top
    if(PawnOwner.DamageDirIntensity[DamageDirFront] > 0)
    {
        C.SetPos(0,C.SizeY * Thickness);
        C.DrawColor.R = PawnOwner.DamageDirIntensity[DamageDirFront];   
        C.DrawColor.G = PawnOwner.DamageDirIntensity[DamageDirFront];
        C.DrawColor.B = PawnOwner.DamageDirIntensity[DamageDirFront];
        C.DrawTile( Material'InterfaceContent.Hud.DamageDir2', C.SizeX, -C.SizeY * Thickness, 0, 0, 128, 32 ); // !! hardcoded size
    }
    // left
    if(PawnOwner.DamageDirIntensity[DamageDirLeft] > 0)
    {
        C.SetPos(0,0);
        C.DrawColor.R = PawnOwner.DamageDirIntensity[DamageDirLeft];   
        C.DrawColor.G = PawnOwner.DamageDirIntensity[DamageDirLeft];
        C.DrawColor.B = PawnOwner.DamageDirIntensity[DamageDirLeft];
        C.DrawTile( Material'InterfaceContent.Hud.DamageDir', C.SizeX * Thickness, C.SizeY, 0, 0, 32, 128 ); // !! hardcoded size
    }

    // bottom
    if(PawnOwner.DamageDirIntensity[DamageDirBehind] > 0)
    {
        C.SetPos(C.SizeX,C.SizeY - C.SizeY * Thickness); 
        C.DrawColor.R = PawnOwner.DamageDirIntensity[DamageDirBehind];   
        C.DrawColor.G = PawnOwner.DamageDirIntensity[DamageDirBehind];
        C.DrawColor.B = PawnOwner.DamageDirIntensity[DamageDirBehind];
        C.DrawTile( Material'InterfaceContent.Hud.DamageDir2', -C.SizeX, C.SizeY * Thickness, 0, 0, 128, 32 ); // !! hardcoded size
    }
    // right
    if(PawnOwner.DamageDirIntensity[DamageDirRight] > 0)
    {
        C.SetPos(C.SizeX,0); 
        C.DrawColor.R = PawnOwner.DamageDirIntensity[DamageDirRight];
        C.DrawColor.G = PawnOwner.DamageDirIntensity[DamageDirRight];
        C.DrawColor.B = PawnOwner.DamageDirIntensity[DamageDirRight];
        C.DrawTile( Material'InterfaceContent.Hud.DamageDir', -C.SizeX * Thickness, C.SizeY, 0, 0, 32, 128 ); // !! hardcoded size
    }
}

// Alpha Pass ==================================================================================
simulated function DrawHudPassA (Canvas C)
{
    local VGWeaponAttachment Att;
	local xPawn xp;

	DrawDamageIndicators(C);

	// vehicle crosshair positioning
	if(PawnOwner.Weapon != none && PawnOwner.Weapon.IsA('VehicleWeapon') && PawnOwner.Weapon.ThirdPersonActor != none && PawnOwner.Weapon.ThirdPersonActor.IsA('VGWeaponAttachment') )
    {
        Att = VGWeaponAttachment(PawnOwner.Weapon.ThirdPersonActor);

		WeaponMuzzleLocation = Att.GetMuzzleLocation();

        WeaponBoneRotation = Att.GetAttachmentRotation();

		WeaponMuzzleLocation += (vector(WeaponBoneRotation)*2000);
	}

    DrawScopeOverlay(C);
	DrawDeathMatchHudPassA(C);
	DrawWECCount( C );

    if(bShowVehicleHealth)
        DrawVehicleHealth(C);

	DrawHealth(C);
    DrawAmmo(C);

	if ( bShowPawnInfo )
	{
		foreach AllActors( class'xPawn', xp )
		{
			xp.DrawHUDDebug(C, PlayerOwner.Pawn.Location);
		}
	}
}

simulated function DrawHealthBubble(Canvas C, float ratio, int index, bool alert)
{
	local float width;
	local float height;
    local int CurrentOffset;

	width = 30;
	height = 12;

	if(ratio == 1.0)
	{
		HealthBubbleBackground[index-1].Tints[TeamIndex] = default.HealthBubbleBackground[index-1].Tints[TeamIndex];
        HealthBubbleTint[index-1].Tints[TeamIndex] = default.HealthBubbleTint[index-1].Tints[TeamIndex];
	}
    else
    {
        if(HealthBubble[index-1].Scale < 0.5)
        {
            HealthBubbleTint[index-1].Tints[TeamIndex].R = 255;
		    HealthBubbleTint[index-1].Tints[TeamIndex].G = 150;
		    HealthBubbleTint[index-1].Tints[TeamIndex].B = 0;

		    HealthBubbleTint[index-1].Tints[TeamIndex].A = default.HealthBubbleTint[index-1].Tints[TeamIndex].A * Sin(Level.TimeSeconds * 5);
        }
        else
            HealthBubbleTint[index-1].Tints[TeamIndex] = default.HealthBubbleTint[index-1].Tints[TeamIndex];

        if(Ratio == 0.0)
            HealthBubbleBackground[index-1].Tints[TeamIndex]= default.HealthBubbleBackground[index-1].Tints[TeamIndex]; 
        else
        {
            HealthBubbleBackground[index-1].Tints[TeamIndex].R = 255;
		    HealthBubbleBackground[index-1].Tints[TeamIndex].G = 150;
		    HealthBubbleBackground[index-1].Tints[TeamIndex].B = 0;
		    HealthBubbleBackground[index-1].Tints[TeamIndex].A = default.HealthBubbleBackground[index-1].Tints[TeamIndex].A * Sin(Level.TimeSeconds * 5);    
        }
        
    }
	if(alert)
	{
        HealthBubbleTint[index-1].Tints[TeamIndex].R = 255;
		HealthBubbleTint[index-1].Tints[TeamIndex].G = 0;
		HealthBubbleTint[index-1].Tints[TeamIndex].B = 0;
		HealthBubbleTint[index-1].Tints[TeamIndex].A = 255;
		HealthBubbleTint[index-1].Tints[TeamIndex].A = HealthBubbleTint[index-1].Tints[TeamIndex].A * Sin(Level.TimeSeconds * 10);

        HealthBubbleBackground[index-1].Tints[TeamIndex].R = 255;
		HealthBubbleBackground[index-1].Tints[TeamIndex].G = 0;
		HealthBubbleBackground[index-1].Tints[TeamIndex].B = 0;
        HealthBubbleBackground[index-1].Tints[TeamIndex].A = 255;
		HealthBubbleBackground[index-1].Tints[TeamIndex].A = HealthBubbleBackground[index-1].Tints[TeamIndex].A * Sin(Level.TimeSeconds * 10);
	}

    CurrentOffset = ( index-1) * default.HealthBubbleBackground[1].OffsetX ;
    HealthBubble[index-1].OffsetX = default.HealthBubble[1].OffsetX + CurrentOffset; 
    HealthBubbleTint[index-1].OffsetX = default.HealthBubble[1].OffsetX + CurrentOffset; 
    HealthBubbleBackground[index-1].OffsetX = CurrentOffset;
    HealthBubble[index-1].Scale = default.HealthBubble[index-1].Scale* ratio;
    HealthBubbleTint[index-1].Scale = default.HealthBubble[index-1].Scale* ratio;
    DrawSpriteWidget( C, HealthBubbleBackground[index-1] );
        
    if(HealthBubble[index-1].Scale > 0)
    {
        DrawSpriteWidget( C, HealthBubble[index-1] );
        DrawSpriteWidget( C, HealthBubbleTint[index-1] );
    }
}

simulated function DrawVehicleHealth(Canvas C)
{
    DrawSpriteWidget (C, VehicleHealthBarBG);
    DrawSpriteWidget (C, VehicleHealthBar);
}

simulated function DrawHealth(Canvas C)
{
	local int i;
	local float ratio;

	i = 1;

    while(true)
	{
		ratio = 1.0 - (((i * 25) - CurHealth) / 25);
		ratio = FClamp(ratio, 0, 1);
		if(i == 1 && CurHealth <= (i * 25))
		{
			DrawHealthBubble(C, ratio, i, true);  // flash!
		}
		else
		{
			DrawHealthBubble(C, ratio, i, false);  // flash!
		}

		++i;
		if(i * 25 > MaxHealth)
		{
			break;
		}
	}
}


exec function HudEdit()
{
    // AsP - you know i love exec functions
    ConsoleCommand("editactor class=hud");
}


simulated function DrawAmmo( Canvas C )
{
    local AmmoClip Clip;
    local float MaxAmmo;
    local int TotalAmmo;
    local int AmmoInClip;
    local int SpaceInClip;
    local int AmmoPerClip;

    local int BulletRows;
    local int BulletStartX;
    local int BulletStartY;

    local int BulletIndex;
    local int Row;
    local int Col;
    local bool HaveBullet;

    if( ActiveWeapon == None || PawnOwner == None )
    {
        return;
    }
    
    if( VGPawn(PawnOwner) != None && VGPawn(PawnOwner).RiddenVehicle == None )
    {
        if( !PawnOwner.IsA('VGVehicle') )
        {
            DrawSpriteWidget(C, AmmoBackground);
            DrawSpriteWidget(C, AmmoCapacityFill);
            DrawSpriteWidget(C, AmmoCapacityTint);
            DrawNumericWidget(C, AmmoDigits, DigitsBig);
        }
    }

    if( ActiveWeapon.AmmoClipTexture != None )
    {
        CurWeaponIcon.WidgetTexture = ActiveWeapon.IconMaterial;
        CurWeaponIcon.TextureCoords = ActiveWeapon.IconCoords;
        DrawSpriteWidget(C, CurWeaponIcon);
	}

    if( ActiveWeapon.Ammo[0] == None )
    {
        return;
    }

    Clip = AmmoClip( ActiveWeapon.Ammo[0] );

    if( Clip != None )
    {
        AmmoInClip = Clip.RemainingMagAmmo;
        AmmoPerClip = Clip.MagAmount;
        SpaceInClip = Clip.MagAmount - Clip.RemainingMagAmmo;
        TotalAmmo = Clip.AmmoAmount;// + (Clip.AvailClips * AmmoPerClip);
        MaxAmmo = Clip.MaxAmmo;
    }
    else
    {
        AmmoInClip = -1;
        AmmoPerClip = -1;
        SpaceInClip = -1;
        TotalAmmo = ActiveWeapon.Ammo[0].AmmoAmount;
        MaxAmmo = ActiveWeapon.Ammo[0].MaxAmmo;
    }
    
    AmmoDigits.Value = TotalAmmo;
    AmmoCapacityFill.Scale =  FClamp( float(TotalAmmo )/ MaxAmmo , 0.0, 1.0 );
    AmmoCapacityTint.Scale = AmmoCapacityFill.Scale;

    if( (AmmoInClip > 0) && (ActiveWeapon.BulletTexture != None) )
    {
        Bullet.WidgetTexture = ActiveWeapon.BulletTexture;
        Bullet.TextureCoords = ActiveWeapon.BulletCoords;

        if(ActiveWeapon.BulletsScale > 0)
            Bullet.TextureScale  = ActiveWeapon.BulletsScale;
        else
            Bullet.TextureScale  = default.Bullet.TextureScale;

        Assert( ActiveWeapon.BulletsPerRow > 0 );
        Assert( AmmoPerClip > 0 );

        BulletRows = Ceil(float(AmmoPerClip) / float(ActiveWeapon.BulletsPerRow));

        BulletStartX = ClipOffsetX - ActiveWeapon.BulletsStartingOffsetX;
        BulletStartY = ClipOffsetY -((BulletRows * ActiveWeapon.BulletSpaceDY)- ActiveWeapon.BulletsStartingOffsetY);

        Bullet.OffsetY = BulletStartY;
        
        BulletIndex = 0;
        
        for( Row = 0; Row < BulletRows; ++Row )
        {
            Bullet.OffsetX = BulletStartX;

            for( Col = 0; Col < ActiveWeapon.BulletsPerRow; ++Col )
            {
                if( ClipEmptyFromTop )
                {
                    if( BulletIndex < SpaceInClip )
                    {
                        HaveBullet = false;
                    }
                    else
                    {
                        HaveBullet = true;
                    }
                }
                else
                {
                    if( BulletIndex < AmmoInClip )
                    {
                        HaveBullet = true;
                    }
                    else
                    {
                        HaveBullet = false;
                    }
                }

                if( HaveBullet )
                {
                    Bullet.Tints[0].A = 255;
                    Bullet.Tints[1].A = 255;
                }
                else
                {
                    Bullet.Tints[0].A = 50;
                    Bullet.Tints[1].A = 50;
                }

     	        DrawSpriteWidget(C, Bullet);
                Bullet.OffsetX -= ActiveWeapon.BulletSpaceDX;
                ++BulletIndex;

                if( BulletIndex >= AmmoPerClip )
                {
                    break;
                }
            }
            
            Bullet.OffsetY += ActiveWeapon.BulletSpaceDY;
        }
    }
}

simulated function UpdateHud()
{
    local xPlayer XP;
	local Actor aTarget;
	local int i;

	XP = xPlayer(PlayerOwner);
    
    Super.UpdateHud ();

    if ((PawnOwnerPRI != none) && (PawnOwnerPRI.Team != None))
        TeamIndex = Clamp (PawnOwnerPRI.Team.TeamIndex, 0, 1);
    else
        TeamIndex = 1; // Default to the blue HUD because it's sexier

    ConsoleColor = ConsoleMessageTints[TeamIndex];

    ShowReloading();

    // Flash the Health Numbers
    FlashAnim( true, DigitsScaleSize, bFlashDigits, CurHealth, LastHealth, ( default.HealthCount.TextureScale * 1.5 ), ( default.HealthCount.TextureScale ), ,HealthCount, 0 );    
    CalculateHealth();
	ShowHideHealth();
    
    LHud[1].Scale = FClamp(Min(CurHealth, MaxHealth) / MaxHealth,0.0,1.0);
	HealthCount.Value = CurHealth;

    CalculateShield();
    ShieldCount.Value = CurShield;

    CalculateAmmo();

	
//    AmmoCount.Value = CurAmmoPrimary;
////	if(PawnOwner.AmmoPool != none) {
//		AmmoCount.Value = CurAmmoPrimary;//PawnOwner.AmmoAmount;
//		AmmoBar[1].Scale = FClamp(Min(CurAmmoPrimary, MaxAmmoPrimary)/MaxAmmoPrimary, 0.0, 1.0);
//		ClipCount.Value = CurClips;
//		if(ClipCount.Value < 0)
//			ClipCount.Value = 0;
//	}

    // rocket seeking reticle
    // support VGRocketLauncher also
    
    for(i = 0; i < ArrayCount(bShowRocketTarget); ++i)
    {
	    bShowRocketTarget[i] = 0;
    }
	
	if (PawnOwner != none && PawnOwner.Weapon != None )
    {
        for(i = 0; i < ArrayCount(bShowRocketTarget); ++i)
        {
            aTarget = PawnOwner.Weapon.GetSeekTarget(i);
            if( aTarget != None )
            {
                bShowRocketTarget[i] = 1;
                RocketTargetLocation[i] = aTarget.Location;
            }
        }
    }
}


/////////////////////////////////////////////////
// HUD ANIMATIONS
/////////////////////////////////////////////////
simulated function ShowLockOnAnimation()
{
	local float CurrentTime, EndTime;
    local int FADE_TIME;

	CurrentTime = Level.TimeSeconds;
	EndTime		= Level.TimeSeconds + FADE_TIME;

	// DefaultCrosshair.TextureScale = CurrentTime - EndTime;

}
simulated function ShowReloading()
{
    // local float hold;
	local VGWeaponFire wf0, wf1;

	ActiveWeapon = PawnOwner.Weapon;

    if (ActiveWeapon == None)
        return;

	//XJ: made this much simpler would have gotten nuts if we had to check every weapon.
	if(ActiveWeapon.IsA('VGWeapon'))
	{
		wf0 = VGWeaponFire(ActiveWeapon.FireMode[0]);
		wf1 = VGWeaponFire(ActiveWeapon.FireMode[1]);

		ReloadingBar(VGWeaponFire(ActiveWeapon.FireMode[0]).HudBarValue);
		
		DesiredCrosshair = 1.0;
		if(ActiveWeapon.IsA('VGAssaultRifle'))
		{
			if(PlayerController(PawnOwner.Controller).bZoomed)
			{
				DesiredCrosshair *= 0.875;
			}
			if(PawnOwner.bIsCrouched)
			{
			    DesiredCrosshair *= 0.75;
			}
		}
        DefaultCrosshair.TextureScale = BaseCrosshair + (VGWeaponFire(ActiveWeapon.FireMode[0]).SpreadAttenuate * VGWeaponFire(ActiveWeapon.FireMode[0]).SpreadAttenuate);
		

		if(PawnOwner.IsA('VGVehicle'))
			ReticleReloadingBar(VGWeaponFire(ActiveWeapon.FireMode[0]).HudBarValue);
	}
    else
    {
		 OverHeatingIcon[0].WidgetTexture = default.OverHeatingIcon[0].WidgetTexture;
         OverHeatingIcon[0].Tints[TeamIndex] = default.OverHeatingIcon[0].Tints[TeamIndex];    
         OverHeatingIcon[0].Scale = default.OverHeatingIcon[0].Scale;

         OverHeatingIcon[1].WidgetTexture = default.OverHeatingIcon[1].WidgetTexture;
         OverHeatingIcon[1].Tints[TeamIndex] = default.OverHeatingIcon[1].Tints[TeamIndex];    
         OverHeatingIcon[1].Scale = default.OverHeatingIcon[1].Scale;        
    }
}
simulated function ReloadingBar(out float RechargeTime)
{
    if(RechargeTime >1)
    {
        RechargeTime=1;
    }
    
   	OverHeatingIcon[0].Tints[TeamIndex].A = default.OverHeatingIcon[0].Tints[TeamIndex].A * RechargeTime;    
    OverHeatingIcon[0].Scale = RechargeTime; 
    
    OverHeatingIcon[1].Tints[TeamIndex].A = default.OverHeatingIcon[1].Tints[TeamIndex].A * RechargeTime;      
    OverHeatingIcon[1].Scale = RechargeTime; 
}
simulated function PulseIcons(out float GlobalFloat,int GlobalBool, float mSize, float oSize, optional out SpriteWidget Texture )
{
    local float  Ratio;
    
     if( GlobalBool != 0 )
    {
        Ratio= FClamp(((GlobalFloat) - Level.TimeSeconds),0.0,1.0);
        Texture.TextureScale = oSize + Ratio *( mSize - oSize );
        
        if (Ratio == 0.0)
            GlobalBool = 0;
    }
}
// optional int i --- is for state change( greater that or less than).   HAX? well im sure i made it not very optimised -- AsP
simulated function FlashAnim(bool ShowColor, out float GlobalFloat, out int GlobalBool, float curValue, float lastValue, float mSize, float oSize, optional out SpriteWidget Texture, optional out NumericWidget Number, optional int i )
{
    local float  Ratio;

    if( i > 0 )
    {
        if( CurValue > LastValue)
        {
            GlobalFloat = Level.TimeSeconds + (DIGITS_FADE_TIME+0.4);
            GlobalBool = 1;
        }
    }else
    {
        if( CurValue < LastValue)
        {
            GlobalFloat = Level.TimeSeconds + (DIGITS_FADE_TIME+0.4);
            GlobalBool = 1;
        }
    }

    if( GlobalBool != 0 )
    {

        Ratio= FClamp(((GlobalFloat) - Level.TimeSeconds),0.0,1.0);
        Texture.TextureScale = oSize + Ratio *( mSize - oSize );
        Number.TextureScale  = oSize + Ratio *( mSize - oSize );
        
        if( ShowColor )
        {
		
            Number.Tints[TeamIndex].G = 255 - Ratio * 255;
            Number.Tints[TeamIndex].B = 255 - Ratio * 255;   
        }


        if (Ratio == 0.0)
            GlobalBool = 0;
    }
}

defaultproperties
{
     ClipOffsetX=10
     ClipOffsetY=7
     BaseCrosshair=1.000000
     LongCount(3)=Sound'PariahAnnouncer.1_minute_remaining'
     VehicleHealthBarBG=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=411,Y1=123,X2=469,Y2=128),TextureScale=2.000000,DrawPivot=DP_LowerLeft,PosX=0.410000,PosY=0.920000,Scale=1.000000,Tints[0]=(A=255),Tints[1]=(A=255))
     VehicleHealthBar=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=411,Y1=123,X2=465,Y2=124),TextureScale=2.000000,DrawPivot=DP_LowerLeft,PosX=0.410000,PosY=0.920000,OffsetX=2,OffsetY=-2,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,A=255),Tints[1]=(G=255,A=255))
     DigitsBigPulse=(DigitTexture=Texture'PariahInterface.HUD.Assets',TextureCoords[0]=(X1=126,X2=139,Y2=19),TextureCoords[1]=(X2=13,Y2=19),TextureCoords[2]=(X1=14,X2=27,Y2=19),TextureCoords[3]=(X1=28,X2=41,Y2=19),TextureCoords[4]=(X1=42,X2=55,Y2=19),TextureCoords[5]=(X1=56,X2=69,Y2=19),TextureCoords[6]=(X1=70,X2=83,Y2=19),TextureCoords[7]=(X1=84,X2=97,Y2=19),TextureCoords[8]=(X1=98,X2=111,Y2=19),TextureCoords[9]=(X1=112,X2=125,Y2=19),TextureCoords[10]=(X1=140,X2=153,Y2=19))
     RocketReticle=(WidgetTexture=Texture'InterfaceContent.ReticleRL.ReticleRL',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=128),TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255),bNeverScalePos=True)
     WeaponLevel=(RenderStyle=STY_Alpha,TextureScale=1.000000,DrawPivot=DP_LowerRight,PosX=0.500000,PosY=1.000000,OffsetX=-35,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WECIcon=(WidgetTexture=Texture'PariahInterface.HUD.WECIcon',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.800000,DrawPivot=DP_UpperMiddle,PosX=0.050000,PosY=0.150000,Scale=1.000000,Tints[0]=(B=103,G=149,R=109,A=255),Tints[1]=(B=103,G=149,R=109,A=255))
     WECCount=(RenderStyle=STY_Alpha,TextureScale=0.800000,DrawPivot=DP_UpperMiddle,PosX=0.050000,PosY=0.150000,OffsetY=20,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeaponNextLevelCount=(RenderStyle=STY_Alpha,TextureScale=1.000000,DrawPivot=DP_LowerRight,PosX=0.500000,PosY=1.000000,OffsetX=25,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ColonSprite=(WidgetTexture=Texture'Engine.Fonts.FontMedium_PageADXT',RenderStyle=STY_Alpha,TextureCoords=(X1=415,X2=420,Y2=23),TextureScale=1.000000,DrawPivot=DP_LowerRight,PosX=0.500000,PosY=1.000000,OffsetX=-22,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BackslashSprite=(WidgetTexture=Texture'Engine.Fonts.FontMedium_PageADXT',RenderStyle=STY_Alpha,TextureCoords=(X1=252,X2=260,Y2=23),TextureScale=1.000000,DrawPivot=DP_LowerRight,PosX=0.500000,PosY=1.000000,OffsetX=8,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ConsoleMessageTints(0)=(R=255,A=255)
     ConsoleMessageTints(1)=(B=253,G=216,R=153,A=255)
     HealthBubble(0)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=19,X2=203,Y2=37),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HealthBubble(1)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=19,X2=203,Y2=37),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HealthBubble(2)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=19,X2=203,Y2=37),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HealthBubble(3)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=19,X2=203,Y2=37),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HealthBubble(4)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=19,X2=203,Y2=37),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HealthBubble(5)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=19,X2=203,Y2=37),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HealthBubbleTint(0)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=38,X2=203,Y2=56),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=43,G=48,R=250,A=255),Tints[1]=(B=160,G=151,R=131,A=255))
     HealthBubbleTint(1)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=38,X2=203,Y2=56),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=43,G=48,R=250,A=255),Tints[1]=(B=160,G=151,R=131,A=255))
     HealthBubbleTint(2)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=38,X2=203,Y2=56),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=43,G=48,R=250,A=255),Tints[1]=(B=160,G=151,R=131,A=255))
     HealthBubbleTint(3)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=38,X2=203,Y2=56),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=43,G=48,R=250,A=255),Tints[1]=(B=160,G=151,R=131,A=255))
     HealthBubbleTint(4)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=38,X2=203,Y2=56),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=43,G=48,R=250,A=255),Tints[1]=(B=160,G=151,R=131,A=255))
     HealthBubbleTint(5)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,Y1=38,X2=203,Y2=56),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=43,G=48,R=250,A=255),Tints[1]=(B=160,G=151,R=131,A=255))
     HealthBubbleBackground(0)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,X2=203,Y2=18),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,Tints[0]=(A=153),Tints[1]=(A=153))
     HealthBubbleBackground(1)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,X2=203,Y2=18),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetX=28,OffsetY=-10,Tints[0]=(A=153),Tints[1]=(A=153))
     HealthBubbleBackground(2)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,X2=203,Y2=18),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,Tints[0]=(A=153),Tints[1]=(A=153))
     HealthBubbleBackground(3)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,X2=203,Y2=18),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,Tints[0]=(A=153),Tints[1]=(A=153))
     HealthBubbleBackground(4)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,X2=203,Y2=18),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,Tints[0]=(A=153),Tints[1]=(A=153))
     HealthBubbleBackground(5)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=174,X2=203,Y2=18),TextureScale=1.000000,PosX=0.010000,PosY=0.040000,OffsetY=-10,Tints[0]=(A=153),Tints[1]=(A=153))
     AmmoBackground=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(Y1=95,X2=89,Y2=127),TextureScale=1.000000,PosX=0.770000,PosY=0.030000,OffsetX=30,OffsetY=-2,Tints[0]=(A=200),Tints[1]=(A=200))
     AmmoCapacityFill=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=90,Y1=95,X2=179,Y2=127),TextureScale=1.000000,PosX=0.770000,PosY=0.030000,OffsetX=30,OffsetY=-2,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=101,G=96,R=85,A=120),Tints[1]=(B=101,G=96,R=85,A=120))
     AmmoCapacityTint=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=180,Y1=95,X2=269,Y2=127),TextureScale=1.000000,PosX=0.770000,PosY=0.030000,OffsetX=30,OffsetY=-2,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=101,G=96,R=85,A=200),Tints[1]=(B=101,G=96,R=85,A=200))
     CurWeaponIcon=(RenderStyle=STY_Alpha,TextureScale=0.500000,DrawPivot=DP_MiddleMiddle,PosX=0.770000,PosY=0.030000,OffsetX=220,OffsetY=27,Tints[0]=(G=150,R=255,A=255),Tints[1]=(G=150,R=255,A=200))
     AmmoDigits=(RenderStyle=STY_Alpha,TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,PosX=0.770000,PosY=0.030000,OffsetX=65,OffsetY=15,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Bullet=(RenderStyle=STY_Alpha,TextureScale=1.100000,DrawPivot=DP_UpperRight,PosX=0.770000,PosY=0.030000,Tints[0]=(B=160,G=151,R=131,A=255),Tints[1]=(B=160,G=151,R=131,A=255))
     HealthHideData=(HideSpeed=0.900000,ShowSpeed=0.900000,HiddenPos=(X=-0.030000,Y=-0.030000),HideTimeout=4.000000)
     VoiceMenuClass=Class'XInterfaceHuds.HudXboxSpeechOverlay'
     VoiceChannelMenuClass=Class'XInterfaceHuds.HudXboxVoiceChannelOverlay'
     SoakModeOverlayClass=Class'XInterfaceHuds.OverlaySoakMode'
     DefaultCrossHair=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(Y1=192,X2=63,Y2=255),TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Scale=1.000000,Tints[0]=(B=128,G=128,R=128,A=200),Tints[1]=(B=128,G=128,R=128,A=255),bNeverScalePos=True)
     DefaultTints(0)=(B=128,G=128,R=128,A=200)
     DefaultTints(1)=(B=128,G=128,R=128,A=200)
     ReticleCrosshair=(WidgetTexture=FinalBlend'InterfaceContent.Reticles.Default_Reticle_Final',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,Scale=1.000000,Tints[0]=(R=200,A=200),Tints[1]=(B=204,G=132,R=74,A=255),bNeverScalePos=True)
     LHud(0)=(WidgetTexture=Texture'InterfaceContent.HUD.newHudTMP',RenderStyle=STY_Alpha,TextureCoords=(Y1=24,X2=96,Y2=47),TextureScale=1.000000,OffsetY=15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=30,G=30,R=255),Tints[1]=(B=255,G=216))
     LHud(1)=(WidgetTexture=Texture'InterfaceContent.HUD.newHudTMP',RenderStyle=STY_Alpha,TextureCoords=(Y1=48,X2=96,Y2=74),TextureScale=1.000000,OffsetY=14,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=7,G=179,R=233),Tints[1]=(B=68,G=238,R=134))
     OverHeatingIcon(0)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=383,Y1=64,X2=336,Y2=127),TextureScale=1.000000,PosX=0.500000,PosY=0.500000,OffsetX=30,OffsetY=-30,ScaleMode=SM_Up,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=100),Tints[1]=(B=255,G=255,R=255,A=100))
     OverHeatingIcon(1)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=336,Y1=64,X2=383,Y2=127),TextureScale=1.000000,DrawPivot=DP_UpperRight,PosX=0.500000,PosY=0.500000,OffsetX=-30,OffsetY=-30,ScaleMode=SM_Up,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=100),Tints[1]=(B=255,G=255,R=255,A=100))
     HealthCount=(RenderStyle=STY_Alpha,TextureScale=1.000000,DrawPivot=DP_MiddleRight,OffsetX=89,OffsetY=17,Tints[0]=(B=255,G=255,R=255),Tints[1]=(B=255,G=255,R=255))
     ShieldCount=(RenderStyle=STY_Alpha,TextureScale=0.850000,DrawPivot=DP_MiddleRight,PosX=0.100000,OffsetX=89,OffsetY=17,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HealthIcon=(WidgetTexture=Texture'InterfaceContent.HUD.newHudTMP',RenderStyle=STY_Alpha,TextureCoords=(X1=97,Y1=24,X2=130,Y2=53),TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,OffsetX=15,OffsetY=20,Scale=1.000000,Tints[0]=(B=30,G=30,R=255),Tints[1]=(B=255,G=200))
     DigitsBig=(DigitTexture=Texture'PariahInterface.HUD.Assets',TextureCoords[0]=(X1=126,X2=139,Y2=19),TextureCoords[1]=(X2=13,Y2=19),TextureCoords[2]=(X1=14,X2=27,Y2=19),TextureCoords[3]=(X1=28,X2=41,Y2=19),TextureCoords[4]=(X1=42,X2=55,Y2=19),TextureCoords[5]=(X1=56,X2=69,Y2=19),TextureCoords[6]=(X1=70,X2=83,Y2=19),TextureCoords[7]=(X1=84,X2=97,Y2=19),TextureCoords[8]=(X1=98,X2=111,Y2=19),TextureCoords[9]=(X1=112,X2=125,Y2=19),TextureCoords[10]=(X1=140,X2=153,Y2=19))
     ConsoleMessageCount=6
     ConsoleMessagePosX=0.005000
     PreGameOverlayClass=Class'XInterfaceHuds.OverlayPreGame'
     SpectatingOverlayClass=Class'XInterfaceHuds.OverlaySpectating'
     UtilityOverlayClass=Class'XInterfaceHuds.OverlayLiveUtility'
}
