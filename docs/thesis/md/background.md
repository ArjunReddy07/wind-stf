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

In \cite{bontempi2013strategies}, Bontenpi et al. define time series as "a sequence of historical measurements $y_t$ of an observable variable $y$ at equal time intervals". An important task in time series analysis is time series forecasting: "prediction of data at future times using observations collected in the past" \cite{hyndman2020principles}.

Time series forecasting tasks can be categorized in terms of (a) inputs, (b) modeling and (c) outputs. In terms of inputs, one can use or not exogenous features, one or more input time series. In terms of modeling, one must define a resolution, can aggregate data in different levels (hierarchical *versus* non-hierarchical), and can use different schemes for generating models (we distinguish conventional from machine learning-based). Finally, regarding outputs, a forecasting task might involve making predictions in terms of single values or whole distributions (deterministic *versus* probabilistic), point-predictions or prediction intervals, predict values for either a single point or for multiple points in future time (one-step-ahead *versus* multi-step-ahead). In this work, we focus on deterministic, one-step-ahead point forecasts. 

In univariate forecasting 

In multivariate forecasting, one aims to predict the value of a variable $y_{T+h}$ on the $h^{th}$ time-index after the last based on measurements for a set of variables $\boldsymbol{X}_{1:T}$ observed from time $t=1$ to $T$.  We denote by $h$ the time horizon for which the prediction is made, i.e. the $h^{th}$ time period after the last observation used to generate the forecasting model.

### 2.2.1 Forecasting Methods

Analogous to AUTHOR in \cite{probabilistic}, we make distinction between method, model and model inference algorithm. A method can specify (1) how training data is used to generate a model (training, model inference, i.e. inference of its parameters) and (2) how a generated model uses its parameters and its input to make a prediction (inference).

Example: simple methods

- naive (random walk model) [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)
- seasonal naive [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)

- drift [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)

$$
\hat{y}_{t+1|t} = y_{t}
$$

