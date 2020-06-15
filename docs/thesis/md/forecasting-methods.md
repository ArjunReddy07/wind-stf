# Conventional Methods

## Exponential Smoothing

> - Exponential smoothing was proposed in the late 1950s (Brown, [1959](https://otexts.com/fpp2/expsmooth.html#ref-Brown59); Holt, [1957](https://otexts.com/fpp2/expsmooth.html#ref-Holt57); Winters, [1960](https://otexts.com/fpp2/expsmooth.html#ref-Winters60)), and has motivated some of the most successful forecasting methods.  [[hyndman20XXprinciples](https://otexts.com/fpp2/expsmooth.html)]
>
> - Forecasts produced using exponential smoothing methods are *weighted  averages of past observations, with the weights decaying exponentially  as the observations get older*. In other words, *the more recent the  observation the higher the associated weight.* [[hyndman20XXprinciples](https://otexts.com/fpp2/expsmooth.html)]

# Machine Learning Methods

## RNNs

(... )  deep learning models (...) designed specifically for processing *sequential data*, and thus could be applied for time series. [[smirnov20XXtsc]](https://project.inria.fr/aaldt18/files/2018/08/oral.pdf)

Spatial temporal forecasting is a crucial task which is widely applied in traffic forecasting, human action recognition, and climate prediction. Some of the forecasting tasks can be modeled as prediction tasks on dynamic graphs, which has static graph structure and dynamic input signals. As shown in Figure 9.2, given historical graph states, the goal is to predict the future graph states.

## GNN-based

To capture both spatial and temporal information, DCRNN [Li et al., 2018d] and
STGCN [Yu et al., 2018a] collect spatial and temporal information using independent modules. DCRNN [Li et al., 2018d] models the spatial graph flows as diffusion process on the graph. The diffusion convolution layers propagate spatial information and update nodes’ hidden states. For temporal dependency, DCRNN leverages RNNs in which the matrix multiplication is replaced by diffusion convolution. The whole model is built under sequence-to-sequence ar-
chitecture for multiple step forward forecasting. STGCN [Yu et al., 2018a] consists of multiple spatial-temporal convolutional blocks. In a spatial-temporal convolutional block, there are two temporal gated convolutional layers and one spatial graph convolutional layer between them. The residual connection and bottleneck strategy are adopted inside the blocks.

![image-20200615023524122](/home/jonasmmiguel/.config/Typora/typora-user-images/image-20200615023524122.png)

Figure 9.2: An example of spatial temporal graph. Each Gt indicates a frame of current graph state at time t.

Differently, Structural-RNN [Jain et al., 2016] and ST-GCN [Yan et al., 2018] collect spatial and temporal messages at the same time. They extend static graph structure with temporal connections so they can apply traditional GNNs on the extended graphs. Structural-RNN adds edges between the same node at time step t and t C 1 to construct the comprehension representation of spatio-temporal graphs. Then, the model represents each node with a nodeRNN and each edge with an edgeRNN. The edgeRNNs and nodeRNNs form a bipartite graph and
forward-pass for each node. 

**ST-GCN** [Yan et al., 2018] stacks graph frames of all time steps to construct spatial-temporal graphs. The model partitions the graph and assigns a weight vector for each node, then performs graph convolution directly on the weighted spatial-temporal graph.

**Graph WaveNet** [Wu et al., 2019d] considers a more challenging setting where the adjacency matrix of the static graph doesn’t reflect the genuine spatial dependencies, i.e., some dependencies are missing or some are deceptive, which are ubiquitous because the distance of nodes doesn’t necessarily mean a causal relationship. They propose a self-adaptive adjacency matrix which is learned in the framework and use a Temporal Convolution Network (TCN) together with a GCN to address the problem.