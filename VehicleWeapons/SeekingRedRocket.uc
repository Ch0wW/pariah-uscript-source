class SeekingRedRocket extends RedRocket;

var() Vector    InitialDir;
var() float     TurnRate;
var() Actor     Seeking;
var   Vector    LastSeekLoc;
var float       LastSeen;

replication
{
    reliable if( Role==ROLE_Authority )
        Seeking, InitialDir;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(0.6, true);
    if(Seeking == None)
    {
        LastSeekLoc = Seeking.Location;
        LastSeen = Level.TimeSeconds;
    }
}

simulated function Timer()
{
    local vector SeekingDir;
    local float MagnitudeVel;
    local float LockAtten;
    local bool Uber;
    
    Uber = false;
    if(Level.Game != None && Level.Game.bSinglePlayer)
    {
        Uber = true;
    }

    if ( InitialDir == vect(0,0,0) )
    {
        InitialDir = Normal(Velocity);
    }
    
    if(Instigator == None || Instigator.Health <= 0 || Seeking == None || Seeking == Instigator || Level.TimeSeconds - LastSeen > 2.0)
    {
        return;
    }
    
    if(!Uber && !FastTrace(Location, Seeking.Location + vect(0,0,30)))
    {
        //log("Lost sight!");
    }
    else
    {
        LastSeekLoc = Seeking.Location;
        LastSeen = Level.TimeSeconds;
    }

    if(Uber)
    {
        LockAtten = 0.25;
    }
    else
    {
        LockAtten = (1.0f + (SeekingDir dot vector(Rotation))) * 0.5;
        LockAtten = Lerp(LockAtten, 0.11, 0.25); // this is where all the tweaking lives
    }
    
    SeekingDir = Normal(LastSeekLoc - Location);
    MagnitudeVel = VSize(Velocity);
    SeekingDir = Normal(SeekingDir * LockAtten * MagnitudeVel + Velocity);
    SeekingDir += VRand() * 0.05;
    Velocity =  MagnitudeVel * SeekingDir;  
    Acceleration = 40 * SeekingDir; 
    SetRotation(rotator(Velocity));
    SetTimer(0.05, true);
}

defaultproperties
{
}
