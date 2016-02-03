class PariahSoundGroup extends xPawnSoundGroup;

static function Sound GetSound(ESoundType soundType)
{
    if( int(soundType) >= default.Sounds.Length )
    {
        return(None);
    }
    else
    {
        return default.Sounds[int(soundType)];
    }
}

static function Sound GetHitSound()
{
    if( default.HitSounds.Length == 0)
        return None;

    return default.HitSounds[Rand(default.HitSounds.Length)];
}

static function Sound GetDeathSound()
{
    if( default.DeathSounds.Length == 0)
        return None;
	
    return default.DeathSounds[Rand(default.DeathSounds.Length)];;
}

defaultproperties
{
     Sounds(0)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     Sounds(4)=SoundGroup'NewFootsteps.JumpGrunt.JumpGruntGroup'
}
