class RosterEntry extends Object
		editinlinenew;

var() class<UnrealPawn> PawnClass;
var() string PawnClassName;
var() string PlayerName;

var() enum EOrders
{
	ORDERS_Defend,
	ORDERS_Attack,
	ORDERS_Freelance,
	ORDERS_None,
} Orders;

var name OrderNames[4];

var   byte SquadNumber;		// FIXME USE
var() bool bTaken;

var() class<Weapon> FavoriteWeapon;
var() float Aggressiveness;		// 0 to 1 (0.3 default, higher is more aggressive)
var() float Accuracy;			// -1 to 1 (0 is default, higher is more accurate)
var() float CombatStyle;		// 0 to 1 (0= stay back more, 1 = charge more)
var() float StrafingAbility;	// -1 to 1 (higher uses strafing more)
var() float Tactics;			// -1 to 1 (higher uses better team tactics)

function Init() //amb
{
    if( PawnClassName != "" ) // gam
        PawnClass = class<UnrealPawn>(DynamicLoadObject(PawnClassName, class'class'));
    //log(self$" PawnClass="$PawnClass);
}

function name GetOrders()
{
    return OrderNames[int(Orders)];
}

function InitBot(Bot B, optional string Character) // cmr -- haw haw haw bad hack DE's fault not mine
{
	B.FavoriteWeapon = FavoriteWeapon;
	B.Aggressiveness = FClamp(Aggressiveness, 0, 1);
	B.BaseAggressiveness = B.Aggressiveness;
	B.Accuracy = FClamp(Accuracy, -1, 1);
	B.StrafingAbility = FClamp(StrafingAbility, -1, 1);
	B.CombatStyle = FClamp(CombatStyle, 0, 1);
	B.Tactics = FClamp(Tactics, -1, 1);
}

function CleanUp();

defaultproperties
{
     Aggressiveness=0.300000
     CombatStyle=0.200000
     OrderNames(0)="DEFEND"
     OrderNames(1)="ATTACK"
     OrderNames(2)="Freelance"
     Orders=ORDERS_None
}
