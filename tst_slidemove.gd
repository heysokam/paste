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
	vel_wish = kinBody.i.fVec*kinBody.i.fmove + kinBody.i.sVec*kinBody.i.smove
	dir = vel_wish.normalized() 
			
	var pos_target = dir * kinBody.base_movespeed
	var accel = kinBody.ground_accel if dir.dot(vel_wish) > 0 else -kinBody.ground_accel
	
	vel_wish = vel_wish.linear_interpolate(pos_target, accel * kinBody.delta)
	vel.x = vel_wish.x
	vel.z = vel_wish.z
	
	grounded = true if kinBody.is_on_floor() else false
	if kinBody.i.jumpB() and grounded:
		jump()
	if !grounded:
		gravity()
	vel = slidemove(vel)
	kinBody.ui.speedU(vel)
	return vel

func jump(): vel.y += kinBody.base_jump#*kinBody.delta
func gravity(): vel.y -= (kinBody.base_gravity*kinBody.delta)

func testmove(velocity:Vector3):
	return kinBody.move_and_collide(velocity, kinBody.infiniteInertia, true, true)

func slidemove(velocity:Vector3): #Slide & Step
	#Check forward move
	var test = testmove(velocity) # Test will contain a KinematicCollision class if it hit. Will be null otherwise.
	var stairs = false if test == null else true
	#Do slide if can move forward. Do step if trace hit somethinkinBody.
	if stairs: kinBody.breakp()
	return step(velocity) if stairs else slide(velocity)

func slide(velocity:Vector3):
	var result = kinBody.move_and_slide(velocity, Vector3.UP,
							kinBody.stopOnSlope,
							kinBody.rampslide_max,
							deg2rad(kinBody.rampAngle),
							kinBody.infiniteInertia)
	return result

func step(velocity:Vector3):
	var stepsize = kinBody.base_stepsize
	var origin = kinBody.global_transform.origin

	# Find where the step is (aka move towards the velocity, which could also be down)
	var collision = testmove(velocity) # A null collision should not happen, since we checked for collision in slidemove before this.
	var safe = 0.1 # Percentage of the full move to avoid, so that we don't get slowed to a halt by colliding with the wall
	var newvel = slide((1-safe) * (velocity - collision.remainder))
	
	# move up as much as possible up to STEPSIZE
	var up = Vector3(origin.x, origin.y+stepsize, origin.z)
	slide(up + velocity) #Same as Vector3.direction_to(point), but without normalizing
	origin = kinBody.global_transform.origin #update after moving
	# move horizontally
	newvel = slide(newvel) #Stores the output of the topside movement so we decelerate normally during a stepup frame. move_and_slide takes a velocity and outputs a modified one. 
	origin = kinBody.global_transform.origin #update after moving
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
