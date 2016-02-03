class xPawnSoundGroup extends Object
    abstract;

var(Sounds) array<Sound> Sounds;
var(Sounds) array<Sound> HitSounds;
var(Sounds) array<Sound> DeathSounds;

Enum ESoundType
{
    EST_Land,
    EST_CorpseLanded,
    EST_Hit,
    EST_HitUnderWater,
    EST_Jump,
    EST_LandGrunt,
    EST_Die,
    EST_Gasp,
    EST_Drown,
    EST_BreatheAgain,
    EST_Dodge,
    EST_DoubleJump
};

static function Sound GetSound(ESoundType soundType)
{
    return default.Sounds[int(soundType)];
}

static function Sound GetHitSound()
{
    return default.HitSounds[Rand(default.HitSounds.Length)];
}

static function Sound GetDeathSound()
{
    return default.DeathSounds[Rand(default.DeathSounds.Length)];
}

defaultproperties
{
     Sounds(0)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     Sounds(4)=SoundGroup'NewFootsteps.JumpGrunt.JumpGruntGroup'
}
