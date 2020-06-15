## 2.1 Wind Power Generation

- Pideal = The Betz Limit (D, v³)
- Preal = Cp(generation losses due to lower atmosphere bound. layer, sub-optimal yaw, wake from neighboring turbines, etc.)*(Betz Limit) <- the power transmitted to the gearbox 
- Operation-independent / design variables/parameters: \rho, D, H
- Operational variables: Cp, v³ 
- v³: dominant parameter for Preal, main reason for *intermittency* & non-*dispatchability* of wind power, thus also main reason for forecasting; also main reason for spatio-temporal dependency of WPG
- Using v to determine power generation via *power curves* (a.k.a. wind-to-power curves)
- a useful definition: Capacity Factor
- turbine: power / rated power
  - group of turbines (e.g. wind farm, district):  power / installed power

## 2.2 Time Series Forecasting

> **Time series forecasting** (...) concerns prediction of data at future times using observations  collected in the past. [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)

> Most machine learning algorithms have **hyperparameters**, settings that we can use to control the algorithm’s behavior. The values of hyperparameters are not adapted by the **learning algorithm** itself (though we can design a nested learning procedure in which one learning algorithm learns the best hyperparameters for another learning algorithm). [[goodfellow2016deep]](https://www.deeplearningbook.org/contents/ml.html)

### 2.2.1 Forecasting Methods

- simple methods

  - naive (random walk model) [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)
    $$
    \hat{y}_{t+1|t} = y_{t}
    $$
    

  - seasonal naive [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)

  - drift [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)

- (univariate) conventional 

  - ARIMA
  - ES: from SES to Holt-Winters [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.), [[chen2019dl-tsf](file:///C:/Users/User/Downloads/fvm939e.pdf)]

- hybrid

  - ES-RNN

- DL-based

  - N-BEATS

### 2.2.2 Evaluating Models Performance

Splitting dataset into training and test dataset

> separate the available data into two portions, **training** and **test** data, where the training data is used to estimate any parameters of a forecasting method and the test data is used to evaluate its accuracy.  Because the test data is not used in determining the forecasts, it  should provide a reliable indication of how well the model is likely to  forecast on new data. [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)

> Some references describe the test set as the “hold-out set” because  these data are “held out” of the data used for fitting. Other references call the training set the “in-sample data” and the test set the  “out-of-sample data”. We prefer to use “training data” and “test data”  in this book. . [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)

- "training partition", "testing partition" [krispin2019handson]

![training-test-split](https://otexts.com/fpp2/fpp_files/figure-html/traintest-1.png)

Time Series Cross-Validation

![img](https://otexts.com/fpp2/fpp_files/figure-html/cv1-1.png)

#### Metrics

- Forecast Errors
- Examples: RMSE, MAPE, ... 

#### Procedures

- Time Series Cross-Validation

## 2.3 Spatio-Temporal Forecasting

Approaches:

- model TS individually
- model TS together (multivariate TS approach) via Multivariate versions
  - VARIMA
- model ST behavior via DL-methods
  - DCRNN
  - Graph WaveNet

### 2.3.1 Metrics

- (spatio-temporal/multivariate version)