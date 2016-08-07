private ["_array","_type","_classname","_holder","_playerID","_text","_broken","_claimedBy","_config","_isOk","_PlayerNear","_wpn","_ismelee","_hasBag"];

_array = _this select 3;
_type = _array select 0;
_classname = _array select 1;
_holder = _array select 2;


if (player distance _holder > 3) exitwith { localize "str_pickup_limit_1","PLAIN DOWN" };

_playerID = getPlayerUID player;
player removeAction s_player_holderPickup;
_text = getText (configFile >> _type >> _classname >> "displayName");

if (!canPickup) exitwith {
	if (pickupInit) then {
		cutText [localize "str_pickup_limit_2","PLAIN DOWN"];
	} else {
		cutText [localize "str_pickup_limit_3","PLAIN DOWN"];
	};
};

_claimedBy = _holder getVariable "claimed";

if (isnil "claimed") then {
	_holder setVariable["claimed",_playerID,true];
};

canPickup = false;

if (_classname isKindOf "TrapBear") exitWith { deleteVehicle _holder; };

player playActionNow "PutDown";

//Adding random chance of arrow is re-usable on pickup
_broken = if ((_classname == "1Rnd_Arrow_Wood") && {[0.15] call fn_chance}) then {true} else {false};
if (_broken) exitWith { deleteVehicle _holder; cutText [localize "str_broken_arrow", "PLAIN DOWN"]; };

_claimedBy = _holder getVariable["claimed","0"];

if (_claimedBy != _playerID) exitWith { cutText [format [localize "str_player_beinglooted",_text] , "PLAIN DOWN"]; };

if (_classname isKindOf "Bag_Base_EP1") exitWith {
	_PlayerNear = {isPlayer _x} count ((getPosATL _holder) nearEntities ["CAManBase", 10]) > 1;
	if (_PlayerNear) exitWith {cutText [localize "str_pickup_limit_4", "PLAIN DOWN"]};

	diag_log("Picked up a bag: " + _classname);
	
	_hasBag = unitBackpack player;

	if (isNull _hasBag) then {
		player action ["TakeBag", _holder];
	} else {
		player action ["putbag", player];
		uiSleep 0.03;
		player action ["TakeBag", _holder];
	};
	
	//Lets wait to make sure the player has some kind of backpack.
	waitUntil { !isNull (unitBackpack player) };
	uiSleep 0.03;
	
	//Lets call inventory save
	PVDZ_plr_Save = [player,nil,false];
	publicVariableServer "PVDZ_plr_Save";
};

_config = (configFile >> _type >> _classname);

//Remove melee magazines (BIS_fnc_invAdd fix)
{player removeMagazines _x} count MeleeMagazines;

_isOk = [player,_config] call BIS_fnc_invAdd;

if (_isOk) then {
	deleteVehicle _holder;
} else {
	if (!_isOk) exitWith {
		_holder setVariable["claimed",0,true];
		cutText [localize "str_player_24", "PLAIN DOWN"];
	};
};
uiSleep 3;

//adding melee mags back if needed
_wpn = primaryWeapon player;
_ismelee = (getNumber (configFile >> "CfgWeapons" >> _wpn >> "melee") == 1);
if (_ismelee) then {
	call dayz_meleeMagazineCheck;
};