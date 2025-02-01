# IEEE 802.11bn Simulator

The IEEE 802.11bn Simulator is designed to evaluate the downlink performance of a Multi-AP Coordination Network (MAPC). This repository implements a flexible simulation framework capable of modeling different traffic types, network configurations, and MAC protocols (including EDCA and various CSR-based schedulers).

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Simulator Configuration](#simulator-configuration)
  - [Input Parameters](#input-parameters)
  - [Simulation Execution Flow](#simulation-execution-flow)
- [Running the Simulator](#running-the-simulator)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Overview

The simulator focuses on evaluating the downlink performance in a network with multiple Access Points (APs) and Stations (STAs). It supports:

- **Traffic Modeling:** Choose among Poisson, Bursty, and Constant Bit Rate (CBR) traffic.
- **Scenario Configuration:** Define AP/STA numbers, grid dimensions, and even incorporate walls in the scenario.
- **System Parameters:** Configure TXOP durations, noise figures, bandwidth, and more.
- **MAC Protocols:** Compare the performance of traditional EDCA with different CSR (Centralized Scheduling Resource allocation) algorithms including:
  - CSR with Minimum Number of Packets (MNP)
  - CSR with Opportunistic Scheduling (OP)
  - CSR with Time Aware Throughput (TAT)

Performance metrics are evaluated over multiple iterations (each representing a unique channel realization), and various plots are generated to illustrate performance aspects such as throughput, delay distributions, and collision probabilities.

---

## Features

- **Flexible Traffic Generation:** Supports different traffic types (`'Poisson'`, `'Bursty'`, `'CBR'`) and load configurations.
- **Detailed Scenario Modeling:** Place APs and STAs in grid-based scenarios with custom wall definitions.
- **Overhead & Power Calculations:** Uses dedicated functions (`TXpowerCalc` and `OverheadsCalc`) to compute TX power, subcarrier numbers, and overheads.
- **Multiple Simulation Systems:** Simulate EDCA and CSR systems (with different schedulers) in parallel.
- **Comprehensive Plotting:** Generate percentile, CDF, and other performance plots using the `MyPlots` class.

---

## Repository Structure

Below is an example of the repository structure. Adjust the structure if your file organization differs.

