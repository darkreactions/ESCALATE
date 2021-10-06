# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %% [markdown]
# # Dependencies 
# Created by wrborrelli
# %%
import sys
import itertools
import matplotlib.pyplot as plt
from scipy.spatial import ConvexHull
from scipy.optimize import linprog
from scipy.optimize import lsq_linear
from scipy.spatial import HalfspaceIntersection
import numpy as np
from numpy.linalg import lstsq

import pint
from pint import UnitRegistry
units = UnitRegistry()
Q_ = units.Quantity

# %% [markdown]
# # Sample Inputs

# %%
reagent1= {'Gamma-Butyrolactone': '0.0 M'}

reagent2= {'Lead Diiodide': '1.81 M',
 'Formamidinium Iodide': '1.36 M',
 'Gamma-Butyrolactone': '0.0 M'}

reagent3 ={'Formamidinium Iodide': '2.63 M', 
           'Gamma-Butyrolactone': '0.0 M'}

reagent7= {'Formic Acid': '26.5 M'}

reagents = [reagent1, reagent2, reagent3, reagent7]
descriptions=['Reagent1', 'Reagent2', 'Reagent3', 'Reagent7']


# %%
nExpt = 96
maxMolarity = 15.0
finalVolume = '500 ul'


# %% [markdown]
# ## Helper Functions

# %%
def get_hull_centroid(hull: ConvexHull):
    """ Returns the centroid of the supplied scipy convex hull object.

    Args:
        hull: a scipy convex hull object 

    Returns:
        np.array() of centroids for each axis. 

    >>> get_hull_centroid(ConvexHull(np.array([[1.8, 0., 0.],[0. , 0.,  0.], [0., 0., 26.5], [0., 2., 1.]])))
    array([0.45, 0.5, 6.875])
    """

    return np.array([np.mean(hull.points[hull.vertices, i]) for i in range(len(hull.points) - 1)])


# %%
def convex_hull_intersection(points1: np.ndarray, points2: np.ndarray, vis2d=False):
    """ Returns the points corresponding to the intersecting region of two convex hulls (up to however  many dimensions scipy ConvexHull takes (9D I think).
    
    Args:
        points1: np.array() of points corresponding to the first convex hull.
        points2: np.array() of points corresponding to the second convex hull. 
        vis2d: True/False if you want to visualize the resulting region (2D hulls only)

    Returns:
        np.array() of points corresponding to the intersection region. 
    """

    assert points1.shape[1] == points2.shape[1]
    hull1 = ConvexHull(points1)
    hull2 = ConvexHull(points2)
    A = np.vstack((hull1.equations[:, :-1], hull2.equations[:, :-1]))
    b = np.hstack((hull1.equations[:, -1], hull2.equations[:, -1]))
    res = linprog(c=np.zeros(A.shape[1]), A_ub=A, b_ub=-b, method="interior-point")
    feasible_point = res.x
    hint = HalfspaceIntersection(np.vstack((hull1.equations, hull2.equations)), feasible_point)

    if vis2d:
        fig = plt.figure()
        ax = fig.add_subplot(1, 1, 1, aspect='equal')
        xlim, ylim = (0, 1), (0, 1)
        ax.set_xlim(xlim)
        ax.set_ylim(ylim)

        for simplex in hull1.simplices:
            ax.plot(points1[simplex, 0], points1[simplex, 1], 'r-')

        for simplex in hull2.simplices:
            ax.plot(points2[simplex, 0], points2[simplex, 1], 'b-')

        x, y = zip(*hint.intersections)
        ax.plot(x, y, 'k^', markersize=8)
        plt.savefig("{}".format(__file__).replace(".py", ".png"))

    return hint.intersections


# %%
def bb_to_cds(bb):
    """ Converts bounding box notation to vertex coordinates. 

    Args:
        bb: list of lists of bounding box notation [[mins], [maxes]] corresponding to the mins and maxes for each axis.

    Returns:
        np.array() of points corresponding to the vertices of the bounding box. 
    """

    outp = list(itertools.product(*bb))
    out = []
    for i in outp:
        temp = []
        for j in i:
            if isinstance(j, list):
                for k in j:
                    temp.append(k)
            else:
                temp.append(j)
        out.append(temp)
    return np.array(out)


