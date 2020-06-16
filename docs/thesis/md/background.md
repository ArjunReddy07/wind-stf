## Our Hypothesis

As 

___



## 2.1 Wind Power Generation

In 1920, Betz (\cite{betz1920maximum}) modeled a wind harvesting system as an open-disc actuator and, by using conservation equations for momentum and energy on a stream tube flowing through this disk, he derived an upper limit for the power harvested by a horizontal-axis wind turbine. The Betz Limit, as it is known, is a function of rotor diameter $D$ (via the rotor swept area $A$)and the average free stream wind velocity $v$ at hub height $H$ (\ref{eq-betz-limit}).
$$
P_{ideal} = \frac{\pi}{2}\rho \cdot A(D)\cdot v^3
$$
Due to generation losses such as (1) momentum deficit in lower atmosphere boundary layer, (2) wakes from neighboring turbines, (3) suboptimal yaw angle and (4) blade tip vortices, the power transmitted from the turbine rotor to the gearbox is only a fraction of this idealized maximum. All these losses are modeled into a *coefficient of power* $C_p$, to yield the actual power generation in the rotor (\ref{eq-power-real-turbine}).
$$
P = C_p \cdot \frac{\pi}{2} \rho \cdot A(D)\cdot v^3
$$
In this equation, $D$ and $H$ are design variables. The air density $\rho$ may vary during operation due to changes in air temperature, but its effects are often negligible. Finally, $C_p$, $v$ depend both on design (e.g. hub height $H$, blade profiles) and operation conditions (e.g. velocity speed and direction). 

In operation, the dominant source of variability for the generated power is $v$. Being climate and weather-dependent, it is also the main reason for the intermittency and non-dispatchability of wind power (\cite{demeo2006natural}): it renders the power harvesting not only intermittent, but also not dispatchable at will. This dependence motivates the usage by designers and operators of the so-called *wind-to-power curves* (or simply *power curves*), which are empirical relations that allow one to determine the generated power $P$ by knowing the wind velocity $v$ .

As design, planning, operation, maintenance and trading wind power are subject to such high variabilities, forecasting wind power generation (WPG) is invaluable at different levels. Table \ref{table-forecasting-reqs} summarizes how different system operation aspects can profit from forecasts at different time scales. Power generation from single turbines can also be aggregated at different levels. Market operators, for example, profit the most from  from regional aggregations, since for energy trading this resolution is high enough, with higher resolutions across the same space scales of interests often too costly (\cite{jung2014forecasting}). In particular for countries such as Germany, where continental and national renewables-promoting public funding initiatives such as the *Energiewende* resulted in a high penetration of wind power in the grid, being able to accurately forecast wind power generation has tangible impact both environmentally and economically.

| Very short <br />($\sim secs\ - 0.5h $) | short <br />($0.5h - 72h$) | medium<br />($72h\ – 1\ week $)               | long<br />($1\ week\  – 1\ year $) |
| --------------------------------------- | -------------------------- | --------------------------------------------- | ---------------------------------- |
| turbine control, <br />load tracking    | pre-load sharing           | power system management, <br />energy trading | turbines maintenance scheduling    |

Table ???. How WPG forecasting can generate value for operators, according to forecasting horizon (\cite{jung2014forecasting}). 

The intermittency of renewables motivated an alternative representation for the power generation: the *capacity factor* (CF). CF is defined as the ratio of the actual generated power and the installed capacity. When considering WPG data across long timespans for both analysis and forecasting, it is usual that new commissionings take place, which manifests as a step disturbance into the overall generated power. In this case, CF can be useful as it is mostly insensitive to single new commissionings. 

Climate and weather-conditioned local wind velocities imply for the power generation not only significant temporal dependencies, but also significant spatial dependencies. As air masses influence one another in different scales, wind power generation in neighboring turbines tend to present higher correlations than turbines distant from one another (\cite{engeland2017variability}). Therefore, wind power generation is a phenomenon with dominant spatio-temporal dependencies.

## 2.2 Time Series Forecasting

In \cite{bontempi2013strategies}, Bontenpi et al. define time series as "a sequence of historical measurements $y_t$ of an observable variable $y$ at equal time intervals". An important task in time series analysis is time series forecasting: "prediction of data at future times using observations collected in the past" \cite{hyndman2020principles}.

Time series forecasting tasks can be categorized in terms of (a) inputs, (b) modeling and (c) outputs. In terms of inputs, one can use exogenous features or not, one or more input time series (univariate *versus* multivariate). In terms of modeling, one must define a resolution (e.g. hourly, weekly), can aggregate data in different levels (hierarchical *versus* non-hierarchical), and can use different schemes for generating models (we distinguish conventional from machine learning-based). Finally, regarding outputs, a forecasting task might involve making predictions in terms of single values or whole distributions (deterministic *versus* probabilistic), point-predictions or prediction intervals, predict values for either a single point or for multiple points in future time (one-step-ahead *versus* multi-step-ahead). In this work, we focus on deterministic, one-step-ahead point forecasts. 

In *univariate forecasting*, one aims to predict the value of a variable $y_{T+1}$ based on measurements $\boldsymbol{y} _{1:T} = \{y_1,…,y_T\}$. We denote by $\hat{y}_{T+1}$ the forecast value. More generally, one might be interested in forecasting for the  $h^{th}$ time period ahead. For a given task, $h$ is often referred to as the *forecast horizon*. In contrast to the univariate setting, *multivariate forecasting* models rely on historical observations not from a single but from several input variables, which can be expressed by a sequence of input vectors $\boldsymbol{X}_{1:T} = \{\boldsymbol{X}_1, ..., \boldsymbol{X}_T\}$. 

### 2.2.1 Forecasting Methods

Analogous to Murphy in \cite{murphy2012probabilistic}, we distinguish the concepts of method, model and model inference algorithm. A method can specify (1) how training data is used to generate a model (training, model inference, i.e. inference of its parameters) and (2) how a generated model uses its parameters and its input to make a prediction (inference).

We start by presenting simple forecasting methods, which are often used as baseline for other methods (\cite{hyndman2020principles}).

**Historical Average (HA) **method: forecasts assume all a constant value: the average of the historical data:
$$
\hat{y}_{T+h|T} = \frac{1}{T}\sum_{t=1}^Ty_t .
$$
**Naïve** method: this constant is the value from the last observation (\ref{eq-naive}). As the naïve forecast is the optimal prediction for a random walk process, it is also known as *random walk* method.
$$
\hat{y}_{T+h|T} = y_T
$$
**Seasonal** **Naïve** method: models the time series as harmonic with period $k$ observations (i.e. perfectly seasonal with seasonal period $k$), and for a given point  in future, suggest as forecast the last observed value from the same season (\ref{eq-snaive}). For example, all forecasts for future June values assume the value from the last observed June value. 
$$
\hat{y}_{T+h|T} = y_{T+h-k}
$$
**Drift** method: analogous to the naïve method, with the constant being not the  the last observed value itself but the average rate of change. 
$$
\hat{y}_{T+h|T} = y_{T} + h\left(\frac{y_T-y_1}{T-1} \right)
$$

- desired properties of residuals
  - uncorrelated, as any correlation in residuals indicate 
  - zero mean 

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

Why spatio-temporal forecasting

This spatio-temporal dependency in power generation thus suggests spatio-temporal   

Approaches:

- model TS individually
- model TS together (multivariate TS approach) via Multivariate versions
  - VARIMA
- model ST behavior via DL-methods\cite{armstrong2002principles}
  - DCRNN
  - Graph WaveNet [see liu2020gnn]

### 2.3.1 Metrics

- (spatio-temporal/multivariate version)