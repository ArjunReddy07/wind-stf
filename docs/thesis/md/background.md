## 2.1. Liberalized Electricity Markets

In a liberalized electricity market, multiple entities are involved in supplying energy to final consumers, as \ref{fig-electricity-grid-players} illustrates. In the EU, these parties are electricity generators, transmission system operators (TSO), distribution system operator (DSO), electricity supplier, and regulator (\cite{erbach2016market}). TSOs are responsible for long-distance transport of energy and for balancing supply and demand in timeframes under quarter-hour. Imbalances of this nature cause deviations from the nominal frequency and shortages in more severe cases. DSOs are responsible for delivering electricity to consumers. Electricity suppliers buy energy from generator parties and resell it to consumers.

![image-20200617060458953](/home/jonasmmiguel/.config/Typora/typora-user-images/image-20200617060458953.png)

Fig. ???. The different stages of electricity supply and the responsible parties in a liberalized market. 

## 2.2 Wind Power Generation

In 1920, Betz (\cite{betz1920maximum}) modeled a generic wind harvesting system as an open-disc actuator and, by using the energy conservation equation for a stream tube flowing through this disk, he derived an upper limit for the power harvested by a horizontal-axis wind turbine. The *Betz Limit*, as it is known, is a function of rotor diameter $D$ (via the rotor swept area $A$) and the average free stream wind velocity $v$ at hub height $H$ (\ref{eq-betz-limit}).
$$
P_{ideal} = \frac{1}{2}\rho \cdot A(D)\cdot v^3
$$
Due to losses such as those associated to (1) momentum deficit in lower atmosphere boundary layer, (2) wakes from neighboring turbines, (3) suboptimal yaw angle and (4) blade tip vortices, the power harvested by the turbine rotor is only a fraction $C_p$ (coefficient of power) of this idealized maximum. Further  losses (a) of mechanical nature in the interfaces rotor-gearbox and gearbox-generator, (b) of electrical nature in the interface generator-converter  are modeled by the fractions $\eta_{m}$ and $\eta_{e}$, respectively,  to yield the actual power generation as measured by the power converter, \ref{eq-power-real-turbine} (\cite{albadi2009capacity}).
$$
P = C_p\eta_{m} \eta_{e}  \cdot \frac{1}{2}\rho \cdot A(D)\cdot v^3
$$
In this equation, $D$ and $H$ are design variables. The air density $\rho$ may vary during operation due to changes in air temperature, but its effects are often negligible. Finally, $C_p$, $v$ depend both on design (e.g., hub height $H$, blade profiles) and operation conditions (e.g., velocity speed and direction). 

