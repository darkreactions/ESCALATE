# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %% [markdown]
# # Dependencies
# Created by wrborrelli
# %%
import sys
import itertools
import random

# import matplotlib.pyplot as plt
from scipy.spatial import ConvexHull
from scipy.optimize import Bounds
from scipy.optimize import linprog
from scipy.optimize import nnls
from scipy.optimize import minimize
from scipy.optimize import lsq_linear
from scipy.spatial import HalfspaceIntersection

# from scipy.spatial.qhull import _Qhull
import numpy as np

import pint
from pint import UnitRegistry

units = UnitRegistry()
Q_ = units.Quantity

# %% [markdown]
# # Helper Functions
# %% [markdown]
def convex_hull_intersection(points1: np.ndarray, points2: np.ndarray, vis2d=False):
    """Returns the points corresponding to the intersecting region of two convex hulls (up to however  many dimensions scipy ConvexHull takes (9D I think).

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
    hint = HalfspaceIntersection(
        np.vstack((hull1.equations, hull2.equations)), feasible_point
    )

    if vis2d:
        fig = plt.figure()
        ax = fig.add_subplot(1, 1, 1, aspect="equal")
        xlim, ylim = (0, 1), (0, 1)
        ax.set_xlim(xlim)
        ax.set_ylim(ylim)

        for simplex in hull1.simplices:
            ax.plot(points1[simplex, 0], points1[simplex, 1], "r-")

        for simplex in hull2.simplices:
            ax.plot(points2[simplex, 0], points2[simplex, 1], "b-")

        x, y = zip(*hint.intersections)
        ax.plot(x, y, "k^", markersize=8)
        plt.savefig("{}".format(__file__).replace(".py", ".png"))

    return hint.intersections


# %%
def get_hull_centroid(hull: ConvexHull):
    """Returns the centroid of the supplied scipy convex hull object.

    Args:
        hull: a scipy convex hull object

    Returns:
        np.array() of centroids for each axis.

    >>> get_hull_centroid(ConvexHull(np.array([[1.8, 0., 0.],[0. , 0.,  0.], [0., 0., 26.5], [0., 2., 1.]])))
    array([0.45, 0.5, 6.875])
    """

    return np.array(
        [np.mean(hull.points[hull.vertices, i]) for i in range(len(hull.points) - 1)]
    )


# %%
## functions from randomSampling_py that are needed


# %%
def bb_to_cds(bb):
    """Converts bounding box notation to vertex coordinates.

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
def dropZeroColumns(reagents, uniqueChemicalNames=None):
    """Version of dropZeroColumns that includes the uniqueChemicalNames corresponding to only nonzero columns in the reagent dictionary.

    Args:
        reagents: Dictionary defining the reagents.
        uniqueChemicalNames: (optional) Provide a list of unique chemical names.
    Returns:
        Dictionary of reagents with only the nonzero columns, as well as a list of the unique chemical names that correspond to the nonzero columns.
    """
    if uniqueChemicalNames is None:
        d_keys = list(reagents.keys())
        array = np.array(list(reagents.values()))
        new_vals = array[:, array.any(0)]
        return dict(zip(d_keys, new_vals))
    else:
        d_keys = list(reagents.keys())
        array = np.array(list(reagents.values()))
        new_vals = array[:, array.any(0)]
        array = np.array(list(reagents.values()))
        noz_cols = list(
            np.nonzero(np.array([max(array.T[:, i]) for i in range(len(array.T))]))[0]
        )
        noz_chems = list(np.take(np.array(uniqueChemicalNames), noz_cols))
        return [dict(zip(d_keys, new_vals)), noz_chems]


