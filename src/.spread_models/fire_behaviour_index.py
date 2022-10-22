"""Fire behaviour index (FBI) calculations
   FBI is alingned to have round number values at the category
   boundaries in the fire danger rating definition tables
"""

import numpy as np

#Common 'round numbers' to be used for all fuel types
FBI_thresholds = [0,6,12,24,50,100]

#Arbitrary high values to anchor FBI above the top threshold
FBI_HIGH = 200
INTENSITY_HIGH = 90000

def forest(intensity):
    intensity_thresholds = [0,100,750,4000,10000,30000]
    
    #Use linear interpolation for FBI up to the top threshold
    FBI = np.full(intensity.shape,np.nan)
    for i in range(len(intensity_thresholds)-1):
        mask = ((intensity>=intensity_thresholds[i]) & (intensity<intensity_thresholds[i+1]))
        FBI[mask] = (FBI_thresholds[i] + 
                     (FBI_thresholds[i+1]-FBI_thresholds[i])*(intensity-intensity_thresholds[i])/(intensity_thresholds[i+1]-intensity_thresholds[i])
                    )[mask]

    #Above top threshold scale so that Kilmore East (90,000 kW/m) has FBI of 200.
    mask = (intensity>=intensity_thresholds[-1])
    FBI[mask] = (FBI_thresholds[-1] + 
                     (FBI_HIGH-FBI_thresholds[-1])*(intensity-intensity_thresholds[-1])/(INTENSITY_HIGH-intensity_thresholds[-1])
                    )[mask]
                    
    FBI = np.trunc(FBI)
    return FBI
    
#Use the same calculation for pine and forest. May change in future.
pine = forest
    
def grass(intensity):
    intensity_thresholds = [0,100,3000,9000,17500,25000]
    
    #Use linear interpolation for FBI up to the top threshold
    FBI = np.full(intensity.shape,np.nan)
    for i in range(len(intensity_thresholds)-1):
        mask = ((intensity>=intensity_thresholds[i]) & (intensity<intensity_thresholds[i+1]))
        FBI[mask] = (FBI_thresholds[i] + 
                     (FBI_thresholds[i+1]-FBI_thresholds[i])*(intensity-intensity_thresholds[i])/(intensity_thresholds[i+1]-intensity_thresholds[i])
                    )[mask]

    #Above top threshold scale so that 90,000 kW/m has FBI of 200.
    mask = (intensity>=intensity_thresholds[-1])
    FBI[mask] = (FBI_thresholds[-1] + 
                     (FBI_HIGH-FBI_thresholds[-1])*(intensity-intensity_thresholds[-1])/(INTENSITY_HIGH-intensity_thresholds[-1])
                    )[mask]
                    
    FBI = np.trunc(FBI)
    return FBI

def heathland(intensity):
    #Added thresholds that are not in the table:
    #   5-6     40000 kW/m
    intensity_thresholds = [0,50,500,4000,20000,40000]
    
    #Use linear interpolation for FBI up to the top threshold
    FBI = np.full(intensity.shape,np.nan)
    for i in range(len(intensity_thresholds)-1):
        mask = ((intensity>=intensity_thresholds[i]) & (intensity<intensity_thresholds[i+1]))
        FBI[mask] = (FBI_thresholds[i] + 
                     (FBI_thresholds[i+1]-FBI_thresholds[i])*(intensity-intensity_thresholds[i])/(intensity_thresholds[i+1]-intensity_thresholds[i])
                    )[mask]

    #Above top threshold scale so that 90,000 kW/m has FBI of 200.
    mask = (intensity>=intensity_thresholds[-1])
    FBI[mask] = (FBI_thresholds[-1] + 
                     (FBI_HIGH-FBI_thresholds[-1])*(intensity-intensity_thresholds[-1])/(INTENSITY_HIGH-intensity_thresholds[-1])
                    )[mask]
                    
    FBI = np.trunc(FBI)
    return FBI
    
def savannah(intensity):
    #Added thresholds that are not in the table:
    #   3-4     9000 kW/m
    #   5-6     25000 kW/m
    intensity_thresholds = [0,100,3000,9000,17500,25000]
    
    #Use linear interpolation for FBI up to the top threshold
    FBI = np.full(intensity.shape,np.nan)
    for i in range(len(intensity_thresholds)-1):
        mask = ((intensity>=intensity_thresholds[i]) & (intensity<intensity_thresholds[i+1]))
        FBI[mask] = (FBI_thresholds[i] + 
                     (FBI_thresholds[i+1]-FBI_thresholds[i])*(intensity-intensity_thresholds[i])/(intensity_thresholds[i+1]-intensity_thresholds[i])
                    )[mask]

    #Above top threshold scale so that 90,000 kW/m has FBI of 200.
    mask = (intensity>=intensity_thresholds[-1])
    FBI[mask] = (FBI_thresholds[-1] + 
                     (FBI_HIGH-FBI_thresholds[-1])*(intensity-intensity_thresholds[-1])/(INTENSITY_HIGH-intensity_thresholds[-1])
                    )[mask]
                    
    FBI = np.trunc(FBI)
    return FBI

