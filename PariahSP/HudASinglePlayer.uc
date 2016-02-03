class HudASinglePlayer extends HudADeathMatch;

var() SpriteWidget Test;
var() SpriteWidget RadarBG;
var() SpriteWidget Blip;
var() SpriteWidget BossIcon;
var() SpriteWidget BossHealthBar;
var Texture Black;
var float RadarCenterX;
var float RadarCenterY;
var float RangeX;
var float RangeY;

var float FireCircleRange;

var int RadarTop,RadarLeft,RadarWidth,RadarHeight;

const MaxMatineeText=5;

var SpriteWidget RideHud[2];
var NumericWidget RideHealthCount;
var SpriteWidget RideHealthIcon;


var int LastRideHealth;

var NumericWidget TimerValue[2];
var() SpriteWidget	TimerColonSprite;
var float FadeOut;
var float FadeDuration;
var color FadeOutColor;
var bool TransitionOut;

simulated function QueueCinematicFade(float time, color TransitionColor)
{
	// sjs - time < 0 means fade in > 0 means fade out.  Also, vice versa.
	if(time < 0)
	{
		FadeDuration = -time;
		TransitionOut = false;
	}
	else
	{
		FadeDuration = time;
		TransitionOut = true;
        StopAllMusic(time);
	}
	FadeOut = FadeDuration;
	FadeOutColor = TransitionColor;
}

simulated function DrawBars(Canvas C, float LerpIn)
{
	local float BarRatio; // sjs - !! 640x480 becomes 640x360 in the current bink cutscenes (except ch1sc2!!!)
	BarRatio = 0.125 * LerpIn;

	C.SetPos(0,0); // draw upper bar
    C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.DrawColor.A = 255;

	C.Style = ERenderStyle.STY_Alpha;

	if( PlayerOwner.IsSharingScreen() )
	{
		if( PlayerOwner.Player.SplitIndex == 0 )
		{
			C.DrawTile( Black, C.SizeX, 480 * BarRatio, 0.0, 0.0, 32, 32 );
		}
		else
		{
			C.SetPos(0,C.SizeY); // draw upper bar
			C.DrawTile( Black, C.SizeX, -480 * BarRatio, 0.0, 0.0, 32, 32 );
		}
	}
	else
	{
		C.DrawTile( Black, C.SizeX, C.SizeY * BarRatio, 0.0, 0.0, 32, 32 );
		C.SetPos(0,C.SizeY); // draw upper bar
		C.DrawTile( Black, C.SizeX, -C.SizeY * BarRatio, 0.0, 0.0, 32, 32 );
	}
}



simulated function DrawHudPassB(Canvas C)
{
	local vector fade;
	local vector fog;

	Super.DrawHudPassB(C);

	if(FadeOut > 0.0)
	{
	    if(TransitionOut)
	    {
	        fade.X = (FadeOut / FadeDuration);
        }
        else
        {
            fade.X = 1.0 - (FadeOut / FadeDuration);
        }
	    fade.Y = 1;
	    fade.Z = 1;
	    fog.X = FadeOutColor.R;
	    fog.Y = FadeOutColor.G;
	    fog.Z = FadeOutColor.B;
	    DrawScreenFlash(C, fade, fog);
	    DrawBars(C, 1.0 - fade.X);
	}
}

simulated function Tick(float d)
{
	Super.Tick(d);
	if(FadeOut > 0.0)
	{
		FadeOut = FClamp(FadeOut - d, 0.0, FadeDuration);
	}
}

simulated function Vector GetRadarLoc(Actor p)
{
	local vector loc, ret, norm;
	local Rotator fudge;
	local float f;

	loc = p.Location - PawnOwner.Location; //center is our character

	if(true) //transform the point
	{
		fudge.yaw = 16384;
		loc = loc << (PawnOwner.Rotation + fudge);
	}

	//cap at 4400 dist

	f = VSize(loc);
	if(f > 4400.0)
	{
		norm = Normal(loc);
		loc = norm * 4400.0;
	}

	ret.x = loc.x * (RadarWidth/2.15) / RangeX;
	ret.y = loc.y * (RadarHeight/2.15) / RangeY;

	return ret;

}

simulated function DrawFriendlyBlip( Canvas C, float X, float Y)
{
	Blip.PosX = X;
	Blip.PosY = Y;
	DrawSpriteWidget (C, Blip);
	C.Flush();
}

