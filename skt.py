#___________________
# Real Life context:
#   Sports coaching.
#   My players have a current speed performance of 24sec/lap. Today is day 0
#   I have speed goal for this season, lets say 20sec/lap, and I want to achieve that by next month, so day30
#   Getting from 24 to 23 is much easier than getting from 21 to 20 (logarithmic model)
#   This code is used to find all of the inbetween speeds,
#   so that growth is not absurdly modeled, like it would be with linear interpolation
#__________________________________________________________________________________________

#___________________________
# Mathematical explanation:
# Given:
#  - a logarithmic data set
#  - two known data points p1(0,24) and p2(30,20)
#  - a known amount of intermediate values, in the integer range of (p1.x = 0, p2.x = 30)
# Use logarithmic interpolation to estimate the intermediate values of y.
#__________________________________________________________________________________________

#___________________________
# Theoretical context:
#   Logarithmic interpolation is a method for estimating values between two known data points by using a logarithmic function. 
#   The basic idea is that you can use the logarithmic function to describe the relationship between x and y, 
#   and then use the two known data points to estimate the coefficients of the logarithmic function. 
#   Once you have the coefficients, you can use the logarithmic function to estimate the intermediate values of y.
#__________________________________________________________________________________________

# Math functions dependencies
import math
import numpy as np

# Data configuration
spdStart = 24  # y1
spdGoal  = 20  # y2
dayGoal  = 30  # x2

# Known data points
start = [0,       spdStart]  # Data set always starts at day0 (aka today)
goal  = [dayGoal, spdGoal ]
# Logarithm type to use.  Alternatives:  math.log2   math.log1p
log    = math.log

def getIntermediate(p1, p2):
  ## Find the intermediate values of Y, based on the two given data points
  x1, y1 = p1[0], p1[1]
  x2, y2 = p2[0], p2[1]
  # Calculate the logarithmic function parameters
  #   The function y = a*log(bx+c) + d has 4 parameters (a, b, c, and d), 
  #   By using these 4 coefficients, we have more flexibility in shaping the function 
  #   The choice of the function and the number of coefficients depend on the nature of the data and the purpose of the modeling.
  # Each parameter represents a specific aspect of the function:
  # c: Shifts the function along the x-axis. 
  #    It determines the point at which the function starts to grow or decrease.
  c = 1
  # a: Overall scale of the function. 
  #    It determines how steep the function is. 
  #    A larger value of a will result in a steeper function and a smaller value of a will result in a flatter function.
  a = (y2 - y1) / (log(x2 + c) - log(x1 + c))
  # b: How fast the function grows or decreases. 
  #    A larger value of b will result in a faster growing or decreasing function 
  #    and a smaller value of b will result in a slower growing or decreasing function.
  b = 1
  # d: Shifts the function along the y-axis. 
  #    It determines the value of y when x = 0
  d = y1 - a * log(x1+c)
  # Find the intermediate values of x
  def IntermediateX1(): return np.linspace(x1, x2, x2+1)     # Supposedly more efficient in larger ranges. Also usable for non-ints
  def IntermediateX2(): return [x for x in range(x1, x2+1)]  # Same output in essence, since we are increasing integers
  # Find the intermediate values of y
  # using the logarithmic function y = a*log(b*x + c) + d, 
  return [a * log(b*x + c) + d for x in IntermediateX1()] 

intermediate_y = getIntermediate(start, goal)
for day, speed in enumerate(intermediate_y):
  diff = intermediate_y[max(0, day-1)] - intermediate_y[day]
  print("day", format(day, '02d'), ": ", format(speed, '.3f'), "  |  diff:", format(diff, '.3f'))
