class AltMuzzleFlash extends Emitter;

var int numEmitters;

var array<float> pps;
var bool bNeedRestart;
var bool bOnceOnly;

function StartFlash()
{
	local int n;

	if(bNeedRestart) {
		for(n = 0; n < numEmitters; n++) {
			Emitters[n].Trigger();
			Emitters[n].ParticlesPerSecond = pps[n];//10.0;
			Emitters[n].Disabled = false;
		}
//		Emitters[1].Trigger();
//		Emitters[1].ParticlesPerSecond = pps2;
//		Emitters[1].Disabled = false;
//		bNeedRestart = false;
	}
	else {
		for(n = 0; n < numEmitters; n++)
			pps[n] = Emitters[n].ParticlesPerSecond;

		bNeedRestart = true;
	}

	bHidden = false;
	bPaused = false;
}

function StopFlash()
{
	local int n;

	for(n = 0; n < numEmitters; n++) {
		pps[n] = Emitters[n].ParticlesPerSecond;
//		pps2 = Emitters[1].ParticlesPerSecond;

		Emitters[n].ParticlesPerSecond = 0.0;
//		Emitters[1].ParticlesPerSecond = 0.0;

		Emitters[n].Disabled = true;
//		Emitters[1].Disabled = true;
	}

	bNeedRestart = true;
	bHidden = true;
	bPaused = true;
}

defaultproperties
{
}
