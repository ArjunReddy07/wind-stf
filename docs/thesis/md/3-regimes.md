2.1.1 Problem statement

In this work, we categorize spatio-temporal forecasting problems according to (1)
the degree of dependency among sensors and (2) the stationarity of sensors locations. The
term sensor is used here in the abstract sense of a stochastic data generation process,
which could be physically represented by an actual sensor measuring a variable of interest
in a particular phenomenon.
In a first regime, referred here as regime I, sensors are fixed in space, with negligible
dependencies among them. The uncertainty about the state of a sensor cannot be reduced
by knowing the states of its neighboring sensors. As a consequence, using a single model
to represent the different sensors is expected to present no advantage over modeling every
sensor independently. Characteristic of this regime is also the covariance matrix for the
different sensors being both diagonal and invariant in time.
In regime II, sensors are also fixed in space, but this time with significant dependen-
cies among them. The uncertainty about the state of a sensor can be reduced by knowing
the states of its neighboring sensors. In other words, uncertainties among sensors are
coupled. Modeling sensors together could be potentially beneficial in such case. Besides,
the covariance matrix is expected to be non-diagonal but still invariant in time.
Finally, in regime III, dependent sensors move in space. Dependencies across sensors
should hence also change over time, and a corresponding time-dependent covariance matrix
is expected to follow. Again, models representing multiple sensors could make use of this
and outperform models for single sensors.



**I negligible association**

**II significant, time-invariant association**

**III significant association**



20200601 Roberto Fray

- objetivos: forecasting settings as dependence regimes
  - uma forma de apresentacao de problema em que univariate time series seja um caso especial, uma simplificacao de spatiotemporal series
  - uma forma de apresentacao que ajude a discernir e a guiar a abordagem de forecasting apropriada: convencionais univariate, convencionais multivariate ou deep learning?
- faz sentido?
- já leu sobre alguma categorizacao de problemas de forecasting semelhante?
- melhor como hipótese? Complitude vs Extendability

**Suggestions**

Forecasting settings != Dependency settings

Before stating problems

- what is temporal, spatio, spatiotemporal dependency & references
- what is forecasting & references

No sensor; direct problem statement, no abstraction

How the problem is currently approached

Diferentes classes de correlacao: sem referencia

através de referencias, convencer leitor de que regime III é o pior e que wind power generation é regime III

comparing models: performance + **custos/training time** & inference time

"correlacao temporal" err => autocorrelation

"sensor" = variate (check)

"sensor measurements"