simulated function DrawSpecialTimedScene(Canvas C)
{
	local SinglePlayerController spc;
	local float TimeLeft, s;

	spc = SinglePlayerController(PlayerOwner);

	if(spc == None || spc.bInSpecialTimedScene==false)
	{
		return;
	}

	TimeLeft = FMax(0.0, spc.TimerSceneExpireTime - Level.TimeSeconds);

	if(TimeLeft > 60.0) //more than a minute, do minutes:seconds
	{
		TimerValue[0].Value = TimeLeft / 60;
		TimerValue[1].Value = TimeLeft - TimerValue[0].Value * 60;
	}
	else if(TimeLeft >= 0.0) //seconds:hundredths
	{
		TimerValue[0].Value = TimeLeft;
		s=(TimeLeft - float(TimerValue[0].Value)) * 100.0;
		TimerValue[1].Value = s;
	}

	DrawNumericWidget (C, TimerValue[0], DigitsBig);
	DrawNumericWidget (C, TimerValue[1], DigitsBig);
	DrawSpriteWidget(C, TimerColonSprite);

}

simulated function DrawBossBar(Canvas C)
{
	local SinglePlayerController spc;
	local Pawn p;

	spc = SinglePlayerController(PlayerOwner);

	if(spc == None || spc.bEnableBossBar==false)
	{
		LastRideHealth=0;
		return;
	}

	p = spc.Boss;

	if(p==None)
	{
		LastRideHealth=0;
		return;
	}

	if(LastRideHealth==0)
		LastRideHealth = p.Health;

    BossHealthBar.Scale = FClamp(Min(float(p.Health), float(p.default.Health)) / float(p.default.Health),0.0,1.0);

    BossIcon.WidgetTexture = SPPawn(p).HUDIcon;
    BossIcon.TextureCoords = SPPawn(p).HUDIconCoords;

	DrawSpriteWidget (C, BossIcon);
    DrawSpriteWidget (C, BossHealthBar);

	LastRideHealth = p.Health;

}


simulated function DrawSpecialVehicleScene(Canvas C)
{
	local SinglePlayerController spc;
	local VGVehicle v;

	spc = SinglePlayerController(PlayerOwner);

	if(spc == None || spc.bInSpecialVehicleScene==false)
	{
		LastRideHealth=0;
		return;
	}

	v = VGPawn(spc.Pawn).RiddenVehicle;

	if(v==None)
	{
		LastRideHealth=0;
		return;
	}

    VehicleHealthBar.Scale = FClamp(Min(float(v.Health), float(v.default.Health)) / float(v.default.Health),0.0,1.0);

    if(VehicleHealthBar.Scale < 0.4)
        VehicleHealthBar.Tints[TeamIndex].A = default.VehicleHealthBar.Tints[TeamIndex].A * Sin(Level.TimeSeconds * 10);
    else
        VehicleHealthBar.Tints[TeamIndex].A = default.VehicleHealthBar.Tints[TeamIndex].A;

    DrawSpriteWidget (C, VehicleHealthBarBG);
    DrawSpriteWidget (C, VehicleHealthBar);
	LastRideHealth = v.Health;
}

simulated function DrawTagLocator( Canvas C )
{
	local SinglePlayerController spc;
	local Vector TagPos;

	spc = SinglePlayerController(PlayerOwner);

	if(spc == None || spc.bEnableTagLocator==false || spc.LocatorPawn == None)
	{
		return;
	}

	if(RadarTop == 0) //probably not initialized
	{
		GetSpriteWidgetExtents(C, RadarBG, RadarLeft,RadarTop,RadarWidth,RadarHeight);
	}


	DrawSpriteWidget (C, RadarBG);

	TagPos = GetRadarLoc(spc.LocatorPawn);

	if( TagPos != Vect(0,0,0) )
	{
		DrawFriendlyBlip(C, TagPos.x / C.ClipX + RadarCenterX, TagPos.y / C.ClipY + RadarCenterY);
	}



}

function Timer()
{
	RideHud[0].WidgetTexture=Material'InterfaceContent.Hud.newHudTMP';
	RideHud[1].WidgetTexture=Material'InterfaceContent.Hud.newHudTMP';
	RideHealthIcon.WidgetTexture=Material'InterfaceContent.Hud.newHudTMP';
}

