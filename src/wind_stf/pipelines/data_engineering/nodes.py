# Copyright 2020 QuantumBlack Visual Analytics Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND
# NONINFRINGEMENT. IN NO EVENT WILL THE LICENSOR OR OTHER CONTRIBUTORS
# BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF, OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# The QuantumBlack Visual Analytics Limited ("QuantumBlack") name and logo
# (either separately or in combination, "QuantumBlack Trademarks") are
# trademarks of QuantumBlack. The License does not grant you any right or
# license to the QuantumBlack Trademarks. You may not use the QuantumBlack
# Trademarks or any confusingly similar mark as a trademark for your product,
# or use the QuantumBlack Trademarks in any other manner that might cause
# confusion in the marketplace, including but not limited to in advertising,
# on websites, or on software.
#
# See the License for the specific language governing permissions and
# limitations under the License.
"""Example code for the nodes in the example pipeline. This code is meant
just for illustrating basic Kedro features.

PLEASE DELETE THIS FILE ONCE YOU START WORKING ON YOUR OWN PROJECT!
"""

from typing import List, Any
import pandas as pd
import nvector as nv


# helper functions
def _parse_datetime():
    return None


def _ensure_same_timespans(
        mts_ref: pd.DataFrame,
        mts: pd.DataFrame,
) -> pd.DataFrame:
    start = mts_ref['date'][0]
    end = mts_ref['date'][-1]
    valid_dates = (
            (mts['date'] > start)
            and
            (mts['date'] < end)
    )
    mts_trimmed = mts.loc[valid_dates, :]
    return mts_trimmed


def _get_centroid(lat: pd.Series, lon: pd.Series) -> tuple:
    # TODO: currently getting centroid of turbines installed anytime. Get centroid for each day instead!
    # TODO: currently getting geospatial centroid. Get power-weighted centroid instead!
    points = nv.GeoPoint(
        latitude=lat.values,
        longitude=lon.values,
    )
    vectors = points.to_nvector()
    centroid_vector = vectors.mean()
    centroid = centroid_vector.to_geo_point()
    return (centroid.latitude_deg, centroid.longitude_deg)


# node functions
def concatenate(*data_single_years: List[pd.DataFrame]) -> pd.DataFrame:  # using inputs of *args type so that any number of dataframes can be used as input
    data_all_years = pd.concat(data_single_years)  # TODO: ensure date | hour format
    return data_all_years


def aggregate_temporally(data_hourly: pd.DataFrame) -> pd.DataFrame:
    data_daily = data_hourly.groupby(
        by=['date'],  # TODO: drop "hour" column
        as_index=False,
    ).agg(func='sum')  # TODO: ensure date | hour format
    return data_daily


def filter_districts(data_all_districts: pd.DataFrame) -> pd.DataFrame:
    blacklist = ['DE409', 'DE40C', 'DE403',     # outliers in spatial correlogram
                 'DE24C', 'DE266', 'DEA2C',]    # zero installed capacity at 2015-01-01
    # TODO: remove districts where any single turbine represents >10% installed capacity
    data_selected_districts = data_all_districts.drop(blacklist, axis='columns')
    return data_selected_districts


def convert_kw_to_capfactor(
        power_generated_daily: pd.DataFrame,
        power_installed_daily: pd.DataFrame,
) -> pd.DataFrame:
    power_installed_daily = _ensure_same_timespans(mts_ref=power_generated_daily, mts=power_installed_daily)
    data_capfactors = power_generated_daily.divide(power_installed_daily, axis='columns')  # TODO: ensure it is dividing same-label columns, regardless of columns ordering
    return data_capfactors


def build_power_installed_mts(sensors: pd.DataFrame) -> pd.DataFrame:
    power_installed = sensors.groupby(by=['NUTS_ID', 'dt'])['power'].cumsum()
    return power_installed


def build_power_centroids_mts(sensors: pd.DataFrame) -> pd.DataFrame:
    power_centroids = sensors.groupby(['NUTS_ID'])['lat', 'lon'].expanding().mean()  # TODO: currently getting geospatial centroid. Get power-weighted centroid instead!
    return power_centroids

