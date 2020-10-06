from typing import Dict, Tuple
from geopy.distance import geodesic


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
    distance = geodistance(nodes_pair[0], nodes_pair[1], nodes_coord)
    return distance