simulated function DrawHudPassA (Canvas C)
{
	local SPAIController bot;
	local GameplayDevices d;
	//local Material mat;
	//local TexRotator trot;
	//local Controller ctrl;
	//local Rotator rot;
	//local Pawn p;
	//local vector loc;
	//local SPAIController spai;
	//local color white;
	DrawBossBar(C);
	DrawSpecialVehicleScene(C);
	DrawSpecialTimedScene(C);
	Super.DrawHudPassA(C);
	//DrawTagLocator(C);

	// jim: Disable radar until art is finalized and performance optimized.
	//PassStyle=STY_Subtractive;
	//DrawSpriteWidget (C, RadarBG);
	//PassStyle=STY_Alpha;

	//SetFireCircleWidth(C, ActiveWeapon.FireMode[0].MaxFireNoiseDist);
	//if(FireCircleRange > 0.0f)
	//{
	//	DrawSpriteWidget (C, FireCircle);

	//	if(ActiveWeapon.FireMode[0].bIsFiring)
	//	{
	//		DrawSpriteWidget (C, FireCircle);
	//	}
	//}


	////log("Got"@l@t@w@h);

	//if(RadarTop == 0) //probably not initialized
	//{
	//	GetSpriteWidgetExtents(C, RadarBG, RadarLeft,RadarTop,RadarWidth,RadarHeight);
	//}

	//C.SetPos(RadarLeft, RadarTop);
	//C.DrawBox(C, RadarWidth, RadarHeight);

	//mat = Test.WidgetTexture;
	//trot = TexRotator(mat);
	//
	//white.R =  255;
	//	white.G =  255;
	//	white.B = 255;
	//	white.A = 255;
	//if(!PlayerOwner.bRelativeRadar)
	//	DrawBlipCone(C, trot, RadarCenterX, RadarCenterY, 65536 - (PawnOwner.Rotation.Yaw&65535) - 8192, white);
	//else
	//	DrawBlipCone(C, trot, RadarCenterX, RadarCenterY, 8192, white);

	////now draw all the controllers

	//for(ctrl=Level.ControllerList; ctrl!= None; ctrl=ctrl.NextController)
	//{
	//	p = ctrl.Pawn;
	//	spai = SPAIController(ctrl);

	//	if(p==None || spai==None) continue;

	//	loc = GetRadarLoc(p);
	//	if(loc == Vect(0,0,0)) continue;

	//	rot = p.Rotation;
	//
	//	if(PlayerOwner.bRelativeRadar)
	//	{
	//		rot -= PawnOwner.Rotation;
	//	}


	//	if(ctrl.SameTeamAs(PlayerOwner))
	//	{
	//		if(!PlayerOwner.bRelativeRadar)
	//			DrawFriendlyBlip(C, loc.x / C.ClipX + RadarCenterX, loc.y / C.ClipY + RadarCenterY);
	//		else
	//			DrawFriendlyBlip(C, loc.x / C.ClipX + RadarCenterX, loc.y / C.ClipY + RadarCenterY);
	//
	//	}
	//	else
	//	{
	//		if(!PlayerOwner.bRelativeRadar)
	//			DrawBlipCone(C, trot, loc.x / C.ClipX + RadarCenterX, loc.y / C.ClipY + RadarCenterY, 65535 - (rot.yaw&65535) - 8192 , GetAlertnessColor(spai.GetAlertness()));
	//		else
	//			DrawBlipCone(C, trot, loc.x / C.ClipX + RadarCenterX, loc.y / C.ClipY + RadarCenterY, 65535 - (rot.yaw&65535) + 8192 , GetAlertnessColor(spai.GetAlertness()));
	//	}
	//}


    if( SinglePlayerController(PlayerOwner) != None )
    {
        if( SinglePlayerController(PlayerOwner).bDebugBots )
        {
		    foreach AllActors( class'SPAIController', bot )
		    {
			    bot.DrawHUDDebug(C);
		    }
        }
        if( SinglePlayerController(PlayerOwner).bBotStats )
        {
            SinglePlayerController(PlayerOwner).drawBotStats(C);
        }
    }

    if( SinglePlayerController(PlayerOwner) != None )
    {
        if( SinglePlayerController(PlayerOwner).bDebugDevices )
        {
		    foreach AllActors( class'GameplayDevices', d )
		    {
			    d.DrawHUDDebug(C, PlayerOwner.Pawn.Location);
		    }
        }
    }

}

function DrawSpectatingHud(Canvas C)
{
	DisplayLocalMessages (C);
}

simulated function CalculateHealth()
{
	Super.CalculateHealth();
}


