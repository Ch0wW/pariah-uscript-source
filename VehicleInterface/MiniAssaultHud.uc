class MiniAssaultHud extends HudATeamDeathmatch;

var SpriteWidget ObjectiveIcon;
var SpriteWidget ObjectiveHealth[2];

simulated function DrawHudPassA (Canvas C)
{
	local float newdamage;

	Super.DrawHudPassA(C);
	
	C.SetDrawColor(0,0,255);
	C.Font = C.MedFont;

	//damage bar stuff
	if(PlayerOwner.GameReplicationInfo.ObjectiveDamage[0] == 0) 
		return;

	newdamage = float(PlayerOwner.GameReplicationInfo.ObjectiveDamage[0]) / 255.0;

	ObjectiveHealth[1].Tints[TeamIndex] = GoldColor;
	ObjectiveHealth[1].Scale = newdamage;

	DrawSpriteWidget( C, ObjectiveIcon );
	DrawSpriteWidget( C, ObjectiveHealth[0] );
	DrawSpriteWidget( C, ObjectiveHealth[1] );
}

defaultproperties
{
     ObjectiveIcon=(WidgetTexture=Texture'PariahInterface.HUD.XAssaultObjective',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=127),TextureScale=0.800000,PosX=0.020000,PosY=0.720000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ObjectiveHealth(0)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=411,Y1=123,X2=469,Y2=128),TextureScale=2.000000,DrawPivot=DP_LowerLeft,PosX=0.030000,PosY=0.920000,Scale=1.000000,Tints[0]=(A=255),Tints[1]=(A=255))
     ObjectiveHealth(1)=(WidgetTexture=Texture'PariahInterface.HUD.Assets',RenderStyle=STY_Alpha,TextureCoords=(X1=411,Y1=123,X2=465,Y2=124),TextureScale=2.000000,DrawPivot=DP_LowerLeft,PosX=0.030000,PosY=0.920000,OffsetX=2,OffsetY=-2,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,A=255),Tints[1]=(G=255,A=255))
}
