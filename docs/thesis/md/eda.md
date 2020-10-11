# The dataset

For all investigations in this work, we use the two datasets from \cite{}.
We name them the measurements dataset and the sensors dataset.
The first dataset is the main source of temporal information, while the second conveys most of the spatial information we use.

The measurements dataset (\ref{table:measurements-dataset}) consists of measurements for wind power generation (in kW) in Germany, being measured, aggregated and reported by wind farm operators and published by german federations. 

<img style="" data-natural-width="619" data-natural-height="210" data-lazy-loaded="" src="https://s3.amazonaws.com/media-p.slid.es/uploads/1280418/images/7527829/pasted-from-clipboard.png">

The sensors dataset (\ref{table:sensors-dataset}) reports individual turbines design and commissioning specifications provided by operators, most importantly the geolocation, the rated power and the commissioning date. 

<img style="" data-natural-width="897" data-natural-height="182" data-lazy-loaded="" src="https://s3.amazonaws.com/media-p.slid.es/uploads/1280418/images/7527809/pasted-from-clipboard.png">

Both datasets were compiled and prepared by authors in \cite{}, most importantly by imputing missing entries (about 15\% in the measurements dataset, 8\% in the sensors dataset) via machine learning-based methods. We summarize their main characteristics in table \ref[table].

% TODO: add to dataset summary: primary key, foreign key, quantity is kW 

# Exploratory Data Analysis 

We carried out an exploratory data analysis on both datasets to better understand their generation process, as well as to identify data patterns and limitations.
As final purpose, we used the findings resulting from this analysis to not only guide our design decisions on both preprocessing and modeling, but also to define our key modeling assumptions.

First, we identified major spatial and temporal conditions underlying the data generation. 
Figure \ref{fig:3-germanies} highlights the most relevant findings. 
Figure \ref{fig:3-germanies}(a) shows how the 23191 onshore wind turbines are spatially distributed across 296 districts harvesting wind power \ref{fig:3-germanies}(c).
Although the northern region still concentrates most of the generation capacity (\ref{fig:3-germanies}(c)) and concentrates most of the high-yield single units so as to harness the local higher wind power availability (\cite{windatlas}), figure \ref{fig:3-germanies}(b) evidences a recent the trend over the last decade.
Germany has been commissioning more turbines, typically of medium-yield, closer to locations of high electricity demand at the southern and central Germany so as to prevent curtailments due to network congestion (\cite{}). 

![image-20201010174311628](/home/jonasmmiguel/.config/Typora/typora-user-images/image-20201010174311628.png)

The second step in our analysis concerned the determination of (1) how power generation is distributed and (2) what is a typical production behavior.
The kernel-estimated density function for the districtwise, yearly average power generation (e.g. figure \ref[power-generation]) suggests a unimodal, approximately log-normal distribution.

<div class="sl-block is-focused" data-block-type="image" style="width: 697.35px; height: 430.857px; left: 380.993px; top: 324.572px; min-width: 1px; min-height: 1px;" data-name="image-20491b" data-origin-id="270c39e3c433fa37a13ce0bdc8bc2690"><div class="sl-block-content" style="z-index: 14;"><img style="" data-natural-width="2185" data-natural-height="1350" data-lazy-loaded="" src="https://s3.amazonaws.com/media-p.slid.es/uploads/1280418/images/7517216/power-generated-yearly-distribution.png"></div></div>

We noticed near-median yearly power productions tend to be distributed across time as the one shown in figure \ref[typical-production]. 
The observed Weibull distribution is in agreement with other authors findings (\cite{, , ,}).
Here, we notice an important behavior trend: not only the measurements values vary, but also their amplitude, as new turbines are commissioned (and decommissioned).
This is specially significant in case of Germany, where wind power generation rapidly increases its share in the energy portfolio.

This might pose a significant limitation to models inferred from historic data for power generation alone, as they would be unable to capture the correlations arising from the causal effect of (de-)commissionings on future values of power generation. 
In other words, trained on the dataset as it is, models would be unable to account for eventual sudden increases in power generation due to new commissionings, eventually underestimating the .
Furthermore, we would expect this effect to be more pronounced for longer forecast horizons, as the probability of new commissionings for the forecast period would increase.   

