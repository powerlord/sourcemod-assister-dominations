/**
 * vim: set ts=4 :
 * =============================================================================
 * Battlecry Melee Dare
 * When a player does a Battlecry with melee out, always do a melee dare
 *
 * Battlecry Melee Dare (C)2014 Powerlord (Ross Bemrose).
 * All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: 1.0
 */
#include <sourcemod>
#include <tf2_stocks>
#include <tf2>
#include <sdktools>

#define VERSION "1.0"

public Plugin:myinfo = 
{
	name = "Battlecry Melee Dare",
	author = "Powerlord",
	description = "When a player does a Battlecry with melee out, always do a melee dare",
	version = VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=222455"
}

new Handle:g_Cvar_Enabled;

public OnPluginStart()
{
	CreateConVar("battlecry_meleedare_version", VERSION, "Battlecry Melee Dare version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_Cvar_Enabled = CreateConVar("battlecry_meleedare_enabled", "1", "Enable Battlecry Melee Dare?", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AddCommandListener(Cmd_VoiceMenu, "voicemenu");
}

public Action:Cmd_VoiceMenu(client, const String:command[], argc)
{
	if (client == 0 || !GetConVarBool(g_Cvar_Enabled) || argc != 2)
		return Plugin_Continue;
	
	new String:arg1[3];
	new String:arg2[3];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	new menu = StringToInt(arg1);
	new cmd = StringToInt(arg2);
	// Battlecry is C, 2
	if (menu != 2 && cmd != 1)
	{
		return Plugin_Continue;
	}
	
	SetVariantString("crosshair_enemy:Yes");
	AcceptEntityInput(client, "AddContext");
	
	return Plugin_Continue;
}

// Use this if the above didn't work
stock PlayMeleeDareSound(client)
{
	SetVariantString("crosshair_enemy:Yes");
	AcceptEntityInput(client, "AddContext");

	SetVariantString("TLK_PLAYER_BATTLECRY");
	AcceptEntityInput(client, "SpeakResponseConcept");

	AcceptEntityInput(client, "ClearContext");
}