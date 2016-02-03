//=============================================================================
// ViewShaker:  Shakes view of any playercontrollers - amb - rewrote this
// within the ShakeRadius
// EDIT:  - modified so that strength of shaking may be made to decrease radial
//        from the source (mthorne - Dec 2003)
// EDIT:  - added an optional initial delay before the first shaking pulse (mthorne - Jan 15/2004)
//        - added incr/sustain/decay phases to the view shaker; these are defined separately
//          from the frequence of the shakes and define a cyclical cycle of strength for the shakes
//          so that each shake is modulated by where we are in the overall cycle
//=============================================================================
class ViewShaker extends Triggers;

// some constants relating to incr and decay phases
const LINEAR_INCR = 0;	// use linear incr/decay
const CUBIC_INCR  = 1;  // use cubic incr/decay
const TRIG_INCR	  = 2;  // use trigonometric incr/decay

// some constants for the phase
const PHASE_INCR    = 0;
const PHASE_SUSTAIN = 1;
const PHASE_DECAY   = 2;
const PHASE_ZERO    = 3;

//-----------------------------------------------------------------------------
// Variables.

var() float  ShakeRadius;		// radius within which to shake player views
var() vector RotMag;			// how far to rot view
var() vector RotRate;			// how fast to rot view
var() float  RotTime;			// how much time to rot the instigator's view
var() vector OffsetMag;		    // max view offset vertically
var() vector OffsetRate;		// how fast to offset view vertically
var() float  OffsetTime;	    // how much time to offset view
var() Range  ShakeInterval;		// how much time passes between shakes (min and max)
var() float  ImpulseStr;		// strength of impulse
var() bool   bScaleMag;			// scale magnitude based on distance from shaker
var() bool   bShakeOnce;		// only shake once
var() bool   bAddImpulse;		// adds impulse to targets in the shake radius
var() float  StartDelay;		// delay before first shake
var() float  IncrTime;			// time to increase to full power
var() float  DecayTime;			// time to decay from full power to nothing
var() float  SustainTime;		// duration to sustain full power
var() float  ZeroTime;			// time to hold at zero
var() int    IncDecMode;		// incr/decay mode
var() bool   bTimeModulate;		// cyclically modulate shake strength based on time

var   bool   bStarted;			// has the trigger been started yet?
var   int    ShakeCount;		// number of shakes
var   int    IncDecPhase;		// current phase, 0 = Increase, 1 = Sustain, 2 = Decay
var   float  PhaseTime;         // current phase time
var   float  LastTime;			// the last time a pulse occured

//-----------------------------------------------------------------------------
// Functions.

function Reset()
{
	ShakeCount = 0;
	bStarted = false;
	SetTimer(0, false);
	IncDecPhase = PHASE_INCR;
	PhaseTime = 0;
}

function Trigger( actor Other, pawn EventInstigator )
{
	// if this function gets called, then start the shaker if it's not been started yet
	if(!bStarted) {
		// if there an initial delay has been requested then wait that amount of time before
		// shaking, otherwise do a shake and then set the timer
		if(StartDelay > 0)
			SetTimer(StartDelay, true);
		else {
			Shake();
			ShakeCount++;
//			log("VS:  Trigger -> ShakeCount++");
			if(!bShakeOnce)
				SetTimer(RandRange(ShakeInterval.Min, ShakeInterval.Max), true);
		}

		bStarted = true;
	}
//	Shake();
}

function Touch(actor Other)
{
//	Shake();

	// start the trigger as soon as the first player touches it
	if(!bStarted) {
//		log("VS:  Touch, StartDelay = "$StartDelay);
		if(StartDelay > 0)
			SetTimer(StartDelay, true);
		else {
			Shake();
			ShakeCount++;
//			log("VS:  Touch -> ShakeCount++");
			if(!bShakeOnce)
				SetTimer(RandRange(ShakeInterval.Min, ShakeInterval.Max), true);
		}
		bStarted = true;
	}
}

