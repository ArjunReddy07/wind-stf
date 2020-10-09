from typing import Dict, Any
from statsmodels.tsa.holtwinters import ExponentialSmoothing
import pandas as pd


class ForecastingModel:
    def __init__(self, modeling: Dict[str, Any]):
        self.modeling = modeling

        self.submodels_ = {}
        self.model_ = None

    def fit(self):

        if self.modeling['mode'] == 'districtwise':

            if self.modeling['approach'] == 'HW-ES':
                for district in self.modeling['targets']:
                    self.submodels_[district] = ExponentialSmoothing(self.df[district], **self.modeling['hyperpars']).fit()

            return self.submodels_

        elif self.modeling['mode'] == 'spatio-temporal':  # i.e. all districts at once

            if self.modeling['approach'] == 'RNN-ES':
                self.model_ = None

            elif self.modeling['approach'] == 'GWNet':
                self.model_ = None

            return self.model_

        else:
            return NotImplementedError('')

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
                columns=scaler.columns,
                index=yhat.index,
            )

            df_preds.update(yhat)


            # y_hat = self.model_.predict(start, end)
            # y_hat_unscaled = scaler.inverse_transform(y_hat)
            # return y_hat_unscaled

            return yhat

        elif self.modeling['mode'] == 'spatio-temporal':
            ...

        else:
            return NotImplementedError('')





