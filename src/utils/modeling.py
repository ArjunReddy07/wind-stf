class ForecastingModel:
    def __init__(self, y_train, modeling, mode, inference, hyperpars):
        self.hyperpars = modeling
        self.y_train = y_train

        self.targets = self.hyperpars['targets']
        if self.targets == 'all_available':
            self.targets = y_train.columns

    def fit(self):

        if self.modeling['mode'] == 'temporal':  # i.e. districtwise
            self.submodels_ = {
                district:
                    ForecastingModel(
                        self.y_train['temporal'][district],
                        hyperpars=self.modeling['inference']
                    ).fit() for district in self.targets
            }

        elif self.modeling['mode'] == 'spatio-temporal':  # i.e. all districts at once

            if self.modeling['inference']['approach'] == 'RNN-ES':
                self.model_ = None

            elif self.modeling['inference']['approach'] == 'GWNet':
                self.model_ = None

        else:
            return NotImplementedError('')
        return self

    def predict(self, start, end, transformer):
        y_hat = self.model_.predict(start, end)
        y_hat_unscaled = transformer.inverse_transform(y_hat)
        return y_hat_unscaled