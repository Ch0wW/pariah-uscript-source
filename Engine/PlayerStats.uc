class PlayerStats extends Info
    native;

struct native export StatData
{
    var() int Kills;        // Does not count TeamKills
    var() int TeamKills;
    var() int Deaths;       // Does not include Suicides
    var() int Suicides;     // Includes falling etc.
    var() int Frags;        // Kills - Suicides - TeamKills
    var() int Specials;     // Head-shots, combos, etc

    var() int Shots;
    var() int Hits;
    var() int Accuracy;     // derived percent

    var() class<Weapon> WeaponClass;

    var int LastSentDeaths; // my head hurts
    var int LastSentFrags;  // don't worry, this struct doesn't get replicated in its entirety anymore
    var int LastSentAcc;
};

var() StatData      Overall;
var() StatData      WeaponStats[16];
var() float         PlayTime;
var() int           Efficiency;
var() float         LastTimeUpdate;
var() int           MonsterKills;
var() int           GoalScores;
var() int           Assists;

function PostBeginPlay()
{
    if( PlayerController(Owner) != None )
    {
        SetTimer(0.33, true);
    }
}

function Timer()
{
    PlayerController(Owner).UpdateStats();
}

simulated function int GetNumWeaponStats()
{
    return ArrayCount(WeaponStats);
}

simulated function SetPlayerTimeStats(float PT)
{
    PlayTime = PT;
    LastTimeUpdate = Level.TimeSeconds;
}

simulated function SetWeaponStats(int Index, StatData SD)
{
    WeaponStats[Index] = SD;
}

simulated function StatData GetWeaponStats(int w)
{
    return WeaponStats[w];
}

simulated function float GetWeaponEfficiency(int w)
{
    local int d;
    local StatData WS;

    WS = WeaponStats[w];
    d = WS.Kills + WS.Deaths + WS.Suicides + WS.TeamKills;

    if( d == 0 )
        return( 0 );
    else
        return( float( WS.Kills ) / float( d ) );
}

simulated function float GetWeaponAccuracy(int w)
{
    local StatData WS;

    WS = WeaponStats[w];

    if( WS.Shots == 0 )
        return( 0 );

    return( float(WS.Hits) / float(WS.Shots) );
}

// Synthetic values

function UpdateEfficiency()
{
    local int d;

    d = Overall.Kills + Overall.Deaths + Overall.Suicides + Overall.TeamKills;

    if( d == 0 )
        Efficiency = 0;
    else
        Efficiency = Overall.Kills * 100 / d;
}

/*simulated function float Efficiency()
{
    local int d;

    d = Overall.Kills + Overall.Deaths + Overall.Suicides + Overall.TeamKills;

    if( d == 0 )
        return( 0 );
    else
        return( float( Overall.Kills ) / float( d ) );
}*/

simulated function float Accuracy()
{
    if( Overall.Shots == 0 )
        return( 0 );

    return( float(Overall.Hits) / float(Overall.Shots) );
}

simulated function float FragsPerMinute()
{
    return( float( Overall.Frags * 60) / PlayTime );
}

simulated function float AverageLifeTime()
{
    local int Lives;

    Lives = Overall.Deaths + Overall.Suicides + 1;

    if( Lives < 2 )
        return( PlayTime );
    else
        return( PlayTime / float( Lives ) );
}


// End game stat helpers

function int GetWeaponClassSpecials(name WepName)
{
    local int i;
    local StatData WS;

    for( i = 0; i < GetNumWeaponStats(); i++ )
	{
        WS = GetWeaponStats(i);
        if( WS.WeaponClass != None && WS.WeaponClass.Name == WepName )
            return WS.Specials;
    }
    return 0;
}

function int GetWeaponClassAccuracy(name WepName)
{
    local int i;
    local StatData WS;

    for( i = 0; i < GetNumWeaponStats(); i++ )
	{
        WS = GetWeaponStats(i);
        if( WS.WeaponClass != None && WS.WeaponClass.Name == WepName )
        {
            if( WS.Frags < 5 )
                return( 0 );
            return( WS.Hits * 100 / WS.Shots );
        }
    }
    return 0;
}

function int GetWeaponClassExclusive(name WepName)
{
    local int i;
    local StatData WS;
    local int Frags, OtherFrags;

    for( i = 0; i < GetNumWeaponStats(); i++ )
	{
        WS = GetWeaponStats(i);
        if( WS.WeaponClass != None )
        {
            if ( WS.WeaponClass.Name == WepName )
                Frags = WS.Frags;
            else
                OtherFrags += WS.Frags;
        }
    }
    if (OtherFrags * 5 > Frags)
        Frags = 0;
    return Frags;
}

function int GetWeaponClassDeaths(name WepName)
{
    local int i;
    local StatData WS;

    for( i = 0; i < GetNumWeaponStats(); i++ )
	{
        WS = GetWeaponStats(i);
        if( WS.WeaponClass != None && WS.WeaponClass.Name == WepName )
            return WS.Deaths;
    }
    return 0;
}

// Server Stuff

function bool IsSelf( Controller C )
{
    if( C == None )
        return( true );

    if( C == Controller( Owner ) )
        return( true );

    return( false );
}

