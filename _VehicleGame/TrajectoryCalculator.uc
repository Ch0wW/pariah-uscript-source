class TrajectoryCalculator extends Actor;

const RadiansToDegrees					= 57.295779513082321;	//180.0 / PI
const DegreesToRotationUnits			= 182.044; 				//65536 / 360
const Radians45				= 0.785398; // 45 degrees in radians

var int VerifyTrajectorySamples;
var float VerifyTrajectoryHorizontalExtentPadding;
var float VerifyTrajectoryVerticalExtentPadding;

//==========================================

static final function float RadianToRotation(float rads)
{
    return rads * RadiansToDegrees * DegreesToRotationUnits;
}

static final function float VSize2D(vector A)
{
	return sqrt(A.X*A.X + A.Y*A.Y);
}

static final function float GetMaxRange( Actor SourceActor, class<Actor> ProjectileClass, float ProjectileSpeed )
{
	return ProjectileSpeed * ProjectileSpeed / GetGravityConstant( SourceActor, ProjectileClass );
}

static final function float GetGravityConstant( Actor SourceActor, class<Actor> ProjectileClass )
{
    if( ClassIsChildOf( ProjectileClass, class'Pawn' ) )
		return -0.5 * SourceActor.PhysicsVolume.default.Gravity.Z;
	else
		return -1.0 * SourceActor.PhysicsVolume.default.Gravity.Z;
}

/** 
 * More or less from the AI Game Wisdom book.
 **/

static final function int GetInverseTrajectory( 
	Actor SourceActor, 
	class<Actor> ProjectileClass, 
	float ProjectileSpeed, 
	vector StartLocation, 
	vector TargetLocation, 
	out float ThetaLow, 
	out float ThetaHigh, 
	out float InterceptTimeLow, 
	out float InterceptTimeHigh )
{
	local float V;
	local float G;
	local float X, Y;
	local float Root, SquareRoot;
	local float XSquared, VSquared, GXSquared;
	local float TempFloat;
	local int NumSolutions;

	if( ProjectileSpeed ~= 0.0 )
		return 0;

	V = ProjectileSpeed;
	X = VSize2D( TargetLocation - StartLocation );
	Y = -(TargetLocation.Z - StartLocation.Z);
	
	G = GetGravityConstant( SourceActor, ProjectileClass );

	XSquared = X*X;		
	VSquared = V*V;
	
	Root = XSquared - (G*G*XSquared*XSquared/(VSquared*VSquared)) + (2*G*XSquared*Y/VSquared);
	
	if( Root < 0 )
	{
		NumSolutions = 0;
	}
	else
	{
		GXSquared = G*XSquared;
			
		if( Root ~= 0 )
		{
			ThetaLow = ATan( -X, G*XSquared );
			ThetaHigh = ThetaLow;

			InterceptTimeLow = X / (V * Cos( ThetaLow ));
			InterceptTimeHigh = InterceptTimeLow;
			
			NumSolutions = 1;
		}
		else
		{
			SquareRoot = Sqrt( Root );
			
			ThetaLow = ATan( VSquared*(-X + SquareRoot), GXSquared );
			ThetaHigh = ATan( VSquared*(-X - SquareRoot), GXSquared );
			
			if( Abs( ThetaHigh ) < Abs( ThetaLow ) )
			{
				TempFloat = ThetaHigh;
				ThetaHigh = ThetaLow;
				ThetaLow = TempFloat;
			}
			
			InterceptTimeLow = X / (V * Cos( ThetaLow ));
			InterceptTimeHigh = X / (V * Cos( ThetaHigh ));
			
			NumSolutions = 2;
		}
	}
	
	//SourceActor.log( "  ThetaLow:  " $ ThetaLow $  " Time: " $ InterceptTimeLow );
	//SourceActor.log( "  ThetaHigh: " $ ThetaHigh $ " Time: " $ InterceptTimeHigh );
	//SourceActor.log( "GetInveseTrajectory END  NumSolutions: " $ NumSolutions );
	
	return NumSolutions;
}

/*-----------------------------------------------------------------------------
Return false if any of several lines along trajectory are blocked by anything
apart from the target actor. Also return false if the projectile won't arive 
before it expires (non-zero LifeSpan).

The location of the projectile at time T is given by:

	X = X0 + Vx * t
	Y = Y0 + Vy * t + 1/2 * gt^2

or, if we shift the projectile start to the origin:

	X = Vx * t
	Y = Vy * t + 1/2 * gt^2	
	
where

X0 = starting X position
Y0 = starting Y position
Vx = horizontal component of initial velocity
Vy = vertical component of initial velocity
G  = gravity

and
	
	Vx = V * cos( Theta )
	Vy = V * sin( Theta )
*/