simulated function DrawMatineeHud(Canvas C)
{
	local PlayerController PC;
	local int i;
	local float barheight;


	PC = PlayerOwner;

	if(PC==None) return;

	if(C.Viewport != None && C.IsCinematicMode()) //draw some black bars
	{
		barheight = 100.0 / 480.0 * C.ClipY;
		C.SetDrawColor(0,0,0,255);
		C.Style = ERenderStyle.STY_Normal;
		C.SetFPos(0,0);
		C.DrawTile(Black, C.ClipX,barheight,0,0, 16,16);
		C.SetPos(0,380.0 / 480.0 * C.ClipY);
		C.DrawTile(Black, C.ClipX,barheight,0,0, 16,16);
	}


	for(i=0;i<PC.MatineeMaterialArray.Length;i++)
	{
		C.DrawColor = PC.MatineeMaterialArray[i].Color;
		C.DrawScreenTile(PC.MatineeMaterialArray[i].M, PC.MatineeMaterialArray[i].X, PC.MatineeMaterialArray[i].Y, PC.MatineeMaterialArray[i].Pivot, PC.MatineeMaterialArray[i].Width, PC.MatineeMaterialArray[i].Height);
	}


	for(i=0;i<PC.MatineeTextArray.Length;i++)
	{
		C.Font = C.MedFont;
		C.DrawColor = PC.MatineeTextArray[i].Color;
		C.DrawScreenText(PC.MatineeTextArray[i].TextID, PC.MatineeTextArray[i].X, PC.MatineeTextArray[i].Y, PC.MatineeTextArray[i].Pivot);
	}

	Super.DrawMatineeHud(C);
}

defaultproperties
{
     RadarCenterX=0.870000
     RadarCenterY=0.125500
     RangeX=5000.000000
     RangeY=5000.000000
     Black=Texture'InterfaceContent.HUD.Black'
     RadarBG=(WidgetTexture=Texture'InterfaceContent.Radar.Base',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,PosX=0.870000,PosY=0.125500,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Blip=(WidgetTexture=Shader'InterfaceContent.Radar.sDotRed',RenderStyle=STY_Alpha,TextureCoords=(X2=16,Y2=16),TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,PosX=0.870000,PosY=0.125500,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BossIcon=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=1.000000,DrawPivot=DP_LowerLeft,PosX=0.010000,PosY=0.900000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BossHealthBar=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=411,Y1=123,X2=469,Y2=126),TextureScale=1.000000,DrawPivot=DP_LowerLeft,PosX=0.010000,PosY=0.900000,OffsetX=2,OffsetY=-2,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,A=255),Tints[1]=(G=255,A=255))
     RideHud(0)=(WidgetTexture=Texture'InterfaceContent.HUD.newHudTMP',RenderStyle=STY_Alpha,TextureCoords=(Y1=24,X2=96,Y2=47),TextureScale=1.200000,PosY=0.500000,OffsetY=15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=30,G=30,R=255,A=255),Tints[1]=(B=255,G=216,A=255))
     RideHud(1)=(WidgetTexture=Texture'InterfaceContent.HUD.newHudTMP',RenderStyle=STY_Alpha,TextureCoords=(Y1=48,X2=96,Y2=74),TextureScale=1.200000,PosY=0.500000,OffsetY=14,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=7,G=179,R=233,A=255),Tints[1]=(B=68,G=238,R=134,A=255))
     RideHealthCount=(RenderStyle=STY_Alpha,TextureScale=1.200000,DrawPivot=DP_MiddleRight,PosY=0.500000,OffsetX=89,OffsetY=17,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RideHealthIcon=(WidgetTexture=Texture'InterfaceContent.HUD.newHudTMP',RenderStyle=STY_Alpha,TextureCoords=(X1=97,Y1=24,X2=130,Y2=53),TextureScale=1.200000,DrawPivot=DP_MiddleMiddle,PosY=0.500000,OffsetX=15,OffsetY=20,Scale=1.000000,Tints[0]=(B=30,G=30,R=255,A=255),Tints[1]=(B=255,G=200,A=255))
     TimerValue(0)=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=1.200000,DrawPivot=DP_MiddleRight,PosX=0.890000,PosY=0.500000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255),bPadWithZeroes=1)
     TimerValue(1)=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=1.200000,DrawPivot=DP_MiddleLeft,PosX=0.900000,PosY=0.500000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255),bPadWithZeroes=1)
     TimerColonSprite=(WidgetTexture=Texture'Engine.Fonts.FontMedium_PageADXT',RenderStyle=STY_Alpha,TextureCoords=(X1=415,X2=420,Y2=23),TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,PosX=0.895000,PosY=0.495000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     bHudShowsTargetInfo=False
}
