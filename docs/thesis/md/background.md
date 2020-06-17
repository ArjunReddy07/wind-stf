## Our Hypothesis

As 

___



## 2.1 Wind Power Generation

In 1920, Betz (\cite{betz1920maximum}) modeled a generic wind harvesting system as an open-disc actuator and, by using energy conservation equation for a stream tube flowing through this disk, he derived an upper limit for the power harvested by a horizontal-axis wind turbine. The *Betz Limit*, as it is known, is a function of rotor diameter $D$ (via the rotor swept area $A$) and the average free stream wind velocity $v$ at hub height $H$ (\ref{eq-betz-limit}).
$$
P_{ideal} = \frac{1}{2}\rho \cdot A(D)\cdot v^3
$$
Due to losses such as those associated to (1) momentum deficit in lower atmosphere boundary layer, (2) wakes from neighboring turbines, (3) suboptimal yaw angle and (4) blade tip vortices, the power harvested by the turbine rotor is only a fraction $C_p$ (coefficient of power) of this idealized maximum. Further  losses (a) of mechanical nature in the interfaces rotor-gearbox and gearbox-generator, (b) of electrical nature in the interface generator-converter  are modeled by the fractions $\eta_{m}$ and $\eta_{e}$, respectively,  to yield the actual power generation as measured by the power converter, \ref{eq-power-real-turbine} (\cite{albadi2009capacity}).
$$
P = C_p\eta_{m} \eta_{e}  \cdot \frac{1}{2}\rho \cdot A(D)\cdot v^3
$$
In this equation, $D$ and $H$ are design variables. The air density $\rho$ may vary during operation due to changes in air temperature, but its effects are often negligible. Finally, $C_p$, $v$ depend both on design (e.g. hub height $H$, blade profiles) and operation conditions (e.g. velocity speed and direction). 

