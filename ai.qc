void() movetarget_f;
void() t_movetarget;

void(entity etemp, entity stemp, entity stemp, float dmg, float kick) T_Damage;
/*

.enemy
Will be world if not currently angry at anyone.

.movetarget
The next path spot to walk toward.  If .enemy, ignore .movetarget.
When an enemy is killed, the monster will try to return to it's path.

.huntt_ime
Set to time + something when the player is in sight, but movement straight for
him is blocked.  This causes the monster to use wall following code for
movement direction instead of sighting on the player.

.ideal_yaw
A yaw angle of the intended direction, which will be turned towards at up
to 45 deg / state.  If the enemy is in view and hunt_time is not active,
this will be the exact line towards the enemy.

.pausetime
A monster will leave it's stand state and head towards it's .movetarget when
time > .pausetime.

real_walkmove(angle, speed) primitive is all or nothing
*/


//
// globals
//

//
// when a monster becomes angry at a player, that monster will be used
// as the sight target the next frame so that monsters near that one
// will wake up even if they wouldn't have noticed the player
//
entity	sight_entity;
float	sight_entity_time;

float(float v) anglemod;

void(vector dest) ChooseTurn;

void() ai_face;

float RANGE_CLOSE = 1;

float	enemy_vis, enemy_infront, enemy_range;
float	enemy_yaw;

/*
==============================================================================

MOVETARGET CODE

The angle of the movetarget effects standing and bowing direction, but has no effect on movement, which allways heads to the next target.

targetname
must be present.  The name of this movetarget.

target
the next spot to move to.  If not present, stop here for good.

pausetime
The number of seconds to spend standing or bowing for path_stand or path_bow

==============================================================================
*/

float(float v) anglemod =
{
	while (v >= 360)
		v = v - 360;
	while (v < 0)
		v = v + 360;
	return v;
};

void() movetarget_f =
{
	if (!self.targetname)
		objerror ("monster_movetarget: no targetname");
		
	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize (self, '-8 -8 -8', '8 8 8');
	
};

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will continue walking towards the next target corner.
*/
void() path_corner =
{
	movetarget_f ();
};


/*
=============
t_movetarget

Something has bumped into a movetarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
void() t_movetarget =
{
local entity	temp;

	if (other.movetarget != self)
		return;
	
	if (other.enemy)
		return;		// fighting, not following a path

	temp = self;
	self = other;
	other = temp;

	if (self.classname == "monster_ogre")
		sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);// play chainsaw drag sound

//dprint ("t_movetarget\n");
	self.goalentity = self.movetarget = find (world, targetname, other.target);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	if (!self.movetarget)
	{
		self.pausetime = time + 999999;
		self.th_stand ();
		return;
	}
};



//============================================================================


/*
=============
range

returns the range catagorization of an entity reletive to self
0	melee range, will become hostile even if back is turned
1	visibility and infront, or visibility and show hostile
2	infront and show hostile
3	only triggered by damage
=============
*/
float(entity targ) range =
{
local vector	spot1, spot2;
local float		r;	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	
	r = vlen (spot1 - spot2);
	if (r < 120)
		return RANGE_MELEE;
	if (r < 300)
		return RANGE_CLOSE;
	if (r < 500)
		return RANGE_NEAR;
	if (r < 1000)
		return RANGE_MID;
	return RANGE_FAR;
};

/*
=============
visible

returns 1 if the entity is visible to self, even if not infront ()
=============
*/
float (entity caller, entity targ) visible =
{
	local vector	spot1, spot2;
	
	spot1 = caller.origin + caller.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline (spot1, spot2, TRUE, self);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents
	
	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};


/*
=============
infront

returns 1 if the entity is in front (in sight) of self
=============
*/
float(entity targ) infront =
{
	local vector	vec;
	local float		dot;
	
	makevectors (self.angles);
	vec = normalize (targ.origin - self.origin);
	dot = vec * v_forward;
	
	if ( dot > 0.3)
	{
		return TRUE;
	}
	return FALSE;
};


//============================================================================

