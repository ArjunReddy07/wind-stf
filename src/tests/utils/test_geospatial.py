from src.utils import geospatial
import pytest
from numpy import nan

EPS = 1E-05

@pytest.mark.parametrize('geopt1, geopt2, distance',
                         [
                             (0.53, 0.90, 0.90),
                             (1.00, 0.85, 4.30),
                             (1.00, 0.80, 4.50),
                             (1.00, 1.50, 0.50),
                             (0.63, 1.20, 0.50),
                             (1.00, 2.00, 0.25),
                         ])
def test_get_geodistance_mx(pr, Tr, hdep):
    assert geospatial.get_geodistance_mx(pr=pr, Tr=Tr) == pytest.approx(hdep, abs=1E-06)