![https://www.researchgate.net/profile/Marcelo_Molina/publication/221911675/figure/fig2/AS:304715268149248@1449661189252/General-description-of-a-wind-turbine-system-The-appropriate-voltage-level-is-related-to.png](https://www.researchgate.net/profile/Marcelo_Molina/publication/221911675/figure/fig2/AS:304715268149248@1449661189252/General-description-of-a-wind-turbine-system-The-appropriate-voltage-level-is-related-to.png)

Fig ???. The different stages of the overall wind power conversion process (adapted from \cite{}). 

In operation, the dominant source of variability for the generated power is $v$. Being climate and weather-dependent, it is also the main reason for the intermittency and non-dispatchability of wind power (\cite{demeo2006natural}). Moreover, this dependence motivates the usage by designers and generation operators of the so-called *wind-to-power curves* (or simply *power curves*), which are empirical relations that allow one to determine the generated power $P$ by knowing the wind velocity $v$ .

As design, planning, operation, maintenance and trading of wind power are subject to such high variabilities, forecasting wind power generation (WPG) provides value for the different players in the electricity grid, illustrated in \ref{fig-electricity-grid-players}.  Table \ref{table-forecasting-reqs} summarizes how different system operation aspects can profit from forecasts at different time scales. Power generation from single turbines can also be aggregated at different levels. 

- energy balance: preventing supply shortages and changes in frequency.

Market operators, for example, profit the most from  from regional aggregations, since for energy trading this resolution is high enough, with higher resolutions across the same space scales of interests often too costly (\cite{jung2014forecasting}). In particular for countries such as Germany, where continental and national renewables-promoting public funding initiatives such as the *Energiewende* resulted in a high penetration of wind power in the grid, being able to accurately forecast wind power generation has tangible impact both environmentally and economically.

| Very short <br />($\sim secs\ - 0.5h $) | short <br />($0.5h - 72h$) | medium<br />($72h\ – 1\ week $)               | long<br />($1\ week\  – 1\ year $) |
| --------------------------------------- | -------------------------- | --------------------------------------------- | ---------------------------------- |
| turbine control, <br />load tracking    | pre-load sharing           | power system management, <br />energy trading | turbines maintenance scheduling    |

Table ???. How WPG forecasting can generate value for generation operators, according to forecasting horizon (\cite{jung2014forecasting}). 

The intermittency of renewables motivated an alternative measure of power generation: the *capacity factor* (CF). CF is defined as the ratio of the actual generated power and the installed capacity. When considering WPG data across long timespans for both analysis and forecasting, it is usual that new commissionings take place, which manifests itself as a step perturbation into the overall generated power. In this case, CF can be useful as it is mostly insensitive to single new commissionings. 

Climate and weather-conditioned local wind velocities imply for the power generation not only significant temporal dependencies, but also significant spatial dependencies. As air masses influence one another in different scales, wind power generation in neighboring turbines tend to present higher correlations than turbines distant from one another (\cite{engeland2017variability}). Therefore, wind power generation is a phenomenon with dominant spatio-temporal dependencies.

\cite{} Different approaches exist for forecasting wind power generation

## 2.2 Time Series Forecasting

In \cite{brockwell2016intro}, Brockwell & Davis define time series as "a set of observations $y_t$, each one being recorded at a specific time $t$". When observations are recorded at discrete times, they are called a discrete-time time series, on which we focus this work. 

An important task in time series analysis is time series forecasting: "prediction of data at future times using observations collected in the past" \cite{hyndman2018principles}. Time series forecasting permeates most aspects of modern business, such as business planning from production to distribution, to finance and marketing, inventory control and customer management (\cite{oreshkin2020nbeats}). In some business use cases, a single point in forecasting accuracy may represent millions of dollars (\cite{kahn2003apudOreshkin}, \cite{jain2017apudOreshkin}).  

Time series forecasting tasks can be categorized in terms of (a) inputs, (b) modeling and (c) outputs. In terms of inputs, one can use exogenous features or not, one or more input time series (univariate *versus* multivariate). In terms of modeling, one must define a resolution (e.g. hourly, weekly), can aggregate data in different levels (hierarchical *versus* non-hierarchical), and can use different schemes for generating models (we distinguish conventional from machine learning-based). Finally, regarding outputs, a forecasting task might involve making predictions in terms of single values or whole distributions (deterministic *versus* probabilistic), point-predictions or prediction intervals, predict values for either a single point or for multiple points in future time (one-step-ahead *versus* multi-step-ahead). In this work, we focus on deterministic, one-step-ahead point forecasts. 

In *univariate forecasting*, one aims to predict the value of a variable $y_{T+1}$ based on measurements $\boldsymbol{y} _{1:T} = \{y_1,…,y_T\}$. We denote by $\hat{y}_{T+1}$ the forecast value. More generally, one might be interested in forecasting for the  $h$ time period ahead. For a given task, $h$ is often referred to as the *forecast horizon*. In contrast to the univariate setting, *multivariate forecasting* models rely on historical observations not from a single but from several input variables, which can be expressed by a sequence of input vectors $\boldsymbol{X}_{1:T} = \{\boldsymbol{X}_1, ..., \boldsymbol{X}_T\}$. 

### 2.2.1 Forecasting Methods

Analogous to Murphy in \cite{murphy2012probabilistic}, we distinguish the concepts of method, model and model inference algorithm. A method can specify (1) how training data is used to generate a model (training, model inference, i.e. inference of its parameters) and (2) how a generated model uses its parameters and its input to make a prediction (inference). We denote by a model any unique configuration of parameters in a space defined by a method. Equivalently, a model represents a response surface (deterministic model) or the distribution of the response conditional on its inputs (probabilistic model).

We start by presenting simple forecasting methods, which are often used as baseline for other methods (\cite{hyndman2018principles}).

**Historical Average (HA) method. Along wit**Forecast for any point assumes a constant value: the average of the historical data (\ref{eq-naive}).
$$
\hat{y}_{T+h|T} = \frac{1}{T}\sum_{t=1}^Ty_t
$$
**Naïve method**. Forecast for any point assumes a constant value: the value from the last observation (\ref{eq-naive}). As the naïve forecast is the optimal prediction for a random walk process, it is also known as *random walk* method.
$$
\hat{y}_{T+h|T} = y_T
$$
**Seasonal Naïve method**. Time series are modeled as harmonic with period $k$ observations (i.e. perfectly seasonal with seasonal period $k$), and for a given point  in future, suggest the corresponding last observed value from the last season (\ref{eq-snaive}). For example, all monthly forecasts for any future June assume the value from the last observed June value. 
$$
\hat{y}_{T+h|T} = y_{T+h-k}
$$
**Drift method**. Forecast for any point assumes a constant value rate of change, with values themselves starting from the latest observed value. 
$$
\hat{y}_{T+h|T} = y_{T} + h\left(\frac{y_T-y_1}{T-1} \right)
$$

- desired properties of residuals
  - uncorrelated, as any correlation in residuals indicate there is information left in them which could be used to improve the forecasts. 
  - zero mean 

- getting better results – general approach: minimizing residuals, by  using a partition of the available historical data for updating (iteratively or not) the model parameters configuration towards one that either (a) maximizes the likelihood of this configuration or (b) minimizes a loss function. Likelihood is defined as the relative number of ways that a configuration of model parameters can produce the provided data (\cite{mcelreath2020rethinking}). In contrast, loss functions quantify the deviation between predicted and ground truth values. The Mean Squared Error (MSE, \ref{eq-mse}) is typical choice for a loss function for continuous-type responses, as it accounts for both bias and variance errors and its smoothness is amenable to convex optimization. (\cite{goodfellow2016deep}).
  $$
  MSE = \frac{1}{N}\sum_{t=1}^N e^2_t
  $$
  The ultimate aim of the optimization process underlying the model inference is to maximize model generalization performance, i.e. to minimize its generalization error. Aiming at an unbiased estimation of this error, one often dedicates exclusive partitions of the available data for (a) model inference and for (b) assessing the generalization error. The partition (a) is often referred as the *training set*; the partition (b), as the *test set* (\cite{hyndman2018principles}, \ref{fig-training-test-split}). 

  

  ![training-test-split](https://otexts.com/fpp2/fpp_files/figure-html/traintest-1.png)

  Fig ???. Splitting the available data into training and test sets (adapted from \cite{krispin2019handson}). 

  

  For a forecasting horizon of interest, A single training/test split allows estimating a single value for the generalization error for a predefined forecasting horizon. Estimating the generalization error on a single test data has the drawback

- Quantifying generalization error via performance metrics

- As models have parameters, so do methods have their own, often referred as *hyperparameters*. They may control the space of model parameters configurations, the model inference process or eventually the loss function (\cite{hutter2019automated}). Hyperparameters may have a major influence on model performance. When besides the model parameters themselves, we also search for the parameters from its parent method, yet another partition becomes necessary in order to attain a minimally unbiased estimate of the resulting generalization errors. When working with three partitions, one for model inference, another for assessing its generalization error given a hyperparameters configuration and another one for assessing it across different hyperparameters configurations, authors often refer to them as training, validation and test set, respectively.

### 2.2.2 Model Evaluation / Evaluating Models Performance

> Hyndman, R.J., & Athanasopoulos, G. (2018) *Forecasting: principles and practice*, 2nd edition, OTexts: Melbourne, Australia. OTexts.com/fpp2. Accessed on 14 Jun 2020.)

- 

Time Series Cross-Validation

![img](https://otexts.com/fpp2/fpp_files/figure-html/cv1-1.png)

- expanding window (figure)
- out-of-sample cross-validation

#### Metrics

A central requirement for forecasting models is accuracy. It is usual to quantify it in terms of accuracy metrics, which characterize the distribution of *forecast errors* (\cite{hyndman2018principles}). A forecast error expresses by how much a forecast  $\hat{y}_{T+h|T}$ for a point in the test set deviates from its corresponding observed value $y_{T+h}$. It could be expressed as
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

Although often the most important one, accuracy is often just one of many requirements in a forecasting model development. In \cite{armstrong2002principles}, Armstrong reports that value inference time, cost savings resulting from improved decisions, interpretability, usability, ease of implementation and development costs (human and computational resources) tend to be of comparable importance to researchers, practitioners and decision makers.

### 2.2.3 Non-Trivial Forecasting Methods

\ref{fig-methods-overview}

Conventional approaches are characterized by the modeling of the time series as a realization of stationary stochastic process (\cite{brockwell2009}, \cite{bontenpi2013strategies}). The two most widely used families of conventional methods are the Exponential Smoothing (ES) family the ARIMA family (\cite{hyndman2018principles}). 

In the ES approach, time series is modeled as combination of  interpretable components \cite{brockwell2009}. In the *classical decomposition* (\cite{makridakis1998}), these components are trend component $m$, seasonal component $d$ and random noise (*white noise*) $y_t$, which are linearly combined to reconstruct the time series:
$$
y_t = m_t + s_t + a_t .
$$
We now describe some of the most known methods from the ES family.

**Simple Exponential Smoothing Method.** Predicts for the next period the forecast value for the previous period, adjusting it using the forecast error. Parameter: $\alpha \in \mathbb{R}_{[0,1]}$.
$$
\hat{y}_{t+1} = \hat{y}_{t} + \alpha(\hat{y}_{t} - \hat{y}_{t-1}) \\
$$
**Holt's Linear Method.** Features an additive trend component.  (\cite{hyndman2008es}). Parameters: $(\alpha, \beta^*) \in \mathbb{R}^2_{[0,1]}$
$$
\begin{align}
\hat{y}_{t+h|t} &= \ell_t + b_th, \\
where\ \  \ell_t &= \alpha y_t + (1-\alpha)(\ell_{t-1}+b_{t-1}) \ \ \ \ \ \ (level) \\
b_t &= \beta^*(\ell_t - \ell_{t-1}) + (1-\beta^*)b_{t-1} \ \ \ (growth)
\end{align}
$$
**Holt-Winters' Method.** Features additive trend and multiplicative seasonality components, for a seasonality length $m$, and forecasting horizon $h$. Parameters: $(\alpha, \beta^*,\gamma) \in \mathbb{R}^3_{[0,1]}$ (usual bounds, refer to \cite{hyndman2008es} for details). 
$$
\begin{aligned}
\hat{y}_{t+h|t} = (&\ell_t + b_th)s_{t-m+h^+_m}, \\
where \ \ell_t &= \alpha \frac{y_t}{s_{t-m}} + (1-\alpha)(\ell_{t-1}+b_{t-1})   &(level) \\
b_t &= \beta^*(\ell_t - \ell_{t-1}) + (1-\beta^*)b_{t-1} &(growth) \\
s_t &= \gamma y_t/(\ell_{t-1}+b_{t-1}) + (1-\gamma)s_{t-m} \ \ \ &(seasonal)
\end{aligned}
$$
ARIMA (Autoregressive Integrated Moving Average) methods (\cite{box1970}) rely on repeatedly applying a difference operator to the observed values until the differenced series resemble a realization of some stationary stochastic process (\cite{brockwell2009methods}).  We denote by $\nabla^k(\cdot)$ the difference operator of order $k$. For $k=1$, $\nabla y_t = y_t - y_{t-1}$; for $k=2$, we have $\nabla^2(y_t) = \nabla(\nabla y_t) = \nabla y_t - \nabla y_{t-1} = y_t -2y_{t-1} + y_{t-2}$  and so forth. Another operator useful in ARIMA methods is the *backshift operator* $B^k(\cdot)$ with lag $k$. For $k=1$, we have $B y_t = y_{t-1}$. For $k=2$, $B^2(y_t) = B(B(y_t)) = y_{t-2}$.

**AR (Autoregressive) Method. ** Linear regression with past values of the same variable (lagged values) as predictors. A constant level $c$ and a white noise $\varepsilon_t \sim WN(\mu_\varepsilon, \sigma^2_\varepsilon)$ are considered. Parameters: $\boldsymbol{\phi} = [\phi_1 \ \phi_2 \ \cdots \ \ \phi_p]^\top, \ \mu_\varepsilon, \ \sigma_\varepsilon, c$. Hyperparameter: $p$. 
$$
\hat{y}_t = c + \varepsilon_t + \phi_1 y_{t-1} + \phi_2 y_{t-2} + ... + \phi_p y_{t-p}
$$
**MA (Moving Average) Method.** Linear regression with lagged forecast errors $\varepsilon_\tau = \hat{y}_\tau - y_\tau$ as predictors. Parameters:$\boldsymbol{\theta} = [\theta_1 \ \theta_2 \ \cdots \ \ \theta_q]^\top, \ \mu_\varepsilon, \ \sigma_\varepsilon, c$. Hyperparameter: $q$.
$$
\hat{y}_t = c + \varepsilon_{t} + \theta_1 \varepsilon_{t-1} + \theta_2 \varepsilon_{t-2} + ... + \theta_q \varepsilon_{t-q}
$$
**(Non-seasonal) ARIMA Method.** Linear regression, with lagged *differenced* values $y_\tau'$ and lagged errors as predictors. It combines autoregression on the differenced time series with a moving average model, hence the name *Autoregressive Integrated Moving Average*, with *integration* referring to the reverse operation of differencing, used when reconstructing the original time series from its differenced version. Parameters:   $\boldsymbol{\phi} = [\phi_1 \ \phi_2 \ \cdots \ \ \phi_p]^\top,\boldsymbol{\theta} = [\theta_1 \ \theta_2 \ \cdots \ \ \theta_q]^\top, \ \mu_\varepsilon, \ \sigma_\varepsilon, c$. Hyperparameters: $p, d, q$.
$$
\hat{y}'_t = c + \varepsilon_t + \phi_1 y'_{t-1} + ... + \phi_p y'_{t-p} + \cdots + \theta_1 \varepsilon_{t-1} + ... + \theta_q \varepsilon_{t-q}
$$
Approaches solely based on Machine Learning struggled until recently to consistently outperform conventional time series forecasting approaches (\cite{makridakis2018waysforward}).  Despite relying on biased evidence (e.g. models were evaluated across all time series without any sound choice nor search for hyperparameters), Makridakis claimed in \cite{makridakis2019ml} that "hybrid approaches and combinations of methods are the way forward for improving the forecasting accuracy and making forecasting more valuable". Oreshkin et al. challenged in \cite{bengio2020nbeats} this conclusion, introducing N-BEATS, a pure deep learning method that not only outperformed conventional and hybrid methods, but also allowed high interpretability of intermediate outputs. 

Below we present selected deep learning methods helpful for understanding current state-of-the-art approaches for both wind power generation-specific applications and in general univariate time series forecasting applications. 

**RNN (Recurrent Neural Network).** Uses the recurrent layer as building block (\ref{fig-rnn}), implemented over a sequence of steps. Successive hidden states between layers are related by the so-called *Markov dependence* (\cite{battaglia2020gnn}). This allows RNN to capture dependencies in sequential data. However, in its basic design, RNN is often unable to incorporate dependencies that span over more than a few timesteps due most importantly due to vanishing gradients. Every block concatenates the last hidden state with the current input, passing the result to an activation function. The result is carried forward as the updated hidden state. 

![http://colah.github.io/posts/2015-08-Understanding-LSTMs/img/LSTM3-SimpleRNN.png](http://colah.github.io/posts/2015-08-Understanding-LSTMs/img/LSTM3-SimpleRNN.png)

Fig ???. The basic RNN architecture in its unfolded representation. Arrows indicate transfers of input and hidden states (adapted from \cite{http://colah.github.io/posts/2015-08-Understanding-LSTMs/}).  

**LSTM (Long-Short Term Memory).** A type of RNN, improves on its basic design  most importantly by the cell state transfer (superior horizontal line inside the repeating module in /ref{fig-lstm}), which allows information to be persist across many transitions of cell states. Instead of a single layer, each cell presents four layers interacting in a way that defines how the old cell state, the old state from new hidden state from the previous unit. For instance, in the leftmost vertical channel, the forget gate (sigmoid layer in /ref{fig-lstm}) controls how much from the old cell state should be used to define the new cell state. The rightmost layer represents the output gate, which controls how much of the current cell state should be passed the current hidden state modifies the next updated state. 

![http://colah.github.io/posts/2015-08-Understanding-LSTMs/img/LSTM3-chain.png](http://colah.github.io/posts/2015-08-Understanding-LSTMs/img/LSTM3-chain.png)

Fig ???. Basic LSTM architecture in its unfolded representation (adapted from \cite{http://colah.github.io/posts/2015-08-Understanding-LSTMs/}).

**NBEATS.** Uses as basic building block a multi-layer fully connected network with ReLU nonlinearities, which feed basis layers that generate a backcast and a forecast output. Blocks are arranged into stacks, organized to form a model.  Models resulting from this architecture consistently outperformed state-of-the-art methods for univariate forecasting across different horizons and thousands of time series datasets of different nature, while using a a single hyperparameter configuration (\cite{bengio2020nbeats}).  

![image-20200616201550854](/home/jonasmmiguel/.config/Typora/typora-user-images/image-20200616201550854.png)

Fig ???. NBEATS architecture.

Hybrid methods combine machine learning and conventional approaches by using the outputs from statistical engines as features \cite{bengio2020nbeats}. Below we present ES-RNN, a hybrid method winner of the 2017 M4 forecasting competition.

**ES-RNN.** It uses Holt-Winters' ES method as statistical engine for capturing the seasonal and level components from the time series into features, which are then used by a LSTM model to exploit non-linear dependencies.
$$
\begin{aligned}
\hat{y}_{t+h|t} = LS&TM(y_t,\ell_t, s_t)\\
where \ \ \ell_t &= \alpha \frac{y_t}{s_{t-m}} + (1-\alpha)\ell_{t-1}   &(level) \\
s_t &= \gamma y_t/\ell_{t} + (1-\gamma)s_{t-m} \ \ \ &(seasonal)
\end{aligned}
$$

## 2.3 Spatio-Temporal Forecasting

In a univariate, deterministic, one-step ahead, point-forecast time series forecasting problem, one is interested in obtaining a function $f: \mathbb{R}^T \rightarrow \mathbb{R}$ that maps historical observations of a variable $y_t$ to its value in the next timestep. In the spatio-temporal (ST) version of this problem, one aims to attain a function $f: \mathbb{R}^{|V|\times T} \rightarrow \mathbb{R}^{|V|}$ which maps historical observations of a quantity across different regions $v\in V$, $\boldsymbol{y}_t = [y_{1,t}\  \  y_{2,t}\ \ \cdots \ \ y_{|V|,t}]^\top$ ,  to its value $\boldsymbol{y}_{t+1}$ in the next timestep  (\ref{eq-spatio-temporal-forecasting}). 
$$
[\boldsymbol{y}_{t-T+1}, \  \cdots\ , \boldsymbol{y}_{t}] \xrightarrow{f(\cdot)} \boldsymbol{y}_{t+1}
$$
For some forecasting problems such as the weather-conditioned wind power generation, the spatial dependency might play an important along with the temporal dependencies themselves (\cite{engeland2017variability}). In this work, we consider three different approaches to the ST forecasting problem. In a naïve approach, time series for different locations are modeled independently, thus neglecting spatial dependencies. In a second approach, the time series are modeled jointly via multivariate forecasting methods. Finally, we consider the explicit modeling of both spatial and temporal dependencies via graphical models. 

Approaches:

- model TS individually
- model TS together (multivariate TS approach) via Multivariate versions
  - VARIMA
- model ST behavior via DL-methods\cite{armstrong2002principles}
  - DCRNN
  - Graph WaveNet [see liu2020gnn]

### 2.3.1 Metrics

- (spatio-temporal/multivariate version)