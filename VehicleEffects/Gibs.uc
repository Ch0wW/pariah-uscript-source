class Gibs extends Actor;

var vector headpos;
var vector torsopos;
var vector legpos1;
var vector legpos2;
var vector smallpos1;
var vector smallpos2;
var vector smallpos3;


function SpawnGibs(vector newvelocity)
{
	local Gib g;
	local vector v;

	return;
	v.z=500;
	g=spawn(class'GibTorso',,,Location + (torsopos>>Rotation),Rotation);
	g.Velocity = newvelocity+v;
	g=spawn(class'GibLeg',,,Location + (legpos1>>Rotation),Rotation);
	g.Velocity = newvelocity+v;
	g=spawn(class'GibLeg',,,Location + (legpos2>>Rotation),Rotation);
	g.Velocity = newvelocity+v;
	g=spawn(class'GibHead',,,Location + (headpos>>Rotation),Rotation);
	g.Velocity = newvelocity+v;
	
}	

defaultproperties
{
     headpos=(Z=60.000000)
     torsopos=(Z=20.000000)
     legpos1=(Y=-10.000000,Z=-20.000000)
     legpos2=(Y=10.000000,Z=-20.000000)
     DrawType=DT_None
}
