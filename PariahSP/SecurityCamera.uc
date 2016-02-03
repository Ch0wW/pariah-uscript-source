class SecurityCamera extends GameplayDevices
	placeable;

var Vector HeadAttachPoint;
var SecurityCameraHead Head;

var() Range CameraYawRange;
var() const int CameraYawCenter; 

var() Name AlertEvent, AlarmEvent, NoAlarmEvent;
var() float AlertEventRepeat, AlarmEventRepeat, NoAlarmEventRepeat;
var() float BaseScanSpeed, AlertScanSpeed, ScanPause;


function PostBeginPlay()
{
	local Rotator r;
	GetAttachPoint('attachcamera',HeadAttachPoint,r);

	r.pitch = -5000;
	r.roll = 0;
	r.yaw = CameraYawCenter;

	Head = Spawn(class'SecurityCameraHead',,,(HeadAttachPoint >> Rotation) + Location, r);
	Head.MyCamera = self;
	Head.YawRange = CameraYawRange;
	Head.YawCenter = CameraYawCenter;
	Head.AlertEvent=AlertEvent;
	Head.AlarmEvent=AlarmEvent;
	Head.AlertEventRepeat=AlertEventRepeat;
	Head.AlarmEventRepeat=AlarmEventRepeat;
	Head.NoAlarmEvent=NoAlarmEvent;
	Head.NoAlarmEventRepeat=NoAlarmEventRepeat;

	Head.BaseScanSpeed=BaseScanSpeed;
	Head.AlertScanSpeed=AlertScanSpeed;
	Head.ScanPause=ScanPause;


}

defaultproperties
{
     BaseScanSpeed=2000.000000
     AlertScanSpeed=8000.000000
     ScanPause=2.000000
     CameraYawRange=(Min=-8000.000000,Max=8000.000000)
     StaticMesh=StaticMesh'PariahGametypeMeshes.Camera.camera_base'
     DrawType=DT_StaticMesh
}