/*
===========
ChangeYaw

Turns towards self.ideal_yaw at self.yaw_speed
Sets the global variable current_yaw
Called every 0.1 sec by monsters
============
*/
/*

void() ChangeYaw =
{
	local float		ideal, move;

//current_yaw = self.ideal_yaw;
// mod down the current angle
	current_yaw = anglemod( self.angles_y );
	ideal = self.ideal_yaw;
	
	if (current_yaw == ideal)
		return;
	
	move = ideal - current_yaw;
	if (ideal > current_yaw)
	{
		if (move > 180)
			move = move - 360;
	}
	else
	{
		if (move < -180)
			move = move + 360;
	}
		
	if (move > 0)
	{
		if (move > self.yaw_speed)
			move = self.yaw_speed;
	}
	else
	{
		if (move < 0-self.yaw_speed )
			move = 0-self.yaw_speed;
	}

	current_yaw = anglemod (current_yaw + move);

	self.angles_y = current_yaw;
};

*/


//============================================================================

void() HuntTarget =
{	
	self.goalentity = self.enemy;
	if(!(self.flags & FL_DODGED))
		self.think = self.th_run;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
	SUB_AttackFinished (self, 1);	// wait a while before first attack
};

void() SightSound =
{
local float	rsnd;

	if (self.classname == "monster_ogre")	
		sound (self, CHAN_VOICE, "ogre/ogwake.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_knight")
		sound (self, CHAN_VOICE, "knight/ksight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_shambler")
		sound (self, CHAN_VOICE, "shambler/ssight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_demon1")
		sound (self, CHAN_VOICE, "demon/sight2.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_wizard")
		sound (self, CHAN_VOICE, "wizard/wsight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_zombie")
		sound (self, CHAN_VOICE, "zombie/z_idle.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_dog")
		sound (self, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_hell_knight")
		sound (self, CHAN_VOICE, "hknight/sight1.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_tarbaby")
		sound (self, CHAN_VOICE, "blob/sight1.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_vomit")
		sound (self, CHAN_VOICE, "blob/sight1.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_enforcer")
	{
		rsnd = rint(random() * 3);			
		if (rsnd == 1)
			sound (self, CHAN_VOICE, "enforcer/sight1.wav", 1, ATTN_NORM);
		else if (rsnd == 2)
			sound (self, CHAN_VOICE, "enforcer/sight2.wav", 1, ATTN_NORM);
		else if (rsnd == 0)
			sound (self, CHAN_VOICE, "enforcer/sight3.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "enforcer/sight4.wav", 1, ATTN_NORM);
	}
	else if (self.classname == "monster_army")
		sound (self, CHAN_VOICE, "soldier/sight1.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_shalrath")
		sound (self, CHAN_VOICE, "shalrath/sight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_boss2")
		sound (self, CHAN_VOICE, "boss2/ssight.wav", 1, ATTN_NORM);
};

void() FoundTarget =
{	
	dprint("got one");
	if (self.enemy.classname == "player")
	{	// let other monsters see this monster for a while
		dprint("got one");
		sight_entity = self;
		sight_entity_time = time;
	}
	
	self.show_hostile = time + 1;		// wake up other monsters
	
	self.last_sighting = self.enemy.origin;
	SightSound ();
	HuntTarget ();
};

/*
===========
FindTarget

Self is currently not attacking anything, so try to find a target

Returns TRUE if an enemy was sighted

When a player fires a missile, the point of impact becomes a fakeplayer so
that monsters that see the impact will respond as if they had seen the
player.

To avoid spending too much time, only a single client (or fakeclient) is
checked each frame.  This means multi player games will have slightly
slower noticing monsters.
============
*/
float() FindTarget =
{
	local entity	client;
	local float		r;

	if (self.flags & FL_TORTURED)
		return FALSE;	
	
// if the first spawnflag bit is set, the monster will only wake up on
// really seeing the player, not another monster getting angry

// spawnflags & 3 is a big hack, because zombie crucified used the first
// spawn flag prior to the ambush flag, and I forgot about it, so the second
// spawn flag works as well
	if (sight_entity_time >= time - 0.1 && !(self.spawnflags & 3) )
	{
		client = sight_entity;
		if (client.enemy == self.enemy)
			return TRUE;
	}
	else
	{
		client = checkclient ();
		if (!client)
			return FALSE;	// current check entity isn't in PVS
	}

	if (client == self.enemy)
		return FALSE;

	if (client.flags & FL_NOTARGET)
		return FALSE;

	if (client.items & IT_INVISIBILITY)
		return FALSE;

	r = range (client);
	if (r == RANGE_FAR)
		return FALSE;
		
	if (!visible (self, client))
		return FALSE;

	if (r == RANGE_NEAR)
	{
		if (client.show_hostile < time && !infront (client))
			return FALSE;
	}

	else if (r == RANGE_MID)
	{
		if ( !infront (client))
			return FALSE;
	}
	
//
// got one
//
	self.enemy = client;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return FALSE;
		}
	}
	
	FoundTarget ();
	return TRUE;
};



