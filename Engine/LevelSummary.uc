//=============================================================================
// LevelSummary contains the summary properties from the LevelInfo actor.
// Designed for fast loading.
//=============================================================================
class LevelSummary extends Object
	native;

var(LevelSummary) localized String Title;
var(LevelSummary) String Author;

var(LevelSummary) Material Screenshot;
var(LevelSummary) Material Vignette;
var(LevelSummary) String VideoFile;

var(LevelSummary) int IdealPlayerCountMin;
var(LevelSummary) int IdealPlayerCountMax;

var(LevelSummary) bool HideFromMenus;

var() localized string LevelEnterText;

defaultproperties
{
}