<div class="sl-block is-focused" data-block-type="image" style="width: 1612.8px; height: 331.665px; left: 147.2px; top: 340.451px; min-width: 1px; min-height: 1px;" data-name="image-d0981e" data-origin-id="7f528c326e07deb5d10f76a18c7f22fd"><div class="sl-block-content" style="z-index: 14;"><img style="" data-natural-width="2480" data-natural-height="510" data-lazy-loaded="" src="https://s3.amazonaws.com/media-p.slid.es/uploads/1280418/images/7525976/wpg-daily-typical-ts_20200701_155716_fav.png"></div></div>

One way to overcome this would be to provide to the models an exogenous feature which informed it about new commissioning ahead.
Not every forecasting approach supports this, however, as in the case of historical average or single-input ARIMA variants.
This would thus limit the comparability of methods performance.

For this reason, we use another approach in this work.
Essentially, we train the models to predict a normalized version of the time series and handle the effect by re-scaling model outputs in a model-agnostic, post-processing step.
More specifically, we scale each time series value by the installed capacity for the specific district and point in time.
In the renewables field, the resulting scaled variable is known as the Capacity Factor ($CF$) (\cite{}).
The resulting time series are illustrated in \ref{fig:CF}.

<div class="sl-block is-focused" data-block-type="image" style="width: 1612.8px; height: 331.665px; left: 147.2px; top: 683.189px; min-width: 1px; min-height: 1px;" data-name="image-77f71a" data-origin-id="f16ba894007f8d52391d7add8a15608e"><div class="sl-block-content" style="z-index: 16;"><img style="" data-natural-width="2480" data-natural-height="510" data-lazy-loaded="" src="https://s3.amazonaws.com/media-p.slid.es/uploads/1280418/images/7527739/wpg-cf-daily-typical-ts_20200703_075319.png"></div></div>

<div class="sl-block is-focused" data-block-type="image" style="width: 1612.8px; height: 331.665px; left: 147.2px; top: 676.335px; min-width: 1px; min-height: 1px;" data-name="image-9d17cf" data-origin-id="87be763b06e4f30b71adee9f49bde594"><div class="sl-block-content" style="z-index: 14;"><img style="" data-natural-width="2480" data-natural-height="510" data-lazy-loaded="" src="https://s3.amazonaws.com/media-p.slid.es/uploads/1280418/images/7527877/wpg-cf-daily-all-ts_20200701_163815_fav.png"></div></div>One way to overcome this would be to provide to the models an exogenous feature which informed it about new commissioning ahead.

While the transformation of time series from kW into Capacity Factors solves the issue concerning new commissionings, another issue involving the distribution of time series values remains.
Being Weibull-distributed, values in a time series would be concentrated around the median, thus less discernible from one another than if they were normally distributed, for instance.
Thus, we expect gains in terms of informational entropy and thus in model training cost and performance by properly scaling the model inputs.
The nature of the Weibull density function suggests that any linear scale such as the min-max scaling would not suffice to improve discernibility (informational entropy) in our data.
%As a consequence, the models performance would be unnecessarily more conditioned on the numerical precision, %which could eventually provoke unwanted loss of informational entropy. 
%In fact, any linear transformation would incur in the same shortcoming.

In a third step of our exploratory data analysis, we investigated to what extent power generation is correlated in space and time. 
For the spatial dependency, we inquired *"how more similarly do closer districts behave than distant ones?"*.
We performed this by assessing how pairwise Spearman correlations between districts change as districts are more distant from one another (\cite{}).
We verified that pairwise Spearman correlations between closer districts are significantly higher than distant ones, evidencing a significant spatial character for power production (\ref{fig:spatial-correlation}).
In fact, districts present significant correlations ($\rho_s>0.8$) for distances up to about 150 km.
This *decorrelation distance* is in agreement with values found for Central Europe by other authors (\cite{}).

<img style="" data-natural-width="2185" data-natural-height="1350" data-lazy-loaded="" src="https://s3.amazonaws.com/media-p.slid.es/uploads/1280418/images/7525093/correlation-spearman-vs-distance.png">