static final function bool VerifyTrajectory( 
	Actor SourceActor, 
	class<Actor> ProjectileClass, 
	float ProjectileSpeed, 
	vector StartLocation, 
	vector TargetLocation, 
	Actor TargetActor, 
	float Theta, 
	optional float InterceptTime, 
	optional vector Extents, 
	optional float MinTimeOutDistance,
    optional bool bDrawDebug)
{
	local float G;
	local float X, Y;
	local float VX, VY;
	local float SampleTime, TimeIncrement;
	local int ii;
	local vector SampleLocation, PreviousLocation, ProjectileDirection;
	local Actor HitActor;
	local vector HitNormal, HitLocation;
	local bool bValid;
	
	bValid = true;

	if( InterceptTime <= 0.0 )
	{
		if( ProjectileSpeed ~= 0.0 )
		{
			bValid = false;
		}
		else
		{
			// caller wants us to determine the intercept time
			InterceptTime = VSize2D( TargetLocation - StartLocation) / (ProjectileSpeed * cos( Theta ) );
			//SourceActor.log( "  InterceptTime: " $ InterceptTime );
		}
	}
	
	VX = ProjectileSpeed * cos( Theta );
	VY = ProjectileSpeed * sin( Theta );

	G = GetGravityConstant( SourceActor, ProjectileClass );

	ProjectileDirection = TargetLocation - StartLocation;
	ProjectileDirection.Z = 0;
	ProjectileDirection = Normal( ProjectileDirection );

	// return false if the projectile be within X units of the target before it expires
	if( ProjectileClass != None && ProjectileClass.default.LifeSpan > 0.0 && InterceptTime > ProjectileClass.default.LifeSpan )
	{
		//SourceActor.log( "  Projectile LifeSpan too short checking timeout distance  InterceptTime: " $ InterceptTime );
		
		SampleTime = ProjectileClass.default.LifeSpan;
		
		X = VX * SampleTime;
		Y = VY * SampleTime + 0.5 * G * SampleTime*SampleTime;

		SampleLocation = StartLocation + X * ProjectileDirection;
		SampleLocation.Z = SampleLocation.Z - Y;
		if( VSize( SampleLocation - TargetLocation ) > MinTimeOutDistance )
			bValid = false;
	}

	if( bValid )
	{
		SampleTime = 0.0;
		TimeIncrement = InterceptTime / default.VerifyTrajectorySamples;
        //SourceActor.log( "  TargetActor: " $ TargetActor $ " Gravity: " $ G $ " target distance: " $ VSize( TargetLocation - StartLocation ) $ " TargetHeight: " $ TargetLocation.Z );
		
		PreviousLocation = StartLocation;
		PreviousLocation.Z += default.VerifyTrajectoryVerticalExtentPadding; // so first trace doesn't hit level below source
		
		// needed since the predicted trajectory isn't exactly what we'll get (should be dead-on in X/Y though)
		Extents.X += default.VerifyTrajectoryHorizontalExtentPadding;
		Extents.Y += default.VerifyTrajectoryHorizontalExtentPadding;
		Extents.Z += default.VerifyTrajectoryVerticalExtentPadding;
		
		for( ii=0; ii<default.VerifyTrajectorySamples; ii++ )
		{
			//!!hack: if "projectile" is a pawn, back up the last sample somewhat
			//if( ii == (default.VerifyTrajectorySamples-1) && ClassIsChildOf( ProjectileClass, class'Pawn' ) )
			//	TimeIncrement *= 0.5;

			SampleTime += TimeIncrement;
			
			X = VX * SampleTime;
			Y = VY * SampleTime + 0.5 * G * SampleTime*SampleTime;

			SampleLocation = StartLocation + X * ProjectileDirection;
			SampleLocation.Z = SampleLocation.Z - Y;

			// for the last sample, shift the location up by vertical padding or else 
			// we'll pbly trace into the world geometry below the target locationa
			if( ii == (default.VerifyTrajectorySamples-1) )
			{
				//SourceActor.log( "  Shifting SampleLocation up by " $ default.VerifyTrajectoryVerticalExtentPadding );
				SampleLocation.Z += default.VerifyTrajectoryVerticalExtentPadding;
			}
			//SourceActor.log( "  X: " $ X $ " Y: " $ Y $ " Height: " $ SampleLocation.Z );
			
			HitActor = SourceActor.Trace( HitLocation, HitNormal, SampleLocation, PreviousLocation, false, Extents);
			
			if( HitActor == None )
			{
				//!!@@@: static meshes don't generally block extent traces so try a no-extent trace
				//this might catch some cases but without proper extent collision it won't be perfect
				//this check can be removed if we assume that levels with the GL used by NPCs or
				//leaping NPCs will have extent collision added as needed.
				//!!@@@: possible optimization, especially in areas with low ceilings
				// check the entire trajectory with single line traces first
				HitActor = SourceActor.Trace( HitLocation, HitNormal, SampleLocation, PreviousLocation, false, vect(0,0,0) );
				
				//if( HitActor != None && HitActor != TargetActor )
				//	SourceActor.log( "  no-extent trace hit " $ HitActor );
			}
			
			if( HitActor != None && HitActor != TargetActor && Theta ~= -Radians45 )
			{
				//SourceActor.log( "  checking for max range hit" );
				//SourceActor.log( "    SampleLocation.Z: " $ SampleLocation.Z );
				//SourceActor.log( "    TargetLocation.Z: " $ TargetLocation.Z );
				// hack for using maximum range -- allow a hit below or past target location
				if( SampleLocation.Z < TargetLocation.Z )
					HitActor = TargetActor;
			}
		
			//!!tbd: call OKToHit on HitActor instead of just checking if we hit TargetActor?
			if( HitActor != None && HitActor != TargetActor )
			{
				//SourceActor.log( "  failed - hit: " $ HitActor $ " instead of " $ TargetActor );
				if(bDrawDebug)
                    SourceActor.drawdebugline( PreviousLocation, SampleLocation, 255,0,0);
				//AddCylinder( SampleLocation, Extents.X, Extents.Z, ColorRed() );
				bValid = false;
				break;
			}
			else
			{
                if(bDrawDebug)
				    SourceActor.drawdebugline( PreviousLocation, SampleLocation, 0,255,0);
			}
			
			if( HitActor == TargetActor )
				break;
						
			PreviousLocation = SampleLocation;
		}
	}
	
	return bValid;
}

defaultproperties
{
     VerifyTrajectorySamples=8
     VerifyTrajectoryVerticalExtentPadding=8.000000
}
