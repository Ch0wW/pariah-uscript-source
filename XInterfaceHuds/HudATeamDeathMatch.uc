class HudATeamDeathMatch extends HudADeathMatch;


var() NumericWidget ScoreTeam[2];
var() SpriteWidget  TeamSymbols[2];

var() SpriteWidget Radar[6];

var Sound OvertimeSound;
var bool bWasOvertime;

// Ojective Arrows 
 var Material ObjectiveTex;// , PointerTexUD, PointerTexRL;
var() SpriteWidget ObjectiveAlert;
var() SpriteWidget ObjectiveAlertArrowsUD;
var() SpriteWidget ObjectiveAlertArrowsLR;



simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    SetTimer(1.0, True);
}


// Alpha Pass ==================================================================================
simulated function DrawHudPassA (Canvas C)
{
	local bool bDrawRight, bDrawBottom;
	local bool bDrawRLArrow, bDrawTBArrow;
	local Vector vDrawPos;
	local Vector viewdir, viewpos;// , objdir ;
	local Actor viewact;
	local Rotator viewrot;
	local float angle;
	local bool bInvertX;

	Super.DrawHudPassA (C);

	// DrawNumericWidget (C, ScoreTeam[0], DigitsBig);
	// DrawNumericWidget (C, ScoreTeam[1], DigitsBig);


	if(bHighlightFlagPos)
	{
		if(!bManualHighlight)
		{
			ManualFlagpos = PlayerOwner.GameReplicationInfo.FlagPos[0];
		}

		HighlightPos = C.WorldToScreen(ManualFlagpos);
	
        if(VSize(ManualFlagpos - PawnOwner.Location) < 700) return;

		C.DrawColor = HudHighLightColor;
				
		if(HighlightPos.z <= 1.0)
		{
			if(HighlightPos.x < 0 || HighlightPos.x >= C.ClipX || HighlightPos.y < 0 || HighlightPos.y > C.ClipY)
			{
				bDrawRLArrow = HighlightPos.x < 0 || HighlightPos.x >= C.ClipX;
				bDrawTBArrow = HighlightPos.y < 0 || HighlightPos.y > C.ClipY;
				bDrawRight = ( HighlightPos.x >= C.ClipX );
				bDrawBottom = ( HighlightPos.y >= C.ClipY );
			}
			else
			{
				 C.SetPos(HighlightPos.x-32 , HighlightPos.y-32);
				 C.DrawTile(ObjectiveTex, 64, 64, 0, 0, 64, 64);
			}
		}
		else
		{
			//bDrawArrow=True;
			bDrawRLArrow = True;

			//flash side arrows
			if(HighlightPos.x < C.ClipX/2) //right side
				bDrawRight=True;
			if(HighlightPos.y < C.ClipY/2) // bottom side
				bDrawBottom=True;
			
		}

		if(bDrawRLArrow || bDrawTBArrow)
		{
			//log("DrawRLArrow = "$bDrawRLArrow$" DrawTBArrow = "$bDrawTBArrow);
			//right/left arrows should take higher precedence over top/bottom

			if(bDrawRLArrow)
			{

				PlayerOwner.PlayerCalcView(viewact, viewpos, viewrot);
				viewdir=Vector(viewrot);
				angle = Normal(viewdir) dot Normal(PawnOwner.Location - ManualFlagpos);
				//log(angle);
				if(angle > -0.05) // just draw top/bottom
				{
					if(bDrawRLArrow)
					{
						bDrawRLArrow = False;
						bDrawBottom=True;
						bInvertX = True;
					}

					
					
					bDrawTBArrow = True;
				}
			}


						
			if(bDrawRLArrow)
			{
				if(bDrawRight)
				{
					vDrawPos.X = C.ClipX-32;
				}
				else
				{
					vDrawPos.X = 32;
				}

				vDrawPos.Y = Max( Min( HighlightPos.Y, C.ClipY - 32 ), 0 );

				// C.SetPos(vDrawPos.X, vDrawPos.Y);
				
				if(bDrawRight)
				{
					DrawSpriteWidget(C, ObjectiveAlertArrowsLR);

					ObjectiveAlertArrowsLR.TextureCoords.X2 = 0;
					ObjectiveAlertArrowsLR.TextureCoords.X1 = 32;
					ObjectiveAlertArrowsLR.OffsetX = -15;
	
					ObjectiveAlertArrowsLR.PosY = vDrawPos.Y / C.ClipY;
					ObjectiveAlertArrowsLR.PosX = 1.0;

				}
				else
				{
					DrawSpriteWidget(C, ObjectiveAlertArrowsLR);
					ObjectiveAlertArrowsLR = default.ObjectiveAlertArrowsLR;
					ObjectiveAlertArrowsLR.OffsetX = 15;
					ObjectiveAlertArrowsLR.PosY = vDrawPos.Y  / C.ClipY;
					ObjectiveAlertArrowsLR.PosX =0.0;
				}


			}
			else if(bDrawTBArrow)
			{
				if(bDrawBottom)
				{
					vDrawPos.Y = C.ClipY;
				}
				else
				{
					vDrawPos.Y = 0;
				}
				
				vDrawPos.X = Max( Min( HighlightPos.X, C.ClipX ), 0 );
				if(bInvertX)
					vDrawPos.X = C.ClipX - vDrawPos.X ;// Asp - 64;

				//log(HighlightPos);

				// C.SetPos(vDrawPos.X, vDrawPos.Y);
				if(bDrawBottom)
				{
					// C.DrawTile(PointerTexUD, 32, -32, 0, 0, 32, 32);
					DrawSpriteWidget(C, ObjectiveAlertArrowsUD);

					ObjectiveAlertArrowsUD.TextureCoords.X1 = 32;
					ObjectiveAlertArrowsUD.TextureCoords.Y1 = 32;
					ObjectiveAlertArrowsUD.TextureCoords.X2 = 0;
					ObjectiveAlertArrowsUD.TextureCoords.Y2 = 0;

					ObjectiveAlertArrowsUD.PosX = vDrawPos.X / C.ClipX;
					ObjectiveAlertArrowsUD.OffsetY = -15;
					ObjectiveAlertArrowsUD.PosY = 1.0;

				}
				else
				{
					// C.DrawTile(PointerTexUD, 32, 32, 0, 0, 32, 32);
					DrawSpriteWidget(C, ObjectiveAlertArrowsUD);
					ObjectiveAlertArrowsUD = default.ObjectiveAlertArrowsUD;
					ObjectiveAlertArrowsUD.OffsetY = 15;
					ObjectiveAlertArrowsUD.PosX = vDrawPos.X  / C.ClipX;
					ObjectiveAlertArrowsUD.PosY =0.0;
				}

			}


		/*	if(bDrawRight)
			{
				C.SetPos( C.ClipX-10, C.ClipY/2-32);
				C.DrawTile(PointerTex, -32, 64, 0, 0, 32, 64);
			}
			else
			{
				C.SetPos( 10, C.ClipY/2-32);
				C.DrawTile(PointerTex, 32, 64, 0, 0, 32, 64);
			}*/


		}
	}

}