# %%
def bb_cds(corners):
    """ Returns a list of the mins and maxes for each axis in a bounding box, given the corners of concentration space.

    Args:
        corners: np.array() of points corresponding to the corners of the concentration space. 

    Returns:
        list of [[mins], [maxes]] defining the resulting bounding box. 
    """
    tarray = np.transpose(corners)
    maxes = [max(tarray[i]) for i in range(len(corners[0]))]
    mins = [min(tarray[i]) for i in range(len(corners[0]))]
    return [mins, maxes]


# %%
def box_int(b1, b2):
    """ Gets the coordinates of the overlapping region for two n-dimensional hypercubes. 

    Args:
        b1: list of lists in bounding box notation [[mins], [maxes]] for each axis of box 1
        b2: list of lists in bounding box notation [[mins], [maxes]] for each axis of box 2

    Returns:
        List of the coordinates for the overlapping region (returns 0 for no overlap). 
    """
    olap_cds = []
    for i in range(len(b1.T)):
        if (b1.T[i][0] <= b2.T[i][0]):
            None
        else:
            b1, b2 = b2, b1 
        if ((b1.T[i][0] <= b1.T[i][1]) and (b1.T[i][1] <= b2.T[i][0]) and (b2.T[i][0] <= b2.T[i][1])):
            return 0
        elif ((b1.T[i][0] <= b2.T[i][0]) and (b2.T[i][0] <= b1.T[i][1]) and (b1.T[i][1] <= b2.T[i][1])):
            olap_cds.append([b2.T[i][0], b1.T[i][1]])
        elif ((b1.T[i][0] <= b2.T[i][0]) and (b2.T[i][0] <= b2.T[i][1]) and (b2.T[i][1] <= b1.T[i][1])):
            olap_cds.append([b2.T[i][0], b2.T[i][1]])
    return olap_cds


# %%
def in_hull(points, x):
    """ Tests if a point is inside the ConvexHull given by points. 

    Args:
        points: np.array() of points defining the ConvexHull.
        x: point to be tested for inclusion in the Convexhull.

    Returns:
        True: point is inside hull.
        False: point is not inside hull 
    """
    n_points = len(points)
    n_dim = len(x)
    c = np.zeros(n_points)
    A = np.r_[points.T, np.ones((1, n_points))]
    b = np.r_[x, np.ones(1)]
    lp = linprog(c, A_eq=A, b_eq=b)
    return lp.success

# %% [markdown]
# ## Sampling Functions

# %%
def allowedExperiments(reagents, maxConcentration, minConcentration):
    """ Find the allowed ConvexHull given the reagent definitions and max/min concentration. 

    Note that, relative to the Mathematica code, the location of max and min 
    concentration in the function arguments are swapped. 
    This allows for the case where you only want to give a max concentration. 

    Because this generates a scipy ConvexHull, it is susceptible to dimensional constraints. 

    Args:
        reagents: dictionary of reagent definitions. 
        maxConcentration: the maximum concentration imposed. 
        minConcentration: the minimum concentration imposed.

    Returns:
        scipy ConvexHull defining the allowed experimental sampling region. 
    """
    compositionBoundary = np.array(list(reagents.values())) # array of convex hull points
    minMax = [] # list to format imposedBoundary points
    if ((type(minConcentration) is list) and (type(maxConcentration)) is list): # run this if both min/max Concentrations are given as lists 
        for i in range(len(minConcentration)): # formats imposedBoundary into coords
            minMax.append([minConcentration[i], maxConcentration[i]])
        imposedBoundary = np.array(minMax) # array of imposedBoundary points 
        return ConvexHull(convex_hull_intersection(compositionBoundary, bb_to_cds(imposedBoundary))) # return the intersection convex hull
    else:
        return print('error') # or print an error 
    
