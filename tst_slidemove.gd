####################
## Type0. Godot Default
#  ...
class_name Gm extends Reference

# Init & Name
const cname:String = "Gm"
func get_class(): return cname
func is_class(value): return true if value == cname else false
func _init(body): 
	g = body
var g # Player Node / Parent connection.

var grounded:bool
var dir:Vector3
var vel:Vector3
var vel_wish:Vector3
func move():
	vel_wish = g.i.fVec*g.i.fmove + g.i.sVec*g.i.smove
	dir = vel_wish.normalized() 
			
	var pos_target = dir * g.cvar.phy_base_movespeed
	var accel = g.cvar.phy_ground_accel if dir.dot(vel_wish) > 0 else -g.cvar.phy_ground_accel
	
	vel_wish = vel_wish.linear_interpolate(pos_target, accel * g.delta)
	vel.x = vel_wish.x
	vel.z = vel_wish.z
	
	grounded = true if g.is_on_floor() else false
	if g.i.jumpB() and grounded:
		jump()
	if !grounded:
		gravity()
	vel = slidemove(vel)
	g.ui.speedU(vel)
	return vel

func jump(): vel.y += g.cvar.phy_base_jump#*g.delta
func gravity(): vel.y -= (g.cvar.phy_base_gravity*g.delta)

var fixf = 0.01 #Floating point precision desired
var fix = Vector3()*fixf #Vector3 version of the fix, for more readable code than fixf everywhere.
#move_and_collide ( Vector3 rel_vec, bool infinite_inertia=true, bool exclude_raycast_shapes=true, bool test_only=false )
func testmove(velocity:Vector3):
	return g.move_and_collide(velocity, g.cvar.phy_gd_infiniteInertia, true, true)

func slidemove(velocity:Vector3): #Slide & Step
	velocity = velocity.snapped(fix)
	#var origin = g.global_transform.origin
	#Check forward move
	#var trace = Trace.new(g, origin+velocity, velocity)
	#trace.check("move")
	var test = testmove(velocity) # Test will contain a KinematicCollision class if it hit. Will be null otherwise.
	var stairs = false if test == null else true
	#Do slide if can move forward. Do step if trace hit something.
	if stairs: g.breakp()
	return step(velocity) if stairs else slide(velocity)

func slide(velocity:Vector3):
	var result = g.move_and_slide(velocity, Vector3.UP,
							g.cvar.phy_gd_stopOnSlope,
							g.cvar.phy_gd_rampslide_max,
							deg2rad(g.cvar.phy_gd_rampAngle),
							g.cvar.phy_gd_infiniteInertia)
	return result.snapped(fix)

func step(velocity:Vector3):
	var stepsize = g.cvar.phy_base_stepsize
	var origin = g.global_transform.origin
	# Find where the step is (aka move towards the velocity, which could also be down)
	var collision = testmove(velocity) # A null collision should not happen, since we checked for collision in slidemove before this.
	var safe = 0.1 # Percentage of the full move to avoid, so that we don't get slowed to a halt by colliding with the wall
	var newvel = slide((1-safe) * (velocity - collision.remainder))
	
	# move up as much as possible up to STEPSIZE
	var up = Vector3(origin.x, origin.y+stepsize, origin.z)
	slide(up + velocity) #Same as Vector3.direction_to(point), but without normalizing
	origin = g.global_transform.origin #update after moving
	# move horizontally
	newvel = slide(newvel) #Stores the output of the topside movement so we decelerate normally during a stepup frame. move_and_slide takes a velocity and outputs a modified one. 
	origin = g.global_transform.origin #update after moving
	# step back down as far as possible up to the same step size
	var down = Vector3(origin.x, origin.y-stepsize, origin.z)
	slide(down + velocity) #Same as Vector3.direction_to(point), but without normalizing
	return newvel
# The step algorithm is just: 
#    move up as much as possible up to STEPSIZE 
#    -> move horizontally
#    -> step back down as far as possible up to the same step size

#
## ---
####################