function bool IsTeamMate( Controller C )
{
    local TeamInfo A, B;

    assert( !IsSelf( C ) );
    assert( C != None );

    A = C.PlayerReplicationInfo.Team;

    if( A == None )
        return( false );

    B = Controller( Owner ).PlayerReplicationInfo.Team;

    if( B == None )
        return( false );

    return( A == B );
}

function int GetWeaponStat( class<Weapon> WeaponClass )
{
    local int i;

    if( WeaponClass == None )
        return -1;

    for( i = 0; i < ArrayCount(WeaponStats); i++ )
    {
        if( WeaponStats[i].WeaponClass == None )
        {
            //WeaponStats[i] = Spawn( class'WeaponStat', Owner );
            WeaponStats[i].WeaponClass = WeaponClass;
            return i;
        }
        
        if( WeaponStats[i].WeaponClass == WeaponClass )
            return i;
    }

    log( "Out of WeaponStat slots!", 'Error' );

    return -1;
}

function RegisterKill( Controller Killed, class<DamageType> DamageType )
{
    local Controller C;
    local int w;
    local int i;
    local int Best;

    // Don't do suicides here -- they're counted under RegisterDeath

    if( IsSelf( Killed ) )
        return;

    // Basic Stats:

    if( IsTeamMate( Killed ) )
    {
        Overall.TeamKills++;
        Overall.Frags--;
    }
    else
    {
        Overall.Kills++;
        Overall.Frags++;
        if( DamageType.default.bSpecial )
        {
            Overall.Specials++;
            Controller(Owner).PlayerReplicationInfo.Specials += 1.0;
        }
    }
    UpdateEfficiency();

    // Per-Weapon Stats:

    C = Controller( Owner );

    if( C == None )
        return;

    w = GetWeaponStat( DamageType.default.WeaponClass );

    if( w == -1 )
        return;

    if( IsTeamMate( Killed ) )
    {
        WeaponStats[w].TeamKills++;
        WeaponStats[w].Frags--;
    }
    else
    {
        WeaponStats[w].Kills++;
        WeaponStats[w].Frags++;
        if( DamageType.default.bSpecial )
            WeaponStats[w].Specials++;
    }

    // determine fav weapon here
    Overall.WeaponClass = WeaponStats[w].WeaponClass;
    Best = WeaponStats[w].Kills + WeaponStats[w].TeamKills;
    for( i = 0; i < ArrayCount(WeaponStats); i++ )
    {
        if( WeaponStats[i].WeaponClass == Overall.WeaponClass )
            continue;

        if( WeaponStats[i].WeaponClass == None )
            continue;

        if( WeaponStats[i].Kills + WeaponStats[i].TeamKills > Best )
        {
            Overall.WeaponClass = WeaponStats[i].WeaponClass;
            Best = WeaponStats[i].Kills + WeaponStats[i].TeamKills;
        }
    }
}

function RegisterDeath( Controller Killer, class<DamageType> DamageType )
{
    local Controller C;
    local int w;

    // Basic Stats:

    if( IsSelf( Killer ) )
    {
        Overall.Suicides++;
        Overall.Frags--;
    }
    else if( IsTeamMate( Killer ) )
    {
        Overall.Deaths++;
    }
    else
    {
        Overall.Deaths++;
    }
    UpdateEfficiency();

    // Per-Weapon Stats:

    C = Controller( Owner );

    if( C == None )
        return;

    w = GetWeaponStat( DamageType.default.WeaponClass );

    if( w == -1 )
        return;

    if( IsSelf( Killer ) )
    {
        WeaponStats[w].Suicides++;
        WeaponStats[w].Frags--;
    }
    else if( IsTeamMate( Killer ) )
    {
        WeaponStats[w].Deaths++;
    }
    else
    {
        WeaponStats[w].Deaths++;
    }
}

function RegisterShot( class<Weapon> WeaponClass, int NumShots )
{
    local int w;

    if( NumShots == 0 || !WeaponClass.static.CollectStats() )
        return;

    Overall.Shots += NumShots;

    w = GetWeaponStat( WeaponClass );

    if( w == -1 )
        return;

    WeaponStats[w].Shots += NumShots;

    if( WeaponStats[w].Shots == 0 )
        WeaponStats[w].Accuracy = 0;
    else
        WeaponStats[w].Accuracy = WeaponStats[w].Hits * 100 / WeaponStats[w].Shots;
}

function RegisterHit( class<DamageType> DamageType )
{
    local Controller C;
    local int w;

    Overall.Hits++;

    C = Controller( Owner );

    if( C == None )
        return;

    if (DamageType.default.WeaponClass != None && !DamageType.default.WeaponClass.static.CollectStats())
        return;

    w = GetWeaponStat( DamageType.default.WeaponClass );

    if( w == -1 )
        return;

    WeaponStats[w].Hits++;

    if( WeaponStats[w].Shots == 0 )
        WeaponStats[w].Accuracy = 0;
    else
        WeaponStats[w].Accuracy = WeaponStats[w].Hits * 100 / WeaponStats[w].Shots;
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     bAlwaysRelevant=True
}