def allowedExperiments(reagents, maxConcentration, minConcentration=None):
    """ Find the allowed ConvexHull given the reagent definitions and max/min concentration. 

    Note that, relative to the Mathematica code, the location of max and min concentration in the function arguments are swapped. This allows for the case where you only want to give a max concentration. 

    Because this generates a scipy ConvexHull, it is susceptible to dimensional constraints. 

    Args:
        reagents: dictionary of reagent definitions. 
        maxConcentration: the maximum concentration imposed. 
        minConcentration: (optional) the minimum concentration imposed (0 otherwise).

    Returns:
        scipy ConvexHull defining the allowed experimental sampling region. 
    """
    if ((type(maxConcentration) is float) or (type(maxConcentration) is int)): # run this if only maxConcentration is given and it's a float or int
        correctDimensionalityVector = ([1]*len(np.array(list(reagents.values()))[0]))
        compositionBoundary = np.array(list(reagents.values()))
        minMax = []
        minConcVec = ([0]*len(correctDimensionalityVector)) # min [] vec is 0's
        maxConcVec = ([maxConcentration]*len(correctDimensionalityVector)) # max [] vec is maxConc repeated to correct dimension
        for i in range(len(correctDimensionalityVector)):
            minMax.append(([minConcVec[i], maxConcVec[i]]))
        imposedBoundary = np.array(minMax)
        return ConvexHull(convex_hull_intersection(compositionBoundary, bb_to_cds(imposedBoundary)))
    elif type(maxConcentration) is list: # run this if only maxConcentration is given and it's a list 
        compositionBoundary = np.array(list(reagents.values()))
        minMax = []
        minConcVec = ([0]*len(maxConcentration)) # min [] vec is 0's
        maxConcVec = maxConcentration # max [] vec is the list maxConcentration
        for i in range(len(maxConcentration)):
            minMax.append(([minConcVec[i], maxConcVec[i]]))
        imposedBoundary = np.array(minMax)
        return ConvexHull(convex_hull_intersection(compositionBoundary, bb_to_cds(imposedBoundary)))
    else:
        return print('error')


# %%
def sampleConcentrations(allowedHull, nExpts=96):
    """ Randomly samples nExpts # of experiments within an allowed ConvexHull. 

    Args:
        allowedHull: A scipy ConvexHull that defines the allowed sampling region. This input should be what allowedExperiments() returns. 
        nExpts: (optional) The number of experiments to be sampled (default is 96). 
    """
    bbox = [allowedHull.min_bound, allowedHull.max_bound]
    pts = []
    while len(pts) < nExpts:
        rand_pt = [np.random.uniform(bbox[0][i], bbox[1][i]) for i in range(len(bbox[0]))]
        if in_hull(np.array(allowedHull.points), rand_pt):
            pts.append(rand_pt)
    return pts


# %%
def ConvexSolution(corners, cand):
    """ Given the corners (from reagent dictionary) and the concentrations of a single experiment, this finds a convex solution.

    scipy lsq_linear is used, and the non-negative constraint is enforced by the bounds. The sum to 1 constraint is forced by adding a row of all 1's to the coefficient matrix and adding a 1 to the b vector. This seems to work pretty well, but sometimes the solution is very close to 1, but not exactly 1. 

    Args:
        corners: Corners defining the reagent space (given by reagent dictionary).
        cand: Vector defining one experiment (this often comes from the results of sampleConcentrations).

    Returns: 
        A np.array() corresponding to the solution. 
    """
    i_array = np.array(list(corners.values()))
    f_array = np.transpose(i_array)
    f_array = np.vstack([f_array, [1]*len(f_array[0])])
    x = lsq_linear(f_array, np.append(cand, [1]), bounds=(0, np.inf), lsq_solver='exact', method='bvls')
    return x.x


# %%
def convertConcentrationsToVolumes(reagentDefs, experiments):
    if np.array(experiments).ndim > 1:
        """ Converts the concentrations (found by ConvexSolution) into volumes. 

        Args:
            reagentDefs: Dictionary defining the reagents. 
            experiments: matrix or vector defining specific experiment(s).

        Returns:
            Dictionary of {reagents : volumes}
        """
        reagentNames = np.array(list(reagentDefs.keys()))
        vals = np.transpose(np.array([ConvexSolution(reagentDefs, i) for i in np.array(experiments)]))
        vals = list(map(list, vals)) # do we want a tuple or list?
        return dict(zip(reagentNames, vals))
    else:
        reagentNames = np.array(list(reagentDefs.keys()))
        vals = np.array(ConvexSolution(reagentDefs, np.array(experiments)))
        vals = list(vals) # do we want a tuple or list?
        return dict(zip(reagentNames, vals))


