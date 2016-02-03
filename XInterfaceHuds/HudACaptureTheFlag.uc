class HudACaptureTheFlag extends HudATeamDeathMatch;

enum EFlagState
{
    FS_Home,
    FS_Held,
    FS_Down,
};

struct FFlagWidget
{
    var EFlagState      FlagState;
    var SpriteWidget    Widgets[3];
};

var() FFlagWidget   FlagWidgets[2];
var() SpriteWidget  Flags[2];

var Actor RedBase, BlueBase;
var Actor RedFlagPos, BlueFlagPos;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, True);
}

// Alpha Pass ==================================================================================
simulated function DrawHudPassA (Canvas C)
{
	local CTFBase B;
	local CTFFlag FlagCarrierPos;

    Super.DrawHudPassA (C);

	//DrawHudRadar(C);
	
	if ( RedFlagPos == None )
	{
		ForEach DynamicActors(Class'CTFFlag', FlagCarrierPos)
		{
			if ( FlagCarrierPos.IsA('xRedFlag') )
				RedFlagPos = FlagCarrierPos;
			else
				BlueFlagPos = FlagCarrierPos;
		}
	}
	
	if ( RedBase == None )
	{
		ForEach DynamicActors(Class'CTFBase', B)
		{
			if ( B.IsA('xRedFlagBase') )
				RedBase = B;
			else
				BlueBase = B;
		}
	}
	
	// Base Positions
	//Draw2DLocationDot(C, RedBase.Location, default.Radar[0].PosX, default.Radar[0].PosY, 0 );
	//DrawSpriteWidget (C, Radar[2]);
	//Radar[2].PosX = RedRadarPosX;
	//Radar[2].PosY = RedRadarPosY;
	//
	//Draw2DLocationDot(C, BlueBase.Location, default.Radar[0].PosX, default.Radar[0].PosY, 1 );
	//DrawSpriteWidget (C, Radar[3]);	
	//Radar[3].PosX = BlueRadarPosX;
	//Radar[3].PosY = BlueRadarPosY;
	
	//CMR - don't need radar to bump team scoring positions around anymore
	//RadarPostioning();	
	//-- CMR	
	
	DrawSpriteWidget (C, Flags[0]);
	DrawSpriteWidget (C, Flags[1]);
    
    DrawNumericWidget(C, ScoreTeam[0], DigitsBig);
    DrawNumericWidget(C, ScoreTeam[1], DigitsBig);

	DrawSpriteWidget (C, FlagWidgets[0].Widgets[FlagWidgets[0].FlagState]);
    DrawSpriteWidget (C, FlagWidgets[1].Widgets[FlagWidgets[1].FlagState]);

}

function Timer()
{
	Super.Timer();

    if( PawnOwnerPRI == None )
        return;

	if( PawnOwnerPRI.HasFlag != None )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFHUDMessage', 0 );

    if( PawnOwnerPRI.Team == None )
        return;
		
	if( PlayerOwner.GameReplicationInfo.GameObjStates[PawnOwnerPRI.Team.TeamIndex] == GOS_Dropped )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFHUDMessage', 2 );
	else if( PlayerOwner.GameReplicationInfo.GameObjStates[PawnOwnerPRI.Team.TeamIndex] != GOS_Home )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFHUDMessage', 1 );
}

simulated function UpdateHud()
{
	local int i;
    local int TeamOffset;

    Super.UpdateHud ();

	if ((PawnOwnerPRI != none) && (PawnOwnerPRI.Team != None))
        TeamOffset = Clamp (PawnOwnerPRI.Team.TeamIndex, 0, 1);
    else
        TeamOffset = 0;

    for (i = 0; i < 2; i++)
    {
        switch( PlayerOwner.GameReplicationInfo.GameObjStates[i] )
        {
            case GOS_Home:
                FlagWidgets[(i + TeamOffset) % 2].FlagState = FS_Home;
                break;
            case GOS_Dropped:
                FlagWidgets[(i + TeamOffset) % 2].FlagState = FS_Down;
                break;
            case GOS_Held:
                FlagWidgets[(i + TeamOffset) % 2].FlagState = FS_Held;
                break;
        }
    }   
}

defaultproperties
{
     FlagWidgets(0)=(Widgets[0]=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,PosX=0.025000,OffsetX=10,Scale=1.000000,Tints[0]=(B=60,G=60,R=255,A=255),Tints[1]=(B=255,G=205,R=100,A=255)),Widgets[1]=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=54,Y1=28,X2=66,Y2=56),TextureScale=0.800000,DrawPivot=DP_MiddleMiddle,PosX=0.025000,PosY=0.700000,OffsetX=20,OffsetY=25,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)),Widgets[2]=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=31,Y1=28,X2=51,Y2=56),TextureScale=0.800000,DrawPivot=DP_MiddleMiddle,PosX=0.025000,PosY=0.700000,OffsetX=20,OffsetY=25,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)))
     FlagWidgets(1)=(Widgets[0]=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,PosX=0.025000,OffsetX=10,OffsetY=40,Scale=1.000000,Tints[0]=(B=255,G=205,R=100,A=255),Tints[1]=(B=60,G=60,R=255,A=255)),Widgets[1]=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=54,Y1=28,X2=66,Y2=56),TextureScale=0.800000,DrawPivot=DP_MiddleMiddle,PosX=0.025000,PosY=0.700000,OffsetX=20,OffsetY=75,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)),Widgets[2]=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=31,Y1=28,X2=51,Y2=56),TextureScale=0.800000,DrawPivot=DP_MiddleMiddle,PosX=0.025000,PosY=0.700000,OffsetX=20,OffsetY=75,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)))
     Flags(0)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(Y1=28,X2=29,Y2=72),TextureScale=0.600000,PosX=0.025000,PosY=0.700000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=255),Tints[1]=(B=255,G=192,A=255))
     Flags(1)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(Y1=28,X2=29,Y2=72),TextureScale=0.600000,PosX=0.025000,PosY=0.700000,OffsetY=50,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=192,A=255),Tints[1]=(R=255,A=255))
}
