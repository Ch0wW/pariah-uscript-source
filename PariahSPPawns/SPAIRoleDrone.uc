class SPAIRoleDrone extends SPAIRole;

function RoleSelectAction()
{
	if(bot.Enemy == None)
	{
		bot.Perform_NotEngaged_AtRest();
		return;
	}
	else
    {
        if( bot.EnemyIsVisible() )
	    {
		    bot.Perform_Engaged_StrafeMove();
			return;
        }
	    bot.Perform_Engaged_GetLOS();
    }
}

defaultproperties
{
}
