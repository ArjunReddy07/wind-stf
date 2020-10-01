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
from typing import Any, Dict, List, Tuple

from utils.metrics import metrics

import numpy as np
import pandas as pd
from sklearn.preprocessing import QuantileTransformer
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from src.utils.preprocessing import MakeStrictlyPositive
from sklearn.pipeline import make_pipeline


REGISTERED_TRANSFORMERS = {
    'get_quantile_equivalent_normal_dist': QuantileTransformer(
                                                output_distribution='normal',
                                                random_state=0,
                                            ),
    'make_strictly_positive': MakeStrictlyPositive(),
}


def _sort_col_level(df: pd.DataFrame, levelname:str ='nuts_id'):
    target_order = df.columns.sortlevel(level=levelname)[0]
    df = df[target_order]
    return df


def _get_districts(df: pd.DataFrame) -> set:
    return set(df.columns.get_level_values('nuts_id'))


def _split_train_test(df: pd.DataFrame, train_window, test_window):
    train = slice(
        train_window['start'],
        train_window['end']
    )

    test = slice(
        test_window['start'],
        test_window['end']
    )
    return {
        'df_train': df[train],
        'df_test': df[test]
    }


def split_modinfer_test(df: pd.DataFrame, modeling: dict) -> Tuple[Any, Any]:
    infer_window = modeling['model_inference_window']
    test_window = modeling['test_window']

    infer = slice(
        infer_window['start'],
        infer_window['end']
    )

    test = slice(
        test_window['start'],
        test_window['end']
    )

    return df[infer], df[test]


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


def _get_last_train_idx(tss: pd.DataFrame, cv_splits_dict: dict):
    longest_pass = list( cv_splits_dict.keys() )[-1]
    y = _split_train_test(tss, cv_splits_dict, pass_id=longest_pass)
    return y['train'].index[-1]


def _load_model():
    pass


def define_cvsplits(kwargs) -> Dict[str, Any]:  # Dict[str, List[pd.date_range, List[str]]]:
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

    cv_method = kwargs.get('method')

    if cv_method == 'expanding window':
        window_size_first_pass = kwargs.get('window_size_first_pass')
        window_size_last_pass = kwargs.get('window_size_last_pass')
        n_passes = kwargs.get('n_passes')
        forecasting_window_size = kwargs.get('forecasting_window_size')

        cv_splits_dict = {}
        window_size_increment = int((window_size_last_pass - window_size_first_pass) / (n_passes - 1))
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
    else:
        cv_splits_dict = None
        NotImplementedError(f'CV method not recognized: {cv_method}')

    return cv_splits_dict


def scale(df_infer: pd.DataFrame, modeling: List[str]) -> List[Any]:
    preprocessing = modeling['preprocessing']

    # instantiate pipeline with steps defined in preprocessing params
    scaler = make_pipeline(
        *[REGISTERED_TRANSFORMERS[step] for step in preprocessing]
    )

    scaler = scaler.fit(
        df_infer
    )

    # transformation output is a numpy array
    df_infer_scaled = pd.DataFrame(
        index=df_infer.index,
        columns=df_infer.columns,
        data=scaler.transform( df_infer )
    )

    return [df_infer_scaled, scaler]


def train(df: pd.DataFrame,
          cv_splits_dict: Dict[str, Any],
          modeling: Dict[str, Any]
          ) -> Dict[str, Any]:

    hyperpars = modeling['hyperpars']
    targets = modeling['targets']
    mode = modeling['mode']

    if mode == 'temporal':
        df = df['temporal']

    # ignore all vars we don't want to model
    df = df[targets]

    model = {}
    for pass_id in cv_splits_dict.keys():

        model[pass_id] = {}

        # splitting
        y = _split_train_test(df, cv_splits_dict, pass_id)

        # training
        for district in df.columns:
            model[pass_id][district] = ExponentialSmoothing(
                y['train'][district],
                **hyperpars,
            ).fit()

    return model


def _predict(model_metadata: Any, forecasting_idx, targets: list) -> Dict[str, np.ndarray]:
    # model = _load_model(model_metadata)
    #
    # test_idx = cv_splits_dict['y_train']
    #
    # pred = {}
    # pred_scaled = {}
    #
    # for pass_id in cv_splits_dict.keys():
    #
    #     pred_scaled[pass_id] = {}
    #
    #     for district in tss_scaled.columns:
    #         # prediction
    #         pred_scaled[pass_id][district] = model[pass_id][district].predict(
    #             start=test_idx[0],
    #             end=test_idx[-1]
    #         )
    #
    #     # postprocessing prediction
    #     pred[pass_id] = pd.DataFrame(
    #         data=quantile_transformer.inverse_transform(
    #             pd.DataFrame(pred_scaled[pass_id]) - 10
    #         ),
    #         columns=tss_scaled.columns,
    #         index=test_idx,
    #     )
    #
    # return {
    #     'y_hat': None,
    # }
    pass


def _unscale_predictions(model_metadata: Any):
    pass


def _convert_CFtokW():
    pass


def _evaluate_model(_model_metadata: Any, _cv_splits_dict: dict) -> dict:
    pass


def _update_scoreboard():
    pass


def report_scores(scoreboard: pd.DataFrame, model_metadata: Any, cv_splits_dict: dict):
    # TODO: use metrics from utils/metrics.py
    model_scores = _evaluate_model(model_metadata, cv_splits_dict)
    _update_scoreboard(model_scores)
