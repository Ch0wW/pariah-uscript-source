class TeamSayMessagePlus extends StringMessagePlus;

static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional string MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string LocationName;

	if (RelatedPRI_1 == None)
		return;

	Canvas.SetDrawColor(0,255,0);
	Canvas.DrawText( RelatedPRI_1.RetrivePlayerName()$" " );
	Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
	LocationName = RelatedPRI_1.GetLocationName();

	if (LocationName != "")
	{
		Canvas.SetDrawColor(0,128,255);
		Canvas.DrawText( " ("$LocationName$"):" );
	}
	else
		Canvas.DrawText( ": " );
	Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
	Canvas.SetDrawColor(0,128,0);
	Canvas.DrawText( MessageString );
}

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	local string LocationName;

	if (RelatedPRI_1 == None)
		return "";
	LocationName = RelatedPRI_1.GetLocationName();
	if ( LocationName == "" )
		return RelatedPRI_1.RetrivePlayerName() $ ":"@MessageString;
	else
		return RelatedPRI_1.RetrivePlayerName() @ "("$LocationName$"): "$MessageString;
}

static function color GetConsoleColor( PlayerReplicationInfo RelatedPRI_1 )
{
    return Default.DrawColor;
}

defaultproperties
{
     Lifetime=6.000000
     DrawColor=(B=0,R=0)
     bComplexString=True
}
