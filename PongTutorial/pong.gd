extends Node2D

# class member variables go here, for example:
var screen_size
var pad_size
var direction = Vector2(1.0, 0.0)

# Constant for ball start speed
const INITIAL_BALL_SPEED = 80

# Current ball speed
var ball_speed = INITIAL_BALL_SPEED

# Constant for pad speed
const PAD_SPEED = 150

# Amount the AI will be off from the center of the ball; random variable for
# AI mistakes
var AIVariance = 0

func _ready():
	screen_size = get_viewport_rect().size
	pad_size = get_node("LeftPad").get_texture().get_size()
	set_process(true)

func _process(delta):
	var ball_pos = get_node("Ball").get_pos()
	var left_rect = Rect2(get_node("LeftPad").get_pos() - pad_size * .5, pad_size)
	var right_rect = Rect2(get_node("RightPad").get_pos() - pad_size * .5, pad_size)
	
	# Update ball position
	ball_pos += direction * ball_speed * delta
	
	# Collision detection for the top/bottom of screen
	if((ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > screen_size.y) and direction.y > 0):
		direction.y = -direction.y
	
	# Collision and acceleration for game pads
	if((left_rect.has_point(ball_pos) and direction.x < 0) or (right_rect.has_point(ball_pos) and direction.x > 0)):
		direction.x = -direction.x
		direction.y = randf() * 2.0 - 1
		direction = direction.normalized()
		ball_speed *= 1.1
		
		# Determine new AI mistake threshold when colliding with either pad
		# More likely to miss as the ball speeds up, and direction to miss by is random.
		randomize()
		AIVariance = (randf() * 2.0 - 1) * (int(round(rand_range(0, 75)))) + (ball_speed - INITIAL_BALL_SPEED)
		
	# Check for out of bounds & reset ball if OOB
	if(ball_pos.x < 0 or ball_pos.x > screen_size.x):
		ball_pos = screen_size * .5
		ball_speed = INITIAL_BALL_SPEED
		direction = Vector2(-1, 0)
		
	# Left Pad movement logic
	var left_pos = get_node("LeftPad").get_pos()
	
	if(left_pos.y > 0 and Input.is_action_pressed("left_move_up")):
		#print("RIGHTUP")
		left_pos.y += -PAD_SPEED * delta
	if(left_pos.y < screen_size.y and Input.is_action_pressed("left_move_down")):
		left_pos.y += PAD_SPEED * delta
	
	#'get_node' seems to only hold one node at a time?
	get_node("LeftPad").set_pos(left_pos)
	
	# Right Pad movement logic
	var right_pos = get_node("RightPad").get_pos()
	
	# Simple AI implementation test for the right pad
	var aiMoveDirection = "NONE"
	
	if(ball_pos.y > right_pos.y + AIVariance):
		aiMoveDirection = "DOWN"
	elif(ball_pos.y < right_pos.y + AIVariance):
		aiMoveDirection = "UP"
	
	if(right_pos.y > 0 and aiMoveDirection == "UP"): #Input.is_action_pressed("right_move_up")):
		right_pos.y += -PAD_SPEED * delta
	if(right_pos.y < screen_size.y and aiMoveDirection == "DOWN"): #Input.is_action_pressed("right_move_down")):
		right_pos.y += PAD_SPEED * delta
		
	# Update positions
	get_node("Ball").set_pos(ball_pos)
	get_node("RightPad").set_pos(right_pos)