# %%
def allowedExperiments(reagents, maxConcentration, minConcentration):
    """Find the allowed ConvexHull given the reagent definitions and max/min concentration.

    Note that, relative to the Mathematica code, the location of max and min concentration in the function arguments are swapped. This allows for the case where you only want to give a max concentration.

    Because this generates a scipy ConvexHull, it is susceptible to dimensional constraints.

    Args:
        reagents: dictionary of reagent definitions.
        maxConcentration: the maximum concentration imposed.
        minConcentration: the minimum concentration imposed.

    Returns:
        scipy ConvexHull defining the allowed experimental sampling region.
    """
    compositionBoundary = np.array(
        list(reagents.values())
    )  # array of convex hull points
    minMax = []  # list to format imposedBoundary points
    if (type(minConcentration) is list) and (
        type(maxConcentration)
    ) is list:  # run this if both min/max Concentrations are given as lists
        for i in range(len(minConcentration)):  # formats imposedBoundary into coords
            minMax.append([minConcentration[i], maxConcentration[i]])
        imposedBoundary = np.array(minMax)  # array of imposedBoundary points
        return ConvexHull(
            convex_hull_intersection(compositionBoundary, bb_to_cds(imposedBoundary))
        )  # return the intersection convex hull
    else:
        return print("error")  # or print an error


def allowedExperiments(reagents, maxConcentration, minConcentration=None):
    """Find the allowed ConvexHull given the reagent definitions and max/min concentration.

    Note that, relative to the Mathematica code, the location of max and min concentration in the function arguments are swapped. This allows for the case where you only want to give a max concentration.

    Because this generates a scipy ConvexHull, it is susceptible to dimensional constraints.

    Args:
        reagents: dictionary of reagent definitions.
        maxConcentration: the maximum concentration imposed.
        minConcentration: (optional) the minimum concentration imposed (0 otherwise).

    Returns:
        scipy ConvexHull defining the allowed experimental sampling region.
    """
    if (type(maxConcentration) is float) or (
        type(maxConcentration) is int
    ):  # run this if only maxConcentration is given and it's a float or int
        correctDimensionalityVector = [1] * len(np.array(list(reagents.values()))[0])
        compositionBoundary = np.array(list(reagents.values()))
        minMax = []
        minConcVec = [0] * len(correctDimensionalityVector)  # min [] vec is 0's
        maxConcVec = [maxConcentration] * len(
            correctDimensionalityVector
        )  # max [] vec is maxConc repeated to correct dimension
        for i in range(len(correctDimensionalityVector)):
            minMax.append(([minConcVec[i], maxConcVec[i]]))
        imposedBoundary = np.array(minMax)
        return ConvexHull(
            convex_hull_intersection(compositionBoundary, bb_to_cds(imposedBoundary))
        )
    elif (
        type(maxConcentration) is list
    ):  # run this if only maxConcentration is given and it's a list
        compositionBoundary = np.array(list(reagents.values()))
        minMax = []
        minConcVec = [0] * len(maxConcentration)  # min [] vec is 0's
        maxConcVec = maxConcentration  # max [] vec is the list maxConcentration
        for i in range(len(maxConcentration)):
            minMax.append(([minConcVec[i], maxConcVec[i]]))
        imposedBoundary = np.array(minMax)
        return ConvexHull(
            convex_hull_intersection(compositionBoundary, bb_to_cds(imposedBoundary))
        )
    else:
        return print("error")