# %%
def dropZeroColumns(reagents):
    """ Deletes any nonzero columns and reformats a dictionary of reagents. 

    Args:
        reagents: Dictionary of reagents. 

    Returns:
        Dictionary of reagents with only the non-zero columns returned. 
    """
    d_keys = list(reagents.keys())
    array = np.array(list(reagents.values()))
    new_vals = array[:, array.any(0)]
    return dict(zip(d_keys, new_vals))


# %%
def sampleUntilSuccessful(corners, boundingCuboid):
    """ Samples valid convex solutions given corners (defined by reagents) and a bounding cuboid. 

    Args:
        corners: Corners defined by the reagent dictionary. 
        boundingCuboid: Bounding cuboid in [[mins], [maxes]] notation that defines the sampling space. 
    """
    i = 0
    while i < 100000:
         sample = ConvexSolution(corners, np.array([np.random.uniform(boundingCuboid[i][0], boundingCuboid[i][1]) for i in range(len(boundingCuboid))]))
         if sample.sum() > 0:
                        break
         else:
            i += 1
    return sample

# %%
def generate_vectors(descriptions, reagents):
    
    """
    Returns a dictionary where keys are reagent descriptions,
    and values are concentration vectors for components in the reagent.
    This dictionary can then be passed into GenerateExperiments.
    
    Sample input:  descriptions=['Reagent 1', 'Reagent 2', 'Reagent 3', 'Reagent 7']
                   reagents=[reagent1, reagent2, reagent3, reagent7]
                    
    where each variable in the reagents list is defined as follows:
    
    reagent1= {'Gamma-Butyrolactone': '0.0 M'}

    reagent2= {'Lead Diiodide': '1.81 M',
     'Formamidinium Iodide': '1.36 M',
     'Gamma-Butyrolactone': '0.0 M'}

    reagent3 ={'Formamidinium Iodide': '2.63 M', 
               'Gamma-Butyrolactone': '0.0 M'}

    reagent7= {'Formic Acid': '26.5 M'}
    
    Input can be queried directly from database.
    """
    
    #error handling: concentrations must be in molarity. otherwise code breaks
    for entry in reagents:
        for key, val in entry.items():
            conc_unit=val.split()[1]
            if units(conc_unit)!=units('molar'): 
                print('TypeError: Concentration must be a molarity. Please convert and re-enter.')
                sys.exit()
    
    names=[]
    for entry in reagents:
        for key in entry:
            if key not in names:
                names.append(key) #add all chemicals to list of chemical names
    raw_vectors={}
    for name in names:
        raw_vectors[name]=[] #instantiate a series of vectors where keys are chemical names
        #values are empty lists to which concentrations will be appended
    
    for name in names: #loop through and append concentrations to appropriate values list
        for entry in reagents:
            if name in entry.keys():
                val=entry[name].split()
                raw_vectors[name].append(float(val[0]))
            else:
                raw_vectors[name].append(0.0) #if a chemical is not present, append 0.0 as its concentration
                
    array=[]
    
    for val in raw_vectors.values(): #create an array of the concentration lists
        array.append(val) 
    
    new_array= np.array(array).transpose() #transpose the array 
    
    reagent_vectors={} 
    
    for i in range(len(descriptions)): #generate dictionary with keys=reagent descriptions and vals=concentration vectors 
        reagent_vectors[descriptions[i]]=list(new_array[i])

    return reagent_vectors
  
# %%

