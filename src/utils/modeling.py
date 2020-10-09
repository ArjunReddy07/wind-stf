from typing import Dict, Any
from statsmodels.tsa.holtwinters import ExponentialSmoothing
import pandas as pd


class ForecastingModel:
    def __init__(self, modeling: Dict[str, Any]):
        self.modeling = modeling

        self.submodels_ = {}
        self.model_ = None

    def fit(self, df):
        if self.modeling['mode'] == 'districtwise':

            if self.modeling['approach'] == 'HW-ES':
                for district in self.modeling['targets']:
                    self.submodels_[district] = ExponentialSmoothing(df[district], **self.modeling['hyperpars']).fit()

        elif self.modeling['mode'] == 'spatio-temporal':  # i.e. all districts at once

            if self.modeling['approach'] == 'RNN-ES':
                self.model_ = None

            elif self.modeling['approach'] == 'GWNet':
                self.model_ = None

        else:
            raise NotImplementedError('')

        return self

    def predict(self, start, end, scaler):

        if self.modeling['mode'] == 'districtwise':
            yhat = {}
            for district in self.modeling['targets']:
                yhat[district] = self.submodels_[district].predict(
                    start=start,
                    end=end
                )

            yhat = pd.DataFrame(yhat)

            df_preds = pd.DataFrame(
                data=None,
                columns=self.modeling['targets'],
                index=yhat.index,
            )

            df_preds.update(yhat)

            yhat_unscaled = scaler.inverse_transform(yhat)
            return yhat_unscaled[ self.modeling['targets'] ]


        elif self.modeling['mode'] == 'spatio-temporal':
            ...

        else:
            return NotImplementedError('')





