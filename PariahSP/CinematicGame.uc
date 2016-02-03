/*****************************************************************
 * CinematicGame
 * Author: Prof. J. LaChapelle
 * A gametype essentially the same as the singleplayer but without
 * a HUD. Used in the start level (for instance) so you can play
 * videos without a HUD popping up and looking stupid. NOTE: that
 * this game type needs to make use of a cinematicPlayerController, cause
 * there is some stuff in the PlayerController class that FORCES you
 * to have a HUD
 *****************************************************************
 */
class CinematicGame extends SinglePlayer;

defaultproperties
{
     HUDType=""
     PlayerControllerClassName="PariahSP.CinematicPlayerController"
}
