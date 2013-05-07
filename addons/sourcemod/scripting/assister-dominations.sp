#include <sourcemod>
#include <tf2_stocks>
#include <tf2>
#include <sdktools>

/*
	TFClass_None,
	TFClass_Scout,
	TFClass_Sniper,
	TFClass_Soldier,
	TFClass_DemoMan,
	TFClass_Medic,
	TFClass_Heavy,
	TFClass_Pyro,
	TFClass_Spy,
	TFClass_Engineer
	*/
new bool:g_bClassDominations[TFClassType] = { false, true, true, true, true, false, false, false, true, true };

new Handle:g_DominationSounds[TFClassType][TFClassType];

// Revenge list
new Handle:g_RevengeSounds[TFClassType];

public Plugin:myinfo = 
{
	name = "Assister Dominations",
	author = "Powerlord",
	description = "Play domination lines when assister gets a domination",
	version = "1.0",
	url = "<- URL ->"
}

public OnPluginStart()
{
	SetupArrays();
	HookEvent("player_death", Event_PlayerDeath);
}

SetupArrays()
{
	new arraySize = ByteCountToCells(PLATFORM_MAX_PATH);
	
	for (new i = 1; i < _:TFClassType; ++i)
	{
		if (g_bClassDominations[i])
		{
			for (new j = 1; j < _:TFClassType; ++j)
			{
				g_DominationSounds[i][j] = CreateArray(arraySize);
			}
		}
		else
		{
			g_DominationSounds[i][0] = CreateArray(arraySize);
		}
	}
}


public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new deathflags = GetEventInt(event, "deathflags");
	
	if (dontBroadcast || deathflags & TF_DEATHFLAG_DEADRINGER)
	{
		return;
	}

	new victim = GetClientUserId(GetEventInt(event, "userid"));
//	new attacker = GetClientUserId(GetEventInt(event, "attacker"));
	new assister = GetClientUserId(GetEventInt(event, "assister"));
	
	if (victim < 1 || victim > MaxClients || assister < 1 || assister > MaxClients || !IsClientInGame(assister) || !IsPlayerAlive(assister))
	{
		return;
	}

	if (deathflags & TF_DEATHFLAG_ASSISTERDOMINATION)
	{
		new TFClassType:class = TF2_GetPlayerClass(assister);
		new TFClassType:victimClass = TF2_GetPlayerClass(victim);
		
		new String:sound[PLATFORM_MAX_PATH];
		
		if (g_bClassDominations[class])
		{
			victimClass = TF2_GetPlayerClass(victim);
		}
		else
		{
			victimClass = TFClass_Unknown;
		}
		
		new random = GetRandomInt(1, GetArraySize(g_DominationSounds[class][victimClass]));
		GetArrayString(g_DominationSounds[class][victimClass], random, sound, PLATFORM_MAX_PATH);
		
		PrecacheSound(sound);
		
		EmitSoundToAll(sound, assister, SNDCHAN_VOICE);
	}
	
	if (deathflags & TF_DEATHFLAG_ASSISTERREVENGE)
	{
		
	}

}
