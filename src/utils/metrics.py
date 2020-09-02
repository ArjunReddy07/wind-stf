from sklearn.metrics import mean_squared_error, mean_absolute_error


def rmse(y, y_hat):
    return mean_squared_error(y, y_hat, multioutput='raw_values') ** 0.5


def mae(y, y_hat):
    return mean_absolute_error(y, y_hat, multioutput='raw_values')


metrics = {
    'rmse': rmse,
    'mae': mae,
}