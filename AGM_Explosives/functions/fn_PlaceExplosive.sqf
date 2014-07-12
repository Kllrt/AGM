/*
	Name: AGM_Explosives_fnc_PlaceExplosive
	
	Author(s):
		Garth de Wet (LH)
	
	Description:
		
	
	Parameters:
		0: POSITION - Position to place IED
		1: STRING - Magazine class
		2: STRING - Code for remote Explosives
		3: NUMBER - Rotation
		4: NUMBER - (OPTIONAL) timer
	
	Returns:
		OBJECT: Placed IED
	
	Example:
		_explosive = [player modelToWorld [0,0.5, 0.1], "SatchelCharge_Remote_Mag", "", 134] call AGM_Explosives_fnc_PlaceExplosive;
*/
private ["_pos", "_ammo", "_explosive", "_code"];
_pos = _this select 0;
_ammo = getText(configFile >> "CfgMagazines" >> (_this select 1) >> "ammo");
_code = _this select 2;

_explosive = createVehicle [_ammo, _pos, [], 0, "NONE"];
_explosive setDir (_this select 3);
_explosive setPosATL _pos;

if (getText(configFile >> "CfgMagazines" >> (_this select 1) >> "AGM_OnCreate") != "") then {
	_explosive spawn compile (getText(configFile >> "CfgMagazines" >> (_this select 1) >> "AGM_OnCreate"));
};
private ["_triggerSupport"];
_triggerSupport = _this select 4; // check for a timer
if (!isNil "_triggerSupport") exitWith {
	[_explosive, _triggerSupport] call AGM_Explosives_fnc_startTimer;
	_explosive
};
// Set up trigger types for explosive.
_triggerSupport = [(_this select 1)] call AGM_Explosives_fnc_TriggerType;
// clacker enabled
if (_triggerSupport select 0) then {
	private "_clacker";
	_clacker = player getVariable ["AGM_Clacker", []];
	AGM_Explosives_PlacedCount = AGM_Explosives_PlacedCount + 1;
	_clacker set [count _clacker, [_explosive, getNumber(configFile >> "CfgMagazines" >> (_this select 1) >> "AGM_FuseTime"),getNumber (configFile >> "CfgMagazines" >> (_this select 1) >> "AGM_MaxDistance"), "E: " + str(AGM_Explosives_PlacedCount),(_this select 1)]];
	player setVariable ["AGM_Clacker", _clacker, true];
	player sideChat format [localize "STR_AGM_Explosives_DetonateCode", AGM_Explosives_PlacedCount];
};
// Cellphone enabled
if (_triggerSupport select 2) then {
		AGM_Explosives_List set [count AGM_Explosives_List, [_explosive,_code,getNumber(configFile >> "CfgMagazines" >> (_this select 1) >> "AGM_FuseTime"),getNumber (configFile >> "CfgMagazines" >> (_this select 1) >> "AGM_MaxDistance")]];
		publicVariable "AGM_Explosives_List";
		AGM_Explosives_PlacedCount = AGM_Explosives_PlacedCount + 1;
		[format ["E: %1", AGM_Explosives_PlacedCount],_code] call AGM_Explosives_fnc_AddCodeToSpeedDial;
		player sideChat format [localize "STR_AGM_Explosives_DetonateCode", _code];
};

_explosive