We followed a similar procedure to assess the temporal correlation between time series.
In order to attain evidence for this, we used cross-correlograms, which evaluate a cross-correlation function such as the Pearson coefficient $\rho$ as one time series is shifted in time in relation to the other time series.
Figure \ref{fig:cross-correlogram-1} shows an instance of correlogram for a pair of districts at decorrelation distance. 
Figure \ref{fig:cross-correlogram-all} presents the superposition of all correlograms.
We verify a decorrelation time delay of 12 hours, which is in agreement with the literature for Central Europe (\cite{}).



![image-20201010185402380](/home/jonasmmiguel/.config/Typora/typora-user-images/image-20201010185402380.png)

![image-20201010185442419](/home/jonasmmiguel/.config/Typora/typora-user-images/image-20201010185442419.png)

## EDA conclusions

In general, the EDA was important to verify that spatio-temporal dependencies are significant in the use case at hand.
Below, we summarize the main consequences this analysis had to our design decisions.

**Preprocessing**. Handling missing data is not necessary, but scaling the time series e.g. into capacity factors is expected to heavily influence model performances. Weibull-distributed time series might require non-linear scaling.   

**Modeling.** Aggregating time series to time resolutions coarser than 12 hours might diminish correlations between them, thus potentially limiting the potential accuracy gains in using spatio-temporal approaches.

**Key modeling assumptions.** In this work, we assume negligible the effects of (a) curtailments, (b) maintenance of individual units, (c) decommissioning of individual units, (d) sudden increases in capacity factor due to technological advances.

# Pipeline

We developed a pipeline  (\ref{fig:project-pipeline} comprising (1) a data engineering pipeline, and (2) a data science pipeline). 

## Data Engineering Pipeline

The data engineering pipeline (\ref{fig:de-pipeline}) encompasses all the data processing steps involved between (a) measurements and sensors datasets and (b) daily capacity factors, sensors graph inputs.

%TODO: figure

**Get Capacity Installed Time Series.** We load the sensors dataset and build a time series for the capacity installed in every district, essentially by grouping  turbine entries by district, and performing a cumulated sum of power ratings over the commissioning date-sorted entries. 

**Get Power Centroids.** A centroid position is defined for every district, not by its baricenter, but from the rated power-weighted average of all its single turbines coordinates. In practice, the power centroid changes its position every time  a new turbine is commissioned. We neglect this variation over time, and take the resulting average as sufficiently accurate for its purpose. Namely, we use the power centroids for calculating representative Euclidean distances between districts, which we used for the EDA and also when calculating the adjacency matrix initialization values for the graph-based spatio-temporal forecasting methods.

**Concatenate and Downsample.** We concatenate the measurements dataset (power generated districtwise, in $kW$), which is provided for every year, into a single hourly dataframe, then downsample it into a daily measurements by summing same-day entries.

**Filter Districts.**  We filter out previously determined districts  which either represent outliers in spatial correlogram (3 from 303) or have zero installed capacity by 2015-01-01 (4 from 303). Also, districts in which by 2000-01-01 a single turbine represents more than 50\% of its installed capacity (18 districts in total). Although the latter measure might represent a deviation from the industry use case, we perform it in favor of metrics representativity, as otherwise models overall performance metrics would be biased by low predictibility of ill-conditioned time series e.g. from districts where wind harvesting are still in early phases.  

**Transform kW to CF.** Every entry in measurements time series dataset is normalized by the corresponding local installed capacity at the same day. This results in daily time series for capacity factors in every district.

## Data Science Pipeline

This section of the project pipeline processes (a) user-defined parameters, (b) the capacity factors dataset resulting from the data engineering pipeline and, when required, also (c) the power centroids. 