def buttongrass(rate_of_spread):
    rate_of_spread_thresholds = [0,30,480,2040,4200,8400]
    
    #Use linear interpolation for FBI up to the top threshold
    FBI = np.full(rate_of_spread.shape,np.nan)
    for i in range(len(rate_of_spread_thresholds)-1):
        mask = ((rate_of_spread>=rate_of_spread_thresholds[i]) & (rate_of_spread<rate_of_spread_thresholds[i+1]))
        FBI[mask] = (FBI_thresholds[i] + 
                     (FBI_thresholds[i+1]-FBI_thresholds[i])*(rate_of_spread-rate_of_spread_thresholds[i])/(rate_of_spread_thresholds[i+1]-rate_of_spread_thresholds[i])
                    )[mask]

    #Above top threshold scale so that 8,400 m/h has FBI of 200.
    mask = (rate_of_spread>=rate_of_spread_thresholds[-1])
    FBI[mask] = (FBI_thresholds[-1] + 
                     (FBI_HIGH-FBI_thresholds[-1])*(rate_of_spread-rate_of_spread_thresholds[-1])/(16800-rate_of_spread_thresholds[-1])
                    )[mask]
    
    FBI = np.trunc(FBI)
    return FBI
    
def spinifex(spread_index, ros):
    ros_thresholds = [0,50,1300,3875,7500,10750]

    FBI = np.full(ros.shape,np.nan)
    
    #If spread index<0, FBI=0
    mask = (spread_index<=0)
    FBI[mask] = 0
    
    #Use linear interpolation for FBI up to the top threshold
    #Only where spread_index >= 0
    for i in range(len(ros_thresholds)-1):
        mask = ((ros>=ros_thresholds[i]) & (ros<ros_thresholds[i+1]) & (spread_index>0))
        FBI[mask] = (FBI_thresholds[i] + 
                     (FBI_thresholds[i+1]-FBI_thresholds[i])*(ros-ros_thresholds[i])/(ros_thresholds[i+1]-ros_thresholds[i])
                    )[mask]

    #Above top threshold scale so that 90,000 kW/m has FBI of 200.
    mask = ((ros>=ros_thresholds[-1])& (spread_index>0))
    FBI[mask] = (FBI_thresholds[-1] + 
                     (FBI_HIGH-FBI_thresholds[-1])*(ros-ros_thresholds[-1])/(20000-ros_thresholds[-1])
                    )[mask]
                    
    FBI = np.trunc(FBI)
    return FBI
    
def mallee_heath(spread_probability, crown_probability, intensity):
    FBI = np.full(intensity.shape,np.nan)

    #Category 1: spread_probability<0.5
    mask = (spread_probability<0.5)
    FBI[mask] = (FBI_thresholds[0] + (FBI_thresholds[1]-FBI_thresholds[0])*(spread_probability/0.5))[mask]

    #Category 2: spread_probability>=0.5 & crown_probability<0.33
    mask = ((spread_probability>=0.5) & (crown_probability<0.33))
    FBI[mask] = (FBI_thresholds[1] + (FBI_thresholds[2]-FBI_thresholds[1])*(crown_probability/0.33))[mask]

    #Category 3: spread_probability>=0.5 & 0.33<=crown_probability<0.66
    mask = ((spread_probability>=0.5) & (crown_probability>=0.33) & (crown_probability<0.66))
    FBI[mask] = (FBI_thresholds[2] + (FBI_thresholds[3]-FBI_thresholds[2])*(crown_probability-0.33)/(0.66-0.33))[mask]

    #Category 4: spread_probability>=0.5 & crown_probability>=0.66 & intensity < 20000
    mask = ((spread_probability>=0.5) & (crown_probability>=0.66) & (intensity<20000))
    FBI[mask] = (FBI_thresholds[3] + (FBI_thresholds[4]-FBI_thresholds[3])*(intensity)/(20000))[mask]

    #Category 5:  20,0000 < intensity < 40,000 kW/m
    mask = ((spread_probability>=0.5) & (intensity>20000) & (intensity<40000))
    FBI[mask] = (FBI_thresholds[4] + (FBI_thresholds[5]-FBI_thresholds[4])*(intensity-20000)/(40000-20000))[mask]

    #Category 6: crown_probability>=1.00 & intensity >= 40,000 kW/m
    mask = ((spread_probability>=0.5) & (crown_probability>0.99) & (intensity>=40000))
    FBI[mask] = (FBI_thresholds[5] + (FBI_HIGH-FBI_thresholds[5])*(intensity-40000)/(INTENSITY_HIGH-40000))[mask]


    FBI = np.trunc(FBI)
    return FBI
    