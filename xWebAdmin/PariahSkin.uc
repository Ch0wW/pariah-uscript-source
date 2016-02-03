//-----------------------------------------------------------
//
//-----------------------------------------------------------
class PariahSkin extends WebSkin;

function Init(PariahServerAdmin WebAdmin)
{
	WebAdmin.SkinPath = "";
	WebAdmin.SiteBG = DefaultBGColor;
	WebAdmin.SiteCSSFile = SkinCSS;
}

defaultproperties
{
     DisplayName="Standard Pariah"
}