//=============================================================================

/*
=============
ChooseTurn
=============
*/
void(vector dest3) ChooseTurn =
{
	local vector	dir, newdir;
	
	dir = self.origin - dest3;

	newdir_x = trace_plane_normal_y;
	newdir_y = 0 - trace_plane_normal_x;
	newdir_z = 0;
	
	if (dir * newdir > 0)
	{
		dir_x = 0 - trace_plane_normal_y;
		dir_y = trace_plane_normal_x;
	}
	else
	{
		dir_x = trace_plane_normal_y;
		dir_y = 0 - trace_plane_normal_x;
	}

	dir_z = 0;
	self.ideal_yaw = vectoyaw(dir);	
};

/*
============
FacingIdeal

============
*/
float() FacingIdeal =
{
	local	float	delta;
	
	delta = anglemod(self.angles_y - self.ideal_yaw);
	if (delta > 45 && delta < 315)
		return FALSE;
	return TRUE;
};


//=============================================================================

void(float dist) ai_forward =
{
	walkmove (self.angles_y, dist * frametime);
};

void(float dist) ai_back =
{
	walkmove ( (self.angles_y+180), dist * frametime);
};


/*
=============
ai_pain

stagger back a bit
=============
*/
void(float dist) ai_pain =
{
	ai_back (dist);
/*
	local float	away;
	
	away = anglemod (vectoyaw (self.origin - self.enemy.origin) 
	+ 180*(random()- 0.5) );
	
	walkmove (away, dist);
*/
};

/*
=============
ai_painforward

stagger back a bit
=============
*/
void(float dist) ai_painforward =
{
	walkmove (self.ideal_yaw, dist);
};

/*
=============
ai_walk

The monster is walking it's beat
=============
*/
void(float dist) ai_walk =
{	
	movedist = dist;

	// check for noticing a player
	
	if (FindTarget ())
		return;
	
	movetogoal (dist);
};


/*
=============
ai_stand

The monster is staying in one place for a while, with slight angle turns
=============
*/
void() ai_stand =
{			
	if (FindTarget () )
		return;
	
	if (time > self.pausetime)
	{
		self.th_walk ();
		return;
	}
};

/*
=============
ai_turn

don't move, but turn towards ideal_yaw
=============
*/
void() ai_turn =
{
	if (FindTarget () )
		return;
	
	ChangeYaw ();
};

/*
=============
ai_face

Stay facing the enemy
=============
*/
void() ai_face =
{
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	ChangeYaw ();
};

/*
=============
ai_charge

The monster is in a melee attack, so get as close as possible to .enemy
=============
*/
float(entity targ) infront;
float(entity targ) range;

void(float d) ai_charge =
{
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	ChangeYaw ();
	walkmove (self.angles_y, d);

	if(visible(self, self.enemy)) 
		self.last_sighting = self.enemy.origin;
};


void() ai_charge_side =
{
	local	vector	dtemp;
	local	float	heading;
	
// aim to the left of the enemy for a flyby

	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	ChangeYaw ();

	makevectors (self.angles);
	dtemp = self.enemy.origin - 30*v_right;
	heading = vectoyaw(dtemp - self.origin);
	
	walkmove(heading, 20);
};


/*
=============
ai_melee

=============
*/

void() ai_melee_side =
{
	local vector	delta;
	local float 	ldmg;

	if (!self.enemy)
		return;		// removed before stroke
		
	ai_charge_side();
	
	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 60)
		return;
	if (!CanDamage (self.enemy, self))
		return;
	ldmg = (random() + random() + random()) * 3;
	T_Damage (self.enemy, self, self, ldmg, 2);
};

void() ai_melee =
{
	local vector	delta;
	local float 	ldmg;

	if (!self.enemy)
		return;		// removed before stroke
		
	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 60)
		return;
		
	ldmg = (random() + random() + random()) * 3;
	T_Damage (self.enemy, self, self, ldmg, 2);
};