# %%
def generateExperiments(reagents, descriptions, nExpt, excludedReagents=None, maxMolarity=9., finalVolume='500. uL', desiredUnit='uL'):
    
    #convert reagent input into proper vector format
    reagentDefs = generate_vectors(descriptions, reagents) 
    
    if excludedReagents != None:
        excludedReagentDefs = generate_vectors(descriptions, excludedReagents)
    else:
        excludedReagentDefs == None
    
    #convert input volume to microliters, if it isn't already
    v=finalVol.split()
    v1=Q_(float(v[0]), v[1]).to(units.ul)
    finalVolume=v1.magnitude
    
    if excludedReagentsDef == None:
        """ This is the main interface that takes in the dictionary of reagent definitions, decides what experiment generation code to run, and returns the results. 

        If no excluded reagents are given, the species dimensionality decides which block runs:
            <= 3 --> generate3DExperiments runs 
            >3 --? generateHitAndRunExperiments runs 

        If excluded reagents are given, it finds the allowed-excluded hull intersection, then samples from the combined allowed-intersection hull via a bounding box, only taking points that are both inside the total hull and outside the intersection. This isn't super efficient but it runs quick for only 96 expts. I did this because finding the complex polygon is 3D that is given by the difference in both hulls is not easily implemented. 

        Args:
            reagentDefs: Dictionary of reagents, output of generate_vectors() function. 
            excludedReagentDefs: (optional) Dictionary of reagents you would like to exclude from experiment generation. 
            nExpt: (optional) The number of experiments you want to generate (default is 96).
            maxMolarity: (optional) The max molarity you want to impose (default is 9.).
            finalVolume: (optional) The final volume you want to impose (default 500. ul).
                ***must be input as a string with value and units
            desiredUnit: (optional): The unit in which final volumes should be expressed (default ul)

        Returns:
            Nested dictionary of {concentrations : {unique_reagent_names : sampled concecntrations},
            volumes : {reagents : volumes}
            }
        """
        speciesDimensionality = len(list(dropZeroColumns(reagentDefs).values())[0])
        if speciesDimensionality <= 3:
            return generate3DExperiments(reagents, descriptions, nExpt, maxMolarity=9., finalVolume='500. uL', desiredUnit='uL', processValues='round')
        else:
            return generateHitAndRunExperiments(reagents, descriptions, nExpt, maxMolarity=9., finalVolume='500. uL', desiredUnit='uL', processValues='round')
    else:
        nonzeroReagentsDef = dropZeroColumns(reagentDefs)
        nonzeroExcludedReagentsDef = dropZeroColumns(excludedReagentsDef)
        if len(list(nonzeroReagentsDef.values())[0]) > 3:
            return print('Difference sampling only implemented for <= 3 species')
        else:
            a_hull = allowedExperiments(nonzeroReagentsDef, maxMolarity)
            b_hull = allowedExperiments(nonzeroExcludedReagentsDef, maxMolarity)
            int_hull = ConvexHull(convex_hull_intersection(a_hull.points, b_hull.points))
            total_hull = ConvexHull(np.append(a_hull.points, int_hull.points, axis=0))
            if int_hull.volume > 0:
                bbox = [total_hull.min_bound, total_hull.max_bound]
                pts = []
                while len(pts) < nExpt:
                    rand_pt = [np.random.uniform(bbox[0][i], bbox[1][i]) for i in range(len(bbox[0]))]
                    if ((in_hull(np.array(total_hull.points), rand_pt)) and not(in_hull(np.array(int_hull.points), rand_pt))):
                        pts.append(rand_pt)
                dic = convertConcentrationsToVolumes(nonzeroReagentsDef, pts)
                for k, v in dic.items():
                    dic[k] = list(np.round((finalVolume*np.array(v))))
                
                desiredUnit = Q_(1, desiredUnit).units
    
                if desiredUnit!=units('ul'):
                    for key, val in dic.items():
                        dic[key]=(Q_(val, 'ul')).to(desiredUnit)
                
                return dic
            else:
                return print('Volume of remaining space is zero')


