from typing import Dict, Any
from statsmodels.tsa.holtwinters import ExponentialSmoothing


class ForecastingModel:
    def __init__(self, df, modeling: Dict[str, Any]):
        self.modeling = modeling
        self.df = df
        self.targets = df.columns
        self.submodels_ = {}
        self.model_ = None

    def fit(self):

        if self.modeling['mode'] == 'districtwise':

            if self.modeling['approach'] == 'HW-ES':
                self.submodels_ = {
                    district: ExponentialSmoothing(self.df[district], **self.modeling['hyperpars'])
                    for district in self.targets
                }
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
        y_hat = self.model_.predict(start, end)
        y_hat_unscaled = scaler.inverse_transform(y_hat)
        return y_hat_unscaled



