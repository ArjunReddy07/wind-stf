from typing import Dict, Tuple, List
from geopy.distance import geodesic
import numpy as np
import pandas as pd
from itertools import combinations


def geodistance(nodeA: str, nodeB: str, nodes_coords: Dict[str, Tuple]) -> float:
    """

    :param nodeA: node name registered in nodes_coords, e.g. 'DE111'
    :param nodeB: node name registered in nodes_coords, e.g. 'DEF0C
    :param nodes_coords: dictionary in format node_name: (lat, lon)
      example:
    :return: geodesic distance in km btw nodeA and nodeB

    Example:
    nodeA = 'DE111'
    nodeB = 'DEF0C'
    nodes_coords = {
        'DE111': (48.83101796, 9.09743219),
        'DEF0C': (54.63173774352925, 9.39593596801835),
        'DEF08': (54.30476287841092, 10.990861264961348),
    }

    geodistance(nodeA, nodeB, nodes_coords) >>>  645.727618989127
    """
    nodeA_coords = nodes_coords[nodeA]
    nodeB_coords = nodes_coords[nodeB]
    distance = geodesic(nodeA_coords, nodeB_coords, ellipsoid='WGS-84').km
    return distance


def geodistance_from_pair(nodes_pair: Tuple[str], nodes_coord: Dict[str, Tuple]) -> float:
    """

    :param nodes_pair: pair of node names (tuple), both registered in nodes_coord
    :param nodes_coord: dictionary in format node_name: (lat, lon)
    :return: geodesic distance in km btw nodeA and nodeB

    Example:
    nodeA = 'DE111'
    nodeB = 'DEF0C'
    nodes_coords = {
        'DE111': (48.83101796, 9.09743219),
        'DEF0C': (54.63173774352925, 9.39593596801835),
        'DEF08': (54.30476287841092, 10.990861264961348),
    }

    geodistance_from_pair(nodes_pair=(nodeA, nodeB), nodes_coords) >>>  645.727618989127

    """
    nodeA, nodeB = nodes_pair[0], nodes_pair[1]
    return geodistance(nodeA, nodeB, nodes_coord)


def build_distances_mx(targets: List[str], nodes_coords: Dict[str, Tuple[float]]) -> pd.DataFrame:
    """

    :param targets: list of node names being modeled
    :param nodes_coords:
    :return:

    Example:

            DE111 	    DEF0C 	    DEF08
    DE111 	0.000000 	645.727619 	622.931654
    DEF0C 	645.727619 	0.000000 	109.626399
    DEF08 	622.931654 	109.626399 	0.000000
    """
    # unless a list of selected nodes is provided, all nodes registered are used
    if targets is None:
        targets = nodes_coords.keys()

    # initialize distance mx
    distances_mx = pd.DataFrame(
        columns=targets,
        index=targets,
        data=np.nan,
    )

    # get all pairwise combinations of target names
    node_pairs = list(combinations(targets, 2))

    # calculate pairwise distances for upper triangle
    for pair in node_pairs:
        nodeA, nodeB = pair[0], pair[1]
        distances_mx.loc[nodeA, nodeB] = geodistance_from_pair(pair, nodes_coords)

    # mirror upper into lower triangle
    distances_mx.update(distances_mx.T)  # distance B-A = distance A-B

    # fill diagonal with zeroes
    np.fill_diagonal(distances_mx.values, 0.0)  # distance A-A = 0.0

    return distances_mx