simulated function DrawRankAndSpread( Canvas C );


simulated function UpdateHud()
{
    local GameReplicationInfo GRI;
    local int i;
    local int TeamOffset;
    local int Index;
    

    Super.UpdateHud ();

    if ((PawnOwnerPRI != none) && (PawnOwnerPRI.Team != None))
        TeamOffset = Clamp (PawnOwnerPRI.Team.TeamIndex, 0, 1);
    else
        TeamOffset = 0;

	GRI = PlayerOwner.GameReplicationInfo;

	if (GRI == None)
    {
        log ("HudTeamDeathMatch::DrawHud() - Expected PlayerOwner.GameReplicationInfo to be a GameReplicationInfo", 'Error');
        return;
    }

    for (i = 0; i < 2; i++)
    {
        if( GRI.Teams[i] == None )
            continue;


        Index = (i + TeamOffset) % ArrayCount(ScoreTeam);
        ScoreTeam[Index].Value = GRI.Teams[i].Score;
    }
}

function Timer()
{
	Super.Timer();

    if( PlayerOwner == None )
        return;

    if( PlayerOwner.GameReplicationInfo == None )
        return;

    if( PlayerOwner.GameReplicationInfo.bOverTime && PlayerOwner.GameReplicationInfo.Winner == None )
    {
        if (!bWasOvertime)
            PlayerOwner.PlayAnnouncement(OvertimeSound,1,true);
		PlayerOwner.ReceiveLocalizedMessage( class'CTFHUDMessage', 3 );
    }
    bWasOvertime = PlayerOwner.GameReplicationInfo.bOverTime;
}