// calculate the modulation for this state based on time and current phase
function float getShakeModulation(float dt)
{
	local float start, end, u, mod;

	PhaseTime += dt;
	switch(IncDecPhase) {
		case PHASE_INCR:
			if(PhaseTime > IncrTime) {
				IncDecPhase = PHASE_SUSTAIN;
				PhaseTime -= IncrTime;

				// no need to interp for sustain phase, just return max
				return 1;
			}
			// increasing from nothing to max
			start = 0;
			end = 1;
			u = PhaseTime/IncrTime;
			break;
		case PHASE_SUSTAIN:
			if(PhaseTime > SustainTime) {
				IncDecPhase = PHASE_DECAY;
				PhaseTime -= SustainTime;
				// starting to decay from max to nothing
				start = 1;
				end = 0;
				u = PhaseTime/DecayTime;
			}
			else
				// at any point in sustain, we always want maximum shake magnitude
				return 1;
			break;
		case PHASE_DECAY:
			if(PhaseTime > DecayTime) {
				IncDecPhase = PHASE_ZERO;
				PhaseTime -= DecayTime;
				// starting the zero phase so return zero
				return 0;
			}
			else {
				// decay from max to nothing
				start = 1;
				end = 0;
				u = PhaseTime/DecayTime;
			}
			break;
		case PHASE_ZERO:
			if(PhaseTime > ZeroTime) {
				IncDecPhase = PHASE_INCR;
				PhaseTime -= ZeroTime;
				// starting to increase from nothing to max
				start = 0;
				end = 1;
				u = PhaseTime/IncrTime;
			}
			else
				// at any point in zero, we return, well, zero
				return 0;
			break;
	}

	// now do interpolation based on the interp mode (the difference between modes may end up
	// being way to subtle for anyone to notice... for now just implement linear
	mod = (1-u)*start+u*end;

	return mod;
}

// shake the view of all player controllers within range
// the predefined shake strength is modified by distance from
// the shaker (currently there is a linear drop-off) and direction from the shaker; 
// shake strength is never increased beyond RotMag and OffsetMag (they define the 
// maximum); a shake can be considered to be a spherical pulse
function Shake()
{
	local Controller C;
	local vector pulseVec;//, rMag, oMag;
	local float dist;
	local Actor Victims;
	local vector outvector;
	local float dt, timeMod;

//	log("VS:  Shake-> bTimeModulate = "$bTimeModulate);
	if(bTimeModulate) {
		// update time modulation
		if(LastTime > 0)
			dt = Level.TimeSeconds-LastTime;

		timeMod = getShakeModulation(dt);
//		log("VS:  Shake-> dt = "$dt$", lastTime = "$LastTime$", timeMod = "$timeMod);
		LastTime = Level.TimeSeconds;
	}
	else
		// no time modulation, use max
		timeMod = 1;

	for ( C=Level.ControllerList; C!=None; C=C.NextController ) {
		if(PlayerController(C) == None)
			continue;

		pulseVec = Location-PlayerController(C).ViewTarget.Location;
		dist = VSize(pulseVec);

		if(dist < ShakeRadius) {
			// scale the shake magnitude according to the distance between the shaker and the controller
			// when at the edge of the shake radius, the magnitude should be zero (or almost zero)
			if(bScaleMag)
				dist = (ShakeRadius-dist)/ShakeRadius;
			else
				dist = 1;

			C.ShakeView(RotMag*dist*timeMod, RotRate, RotTime, OffsetMag*dist*timeMod, OffsetRate, OffsetTime);
//			if(bAddImpulse && C.Pawn != none)
				// add an impulse to the target
//                C.Pawn.KAddImpulse(Normal(pulseVec)*ImpulseStr,C.Pawn.Location);
		}
	}

	// apply the impulse, if requested
//	log("VS:  bAddImpulse = "$bAddImpulse);
	if(bAddImpulse) {
//		log("VS:  checking impulse...");
		foreach VisibleCollidingActors(class'Actor', Victims, ShakeRadius, Location) {
			if(Victims.Role == ROLE_Authority) {// && (Victims.Physics == Phys_Karma || Victims.Physics == Phys_KarmaRagDoll) ) {
				outvector = Victims.Location - Location;
				dist = VSize(outvector);
				if(dist != 0)
					outvector /= dist;
				else
					// impulse straight up if right at the centre
					outvector = vect(0,0,1);

				// scale impulse by distance from centre
				dist = (ShakeRadius-dist)/ShakeRadius;

				Victims.HAddImpulse(outvector*ImpulseStr*dist*timeMod, Victims.Location);
//				log("VS:  added "$outvector$" impulse to "$Victims);
			}
		}
	}
}

// timer is called at a set frequency
event Timer()
{
//	log("VS:  Timer, bShakeOnce = "$bShakeOnce$", ShakeCount = "$ShakeCount);
	if(!bShakeOnce) {
		// continual shaking
		Shake();
		ShakeCount++;
		SetTimer(RandRange(ShakeInterval.Min, ShakeInterval.Max), true);
	}
	else if(ShakeCount == 0) {
		// shake once with a delayed shake - don't want to set the timer
		Shake();
		ShakeCount++;
//		log("VS:  BLAM!!");
	}
}

defaultproperties
{
     ShakeRadius=2000.000000
     RotTime=3.000000
     OffsetTime=3.000000
     RotRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     OffsetMag=(X=10.000000,Y=10.000000,Z=10.000000)
     OffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeInterval=(Min=0.500000,Max=1.500000)
}