# %%
def generateHitAndRunExperiments(reagents, descriptions, nExpt=96, maxMolarity=9., finalVol='500 uL', desiredUnit='uL', processValues='round'):
    """ This generates hit and run experiments. This block runs if species dimensionality is > 3. 
    Args:
        reagents: list of dictionaries, where each list corresponds to a reagent. keys are chemical components and values are concentrations for the components
        descriptions: list of names of reagents, e.g. ['Reagent 1', 'Reagent 2', 'Reagent 3', Reagent 7']
        nExpt: (optional) The number of experiments to generate (default is 96).
        maxMolarity: (optional) The max molarity you want to impose (default is 9.).
        finalVolume: (optional) The final volume you want to impose (default 500. ul).
            ***must be input as a string with value and units
        desiredUnit: (optional): The unit in which final volumes should be expressed (default ul)
        processValues: (optional) Doesn't currently support an operation other than rounding the volumes to whole number (default is round). 
    Returns:
        Dictionary of {reagents : 96 volumes, expressed in terms of desiredUnit}
    """
    
    #convert input volume to microliters, if it isn't already
    v=finalVol.split()
    v1=Q_(float(v[0]), v[1]).to(units.ul)
    finalVolume=v1.magnitude
    
    reagentDefs = generate_vectors(descriptions, reagents) #convert reagent input into proper vector format
    nonzeroReagentDefs = dropZeroColumns(reagentDefs)
    dimensionality = len(np.array(list(nonzeroReagentDefs.values()))[0])
    hullCorners = np.array(list(nonzeroReagentDefs.values()))
    boundingCuboid = box_int(np.array(bb_cds(hullCorners)), np.array([[0]*int(dimensionality), [maxMolarity]*int(dimensionality)]))
    results = []
    i = 0
    while i < nExpt:
        results.append(sampleUntilSuccessful(nonzeroReagentDefs, boundingCuboid))
        i += 1
    if processValues == 'round':
        results = np.transpose(np.round((finalVolume*np.array(results))))
        results = list(map(list, results))
    else:
        results = np.transpose(results)
        results = list(map(list, results))
    r_keys = np.array(list(reagentDefs.keys()))
    output= dict(zip(r_keys, results))
    desiredUnit = Q_(1, desiredUnit).units
    
    if desiredUnit!=units('ul'):
        for key, val in output.items():
            output[key]=(Q_(val, 'ul')).to(desiredUnit)
    return output


# %%
def generate3DExperiments(reagents, descriptions, nExpt=96, maxMolarity=9., finalVolume='500 uL', desiredUnit='uL', processValues='round'):
    """ This generates hit and run experiments. This block runs if species dimensionality is <= 3. 
    Args:
        reagents: list of dictionaries, where each list corresponds to a reagent. keys are chemical components and values are concentrations for the components
        descriptions: list of names of reagents, e.g. ['Reagent 1', 'Reagent 2', 'Reagent 3', Reagent 7']
        nExpt: (optional) The number of experiments to generate (default is 96).
        maxMolarity: (optional) The max molarity you want to impose (default is 9.).
        finalVolume: (optional) The final volume you want to impose (default 500. ul).
            ***must be input as a string with value and units
        desiredUnit: (optional): The unit in which final volumes should be expressed (default ul)
        processValues: (optional) Doesn't currently support an operation other than rounding the volumes to whole number (default is round). 
    
    Returns:
        Dictionary of {reagents : 96 volumes, expressed in terms of desiredUnit}
    """
    
    #convert input volume to microliters, if it isn't already
    v=finalVol.split()
    v1=Q_(float(v[0]), v[1]).to(units.ul)
    finalVolume=v1.magnitude
    
    reagentDefs = generate_vectors(descriptions, reagents) #convert reagent input into proper vector format
    nonzeroReagentDefs = dropZeroColumns(reagentDefs)
    hull = allowedExperiments(nonzeroReagentDefs, maxMolarity)
    sample_cs = sampleConcentrations(hull, nExpt)
    dic = convertConcentrationsToVolumes(reagentDefs, sample_cs)
    for k, v in dic.items():
        dic[k] = list(np.round((finalVolume*np.array(v))))
    desiredUnit = Q_(1, desiredUnit).units

    if desiredUnit!=units('ul'):
        for key, val in dic.items():
            dic[key]=Q_(val, 'ul').to(desiredUnit)
    return dic


if __name__=='__main__':
    generateExperiments(reagents, descriptions, 5)
    
