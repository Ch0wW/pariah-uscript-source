/*****************************************************************
 * CinematicPlayerController
 * Author: Prof. J LaChapelle
 * This class was create soley to override the SpawnDefaultHUD
 * so that we don't get a hud when we are in a level where we ONLY
 * want to play videos. Likely much of this code can be ripped out, I
 * simply copied the SinglePlayerController because I wanted the input
 * to function identically without the HUD being forced on me by the parent
 * class. Also the video stuff requires that the profiles are loaded properly
 * to be able to skip them.
 *****************************************************************
 */
class CinematicPlayerController extends SinglePlayerController;

function SpawnDefaultHUD()
{
}

function NotifyRestarted()
{
}

exec function CW(int x, int y)
{
}

exec function ShowCurrentObjective()
{
}

defaultproperties
{
}
