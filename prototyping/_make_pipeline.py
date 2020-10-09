import pandas as pd
import numpy as np
from src.utils.preprocessing import make_pipeline, registered_transformers

if __name__ == '__main__':
    preprocessing = ['get_quantile_equivalent_normal_dist', 'make_strictly_positive']

    scaler = make_pipeline(
        *[registered_transformers[step] for step in preprocessing]
    )

    df = capacity_factors_daily_2000to2015 = pd.read_hdf(
        path_or_buf='../data/05_model_input/df_infer.hdf',
        key='df_infer'
    )

    scaler = scaler.fit(df)

    df_scaled = scaler.transform(df)


    # df_unscaled = scaler.inverse_transform(df_scaled)
    # EPS = 1E-08
    # pd.testing.assert_frame_equal(df, df_unscaled, atol=EPS)

    targets = ['DEF0C', 'DE111']
    df_scaled_short = df_scaled[targets]
    df_unscaled_short = scaler.inverse_transform(df_scaled_short)

    print('done!')

    # Xt['DE111'].values
    # dfskeleton['DE111'].values
    #
    # (~np.isnan(Xt)).sum()