**Get Initial Adjacency Matrix.** We calculate the matrix of the pairwise Euclidean distances and transform it into an adjacency matrix. For initializing the values of the (constant) adjacency matrix in DCRNN or the self-adaptive adjacency matrix in the Graph WaveNet case, we apply the Gaussian distance function on every entry of the distances matrix (also used in \cite{DCRNN, GWNet}), so that $A_{ij} = exp(-D_{ij}/\sigma_{D})$, where $\sigma_{D}$ is the standard deviation of the distances matrix. Also as in \cite{DCRNN}, we promote sparsity in the adjacency matrix for computational efficiency by thresholding the entries in the adjacency matrix. However, instead of defining an arbitrary threshold value for $A_{ij}$, we prune adjacency values when the distances they are calculated from surpasses the decorrelation distance of 150 km. This node function is only processed in experiments with DCRNN and Graph WaveNet, as they are the only methods considered which rely on an adjacency matrix.

**Split Inference-Test Data.** We split the capacity factors measurements dataset into a model inference dataset, used for training and model selection, and a test dataset, reserved for the model performance evaluation. The split is done according to the user-defined date ranges defined for each partition.

**Scale.** We apply the user-defined sequence of scaling and offsetting methods on the inference data. 

**Define CV Splits Positions.** Date ranges for defining respectively the training and the validation datasets are determined, the validation window always positioned on dates later than training window last entry. User-defined entries for this function include the cross-validation type and the pertaining parameters. For expanding window CV, the parameters are the relative size of the shortest train window (0.0 - 1.0 proportion of model inference dataset size), the number of total CV passes, the number of steps ahead, and the forecast window size.

**CV Train.** Trains a model for every CV split as well as one for the entire scaled model inference dataset. In the case of single time series-modeling methods such as Holt-Winters Exponential Smoothing, the resulting model is actually a simple collection of single time series submodels.

**Evaluate.** Makes predictions using every trained model in the experiment and calculate overall model performance metrics.  

# Experiments

Currently, all forecasting approaches are evaluated on a reduced case consisting of (a) 5 districts on northern Germany (DEF0C, DEF07, DEF0B, DEF05, DEF0E) located within 80 km distance from one another, (b) model inference time window from 2013-01-01 to 2015-06-22 and test time window from 2015-06-23 to 2015-06-29. We chose the test time window to be in a year period known to be less susceptible to wind gusts and other weather anomalies. Both models were evaluated in terms of predictions in capacity factors, with cross-districts uniform average of metrics. With regards of model tuning, only manual procedure has been carried out.   

**HW-ES.** For preprocessing, relies on quantile transformation into a normal distribution, followed by an offsetting by the absolute value of the minimum of every scaled time series. The latter step is performed to ensure model inputs are strictly positive so as to allow for multiplicative seasonal approach in the HW-ES method. As for hyperparameters, we use additive trend, multiplicative seasonal, seasonal period of 7 steps (days). 

**Graph WaveNet.** For preprocessing, relies on a Z-standard scaling. As for hyperparameters, we define most importantly the number of nodes (5), the sequence length (12), the learning rate (1E-3), and the learning decay rate (0.97).

# Results & Discussion

Table \ref{tab:performances} summarizes the models performances, according to cross-district uniform averages of metrics.
For the reduced case, the spatio-temporal approach GWNet generally outperforms the purely temporal approach HW-ES.
We expect this difference to grow even larger in a larger-scale study case including more districts, as the GWNet approach can make use of more inter-time series correlations.

```TeX
\begin{table}[]
\begin{tabular}{l|cc}
     & HW-ES  & GWNet  \\ \hline
MAE  & 0.182  & 0.091  \\
RMSE & 0.116  & 0.231  \\
MAPE & 41.4\% & 1.78\%
\end{tabular}
\end{table}
```

# Conclusion & Next Steps

Accounting for cross-time series dependencies seems to indeed improve model accuracy, although only a reduced case has been carried out so far. 

Besides expanding the use case to the other districts and its training time window up to, we are reassessing the plausibility of the model evaluation period (currently a fixed week) and metrics.
We intend to reassess model performance in terms of predictions in power generation in kW, and to make a separate model evaluation with metrics more appropriate for the specific use case of renewables power generation.

With regards to the contributions of this work, we invested a significant proportion of effort to follow good practices and data science development standards, so as to ensure reproducibility of results as well as reusability of methods and tools. 







