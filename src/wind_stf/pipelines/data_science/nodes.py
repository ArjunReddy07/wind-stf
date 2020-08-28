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

Delete this when you start working on your own Kedro project.
"""
# pylint: disable=invalid-name

import logging
from typing import Any, Dict, List

import numpy as np
import pandas as pd
from sklearn.preprocessing import QuantileTransformer
from statsmodels.tsa.holtwinters import ExponentialSmoothing


def _sort_col_level(df: pd.DataFrame, levelname:str ='nuts_id'):
    target_order = df.columns.sortlevel(level=levelname)[0]
    df = df[target_order]
    return df


def _get_districts(df: pd.DataFrame) -> set:
    return set(df.columns.get_level_values('nuts_id'))

# def train_


def build_spatiotemporal_dataset(
        df_spatial: pd.DataFrame,
        df_temporal: pd.DataFrame,
) -> pd.DataFrame:

    # sort districts order in dataframes for easier dataframes tabular visualization.
    df_spatial = _sort_col_level(df_spatial, 'nuts_id')
    df_temporal = _sort_col_level(df_temporal, 'nuts_id')

    # build spatiotemporal dataframe via concatenatation
    df_spatiotemporal = pd.concat(
        {'spatial': df_spatial, 'temporal': df_temporal},
        axis=1,  # column-wise concatenation
        join='inner',  # only timestamps in both df's are included
    )
    df_spatiotemporal.columns.names = ['data_type', 'district', 'var']

    # include only districts present in both df_temporal and df_spatial
    districts_to_include = set(
        _get_districts(df_temporal).intersection(
            _get_districts(df_spatial))
    )

    df_spatiotemporal = df_spatiotemporal.loc[
        :,
        (slice(None), districts_to_include)
    ]

    return df_spatiotemporal


def _split_train_test(df: pd.DataFrame, cv_splits_dict: Dict, pass_id: str) -> Dict[str, Any]:
    train_idx_start = cv_splits_dict[pass_id]['train_idx'][0]
    train_idx_end = cv_splits_dict[pass_id]['train_idx'][1]

    test_idx_start = cv_splits_dict[pass_id]['test_idx'][0]
    test_idx_end = cv_splits_dict[pass_id]['test_idx'][1]

    return {
        'train': df.iloc[train_idx_start:train_idx_end, :],
        'test': df.iloc[test_idx_start:test_idx_end, :],
    }


def get_split_positions(cv_pars: Dict) -> Dict[str, Any]:  # Dict[str, List[pd.date_range, List[str]]]:
    """
    Example of Cross-Validation Splits Dictionary:

    cv_splits_dict = {
        'pass_1': {
            'train_idx': [0, 365],
            'test_idx': [365, 465],
        }
    }

    :param window_size_first_pass:
    :param window_size_last_pass:
    :param n_passes:
    :param forecasting_window_size:
    :return:
    """
    window_size_first_pass = cv_pars['window_size_first_pass']
    window_size_last_pass = cv_pars['window_size_last_pass']
    n_passes = cv_pars['n_passes']
    forecasting_window_size = cv_pars['forecasting_window_size']

    cv_splits_dict = {}
    window_size_increment = int( (window_size_last_pass - window_size_first_pass) / (n_passes-1) )
    for p in range(n_passes):
        pass_id = 'pass_' + str(p + 1)
        cv_splits_dict[pass_id] = {
                'train_idx': [
                    0,
                    window_size_first_pass + p * window_size_increment
                ],
                'test_idx': [
                    window_size_first_pass + p * window_size_increment,
                    window_size_first_pass + p * window_size_increment + forecasting_window_size,
                ],
        }
    return cv_splits_dict


def _get_last_train_idx(tss: pd.DataFrame, cv_splits_dict: dict):
    longest_pass = list( cv_splits_dict.keys() )[-1]
    y = _split_train_test(tss, cv_splits_dict, pass_id=longest_pass)
    return y['train'].index[-1]


def scale_offset_timeseries(df_spatiotemporal: pd.DataFrame, cv_splits_dict: dict, level_offset: int, target_timeseries: list) -> pd.DataFrame:
    quantile_transformer = QuantileTransformer(
        output_distribution='normal',
        random_state=0
    )

    tss = df_spatiotemporal['temporal']

    last_train_idx = _get_last_train_idx(tss, cv_splits_dict)
    quantile_transformer.fit(
        tss.loc[:last_train_idx,
        target_timeseries
        ]
    )

    tss_scaled = pd.DataFrame(
        index=tss.index,
        columns=target_timeseries,
        data=quantile_transformer.transform(tss[target_timeseries]) + level_offset
    )

    df_spatiotemporal['temporal'] = tss_scaled

    return df_spatiotemporal


def train(df_spatiotemporal: pd.DataFrame,
          cv_splits_dict: Dict[str, Any],
          modeling: Dict[str, Any]) -> Dict[str, Any]:

    tss_scaled = df_spatiotemporal['temporal']

    model = {}
    for pass_id in cv_splits_dict.keys():

        model[pass_id] = {}

        # splitting
        y = _split_train_test(tss_scaled, cv_splits_dict, pass_id)

        # training
        for district in tss_scaled.columns:
            model[pass_id][district] = ExponentialSmoothing(
                y['train'][district],
                trend=modeling['trend'],
                seasonal=modeling['seasonal'],
                seasonal_periods=modeling['seasonal_periods'],
            ).fit()

    return {
        'model': model,
        'model_metadata': modeling,
    }


def predict(model_metadata: Any, cv_splits_dict: Dict[str, Any]) -> Dict[str, np.ndarray]:
    pred = {}
    pred[district][pass_id] = model[district][pass_id].predict(
        start=y['test'].index.values[0],
        end=y['test'].index.values[1]
    )
    return {
        'train_y_hat': None,
        'test_y_hat': None,
    }


def report_scores(scoreboard: pd.DataFrame, model_metadata: Any, train_y_hat: np.ndarray, test_y_hat: np.ndarray):
    # TODO: use metrics from metrics.py
    scoreboard_new = None


def split_data(data: pd.DataFrame, example_test_data_ratio: float) -> Dict[str, Any]:
    """Node for splitting the classical Iris data set into training and test
    sets, each split into features and labels.
    The split ratio parameter is taken from conf/project/parameters.yml.
    The data and the parameters will be loaded and provided to your function
    automatically when the pipeline is executed and it is time to run this node.
    """
    data.columns = [
        "sepal_length",
        "sepal_width",
        "petal_length",
        "petal_width",
        "target",
    ]
    classes = sorted(data["target"].unique())
    # One-hot encoding for the target variable
    data = pd.get_dummies(data, columns=["target"], prefix="", prefix_sep="")

    # Shuffle all the data
    data = data.sample(frac=1).reset_index(drop=True)

    # Split to training and testing data
    n = data.shape[0]
    n_test = int(n * example_test_data_ratio)
    training_data = data.iloc[n_test:, :].reset_index(drop=True)
    test_data = data.iloc[:n_test, :].reset_index(drop=True)

    # Split the data to features and labels
    train_data_x = training_data.loc[:, "sepal_length":"petal_width"]
    train_data_y = training_data[classes]
    test_data_x = test_data.loc[:, "sepal_length":"petal_width"]
    test_data_y = test_data[classes]

    # When returning many variables, it is a good practice to give them names:
    return dict(
        train_x=train_data_x,
        train_y=train_data_y,
        test_x=test_data_x,
        test_y=test_data_y,
    )