getting better results – Generalities: minimizing residuals [[hyndman2020principles]](https://otexts.com/fpp2/accuracy.html)/loss on a training set

- (univariate) conventional 

  - ARIMA
  - ES: from SES to Holt-Winters [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.), [[chen2019dl-tsf](file:///C:/Users/User/Downloads/fvm939e.pdf)]
- hybrid

  - ES-RNN
- DL-based

  - N-BEATS

### 2.2.2 Models Evaluation / Evaluating Models Performance

Splitting dataset into training and test dataset

> separate the available data into two portions, **training** and **test** data, where the training data is used to estimate any parameters of a forecasting method and the test data is used to evaluate its accuracy.  Because the test data is not used in determining the forecasts, it  should provide a reliable indication of how well the model is likely to  forecast on new data. [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)

> Some references describe the test set as the “hold-out set” because  these data are “held out” of the data used for fitting. Other references call the training set the “in-sample data” and the test set the  “out-of-sample data”. We prefer to use “training data” and “test data”  in this book. . [[hyndman2020principles]](Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)

- "training partition", "testing partition" [krispin2019handson]

![training-test-split](https://otexts.com/fpp2/fpp_files/figure-html/traintest-1.png)

Time Series Cross-Validation

![img](https://otexts.com/fpp2/fpp_files/figure-html/cv1-1.png)

Time Series Cross-Validation

#### Metrics

A central requirement for forecasting models is accuracy. It is usual to quantify it in terms of accuracy metrics, which characterize the distribution of *forecast errors* (\cite{hyndman2020principles}). A forecast error expresses by how much a forecast  $\hat{y}_{T+h|T}$ for a point in the test set deviates from its corresponding observed value $y_{T+h}$. It could be expressed as
$$
e_{T+h} = y_{T+h} - \hat{y}_{T+h|T},
$$
for a training dataset $\{y_1,…,y_T\}$ and a test dataset $\{y_{T+1}, y_{T+2},…\}$.

Many different metrics exist, each one conveying one aspect of the error distribution. Some of the most usual definitions  are presented from \ref{eq-rmse} to \{eq-} (see e.g. \cite{wu2019graphwavenet}, \cite{liu2019st-mgcn},  \cite{hyndman2006metrics}). In particular, $MASE$ and $MdRAE$ use as denominator the forecast errors of the naïve model, which takes the last known value to forecast the next point. The naïve model can be shown to be optimal for a random walk process (\cite{hyndman2006metrics}).
$$
RMSE = \sqrt{\mathbb{E}(e_t^2)} = \sqrt{\frac{1}{N}\sum_{t=1}^N e^2_t}
$$

$$
MAE = \mathbb{E}(|e_t|) = \frac{1}{N}\sum_{t=1}^N |e_t|
$$

$$
MAPE = \mathbb{E}(|e_t/y_t|\cdot 100\%) = \frac{100\%}{N}\sum_{t=1}^N \left|\frac{e_t}{y_t}\right|
$$

$$
sMAPE = \frac{100\%}{N}\sum^N_{T=1} \frac{|e_t|}{(|y_{t}|+|\hat{y}_{t}|)/2}
$$

$$
MdAPE = q_{0.5}(|e_t/y_t|\cdot 100\%)
$$

$$
sMdAPE = q_{0.5}\left(200\% \cdot \frac{|e_t|}{y_{t}+\hat{y}_{t}}\right)
$$

$$
MASE = \mathbb{E}\left(\left|\frac{e_t}{e_{t, naïve}}\right|\right)
$$

$$
MdRAE = q_{0.5}\left(\left|\frac{e_t}{e_{t, naïve}} \right|\right)
$$

| alias  | name                                       | scale <br />sensitivity | OUTLIERS<br />SENSITIVITY |
| ------ | ------------------------------------------ | ----------------------- | ------------------------- |
| RMSE   | Root Mean Squared Error                    | $\circle$               | $\circle \circle$         |
| MAE    | Mean Absolute Error                        | $\circle$               | $\circle$                 |
| MASE   | Mean Absolute Scaled Error                 | o                       | $\circle$                 |
| MAPE   | Mean Absolute Percentual Error             | o                       | $\circle$                 |
| MdAPE  | Median Absolute Percentual Error           | o                       | o                         |
| sMAPE  | Symmetric Mean Absolute Percentual Error   | o                       | o                         |
| sMdAPE | Symmetric Median Absolute Percentual Error | o                       | o                         |
| MdRAE  | Median Relative Absolute Error             | o                       | o                         |

Table ???. Forecasting accuracy metrics and their sensitivities to scale and outliers.

By summarizing the forecast error distribution into a reduced set of values, forecasting metrics are essential in model development as well as in method development.  To forecasters (model developers) and forecast users, metrics offer  a concise, unambiguous way to communicate accuracy requirements and specifications. For methods developers, it allows comparing different methods across different use cases, forecasting settings and datasets.

On one hand, single metrics concisely conveys information about the error distribution, which is useful for comparing models and making decisions. On another hand, a single metric cannot convey all aspects of an error distribution, and often using more than one metric becomes necessary to ensure sufficiency (\cite{armstrong2002principles}). Therefore, deciding on a group of metrics often involves a trade-off between conciseness and sufficiency. 

Metrics differ in interpretability, scale invariance, sensitivity to outliers, symmetric penalization of negative and positive errors, and behavior predictability as $y_t \rightarrow 0$ (\cite{hyndman2006metrics}). Therefore, it is imporant that the choice on the metrics set is coherent with the application requirements \cite{armstrong2002principles}. For example, while failing to forecast single sudden peaks in local wind speed (wind gusts) might not be important in wind farm planning, it might be a primary requirement for wind turbine operation. \ref{table-sensitivities} summarizes sensitivities.

Although often the most important one, accuracy is often just one of many requirements in a forecasting model development. In \cite{armstrong2002principles}, Armstrong reports that value inference time, cost savings resulting from improved decisions, interpretability, usability and ease of implementation tend to be of comparable importance to researchers, practitioners and decision makers.

## 2.3 Spatio-Temporal Forecasting

Approaches:

- model TS individually
- model TS together (multivariate TS approach) via Multivariate versions
  - VARIMA
- model ST behavior via DL-methods\cite{armstrong2002principles}
  - DCRNN
  - Graph WaveNet [see liu2020gnn]

### 2.3.1 Metrics

- (spatio-temporal/multivariate version)