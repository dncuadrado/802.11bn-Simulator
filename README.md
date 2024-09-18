# IEEE 802.11bn simulator

This repository contains a simulator for Coordinated Spatial Reuse on the context of IEEE 802.11bn wireless communication systems. Besides, it is possible to obtain results for the traditional IEEE 802.11 access mechanism, i.e., Distributed Coordination Function (DCF). In general, this simulator is designed to model and analyze the performance of IEEE 802.11-based networks.

The following instructions are referred to the main file "Simulator.m"

## Input Parameters

The simulation system is configured using the `simulation_system` variable. It can be set to either 'DCF' or 'CSR' based on the desired system simulation.

### Scenario-related

- `AP_number`: Number of Access Points (APs)
- `STA_number`: Number of Stations (STAs)
- `grid_value`: Length of the scenario (grid_value x grid_value)
- `scenario_type`: 'grid', APs are placed in the centre of each subarea or 'random', all devices randomly deployed
- `walls`: Scenario design with wall segments defined by coordinates (x1, x2, y1, y2)

### System-related

- `TXOP_duration`: Duration of the TXOP (Transmission Opportunity)
- `Pn_dBm`: Noise level in dBm
- `Cca`: Clear channel assessment in dBm (default Cca = -82 dBm)
- `Nsc`: Number of data subcarriers
- `Nss`: Number of spatial streams
- `L`: Number of bits per single frame

### CSR-related

- `gamma_value`: Gamma parameter for creating CSR groups
- `priority`: Priority for CSR scheduling (1: number of packets, 2: oldest packets)

### Traffic-related

- `traffic_load`: Traffic load in bits per second (bps)
- `poisson_rate`: Packet generation rate per second
- `event_number`: Number of packets transmitted during the simulation

## Running the Simulator

1. Set the `simulation_system` variable to either 'DCF' or 'CSR'.
2. Modify other input parameters as needed.
3. Run the simulator.

## Output Analysis

The simulator outputs various performance metrics, and the analysis is performed at the end of the simulation.
Plots can be activated or deactivated at the end of the file "Simulator.m"

### Validation
The simulator is validated against Bianchi's model. Make sure that `traffic_load` is high enough to saturate the network and `simulation_system` = 'DCF'. Besides, the higher the `event_number` parameter the higher the accuracy of the simulation result when compared with analytical (bianchi's)

- `traffic.PlotValidation`: Simulated Throughput and Collision probability against bianchi's


### Plots

- `PlotCDFdelayTotal`: Cumulative Distribution Function (CDF) of total delay (all transmitted packets by all STAs).
- `PlotCDFdelayPerSTA`: CDF of delay per STA.
- `PlotWorstCaseDelayPerSTA`: Worst-case delay per STA.
- `PlotPrctileDelayPerSTA(99)`: Percentile delay per STA. Indicate inside the parenthesis the percentile to compute 
- `PlotTXOPwinNumber`: Number of times each AP wins the contention
- `PlotAPcollisionProb`: AP collision probability.
- `PlotSTAselectionCounter`: Counter for STA selection.

## License

This simulator is provided under the [CC0 1.0 Universal Public Domain Dedication](LICENSE).

### CC0 1.0 Universal

- **Waiver**: Affirmer (the person associating CC0 with a Work) fully and irrevocably waives all Copyright and Related Rights.
- **Purpose**: The purpose is to contribute to a commons of creative, cultural, and scientific works, allowing the public to build upon, modify, and reuse the Work without fear of infringement claims.
- **Public License Fallback**: In case any part of the Waiver is legally invalid, Affirmer grants a royalty-free, non-exclusive license to exercise Copyright and Related Rights.
- **Limitations and Disclaimers**: No trademark or patent rights held by Affirmer are affected. Affirmer provides the Work as-is without warranties, and disclaims responsibility for clearing rights or obtaining consents.

**Read the full text of the CC0 1.0 Universal Public Domain Dedication**: [CC0 1.0 Legal Code](https://creativecommons.org/publicdomain/zero/1.0/legalcode)

CREATIVE COMMONS CORPORATION IS NOT A LAW FIRM AND DOES NOT PROVIDE LEGAL SERVICES. DISTRIBUTION OF THIS DOCUMENT DOES NOT CREATE AN ATTORNEY-CLIENT RELATIONSHIP. CREATIVE COMMONS PROVIDES THIS INFORMATION ON AN "AS-IS" BASIS. CREATIVE COMMONS MAKES NO WARRANTIES REGARDING THE USE OF THIS DOCUMENT OR THE INFORMATION OR WORKS PROVIDED HEREUNDER, AND DISCLAIMS LIABILITY FOR DAMAGES RESULTING FROM THE USE OF THIS DOCUMENT OR THE INFORMATION OR WORKS PROVIDED HEREUNDER.
## Contribute
If you want to contribute, please contact david.nunez@upf.edu or boris.bellalta@upf.edu
