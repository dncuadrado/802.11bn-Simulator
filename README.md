# IEEE 802.11bn Simulator

The IEEE 802.11bn Simulator is designed to evaluate the downlink performance of a Multi-AP Coordination (MAPC) Wi-Fi Network . This repository implements a flexible simulation framework capable of modeling different traffic types, network configurations, and MAC protocols (including EDCA and various CSR-based schedulers).

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Simulator Configuration](#simulator-configuration)
  - [Input Parameters](#input-parameters)
  - [Simulation Execution Flow](#simulation-execution-flow)
- [Running the Simulator](#running-the-simulator)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Overview

The simulator focuses on evaluating the downlink performance in a network with multiple Access Points (APs) and Stations (STAs). It supports:

- **Traffic Modeling:** Choose among Poisson, Bursty, and Constant Bit Rate (CBR) traffic.
- **Scenario Configuration:** Define AP/STA numbers, grid dimensions, and even incorporate walls in the scenario.
- **System Parameters:** Configure TXOP durations, noise, bandwidth, and more.
- **MAC Protocols:** Compare the performance of traditional EDCA against MAPC, with different scheduling algorithms including:
  - Maximum Number of Packets (MNP)
  - Oldest Packet (OP)
  - Traffic-Alignment Tracker (TAT)

Performance metrics are evaluated over multiple iterations (each representing a unique channel realization), and various plots are generated to illustrate performance aspects such as delay distributions, and collision probabilities, etc

---

## Features

- **Flexible Traffic Generation:** Supports different traffic types (`'Poisson'`, `'Bursty'`, `'CBR'`) and load configurations.
- **Detailed Scenario Modeling:** Place APs and STAs in grid-based scenarios with custom wall definitions.
- **Overhead & Power Calculations:** Uses dedicated functions (`TXpowerCalc` and `OverheadsCalc`) to compute TX power, subcarrier numbers, and overheads.
- **Multiple Simulation Systems:** Simulate EDCA and MAPC systems (with different schedulers) in parallel.
- **Comprehensive Plotting:** Generate percentile, CDF, and other performance plots using the `MyPlots` class.

---


---

## Getting Started

### Prerequisites

- **MATLAB:** R2018b or later is recommended.
- **MATLAB Toolboxes:** Ensure that any required toolboxes (e.g., Signal Processing Toolbox) are installed.

### Installation

1. **Clone the Repository:**

    ```bash
    git clone https://github.com/dncuadrado/802.11bn-Simulator.git
    ```

2. **Set Up the MATLAB Path:**

    Open MATLAB and add the repository folder (and its subdirectories) to your MATLAB path:

    ```matlab
    addpath(genpath('path_to_repository'));
    ```

---

## Simulator Configuration

### Input Parameters

The simulator’s behavior is controlled via a set of input parameters defined at the beginning of the main simulation script `Simulator.m`. Below is an explanation of the key parameters:

- **Traffic Parameters:**
  - `traffic_type`: Defines the type of traffic. Options include `'Poisson'`, `'Bursty'`, or `'CBR'`.
  - `traffic_load`: Specifies the load level. For Poisson and Bursty, use `'low'`, `'medium'`, or `'high'`. For CBR, specify in the format `'x-y'` where `x` is the bitrate and `y` is the frames per second.
  - `EDCAaccessCategory`: Sets the EDCA access category ( `'BE'`, `'VI'`).

- **Scenario-Related Parameters:**
  - `AP_number`: Number of Access Points.
  - `STA_number`: Number of Stations.
  - `grid_value`: Length of the simulation grid (the scenario is a `grid_value x grid_value` area).
  - `scenario_type`: Scenario type (e.g., `'grid'` where APs are centrally placed in subareas and STAs surround them).
  - `walls`: A matrix defining wall segments in the scenario. Each row represents a wall with coordinates `[x1 x2 y1 y2]`.

- **System-Related Parameters:**
  - `TXOP_duration`: Duration of a Transmission Opportunity (e.g., `5E-3` seconds).
  - `Pn_dBm`: Noise power in dBm.
  - `Cca`: Clear Channel Assessment threshold in dBm.
  - `BW`: Bandwidth (in MHz; typical values are 20, 40, 80, or 160).
  - `Nss`: Number of spatial streams.
  - `L`: Number of bits per frame.

- **Overhead and Power Calculations:**
  - The simulator calculates the number of subcarriers (`Nsc`) and the maximum TX power using the function `TXpowerCalc`.
  - Overheads for EDCA and CSR are computed using `OverheadsCalc`.

- **Iteration and Traffic Generation:**
  - `iterations`: Sets how many independent simulation runs (channel realizations) will be executed.
  - Traffic for each STA is generated using the `TrafficGenerator` function and validated to ensure the simulation duration (`timestamp_to_stop`) exceeds the final packet arrival time.

### Simulation Execution Flow

Each simulation iteration involves the following steps:

1. **Device Deployment:**
   - APs and STAs are randomly deployed using `AP_STA_coordinates`.
   - The association between APs and STAs is determined using `AP_STA_Association`.
   - The channel matrix and RSSI values are computed using `GetChannelMatrix`.

2. **Throughput and Overhead Calculations:**
   - The throughput for each STA under EDCA is calculated via `Throughput_EDCA_bianchi`.
   - Coordinated Groups (CGs) for STAs and TX power allocation are computed using `CGcreation`.

3. **Traffic Generation:**
   - Traffic arrivals are generated for each STA based on the specified traffic type and load.
   - The simulation ensures that the traffic generation duration (`timestamp_to_stop`) is appropriate.

4. **Running Simulations:**
   - **EDCA Simulation:** An instance of `MAPCsim` is configured and run with the simulation system set to `'EDCA'`.
   - **MAPC Simulations:** Additional instances of `MAPCsim` are configured for CSR with different schedulers:
     - **MNP:** Maximum Number of Packets scheduler.
     - **OP:** Oldest Packet scheduler.
     - **TAT:** Traffic-Alignment Tracker scheduler (with configurable `alpha_` and `beta_` parameters).

5. **Plot Generation:**
   - After simulation, various plots are generated to visualize performance metrics such as:
     - Percentile values (e.g., 50th and 99th percentiles)
     - Delay distributions (CDF for total delay and per STA)
     - Number of TXOP won per AP
     - AP collision probabilities
     - STA selection counters

   These plots are handled by an instance of the `MyPlots` class.

---

## Running the Simulator

1. **Open MATLAB:**
   Navigate to the cloned repository directory.

2. **Run the Main Simulation Script:**
   Execute the main simulation file (`Simulator.m`):

3. **Observe the Output:**
   The simulator will run for the defined number of iterations, and the specified plots will be generated for each iteration. You can modify the plotting commands in the script (by commenting or uncommenting) to display your desired outputs.

---

## Contributing

Contributions to enhance the simulator, fix bugs, or add new features are very welcome! 

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact

For questions or issues, please open an issue on GitHub or contact:

**David Nunez**  
Email: [david.nunez@upf.edu](mailto:david.nunez@upf.edu)

---

Happy simulating!

