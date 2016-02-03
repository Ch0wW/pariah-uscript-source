class SPAIPopUpGrenadeLauncher extends SPAIPopUp;

var rotator TossRotation;


function debugTick(float DT)
{
    local vector start;
    start = Pawn.Location+vect(0,0,1)*Pawn.BaseEyeHeight;
    
    FindToss(start, GetTweakedFireSpot(Target) );   
}


function bool MayAttack(Vector from, Actor Other)
{
    local vector A, B;
    local float Dist;

    A = from;
    B = Other.Location;
    A.Z = 0;
    B.Z = 0;

    Dist = VSize(A - B); 
    return ( ((Dist > 600) && (Dist < 3000)) ||
        (TimeElapsed(LastHitTIme,0.5) && !TimeElapsed(LastHitTIme, 5.0) ));
}

function rotator AdjustAim( Ammunition FiredAmmunition, vector projStart, 
                            int aimerror )
{
    local vector tweakedSpot;

    tweakedSpot = GetTweakedFireSpot(Target);

    FiredAmmunition.WarnTarget(Target,Pawn,vect(1,0,0));
    FindToss(projStart, tweakedSpot );
    /*         + Target.Velocity * 
            (1.0 + VSize(tweakedSpot - projStart) / (2.0*Pawn.Weapon.FireMode[0].ProjectileClass.default.speed)) );
    */
    return TossRotation;
}

function vector GetTweakedFireSpot( Actor target ) {
    return target.Location + vect(0,0,-1) * target.CollisionHeight;
}

function FindToss(vector StartLocation, vector TargetLocation)
{
	local float ThetaLow;
	local float ThetaHigh; 
	local float InterceptTimeLow;
	local float InterceptTimeHigh; 
    local float Theta;
	
	local int NumSolutions;
	local Rotator LeapRotation;
    local float LeapSpeed;
	
	
    //LeapSpeed = 1.1*Pawn.Weapon.FireMode[0].ProjectileClass.default.speed;
    LeapSpeed = Pawn.Weapon.FireMode[0].ProjectileClass.default.MaxSpeed;

	// set leap parameters
	LeapRotation = rotator(TargetLocation - Pawn.Location); // rotation to aim directly at target

	NumSolutions = class'TrajectoryCalculator'.static.GetInverseTrajectory(
			Pawn,
			class'Pawn',
			LeapSpeed, 
			StartLocation, 
			TargetLocation, 
			ThetaLow, 
			ThetaHigh, 
			InterceptTimeLow, 
			InterceptTimeHigh );

	Theta = ThetaLow;

	// modify the leap pitch
	if( Theta < 0 )
		LeapRotation.Pitch =  class'TrajectoryCalculator'.static.RadianToRotation(-Theta);
	else
		LeapRotation.Pitch = 65535 - class'TrajectoryCalculator'.static.RadianToRotation(Theta);

    /*
    class'TrajectoryCalculator'.static.VerifyTrajectory( 
			Pawn, 
			class'Pawn', 
			LeapSpeed, 
			StartLocation, 
			TargetLocation, 
			Enemy, 
			Theta,,,,true
			);
    */

    TossRotation = LeapRotation;
}

defaultproperties
{
     AssignedWeapon="VehicleWeapons.BotGrenadeLauncher"
     MinNumShots=1
     MaxNumShots=1
     MinShotPeriod=3.000000
     MaxShotPeriod=3.500000
     m_TacticalHeight=5.000000
     Skill=7.000000
}