defaultproperties
{
     ObjectiveTex=Texture'PariahInterface.HUD.ObjReticleFirst'
     ScoreTeam(0)=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=1.000000,PosX=0.100000,PosY=0.700000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ScoreTeam(1)=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=1.000000,PosX=0.100000,PosY=0.700000,OffsetY=30,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TeamSymbols(0)=(RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.400000,DrawPivot=DP_LowerRight,PosY=0.750000,OffsetX=-12,OffsetY=-12,Tints[0]=(B=60,G=60,R=255,A=255),Tints[1]=(B=255,G=205,R=100,A=255))
     TeamSymbols(1)=(RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.400000,DrawPivot=DP_UpperRight,PosX=0.080000,PosY=0.750000,OffsetX=-12,OffsetY=12,Tints[0]=(B=255,G=205,R=100,A=255),Tints[1]=(B=60,G=60,R=255,A=255))
     Radar(0)=(WidgetTexture=Texture'InterfaceContent.Radar.Base',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.700000,DrawPivot=DP_UpperMiddle,PosX=0.500000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=120,A=150),Tints[1]=(G=120,A=150))
     Radar(1)=(WidgetTexture=TexRotator'InterfaceContent.Radar.rRotator',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.700000,DrawPivot=DP_UpperMiddle,PosX=0.500000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=180,G=180,R=180,A=150),Tints[1]=(B=180,G=180,R=180,A=150))
     Radar(2)=(WidgetTexture=Texture'InterfaceContent.Radar.Dot',RenderStyle=STY_Alpha,TextureCoords=(X2=15,Y2=15),TextureScale=0.700000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.040000,OffsetY=32,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=255),Tints[1]=(R=255,A=255))
     Radar(3)=(WidgetTexture=Texture'InterfaceContent.Radar.Dot',RenderStyle=STY_Alpha,TextureCoords=(X2=15,Y2=15),TextureScale=0.700000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.040000,OffsetY=32,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,A=255),Tints[1]=(B=255,A=255))
     Radar(4)=(WidgetTexture=Shader'InterfaceContent.Radar.sBlip',RenderStyle=STY_Alpha,TextureCoords=(X2=15,Y2=15),TextureScale=0.850000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.040000,OffsetY=32,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Radar(5)=(WidgetTexture=Shader'InterfaceContent.Radar.sBlip',RenderStyle=STY_Alpha,TextureCoords=(X2=15,Y2=15),TextureScale=0.850000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.040000,OffsetY=32,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ObjectiveAlert=(WidgetTexture=Texture'PariahInterface.HUD.ObjReticleFirst',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.750000,DrawPivot=DP_MiddleMiddle,Tints[0]=(G=150,R=255,A=255),Tints[1]=(G=150,R=255,A=255))
     ObjectiveAlertArrowsUD=(WidgetTexture=FinalBlend'InterfaceContent.Alerting.fbObjectiveAlertUP',RenderStyle=STY_Alpha,TextureCoords=(X2=32,Y2=32),TextureScale=2.000000,DrawPivot=DP_MiddleMiddle,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=205,R=255,A=255))
     ObjectiveAlertArrowsLR=(WidgetTexture=FinalBlend'InterfaceContent.Alerting.fbObjectiveAlertLeft',RenderStyle=STY_Alpha,TextureCoords=(X2=32,Y2=32),TextureScale=2.000000,DrawPivot=DP_MiddleMiddle,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=205,R=255,A=255))
     HealthBubbleTint(0)=(Tints[1]=(B=205,G=120,R=45))
     HealthBubbleTint(1)=(Tints[1]=(B=205,G=120,R=45))
     HealthBubbleTint(2)=(Tints[1]=(B=205,G=120,R=45))
     HealthBubbleTint(3)=(Tints[1]=(B=205,G=120,R=45))
     HealthBubbleTint(4)=(Tints[1]=(B=205,G=120,R=45))
     HealthBubbleTint(5)=(Tints[1]=(B=205,G=120,R=45))
     AmmoCapacityFill=(Tints[0]=(B=43,G=48,R=250,A=80),Tints[1]=(B=205,G=120,R=45,A=80))
     AmmoCapacityTint=(Tints[0]=(B=43,G=48,R=250,A=150),Tints[1]=(B=205,G=120,R=45,A=255))
     Bullet=(Tints[0]=(B=43,G=48,R=250),Tints[1]=(B=205,G=120,R=45))
}
