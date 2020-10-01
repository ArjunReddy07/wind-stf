from sklearn.base import BaseEstimator, TransformerMixin


class MakeStrictlyPositive(TransformerMixin, BaseEstimator):
    '''Add constant to variable so that it only assumes positive values.'''

    def __init__(self):
        pass

    def fit(self, X, y=None):
        self.offset_ = X.min(axis=0)
        return self

    def transform(self, X, y=None):
        return X + abs(self.offset_) + 1e-08

    def inverse_transform(self, X, y=None):
        return X - abs(self.offset_) - 1e-08