# %%
def in_hull(points, x):
    """Tests if a point is inside the ConvexHull given by points.

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


# %%
def ConvexSolution(corners, cand):
    """Given the corners (from reagent dictionary) and the concentrations of a single experiment, this finds a convex solution.

    scipy lsq_linear is used, and the non-negative constraint is enforced by the bounds. The sum to 1 constraint is forced by adding a row of all 1's to the coefficient matrix and adding a 1 to the b vector. This seems to work pretty well, but sometimes the solution is very close to 1, but not exactly 1.

    Args:
        corners: Corners defining the reagent space (given by reagent dictionary).
        cand: Vector defining one experiment (this often comes from the results of sampleConcentrations).

    Returns:
        A np.array() corresponding to the solution.
    """
    i_array = np.array(list(corners.values()))
    f_array = np.transpose(i_array)
    f_array = np.vstack([f_array, [1] * len(f_array[0])])
    x = lsq_linear(
        f_array,
        np.append(cand, [1]),
        bounds=(0, np.inf),
        lsq_solver="exact",
        method="bvls",
    )
    return x.x


# %%
def convertConcentrationsToVolumes(reagentDefs, experiments):
    if np.array(experiments).ndim > 1:
        """Converts the concentrations (found by ConvexSolution) into volumes.

        Args:
            reagentDefs: Dictionary defining the reagents.
            experiments: matrix or vector defining specific experiment(s).

        Returns:
            Dictionary of {reagents : volumes}
        """
        reagentNames = np.array(list(reagentDefs.keys()))
        vals = np.transpose(
            np.array([ConvexSolution(reagentDefs, i) for i in np.array(experiments)])
        )
        vals = list(map(list, vals))  # do we want a tuple or list?
        return dict(zip(reagentNames, vals))
    else:
        reagentNames = np.array(list(reagentDefs.keys()))
        vals = np.array(ConvexSolution(reagentDefs, np.array(experiments)))
        vals = list(vals)  # do we want a tuple or list?
        return dict(zip(reagentNames, vals))


# %% [markdown]
# ## Inputs

# %%
reagentVectors = {
    "Reagent2 (ul)": [1.8, 0, 0, 2.3],
    "Reagent3 (ul)": [3.51, 0, 0, 0],
    "Reagent1 (ul)": [0, 0, 0, 0],
    "Reagent7 (ul)": [0, 0, 26.50445361720617, 0],
}


# %%
uniqueChemNames = ["4Hydroxyphenethylammoniumiodide", "DMF", "FAH", "PbI2"]


# %%
rvecs3D = {
    "Reagent2 (ul)": [1.8, 0, 0],
    "Reagent3 (ul)": [0, 0, 0],
    "Reagent1 (ul)": [0, 0, 26.5],
    "Reagent7 (ul)": [0, 2, 1],
}

# %% [markdown]
# #  Enumerative Sampling Code

# %%
def speciesMax(reagents):
    """Finds the max concentration for each species given a dictionary defining the reagents.

    Args:
        reagents: Dictionary defining the reagents.
    Returns:
        np.array() of the max for each species.
    """
    return [max(i) for i in np.array(list(reagents.values())).T]


# %%
def achievableGrid(reagents, maximumConcentration=9.0, deltaV=10.0, totalVolume=500.0):
    """Defines the achievable grid for enumerative sampling.

    Args:
        reagents: Dictionary defining the reagents.
        maximumConcentration: (optional) The maximum imposed concentration (default is 9.).
        deltaV: (optional) The volume increment (default is 10.).
        totalVolume: (optional) The total volume (default is 500.).
    Returns:
        np.array() of the grid points achievable given the hull of reagent space.
    """
    maxes = speciesMax(dropZeroColumns(reagents))
    axisGrids = []
    for i in range(len(maxes)):
        if maxes[i] != 0:
            nSteps = int(((maxes[i] / (maxes[i] * (deltaV / totalVolume))) + 1))
            axisGrids.append(list(np.linspace(maxes[i], 0, nSteps)))
        else:
            axisGrids.append(list(np.linspace(maxes[i], 0, 1)))
    hull = allowedExperiments(dropZeroColumns(reagents), maximumConcentration)
    all_grid_pts = list(itertools.product(*axisGrids))
    bools = np.all(
        np.add(np.dot(all_grid_pts, hull.equations[:, :-1].T), hull.equations[:, -1])
        <= 1e-12,
        axis=1,
    )  # creates boolean array of True/False - in/out of hull
    pts_in_hull = np.array(all_grid_pts)[
        np.where(bools == True)[0]
    ]  # returns coords of pts from grid that are inside the hull
    return pts_in_hull


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

    # error handling: concentrations must be in molarity. otherwise code breaks
    for entry in reagents:
        for key, val in entry.items():
            conc_unit = val.split()[1]
            if units(conc_unit) != units("molar"):
                print(
                    "TypeError: Concentration must be a molarity. Please convert and re-enter."
                )
                sys.exit()

    names = []
    for entry in reagents:
        for key in entry:
            if key not in names:
                names.append(key)  # add all chemicals to list of chemical names
    raw_vectors = {}
    for name in names:
        raw_vectors[
            name
        ] = []  # instantiate a series of vectors where keys are chemical names
        # values are empty lists to which concentrations will be appended

    for (
        name
    ) in names:  # loop through and append concentrations to appropriate values list
        for entry in reagents:
            if name in entry.keys():
                val = entry[name].split()
                raw_vectors[name].append(float(val[0]))
            else:
                raw_vectors[name].append(
                    0.0
                )  # if a chemical is not present, append 0.0 as its concentration

    array = []

    for val in raw_vectors.values():  # create an array of the concentration lists
        array.append(val)

    new_array = np.array(array).transpose()  # transpose the array

    reagent_vectors = {}

    for i in range(
        len(descriptions)
    ):  # generate dictionary with keys=reagent descriptions and vals=concentration vectors
        reagent_vectors[descriptions[i]] = list(new_array[i])

    return reagent_vectors


# %%
def generateEnumerations(
    reagents,
    descriptions,
    dV="10. uL",
    maxMolarity=9.0,
    finalVol="500. uL",
    desiredUnit="uL",
    processValues="round",
):
    """Generates the enumerations for the defined reagents and unique chemical names supplied.

    Args:
        reagents: list of dictionaries, where each list corresponds to a reagent. keys are chemical components and values are concentrations for the components
        descriptions: list of names of reagents, e.g. ['Reagent 1', 'Reagent 2', 'Reagent 3', Reagent 7']
        dV: (optional) The volume increment. (default is 10. uL)
            ***must be input as a string with value and units
        maxMolarity: (optional) The max imposed concentration (default is 9.).
        finalVol: (optional) The final volume (default is 500. uL).
            ***must be input as a string with value and units
        desiredUnit: (optional): The unit in which final volumes should be expressed (default is uL)
        processValues: (optional) Currently only does rounding.

    Returns:
        Nested dictionary {concentrations : {unique_chem_names : np.array() of concentrations}, volumes : {reagents : rounded volumes}}
    """
    # convert reagent input into proper vector format
    reagentDefs = generate_vectors(descriptions, reagents)

    # generate list of chemical names
    uniqueChemNames = []
    for i in reagents:
        for key in i.keys():
            if key not in uniqueChemNames:
                uniqueChemNames.append(key)

    # convert input volumes to microliters, if they aren't already
    v = finalVol.split()
    v1 = Q_(float(v[0]), v[1]).to(units.ul)
    finalVolume = v1.magnitude

    v2 = dV.split()
    v3 = Q_(float(v2[0]), v2[1]).to(units.ul)
    deltaV = v3.magnitude

    nonzeroReagentDefs, nonzeroChemicalNames = dropZeroColumns(
        reagentDefs, uniqueChemNames
    )
    hull = allowedExperiments(nonzeroReagentDefs, maxMolarity)
    concentrationSpaceResults = achievableGrid(
        nonzeroReagentDefs, maxMolarity, deltaV, finalVolume
    )
    dic = convertConcentrationsToVolumes(nonzeroReagentDefs, concentrationSpaceResults)
    for k, v in dic.items():
        dic[k] = tuple(np.round((finalVolume * np.array(v))))
    volumeSpaceResults = dic
    conc_dic = dict(zip(nonzeroChemicalNames, np.transpose(concentrationSpaceResults)))

    desiredUnit = Q_(1, desiredUnit).units

    if desiredUnit != units("ul"):
        for key, val in volumeSpaceResults.items():
            volumeSpaceResults[key] = (Q_(val, "ul")).to(desiredUnit)

    return {"concentrations": conc_dic, "volumes": volumeSpaceResults}