![https://www.researchgate.net/profile/Marcelo_Molina/publication/221911675/figure/fig2/AS:304715268149248@1449661189252/General-description-of-a-wind-turbine-system-The-appropriate-voltage-level-is-related-to.png](https://www.researchgate.net/profile/Marcelo_Molina/publication/221911675/figure/fig2/AS:304715268149248@1449661189252/General-description-of-a-wind-turbine-system-The-appropriate-voltage-level-is-related-to.png)

Fig ???. The different stages of the overall wind power conversion process (adapted from \cite{}). 

In operation, the dominant source of variability for the generated power is $v$. Being climate and weather-dependent, it is also the main reason for the intermittency and non-dispatchability of wind power (\cite{demeo2006natural}). This dependence motivates the usage by designers and generation operators of the so-called *wind-to-power curves* (or *power curves*), which are empirical relations that allow one to determine the generated power $P$ by knowing the wind velocity $v$.

As design, planning, operation, maintenance, and trading of wind power are subject to such high variabilities, forecasting wind power generation (WPG) provides value for the different players in the electricity grid, illustrated in \ref{fig-electricity-grid-players}.  Table \ref{table-forecasting-reqs} gives some examples of how various system operation aspects can profit from forecasts at different time scales. 

Power generation from single turbines can also be aggregated at different levels. Market operators, for example, profit the most from regional aggregations, since for energy trading, this resolution is sufficiently high, with higher resolutions across the same space scales of interests often too costly (\cite{jung2014forecasting}). 

In countries such as Germany, where continental and national renewables-promoting public funding initiatives such as the *Energiewende* resulted in high penetration of wind power in the grid, forecasting wind power generation accurately has a tangible impact both environmentally and economically.

| Very short <br />($\sim secs\ - 0.5h $) | short <br />($0.5h - 72h$) | medium<br />($72h\ – 1\ week $)               | long<br />($1\ week\  – 1\ year $) |
| --------------------------------------- | -------------------------- | --------------------------------------------- | ---------------------------------- |
| turbine control, <br />load tracking    | pre-load sharing           | power system management, <br />energy trading | turbines maintenance scheduling    |

Table ???. How WPG forecasting can generate value for generation operators, according to the forecasting horizon (\cite{jung2014forecasting}). 

The intermittency of renewables motivated an alternative measure of power generation: the *capacity factor* (CF). CF is defined as the ratio of the actual generated power and the installed capacity. When considering WPG data across long timespans for both analysis and forecasting, it is usual that new commissionings take place, which manifests itself as a step perturbation into the overall generated power. In this case, CF can be useful as it is mostly insensitive to single new commissionings. 

Climate and weather-conditioned local wind velocities imply for the power generation not only significant temporal dependencies but also significant spatial dependencies. As air masses influence one another in different scales, wind power generation in neighboring turbines tends to present higher correlations than turbines distant from one another (\cite{engeland2017variability}). Therefore, wind power generation is a phenomenon with dominant spatio-temporal dependencies.

Usual approaches to forecasting wind power generation are physical, statistical, and machine learning-based (\cite{jung2014forecasting}). The physical approach relies on the modeling of the power curve using Computational Fluid Dynamic (CFD) models, taking Numerical Weather Prediction (NWP) as inputs for defining the boundary conditions. The main limitations of this approach are (a) the high costs involved in the development of such models, along with (b) the large uncertainties entailed by the NWP data. The statistical approach uses historical data and statistical time series models to produce forecasts for wind speed, which is then used in the power curve for forecasting the power generation itself. Finally, in machine learning approaches, one uses historical data for wind speed or power generation, eventually combined with historical data of weather conditions to forecast either (a) local wind speeds, with their subsequent transformation into generated power via power-curve or (b) generated power directly.  

## 2.3 Time Series Forecasting

In \cite{brockwell2016intro}, Brockwell & Davis define time series as "a set of observations $y_t$, each one being recorded at a specific time $t$." When observations are recorded at discrete times, they are called a discrete-time time series, on which we focus this work. 

An important task in time series analysis is time series forecasting, which concerns "the prediction of data at future times using observations collected in the past" \cite{hyndman2018principles}. Time series forecasting permeates most aspects of modern business, such as business planning from production to distribution,  finance and marketing, inventory control, and customer management (\cite{oreshkin2020nbeats}). In some business use cases, a single point in forecasting accuracy may represent millions of dollars (\cite{kahn2003apudOreshkin}, \cite{jain2017apudOreshkin}).  

Time series forecasting tasks can be categorized in terms of (a) inputs, (b) modeling, and (c) outputs. In terms of inputs, one can use exogenous features or not, one or more input time series (univariate *versus* multivariate). In terms of modeling, one must define a resolution (e.g., hourly, weekly), can aggregate data in different levels (hierarchical *versus* non-hierarchical), and can use different schemes for generating models (we distinguish statistical from machine learning-based). Finally, regarding outputs, a forecasting task might involve making predictions in terms of single values or whole distributions (deterministic *versus* probabilistic), point-predictions or prediction intervals, predict values for either a single point or for multiple points in future time (one-step-ahead *versus* multi-step-ahead). In this work, we focus on deterministic, one-step ahead point forecasting, where one is interested in obtaining a function $f: \mathbb{R}^T \rightarrow \mathbb{R}$ (a *forecasting model*) that maps historical observations  $\boldsymbol{y} _{1:T} = \{y_1,…,y_T\}$ of a variable $y_t$ to its value in a future time step $T+h$, for a forecasting horizon of interest $h$. 

The main requirement for a forecasting model concerns the accuracy of its forecasts $\hat{y}_{t|T}$. This accuracy is quantified by a *metric*, which summarizes the distribution of the forecast error $e_{t} = y_{t} - \hat{y}_{t|T}$ over the different evaluation timesteps $t$. In the following subsections, we introduce some typical options for (a) schemes for defining the evaluation timesteps $t$ (\ref{model evaluation}), (b) accuracy metrics (\ref{model-evaluation}), as well as (c) approaches for generating  forecasting models (\ref{baseline-methods}, \ref{statistical-methods}, \ref{ml-methods}).

### 2.3.1 Model Evaluation

For assessing the performance of a model $f$, the time indexes $t$ for evaluating the forecast errors $e_{t}$, given a forecasting model $f$ and a set of available historical observations $\boldsymbol{y} _{1:T} = \{y_1,…,y_T\}$. In a naive approach, one could use all available data for both model inference and evaluation. This would, however, result in a highly biased estimate of the model generalization performance. Less biased estimations could be attained instead by partitioning the available dataset into a *training dataset*, exclusive for model inference, and a *test dataset*, used for model evaluation (\ref{training-test-split}). Once an estimate for the model performance is attained, a separate model inference using both partitions can be carried out, so that the epistemic part of the generalization error, resulting from limited data in model inference, is kept at a minimum. 

![training-test-split](https://otexts.com/fpp2/fpp_files/figure-html/traintest-1.png)

Furthermore, it is necessary that this partitioning results in two sets of successive observations, in order to preserve the *Markovian dependence* underlying the sequential observations. Even under this constraint, however, the choice on what point to split the data is still arbitrary, implying that assessing model performance on a single arbitrary choice would result in a biased estimate. To minimize this bias, the model performance can be assessed for several different splitting points. The partial results are then aggregated, typically by averaging, into an overall result of model performance. This procedure is known as *out-of-sample cross-validation*.

As the forecast error generally increases for longer forecasting horizons, the out-of-sample estimate might overestimate the generalization error, especially if only one-step forecasts are of interest. For overcoming this, only the  first point in the test data is used in evaluating the error. This approach is known as *expanding window cross-validation*,  and is illustrated in \ref{growing-window-cv}.

![out-of-sample-cv](https://otexts.com/fpp2/fpp_files/figure-html/cv1-1.png)

Fig ???. The growing window cross-validation scheme (adapted from \cite{krispin2019handson}). 

### 2.3.2 Accuracy Metrics

Many different metrics exist, each one summarizing the error distribution in a different way. Some of the most usual definitions  are presented from \ref{eq-rmse} to \{eq-} (see e.g., \cite{wu2019graphwavenet}, \cite{liu2019st-mgcn},  \cite{hyndman2006metrics}). In particular, $MASE$ and $MdRAE$ use as denominator the forecast errors of the naïve model, which takes the last known value to forecast the next point. The naïve model can be shown to be optimal for a random walk process (\cite{hyndman2006metrics}).
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

By summarizing the forecast error distribution into a reduced set of values, forecasting metrics are essential in model development as well as in method development.  To forecasters (model developers) and forecast users, metrics offer  a concise, unambiguous way to communicate accuracy requirements and specifications. For methods developers, it allows comparing different methods across different use cases, forecasting settings, and datasets.

On the one hand, single metrics concisely convey information about the error distribution, which is useful for comparing models and making decisions. On the other hand, a single metric cannot convey all aspects of the error distribution, and often using more than one metric becomes necessary to ensure sufficiency (\cite{armstrong2002principles}). Therefore, deciding on a group of metrics often involves a trade-off between conciseness and sufficiency. 

Metrics differ in interpretability, scale invariance, sensitivity to outliers, symmetric penalization of negative and positive errors, and behavior predictability as $y_t \rightarrow 0$ (\cite{hyndman2006metrics}). Therefore, it is important that the choice on the metrics set is coherent with the application requirements \cite{armstrong2002principles}. For example, while failing to forecast single sudden peaks in local wind speed (wind gusts) might not be important in wind farm planning, it might be a primary requirement for wind turbine operation. \ref{table-sensitivities} summarizes sensitivities.

Although often the most important one, accuracy is often just one of many requirements in a forecasting model development. In \cite{armstrong2002principles}, Armstrong reports that value inference time, cost savings resulting from improved decisions, interpretability, usability, ease of implementation, and development costs (human and computational resources) tend to be of comparable importance to researchers, practitioners, and decision-makers.

### 2.3.3 Forecasting Approaches

getting better results – general approach: minimizing residuals, by  using a partition of the available historical data for updating (iteratively or not) the model parameters configuration towards one that either (a) maximizes the likelihood of this configuration or (b) minimizes a loss function. The likelihood is defined as the relative number of ways that a configuration of model parameters can produce the provided data (\cite{mcelreath2020rethinking}). In contrast, loss functions quantify the deviation between predicted and ground truth values. The Mean Squared Error (MSE, \ref{eq-mse}) is a typical choice for a loss function for continuous-type responses, as it accounts for both bias and variance errors, besides exhibiting smoothness amenable to convex optimization (\cite{goodfellow2016deep}).
$$
MSE = \frac{1}{N}\sum_{t=1}^N e^2_t
$$
ew of the methods reviewed in this work. We start by presenting simple forecasting methods[¹], which are often used as baselines for other methods (\cite{hyndman2018principles}.

[^1]: Analogous to Murphy in \cite{murphy2012probabilistic}, we draw distinctions between the concepts of method, model, and model inference algorithm. A method can specify (1) how training data is used to generate a model (training, model inference, i.e., inference of its parameters) and (2) how a generated model uses its parameters and its input to make a prediction (inference). We denote by a model any unique configuration of parameters in a space defined by a method. Equivalently, a model represents a response surface (deterministic model) or the distribution of the response conditional on its inputs (probabilistic model).

**![methods-overview](/home/jonasmmiguel/Desktop/methods-overview.png)**Fig. ???. Forecasting methods presented in this work. Most of these methods only model dependencies of temporal nature and are presented in this section. Exception are DCRNN, ST-GCN, and Graph WaveNet (ML-based), presented in section \ref{spatio-temporal-forecasting}. They explicitly approach a more general forecasting setting where capturing both temporal and spatial dependencies is a central concern.   

#### 2.3.3.1 Baseline Approaches

**Naïve method**. Forecast for any point assumes a constant value: the value from the last observation (\ref{eq-naive}). As the naïve forecast is the optimal prediction for a random walk process, it is also known as the *random walk* method.
$$
\hat{y}_{T+h|T} = y_T
$$
**Seasonal Naïve method**. Time series are modeled as harmonic with period $k$ observations (i.e., perfectly seasonal with seasonal period $k$), and for a given point  in future, suggest the corresponding last observed value from the last season (\ref{eq-snaive}). For example, all monthly forecasts for any future June assume the value from the last observed June value. 
$$
\hat{y}_{T+h|T} = y_{T+h-k}
$$
**Drift method**. The forecast for any point assumes a constant value rate of change, with values themselves starting from the latest observed value. 
$$
\hat{y}_{T+h|T} = y_{T} + h\left(\frac{y_T-y_1}{T-1} \right)
$$

**Historical Average (HA) method. ** The forecast for any point assumes a constant value: the average of the historical data (\ref{eq-naive}).
$$
\hat{y}_{T+h|T} = \frac{1}{T}\sum_{t=1}^Ty_t
$$

#### 2.3.3.2 Statistical Approaches

#### 2.3.3.3 Machine Learning Approaches





desired properties of residuals

- uncorrelated, as any correlation in residuals indicate there is information left in them which could be used to improve the forecasts. 
- zero mean 

- 
  
  
  
  

  For a forecasting horizon of interest, A single training/test split allows estimating a single value for the generalization error for a predefined forecasting horizon. Estimating the generalization error on a single test data has the drawback

- Quantifying generalization error via performance metrics

- As models have parameters, so do methods have their own, often referred to as *hyperparameters*. They may control the space of model parameters configurations, the model inference process or eventually the loss function (\cite{hutter2019automated}). Hyperparameters may have a major influence on model performance. When besides the model parameters themselves, we also search for the parameters from its parent method, yet another partition becomes necessary in order to attain a minimally unbiased estimate of the resulting generalization errors. When working with three partitions, one for model inference, another for assessing its generalization error given a hyperparameters configuration and another one for assessing it across different hyperparameters configurations, authors often refer to them as training, validation and test set, respectively.

- 

### 2.2.3 Non-Trivial Forecasting Methods

\ref{fig-methods-overview}

Statistical forecasting approaches are characterized by the modeling of the time series as a realization of a stationary stochastic process (\cite{brockwell2009}, \cite{bontenpi2013strategies}). The two most widely used families of statistical methods are the Exponential Smoothing (ES) family and the ARIMA family (\cite{hyndman2018principles}). 

In the ES approach, the time series is modeled as combination of  interpretable components \cite{brockwell2009}. In the *classical decomposition* (\cite{makridakis1998}), these components are trend component $m$, seasonal component $d$, and random noise (*white noise*) $\varepsilon_t$, which are linearly combined to reconstruct the time series:
$$
y_t = m_t + s_t + a_t .
$$
We now describe some of the most known methods from the ES family.

**SES (Simple Exponential Smoothing method)** predicts for the next period the forecast value for the previous period, adjusting it using the forecast error. Parameter: $\alpha \in \mathbb{R}_{[0,1]}$.
$$
\hat{y}_{t+1} = \hat{y}_{t} + \alpha(\hat{y}_{t} - \hat{y}_{t-1}) \\
$$
**Holt's Linear method** features an additive trend component.  (\cite{hyndman2008es}). Parameters: $(\alpha, \beta^*) \in \mathbb{R}^2_{[0,1]}$
$$
\begin{align}
\hat{y}_{t+h|t} &= \ell_t + b_th, \\
where\ \  \ell_t &= \alpha y_t + (1-\alpha)(\ell_{t-1}+b_{t-1}) \ \ \ \ \ \ (level) \\
b_t &= \beta^*(\ell_t - \ell_{t-1}) + (1-\beta^*)b_{t-1} \ \ \ (growth)
\end{align}
$$
**Holt-Winters' method** features additive trend and multiplicative seasonality components, for a seasonality length $m$, and forecasting horizon $h$. Parameters: $(\alpha, \beta^*,\gamma) \in \mathbb{R}^3_{[0,1]}$ (usual bounds, refer to \cite{hyndman2008es} for details). 
$$
\begin{aligned}
\hat{y}_{t+h|t} = (&\ell_t + b_th)s_{t-m+h^+_m}, \\
where \ \ell_t &= \alpha \frac{y_t}{s_{t-m}} + (1-\alpha)(\ell_{t-1}+b_{t-1})   &(level) \\
b_t &= \beta^*(\ell_t - \ell_{t-1}) + (1-\beta^*)b_{t-1} &(growth) \\
s_t &= \gamma y_t/(\ell_{t-1}+b_{t-1}) + (1-\gamma)s_{t-m} \ \ \ &(seasonal)
\end{aligned}
$$
ARIMA (Autoregressive Integrated Moving Average) methods (\cite{box1970}) rely on repeatedly applying a difference operator to the observed values until the differenced series resemble a realization of some stationary stochastic process (\cite{brockwell2009methods}).  We denote by $\nabla^k(\cdot)$ the difference operator of order $k$. For $k=1$, $\nabla y_t = y_t - y_{t-1}$; for $k=2$, we have $\nabla^2(y_t) = \nabla(\nabla y_t) = \nabla y_t - \nabla y_{t-1} = y_t -2y_{t-1} + y_{t-2}$  and so forth. Another operator useful in ARIMA methods is the *backshift operator* $B^k(\cdot)$ with lag $k$. For $k=1$, we have $B y_t = y_{t-1}$. For $k=2$, $B^2(y_t) = B(B(y_t)) = y_{t-2}$.

**AR (Autoregressive) method. ** Linear regression with past values of the same variable (lagged values) as predictors. A constant level $c$ and a white noise $\varepsilon_t \sim WN(\mu_\varepsilon, \sigma^2_\varepsilon)$ are considered. Parameters: $\boldsymbol{\phi} = [\phi_1 \ \phi_2 \ \cdots \ \ \phi_p]^\top, \ \mu_\varepsilon, \ \sigma_\varepsilon, c$. Hyperparameter: $p$. 
$$
\hat{y}_t = c + \varepsilon_t + \phi_1 y_{t-1} + \phi_2 y_{t-2} + ... + \phi_p y_{t-p}
$$
**MA (Moving Average) method.** Linear regression with lagged forecast errors $\varepsilon_\tau = \hat{y}_\tau - y_\tau$ as predictors. Parameters:$\boldsymbol{\theta} = [\theta_1 \ \theta_2 \ \cdots \ \ \theta_q]^\top, \ \mu_\varepsilon, \ \sigma_\varepsilon, c$. Hyperparameter: $q$.
$$
\hat{y}_t = c + \varepsilon_{t} + \theta_1 \varepsilon_{t-1} + \theta_2 \varepsilon_{t-2} + ... + \theta_q \varepsilon_{t-q}
$$
**(Non-seasonal) ARIMA method.** Linear regression, with lagged *differenced* values $y_\tau'$ and lagged errors as predictors. It combines autoregression on the differenced time series with a moving average model, hence the name *Autoregressive Integrated Moving Average*, with *integration* referring to the reverse operation of differencing, used when reconstructing the original time series from its differenced version. Parameters:   $\boldsymbol{\phi} = [\phi_1 \ \phi_2 \ \cdots \ \ \phi_p]^\top,\boldsymbol{\theta} = [\theta_1 \ \theta_2 \ \cdots \ \ \theta_q]^\top, \ \mu_\varepsilon, \ \sigma_\varepsilon, c$. Hyperparameters: $p, d, q$.
$$
\hat{y}'_t = c + \varepsilon_t + \phi_1 y'_{t-1} + ... + \phi_p y'_{t-p} + \cdots + \theta_1 \varepsilon_{t-1} + ... + \theta_q \varepsilon_{t-q}
$$
Approaches solely based on Machine Learning struggled until recently to consistently outperform statistical time series forecasting approaches (\cite{makridakis2018waysforward}).  Despite relying on biased evidence (e.g., models were evaluated across all time series without any sound choice nor search for hyperparameters), Makridakis claimed in \cite{makridakis2019ml} that "hybrid approaches and combinations of methods are the way forward for improving the forecasting accuracy and making forecasting more valuable." Oreshkin et al. challenged in \cite{bengio2020nbeats} this conclusion, introducing N-BEATS, a pure deep learning method that was shown to outperform statistical and hybrid methods, while also ensuring interpretability of intermediate outputs. 

Below we present selected deep learning methods helpful for understanding current state-of-the-art approaches for both wind power generation-specific applications and in general univariate time series forecasting applications. 

**RNN (Recurrent Neural Network).** Use the recurrent layer as building block: a cell that updates its state according to (a) its previous state $h_{t-1}$ and (b) its current input $x_t$ (\ref{fig-rnn}). By performing this update at every timestep of a time series, this basic structure allows the RNN to express temporal dependencies in time series. An RNN can be built by serializing several of these self-looping cells between the input layer and the output layer for achieving higher-order mappings and thus capturing more complex temporal dependencies. The major limitation of RNN in its basic design (recurrent layer as in \ref{fig-rnn}) is its inability to capture dependencies that exist across longer periods than a few timesteps. It arises from a phenomenon called *vanishing gradients*: while inferring optimal parameters via gradient descent (learning phase), the gradients calculated via backpropagation through time become too small to guide the optimization.

![http://colah.github.io/posts/2015-08-Understanding-LSTMs/img/LSTM3-SimpleRNN.png](http://colah.github.io/posts/2015-08-Understanding-LSTMs/img/LSTM3-SimpleRNN.png)

Fig ???. The basic RNN architecture in its unfolded representation. Arrows indicate transfers of input and hidden states (adapted from \cite{http://colah.github.io/posts/2015-08-Understanding-LSTMs/}). Every block concatenates the last hidden state with the current input, passing the result to an activation function (tanh in this illustration). The result is carried forward as the updated hidden state. 

**LSTM (Long-Short Term Memory).** A type of RNN, it improves on its basic design most importantly by including an long memory state which is allowed to be transferred across several update steps with only minimal changes (superior horizontal line inside the repeating module in /ref{fig-lstm}). This allows information to persist across many cell updates, thus making it possible to capture long-term dependencies. The extent to which this long memory state is preserved is controlled by forget gate, illustrated in /ref{fig-lstm}) by the leftmost vertical path inside the cell. The other paths represent other gated state transfers, which determine how (a) the previous cell state, (b) the previous long memory state and (c) the current cell inputs are combined and passed to the next cell iteration and as input to deeper layers. 

![http://colah.github.io/posts/2015-08-Understanding-LSTMs/img/LSTM3-chain.png](http://colah.github.io/posts/2015-08-Understanding-LSTMs/img/LSTM3-chain.png)

Fig ???. Basic LSTM architecture in its unfolded representation (adapted from \cite{http://colah.github.io/posts/2015-08-Understanding-LSTMs/}). 

**NBEATS.** Uses as building block (a) a multi-layer fully connected network with ReLU nonlinearities, which feed (b) basis layers that generate a backcast and a forecast output. Blocks are arranged into stacks, organized to form a model.  Models resulting from this architecture consistently outperformed state-of-the-art methods for univariate forecasting across different horizons and thousands of time series datasets of different nature, while using a single hyperparameter configuration (\cite{bengio2020nbeats}).  

![image-20200616201550854](/home/jonasmmiguel/.config/Typora/typora-user-images/image-20200616201550854.png)

Fig ???. NBEATS architecture.

Hybrid methods combine machine learning and statistical approaches by using the outputs from statistical engines as features \cite{bengio2020nbeats}. Below we present ES-RNN, a hybrid method winner of the 2017 M4 forecasting competition.

**ES-RNN.** It uses Holt-Winters' ES method as statistical engine for capturing the seasonal and level components from the time series into features, which are then used by an LSTM model to exploit non-linear dependencies.
$$
\begin{aligned}
\hat{y}_{t+h|t} = LS&TM(y_t,\ell_t, s_t)\\
where \ \ \ell_t &= \alpha \frac{y_t}{s_{t-m}} + (1-\alpha)\ell_{t-1}   &(level) \\
s_t &= \gamma y_t/\ell_{t} + (1-\gamma)s_{t-m} \ \ \ &(seasonal)
\end{aligned}
$$

## 2.4 Spatio-Temporal Forecasting

In the spatio-temporal (ST) version of this problem, one aims to attain a function $f: \mathbb{R}^{|V|\times T} \rightarrow \mathbb{R}^{|V|}$ that maps historical observations of a quantity across different regions $v\in V$, $\boldsymbol{y}_t = [y_{1,t}\  \  y_{2,t}\ \ \cdots \ \ y_{|V|,t}]^\top$ ,  to its value $\boldsymbol{y}_{t+1}$ in the next timestep  (\ref{eq-spatio-temporal-forecasting}). 
$$
[\boldsymbol{y}_{t-T+1}, \  \cdots\ , \boldsymbol{y}_{t}] \xrightarrow{f(\cdot)} \boldsymbol{y}_{t+1}
$$
For some forecasting problems such as for the weather-conditioned wind power generation, the spatial dependency might play an important along with the temporal dependencies themselves (\cite{engeland2017variability}). In this work, we consider three different approaches to the ST forecasting problem. In a naïve approach, time series for different locations are modeled independently, thus neglecting spatial dependencies. In a second approach, the time series are modeled jointly via a multivariate forecasting approach, where for generating a single model one relies on historical observations not from a single but from several input variables, which can be expressed by a sequence of input vectors $\boldsymbol{X}_{1:T} = \{\boldsymbol{X}_1, ..., \boldsymbol{X}_T\}$.  Finally, we consider the explicit modeling of both spatial and temporal dependencies via dynamic graphs. The latter approach is represented by the methods presented below.

**DCRNN (Diffusion Convolutional RNN).** RNN is leveraged by replacing the matrix multiplication by a diffusion convolution (\cite{liu2020intro}). Motivated by the traffic forecasting problem, where spatial dependencies are directional (non-Euclidean), Li et al. (\cite{li2018dcrnn}) recast the spatio-temporal evolution of a variable as a diffusion process on a directed graph, where every node corresponds to a sensor. Learning is performed via (1) diffusion convolution, further integrated with a (2) seq-to-seq learning framework, and a (3) scheduled sampling for modeling long-term dependencies (\ref{fig-dcrnn}). 

![image-20200616234156789](/home/jonasmmiguel/.config/Typora/typora-user-images/image-20200616234156789.png)

Fig ???. The DCRNN architecture (adapted from \cite{li2018dcrnn}).

**ST-GCN**. A spatial-temporal graph is generated by stacking graph frames from all timesteps, each frame representing the graph state at a specific time (\ref{fig-stgcn}). The spatial-temporal graph is partitioned, and to each of its nodes is assigned a weight vector.   Finally, a graph convolution is performed on the weighted spatial-temporal graph.

![image-20200616235706340](/home/jonasmmiguel/.config/Typora/typora-user-images/image-20200616235706340.png)

**Graph WaveNet.** Uses as building blocks a Temporal Convolution Network (TCN) and a Graph Convolution Network (GCN) for capturing spatio-temporal dependencies in every module. A core idea is the usage of a learnable self-adaptative adjacency matrix, which allows node dependencies to change over time and not necessarily be determined by their distances. (\cite{wu2019graphwavenet}, \cite{liu2020intro}).

![image-20200617004620751](/home/jonasmmiguel/.config/Typora/typora-user-images/image-20200617004620751.png)

Fig. ??? The Graph WaveNet architecture. 

### 2.3.1 Metrics

- (spatio-temporal/multivariate version)