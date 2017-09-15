class OverGameInfo extends GameInfo
config(game);

var OverArchetypesManager ArchetypeManager, OverArchetypes;
var OverPlayerController PlayerController;
var array<OverMonsterPawn> enemies;

function PostBeginPlay()
{	
	local OverMonsterPawn enemyPawn;

	Super.PostBeginPlay();
	ArchetypeManager = new() class'Overlords.OverArchetypesManager'(OverArchetypes);

	foreach DynamicActors(class'OverMonsterPawn', enemyPawn){
		if(enemies.Find(enemyPawn) == -1)
			enemies.addItem(enemyPawn);
	}
}

exec function testSpawn(){
	local OverPlayerController testController;

	//testPlayer = Spawn(class 'OverMonsterPawn',,'NPCPlayer', vect(-100,-850,50),,ArchetypeManager.OverMonsterTemplate);
	//testController = Spawn(class 'OverPlayerController');
	//testController.Possess(testPlayer,true);
	//testController.Defend();
}

function PlayerController SpawnPlayerController(vector SpawnLocation, rotator SpawnRotation){
	local PlayerController tempController;
	tempController = Spawn(PlayerControllerClass,,, SpawnLocation, SpawnRotation);
	PlayerController = OverPlayerController(tempController);
	return tempController;
}

function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot){
	local class<Pawn> DefaultPlayerClass;
	local Rotator StartRotation;
	local Pawn ResultPawn;

	DefaultPlayerClass = GetDefaultPlayerClass(NewPlayer);

	// don't allow pawn to be spawned with any pitch or roll
	StartRotation.Yaw = StartSpot.Rotation.Yaw;

	ResultPawn = Spawn(DefaultPlayerClass,,,StartSpot.Location,StartRotation,ArchetypeManager.OverPawnTemplate);
	if ( ResultPawn == None ){
		`log("Couldn't spawn player of type "$DefaultPlayerClass$" at "$StartSpot);
	}
	return ResultPawn;
}

DefaultProperties
{
	bUseClassicHUD=true
	bDelayedStart=false

	OverArchetypes= OverArchetypesManager'OverlordsPackage.archetypes.OverArchetypesManager';
	
	bWaitingToStartMatch=true
	PlayerControllerClass=class'Overlords.OverPlayerController'	
	HUDType=class'Overlords.OverHUD'
	DefaultPawnClass=class'Overlords.OverPlayer'
	//PlayerControllerClass=class'Overlords.IsometricGamePlayerController'
	//DefaultPawnClass=class'IsometricGame.MyPawn'
	//PlayerReplicationInfoClass = class'IsometricGame.PlayerReplicant'
}
