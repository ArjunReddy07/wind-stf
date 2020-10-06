from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.preprocessing import QuantileTransformer


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


registered_transformers = {
    'get_quantile_equivalent_normal_dist': QuantileTransformer(
                                                output_distribution='normal',
                                                random_state=0,
                                            ),
    'make_strictly_positive': MakeStrictlyPositive(),
}