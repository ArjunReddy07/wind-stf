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


def _sort_col_level(df: pd.DataFrame, levelname:str ='nuts_id'):
    target_order = df.columns.sortlevel(level=levelname)[0]
    df = df[target_order]
    return df


def _get_districts(df: pd.DataFrame) -> set:
    return set(df.columns.get_level_values('nuts_id'))


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
        axis=1,
        join='inner',
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


def get_split_positions(n_splits: int, df: pd.DataFrame) -> Dict[str, Any]:  # Dict[str, List[pd.date_range, List[str]]]:
    cv_splits_dict = {
        'splits1': {
            'train_x_idx': None,
            'train_y_idx': None,
            'test_x_idx': None,
            'test_y_idx': None,
        }
    }
    return cv_splits_dict


def train_model(df: pd.DataFrame, cv_splits_dict: Dict[str, Any], hyperparams: Dict[str, Any]) -> Dict[str, Any]:
    return {
        'model': None,
        'model_metadata': None,
    }


def predict(model_metadata: Any, cv_splits_dict: Dict[str, Any]) -> Dict[str, np.ndarray]:
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