/*
=============
ai_run_slide

Strafe sideways, but stay at aproximately the same range
=============
*/
void(float dis) ai_run_slide =
{
	local float	ofs;
	
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (self.lefty)
		ofs = 90;
	else
		ofs = -90;
	
	if (walkmove (self.ideal_yaw + ofs, dis))
		return;
		
	self.lefty = 1 - self.lefty;
	
	walkmove (self.ideal_yaw - ofs, dis);
};
/*
=============
ai_run_melee

Turn and close until within an angle to launch a melee attack
=============
*/
void() ai_run_melee =
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();

	if (FacingIdeal())
	{
		self.th_melee ();
		self.attack_state = AS_STRAIGHT;
	}
};


/*
=============
ai_run_missile

Turn in place until within an angle to launch a missile attack
=============
*/
void() ai_run_missile =
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (FacingIdeal())
	{
		self.th_missile ();
		self.attack_state = AS_STRAIGHT;
	}
};


//=============================================================================

/*
===========
CheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/
float() CheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	targ = self.enemy;
	
// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);
	
	if (trace_ent != targ)
		return FALSE;		// don't have a clear shot
			
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (enemy_range == RANGE_MELEE)
	{	// melee attack
		if (self.th_melee)
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}
	
// missile attack
	
	if (!self.th_missile)
		return FALSE;
	
	if (self.flags & FL_DODGED)
		return FALSE;
		
	if (time < self.attack_finished)
		return FALSE;
		
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	if (enemy_range == RANGE_MELEE)
	{
		chance = 0.9;
		self.attack_finished = 0;
	}
	else if (enemy_range == RANGE_CLOSE)
	{
		if (self.th_melee)
			chance = 0.4;
		else
			chance = 0.8;
	}
	else if (enemy_range == RANGE_NEAR)
	{
		if (self.th_melee)
			chance = 0.2;
		else
			chance = 0.4;
	}
	else if (enemy_range == RANGE_MID)
	{
		if (self.th_melee)
			chance = 0.05;
		else
			chance = 0.1;
	}
	else
		chance = 0;

	if (random () < chance)
	{
		self.attack_state = AS_MISSILE;
		SUB_AttackFinished (self, 1 + 4*random());
		return TRUE;
	}

	return FALSE;
};

float() CheckAnyAttack =
{
	if (!enemy_vis)
		return FALSE;
	if (self.th_checkattack)
		return self.th_checkattack();
	return CheckAttack ();
};

float() ai_checkattack =
{	
	if (self.flags & FL_TORTURED)
		return FALSE;
	
	// see if the enemy is dead
	if (self.enemy.health <= 0)
	{
		self.enemy = world;
	// FIXME: look all around for other targets
		if (self.oldenemy.health > 0)
		{
			self.enemy = self.oldenemy;
			HuntTarget ();
		}
		else
		{
			if (self.movetarget)
				self.th_walk ();
			else
			{
				self.pausetime = 99999999;
				self.th_stand ();
			}
			return TRUE;
		}
	}
	
	self.show_hostile = time + 1;
	
// check knowledge of enemy	
	enemy_vis = visible(self, self.enemy);
	if (enemy_vis)
	{
		self.last_sighting = self.enemy.origin;
		self.search_time = time + 5;
	}

	if (self.attack_state == AS_MISSILE)
	{
		ai_run_missile ();
		return TRUE;
	}
	if (self.attack_state == AS_MELEE)
	{
		ai_run_melee ();
		return TRUE;
	}

	return CheckAnyAttack();
}

//=============================================================================

/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
void(float dist) ai_run =
{		
	movedist = dist;
	local entity tempgoal, save;
	local float left, right, dis1, dis2, center;
	local vector view, Ltarg, Rtarg;

	self.show_hostile = time + 1;		// wake up other monsters

	enemy_infront = infront(self.enemy);
	enemy_range = range(self.enemy);
	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);

	if (ai_checkattack())
		return;					// beginning an attack

	if ( ( self.flags & FL_STRAFE) )
	{	
		local float strafedist = 0;
		if(dist < 10)
			strafedist = dist * 5.6;
		else if(dist < 20)
			strafedist = dist * 3;
		else if(dist > 25)
			strafedist = dist * 2.25;
		else
			strafedist = dist * 2.5;	
		ai_run_slide (strafedist);
		self.flags = self.flags - (self.flags & FL_STRAFE);
	}

	if (self.attack_state == AS_SLIDING)
	{	
		if ((self.aiflags & AI_LOST_SIGHT))
			self.attack_state = AS_STRAIGHT;
		else 
			ai_run_slide (movedist);
		return;
	}

//--------- q2 port kinda
	if (enemy_vis)
	{
		movetogoal (dist);
		self.aiflags &= ~AI_LOST_SIGHT;
		self.last_sighting = self.enemy.origin;
		return;
	}

	save = self.goalentity;
	
	if (!(self.aiflags & AI_LOST_SIGHT))
	{
		self.aiflags |= AI_LOST_SIGHT;
		self.aiflags &= ~AI_PURSUE_NEXT;
	}
	
	if (self.aiflags & AI_PURSUE_NEXT)
	{
		self.aiflags &= ~AI_PURSUE_NEXT;

		// give ourself more time since we got this far
		self.search_time = time + 5;

		if (self.aiflags & AI_PURSUE_TEMP)
		{
			self.aiflags &= ~AI_PURSUE_TEMP;
			self.last_sighting = self.saved_goal;
		}
	}
	
	if (vlen(self.origin - self.last_sighting) <= dist)
	{
		self.aiflags |= AI_PURSUE_NEXT;
		dist = vlen(self.origin - self.last_sighting);
	}

	tempgoal = spawn();
	self.goalentity = tempgoal;	
	self.goalentity.origin = self.last_sighting;
	
	if((self.aiflags & AI_LOST_SIGHT))
	{		
		traceline(self.origin, self.last_sighting, 2, self); // pray for quakec tracebox
	
		if(trace_fraction < 1)
		{	
			view = normalize(self.goalentity.origin - self.origin);
			dis1 = vlen(self.goalentity.origin - self.origin);
			center = trace_fraction;
			dis2 = dis1 * (center+1) / 2;
			self.angles_y = self.ideal_yaw = vectoyaw(view);
			makevectors(self.angles);
		
			view = setvector(dis2, -16, 0);
			Ltarg = ProjectAim(self.origin, view, v_forward, v_right);
			traceline(self.origin, Ltarg, 2, self);
			left = trace_fraction;

			view = setvector(dis2, 16, 0);
			Rtarg = ProjectAim(self.origin, view, v_forward, v_right);
			traceline(self.origin, Rtarg, 2, self);
			right = trace_fraction;
		
			center = (dis1*center)/dis2;
			if (left >= center && left > right)
			{
				if (left < 1)
				{
					view = setvector(dis2 * left * 0.5, -16, 0);
					Ltarg = ProjectAim(self.origin, view, v_forward, v_right);
				}
				self.aiflags |= AI_PURSUE_TEMP;
				self.saved_goal = self.last_sighting;
				self.goalentity.origin = Ltarg;
				self.last_sighting = Ltarg;
				view = normalize(self.goalentity.origin - self.origin);
				self.angles_y = self.ideal_yaw = vectoyaw(view);
				dprint("turn left");
				dprint("\n");
				//line(self.goalentity.origin);
			}
			else if (right >= center && right > left)
			{
				if (right < 1)
				{
					view = setvector(dis2 * right * 0.5, 16, 0);
					Rtarg = ProjectAim(self.origin, view, v_forward, v_right);
				}
				self.aiflags |= AI_PURSUE_TEMP;
				self.saved_goal = self.last_sighting;
				self.goalentity.origin = Rtarg;
				self.last_sighting = Rtarg;
				view = normalize(self.goalentity.origin - self.origin);
				self.angles_y = self.ideal_yaw = vectoyaw(view);
				dprint("turn right");
				dprint("\n");
				//line(self.goalentity.origin);
			}
		}
		else
		{
			dprint("good path");
			dprint("\n");
			//line(self.goalentity.origin);
		}
	}
		
// head straight in
	if (self.classname != "monster_boss2" || !(self.flags & FL_TORTURED) )
		dist = dist + 25;
	movetogoal (dist);		// done in C code...
	remove(tempgoal);
	self.goalentity = save;
};

