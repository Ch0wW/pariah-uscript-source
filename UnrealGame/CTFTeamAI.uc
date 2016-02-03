class CTFTeamAI extends TeamAI;

var CTFFlag FriendlyFlag, EnemyFlag; 
var float LastGotFlag;

function SquadAI AddSquadWithLeader(Controller C, GameObjective O)
{
	local CTFSquadAI S;

	if ( O == None )
		O = EnemyFlag.HomeBase;
	S = CTFSquadAI(Super.AddSquadWithLeader(C,O));
	S.FriendlyFlag = FriendlyFlag;
	S.EnemyFlag = EnemyFlag;
	return S;
}

defaultproperties
{
     OrderList(0)="ATTACK"
     OrderList(1)="DEFEND"
     OrderList(2)="ATTACK"
     OrderList(3)="DEFEND"
     OrderList(4)="Freelance"
     OrderList(5)="Freelance"
     OrderList(6)="ATTACK"
     OrderList(7)="ATTACK"
     SquadType=Class'UnrealGame.CTFSquadAI'
}
